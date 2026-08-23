// open-room-planner — shared helpers for every part.
//
// Parts are modelled in REAL-WORLD dimensions (centimetres) and shrunk to the
// plan scale on the way out, so a .scad reads like a furniture spec sheet:
// a 160x200 bed is written as 160 x 200, not 32 x 40.
//
// Scale matches the paper plans (base.svg): 1:50, i.e. 2 cm on the plan = 1 m.

// 1:Scale — override from the Makefile / command line with -D Scale=25.
Scale = 50;

// $fn for the final render. The CLI is never in $preview, so this is the real one.
Resolution = 64;

// Engraved-label defaults (see label()).
Label_size  = 3;    // printed cap height, mm
Label_depth = 0.4;  // how deep the text is cut into the top face, mm

// Engraved-symbol defaults, for pieces that carry a pictogram instead of text
// (see hanger()). Printed mm — drawing detail, so they do not scale.
Symbol_size   = 4;    // nominal symbol height, shrunk to what the piece allows
Symbol_stroke = 0.4;  // line width of a symbol — keep it >= one nozzle
Symbol_margin = 0.8;  // min wall between a symbol and the edge of a piece
Hanger_ratio  = 2.2;  // width : height of the hanger symbol

// Corner rounding of a footprint, in printed mm (not scaled — it is a print
// detail, not a real-world dimension).
Corner_radius = 0.6;

// Magnet pockets, in printed mm — hardware, not a real-world dimension, so they
// stay the same at any scale. The pocket opens at the BOTTOM face so the magnet
// touches the steel directly (no plastic in the gap: a 0.4 mm layer over a small
// disc costs half its pull) and needs no bridging — drop it in after printing.
// 5x1 discs pull ~130 g each and only eat 1 mm of a 6 mm piece; 3x2 fits the
// small tokens. Keep every magnet the same way up so neighbouring pieces repel
// gently instead of snapping together and skewing the layout.
Magnet_d     = 5;    // magnet diameter
Magnet_h     = 1;    // magnet height = pocket depth (magnet sits flush)
Magnet_fit   = 0.2;  // added to the diameter for a press fit
Magnet_inset = 1.2;  // min wall between a pocket and the outside of a piece
Magnet_gap   = 1.5;  // min wall between two pockets
Magnet_spread = 0.8; // how much of the usable span multiple pockets use, 0..1

$fn = Resolution;

// ---- unit conversion --------------------------------------------------------
// real-world centimetres -> printed millimetres
function cm(v) = v * 10 / Scale;
// real-world millimetres -> printed millimetres
function mm(v) = v / Scale;

// ---- building blocks --------------------------------------------------------

// The base shape of every piece: a <w_cm> x <d_cm> block, <h> mm tall (printed
// height, chosen for handling — not the scaled real height), centred on the
// origin with rounded corners.
module footprint(w_cm, d_cm, h, r = Corner_radius) {
    linear_extrude(height = h)
        offset(r = r) offset(delta = -r)
            square([cm(w_cm), cm(d_cm)], center = true);
}

// A 2D footprint outline only — for laser-cut / plan output.
module footprint_2d(w_cm, d_cm, r = Corner_radius) {
    offset(r = r) offset(delta = -r)
        square([cm(w_cm), cm(d_cm)], center = true);
}

// Text cut into the top face of a piece. Subtract it from the solid:
//   difference() { footprint(160, 200, 6); label("160x200", 6); }
module label(txt, top_z, size = Label_size, depth = Label_depth) {
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            text(txt, size = size, halign = "center", valign = "center",
                 font = "DejaVu Sans");
}

// ---- symbols ----------------------------------------------------------------
// The tallest hanger that fits a <w> x <h> printed-mm patch of top face, so a
// small piece gets the same symbol as a big one, just smaller.
function hanger_size(w, h, size = Symbol_size, ratio = Hanger_ratio) =
    min(size, h, w / ratio);

// A clothes hanger cut into the top face of a piece — a triangular body under a
// hooked loop, drawn in <stroke>-wide lines, <size> mm tall and <ratio> x that
// wide, centred on the origin. Subtract it from the solid like label():
//   difference() { footprint(100, 58, 6); hanger(4, 6); }
module hanger(size, top_z, stroke = Symbol_stroke, depth = Label_depth,
              ratio = Hanger_ratio) {
    w      = size * ratio;
    hook_d = size * 0.45;      // the loop takes the top of the symbol
    hook_r = hook_d / 2;
    body_h = size - hook_d;    // ... the shoulders the rest
    body   = [[-w / 2, 0], [w / 2, 0], [0, body_h]];
    // the loop sits <stroke> into the apex so body and hook come out as one cut
    cy     = body_h + hook_r - stroke;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            translate([0, -size / 2])
                union() {
                    difference() {          // shoulders + bottom bar
                        polygon(body);
                        offset(delta = -stroke) polygon(body);
                    }
                    difference() {          // hook, open at the lower right
                        translate([0, cy]) difference() {
                            circle(d = hook_d);
                            circle(d = hook_d - 2 * stroke);
                        }
                        translate([0, cy - hook_r]) square([hook_r, hook_r]);
                    }
                }
}

// ---- magnets ----------------------------------------------------------------
// How many magnet pockets of <n> requested actually fit in a <w_cm> x <d_cm>
// footprint: they sit in a row on the longer axis, keep <inset> of wall to the
// outside and <gap> of wall to each other. 0 = the piece is too small for one.
function magnet_count(w_cm, d_cm, n = 1, d = Magnet_d, fit = Magnet_fit,
                      inset = Magnet_inset, gap = Magnet_gap) =
    let (od    = d + fit,
         short = min(cm(w_cm), cm(d_cm)),
         span  = max(cm(w_cm), cm(d_cm)) - 2 * inset - od)
    (short < od + 2 * inset || span < 0) ? 0
                                        : min(n, floor(span / (od + gap)) + 1);

// A single pocket in the bottom face, at <x>,<y> printed mm from the centre of
// the piece (unlike groove(), which takes real-world cm — a magnet is hardware).
module magnet_pocket(x = 0, y = 0, d = Magnet_d, h = Magnet_h, fit = Magnet_fit) {
    translate([x, y, -0.01])
        cylinder(h = h + 0.01, d = d + fit);
}

// <n> pockets spread along the longer axis of a <w_cm> x <d_cm> footprint,
// centred on the piece. Subtract it from the solid:
//   difference() { footprint(160, 200, 6); magnets(160, 200, 2); }
// The count is clamped to what fits; a piece too small for even one is left
// solid with a warning, so the same call is safe at any scale.
module magnets(w_cm, d_cm, n = 1, d = Magnet_d, h = Magnet_h, fit = Magnet_fit,
               inset = Magnet_inset, gap = Magnet_gap, spread = Magnet_spread) {
    count = magnet_count(w_cm, d_cm, n, d, fit, inset, gap);
    if (count < n)
        echo(str("WARNING: ", w_cm, "x", d_cm, " cm at 1:", Scale, " fits ",
                 count, " of ", n, " ", d, "x", h, " mm magnets"));
    if (count > 0) {
        along_x = cm(w_cm) > cm(d_cm);
        // centre-to-centre room, shrunk so the row does not hug the ends
        span = (max(cm(w_cm), cm(d_cm)) - 2 * inset - (d + fit)) * spread;
        step = count > 1 ? span / (count - 1) : 0;
        for (i = [0 : count - 1]) {
            p = count > 1 ? -span / 2 + i * step : 0;
            magnet_pocket(along_x ? p : 0, along_x ? 0 : p, d, h, fit);
        }
    }
}

// A shallow groove on the top face, used to hint at fronts, doors and drawers.
// Coordinates are real-world cm, measured from the centre of the piece.
module groove(x_cm, y_cm, w_cm, d_cm, top_z, depth = Label_depth) {
    translate([cm(x_cm), cm(y_cm), top_z - depth])
        linear_extrude(height = depth + 0.01)
            square([cm(w_cm), cm(d_cm)], center = true);
}
