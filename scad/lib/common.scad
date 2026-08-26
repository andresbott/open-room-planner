// open-room-planner — shared helpers for every part.
//
// Parts are modelled in REAL-WORLD dimensions (centimetres) and shrunk to the
// plan scale on the way out, so a .scad reads like a furniture spec sheet:
// a 160x200 bed is written as 160 x 200, not 32 x 40.
//
// Plan scale 1:40 — 2.5 cm on the plan = 1 m (an A5 sheet is about a 50 m² room).

// 1:Scale — override from the Makefile / command line with -D Scale=50.
Scale = 40;

// $fn for the final render. The CLI is never in $preview, so this is the real one.
Resolution = 64;

// ---- heights ----------------------------------------------------------------
// A height is a real-world dimension like a footprint: a part is written in
// centimetres and shrunk by the same plan scale, so the pieces stand to each
// other as the furniture does — a 236 cm PAX frame is 59 mm, a 90 cm worktop
// 22.5 mm, a 50 cm bed 12.5 mm. Take a height through printed_h() rather than cm():
// on top of the scale it applies Height_scale and keeps a floor of Height_min.
//   Height_scale  squashes every piece at once, for a shorter set that still
//                 reads in the right order (0.75 = three quarters as tall).
//   Height_min    the least a piece may print, whatever its real height says: a
//                 magnet pocket (magnet_pocket_h()) plus material over it. Only
//                 the floor-level pieces — a shower tray — reach it.
// The Makefile mirrors both as HEIGHT_SCALE / HEIGHT_MIN.
Height_scale = 1;
Height_min   = 2.4;  // mm

// Engraved-label defaults (see label()).
Label_size  = 3;    // printed cap height, mm
Label_depth = 0.4;  // how deep the text is cut into the top face, mm

// Engraved-symbol defaults, for pieces that carry a pictogram instead of text
// (see hanger()). Printed mm — drawing detail, so they do not scale.
Symbol_size   = 5;    // nominal symbol height, shrunk to what the piece allows
Symbol_stroke = 0.4;  // line width of a symbol — keep it >= one nozzle
Symbol_margin = 0.8;  // min wall between a symbol and the edge of a piece
Symbol_min    = 1.6;  // a symbol smaller than this comes out a blob — leave it off
Hanger_ratio  = 2.2;  // width : height of the hanger symbol
Drawers_ratio = 1.2;  // width : height of the drawers symbol
Drawers_rows  = 3;    // fronts drawn in the drawers symbol
Setting_ratio = 1.6;  // width : height of the place-setting symbol
Rays_ratio    = 1;    // width : height of the rays symbol — a lit shade is round
Rays_count    = 8;    // how many rays come off it

// Raised soft pads — pillows, seat cushions, a sofa back (see cushion()). How far
// a pad stands proud is a real-world dimension in cm, like any other height; the
// taper and the corner rounding are print details and stay in printed mm.
Cushion_rise   = 8;    // cm a pad stands above the face it sits on
Cushion_taper  = 0.5;  // mm the top is pulled in, so the sides slope
Cushion_radius = 1.2;  // mm corner rounding of a pad — softer than a carcass

// Corner rounding of a footprint, in printed mm (not scaled — it is a print
// detail, not a real-world dimension).
Corner_radius = 0.6;

// Magnet pockets, in printed mm — hardware, not a real-world dimension, so they
// stay the same at any scale. The pocket opens at the BOTTOM face so the magnet
// touches the steel directly (no plastic in the gap: a 0.4 mm layer over a small
// disc costs half its pull) and needs no bridging — drop it in after printing.
// Two discs cover the whole catalogue, both 1 mm high so every pocket is the same
// depth: 4x1 (~90 g of pull) on anything wide enough for it, 2x1 (~20 g) on the
// pieces that are not — at 1:40, the wall segments. magnets() picks between them per
// piece (see magnet_d_for), so a part just asks for pockets and gets the biggest disc
// that fits. A piece too thin for even the 2x1 — the 11.5 cm partition ribbon, at this
// scale — is not left without one: it gets the material it needs instead, a low pad
// under each pocket (see magnet_pads below). Keep every magnet the same way up so
// neighbouring pieces repel gently instead of snapping together and skewing the layout.
Magnet_d       = 4;    // magnet diameter — the standard disc
Magnet_d_small = 2;    // ... and the one for pieces too narrow for it
Magnet_h       = 1;    // magnet height (both sizes)
// Printer allowance. An FDM hole prints undersize, so the pocket is cut wider and
// deeper than the disc: it drops in by hand (a spot of CA glue holds it) and can
// never stand proud of the bottom face and rock the piece. The 0.2 mm of extra
// depth leaves an air gap, which costs far less pull than plastic would.
Magnet_fit   = 0.3;  // added to the pocket diameter
Magnet_fit_h = 0.2;  // ... and to its depth
Magnet_inset = 1;    // min wall between a pocket and the outside of a piece
Magnet_gap   = 1.5;  // min wall between two pockets
Magnet_spread = 0.8; // how much of the usable span multiple pockets use, 0..1
// A piece thinner across than a pocket plus its wall (magnet_min_span — 4.3 mm for the
// small disc) has nowhere to put one: at 1:40 that is the 11.5 cm partition, a 2.875 mm
// ribbon. Rather than print it solid, magnet_pads() gives it the material: a low round
// pad under each pocket, standing a little proud of BOTH faces (symmetric, so a segment
// has no right way round) and only near the floor, so the piece still reads at its real
// thickness from above and a partition is not mistaken for a bearing wall. Print
// hardware like the pocket it carries, so printed mm — it does not scale.
Magnet_pad_cover   = 0.8;  // material kept over a pocket inside its pad
Magnet_pad_chamfer = 0.6;  // 45 deg blend from the top of the pad back to the piece

$fn = Resolution;

// ---- unit conversion --------------------------------------------------------
// real-world centimetres -> printed millimetres
function cm(v) = v * 10 / Scale;
// real-world millimetres -> printed millimetres
function mm(v) = v / Scale;
// the way back for a plan dimension: a printed mm -> the real cm it stands for
// (rise_cm() below is the same for a height). For handing something a part worked
// out in printed mm — the base a slope leaves under a top — to something that
// takes real cm, like magnets().
function plan_cm(v) = v * Scale / 10;
// real-world centimetres -> printed millimetres, for anything that stands ON a
// piece: a cushion, a sofa back, a vanity mirror. The plan scale and Height_scale,
// so a rise keeps its share of the piece however the set is squashed.
function rise(v) = cm(v) * Height_scale;
// ... and for the HEIGHT of a whole piece: the same, with a floor of Height_min so
// the lowest pieces still print and still take a magnet pocket (see above).
function printed_h(v) = max(Height_min, rise(v));
// the way back: a printed height in mm -> the real cm it stands for. For reporting a
// clamped height in the units a part is written in, and for handing one to something
// that takes real cm (cushion(), groove()).
function rise_cm(v) = v * Scale / 10 / Height_scale;

// ---- building blocks --------------------------------------------------------

// The base shape of every piece: a <w_cm> x <d_cm> block, <h> mm tall, centred on
// the origin with rounded corners. <h> is a printed height in mm — pass a real
// height through printed_h() first, as every part does.
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

// The same base shape for a round piece: a <d_cm> disc, <h> mm tall, centred on
// the origin. No corner rounding — a circle has no corners.
module footprint_round(d_cm, h) {
    linear_extrude(height = h) footprint_round_2d(d_cm);
}

// A round 2D footprint outline only, the circular footprint_2d().
module footprint_round_2d(d_cm) {
    circle(d = cm(d_cm));
}

// The same base shape for an oval piece: a <w_cm> x <d_cm> ellipse, <h> mm tall,
// centred on the origin. Like footprint_round(), there are no corners to round.
module footprint_oval(w_cm, d_cm, h) {
    linear_extrude(height = h) footprint_oval_2d(w_cm, d_cm);
}

// An oval 2D footprint outline only, the elliptical footprint_2d(): a unit circle
// stretched to the two axes, so the rim keeps its full $fn of segments however
// flat the ellipse gets.
module footprint_oval_2d(w_cm, d_cm) {
    scale([cm(w_cm) / 2, cm(d_cm) / 2]) circle(r = 1);
}

// A soft raised pad on top of a piece — a pillow, a seat cushion, a sofa back:
// <w_cm> x <d_cm> centred on the origin, rising <h_cm> real-world cm above a face
// at <base_z> printed mm. Dimensions are real (cm), the position it is stood on is
// printed (mm) — as everywhere else. The top is pulled in by <taper> so the sides
// slope instead of stepping: nothing to overhang on the printer, and it reads as
// soft from above. Add it to the solid:
//   union() { footprint(160, 200, h); translate([0, cm(70), 0]) cushion(74, 50, h, 10); }
module cushion(w_cm, d_cm, base_z, h_cm = Cushion_rise, taper = Cushion_taper,
               r = Cushion_radius) {
    h = rise(h_cm);
    hull() {
        translate([0, 0, base_z - 0.01])
            linear_extrude(height = 0.01) footprint_2d(w_cm, d_cm, r);
        translate([0, 0, base_z + h])
            linear_extrude(height = 0.01)
                offset(delta = -taper) footprint_2d(w_cm, d_cm, r);
    }
}

// Text cut into the top face of a piece. Subtract it from the solid:
//   difference() { footprint(160, 200, 6); label("160x200", 6); }
module label(txt, top_z, size = Label_size, depth = Label_depth) {
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            text(txt, size = size, halign = "center", valign = "center",
                 font = "DejaVu Sans");
}

// The same text cut into the FRONT (-Y) face of a piece <d_cm> deep instead — for a
// piece read from the side rather than from above: a wall ribbon, which is longer and
// taller on its face than it is wide on its top. <x>,<z> is where the text is centred
// on that face, printed mm from the centre of the piece and up from the floor.
// Subtract it from the solid:
//   difference() { footprint(200, 11.5, 12.5, r = 0); label_front("200", 11.5, z = 6); }
module label_front(txt, d_cm, x = 0, z = 0, size = Label_size, depth = Label_depth) {
    translate([x, -cm(d_cm) / 2 + depth, z])
        rotate([90, 0, 0])
            linear_extrude(height = depth + 0.01)
                text(txt, size = size, halign = "center", valign = "center",
                     font = "DejaVu Sans");
}

// ---- fitting a label --------------------------------------------------------
// A label's size is its cap height, and a digit is about 0.7 of that wide, so a
// <txt>-long number comes out 0.7 * size * len(txt) across. These size one to what it
// has to fit in — as symbol_size() does for the symbols — and a part drops the label
// when the answer falls under Symbol_min, rather than print a blob.
// label_size():      a <w> x <h> patch of face, printed mm.
// label_size_free(): a label out in the open with <room> mm clear from its centre in
//                    every direction (a door's swing plate) — half its diagonal fits.
function label_size(w, h, txt, size = Label_size) =
    min(size, h, w / (0.7 * len(txt)));
function label_size_free(room, txt, size = Label_size) =
    min(size, room / label_half_diag(txt));
function label_half_diag(txt) = sqrt(pow(0.35 * len(txt), 2) + 0.25);

// ---- symbols ----------------------------------------------------------------
// The tallest symbol of a given width : height <ratio> that fits a <w> x <h>
// printed-mm patch of top face, so a small piece gets the same symbol as a big
// one, just smaller.
function symbol_size(w, h, ratio, size = Symbol_size) = min(size, h, w / ratio);
function hanger_size(w, h, size = Symbol_size, ratio = Hanger_ratio) =
    symbol_size(w, h, ratio, size);
function drawers_size(w, h, size = Symbol_size, ratio = Drawers_ratio) =
    symbol_size(w, h, ratio, size);
function setting_size(w, h, size = Symbol_size, ratio = Setting_ratio) =
    symbol_size(w, h, ratio, size);
function rays_size(w, h, size = Symbol_size, ratio = Rays_ratio) =
    symbol_size(w, h, ratio, size);

// A <w>-wide 2D stroke from <p1> to <p2>, with round ends — the pen symbols are
// drawn with. Round ends also round every join, so no corner comes out sharp.
module stroke_line(p1, p2, w) {
    hull() { translate(p1) circle(d = w); translate(p2) circle(d = w); }
}

// The same pen swept along an arc of radius <r>, from <a1> to <a2> degrees around
// the origin. Chained hulls, so the outer edge stays smooth.
module stroke_arc(r, a1, a2, w, step = 6) {
    n = max(1, ceil(abs(a2 - a1) / step));
    for (i = [0 : n - 1])
        hull() {
            translate(r * [cos(a1 + (a2 - a1) * i / n),
                           sin(a1 + (a2 - a1) * i / n)]) circle(d = w);
            translate(r * [cos(a1 + (a2 - a1) * (i + 1) / n),
                           sin(a1 + (a2 - a1) * (i + 1) / n)]) circle(d = w);
        }
}

// A clothes hanger cut into the top face of a piece — shoulders and a bottom bar
// under a hooked loop, drawn in <stroke>-wide round-ended lines, <size> mm tall
// and <ratio> x that wide, centred on the origin. Subtract it like label():
//   difference() { footprint(100, 58, 6); hanger(4, 6); }
module hanger(size, top_z, stroke = Symbol_stroke, depth = Label_depth,
              ratio = Hanger_ratio) {
    // the pen is centred on the path, so the paths span one stroke less than the
    // symbol they have to fit in
    pw     = size * ratio - stroke;
    ph     = size - stroke;
    hook_d = ph * 0.45;        // the loop takes the top of the symbol
    body_h = ph - hook_d;      // ... the shoulders and the bar the rest
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            translate([0, -ph / 2])
                union() {
                    stroke_line([-pw / 2, 0], [pw / 2, 0], stroke);  // bottom bar
                    stroke_line([-pw / 2, 0], [0, body_h], stroke);  // shoulders
                    stroke_line([ pw / 2, 0], [0, body_h], stroke);
                    // hook: starts at the shoulder apex, loops round and comes
                    // back down on the right, open at the lower right
                    translate([0, body_h + hook_d / 2])
                        stroke_arc(hook_d / 2, -90, -360, stroke);
                }
}

// A chest of drawers cut into the top face — <rows> fronts stacked inside an
// outline, drawn with the same pen as hanger(), <size> mm tall and <ratio> x that
// wide, centred on the origin. Subtract it like label():
//   difference() { footprint(108, 50, 6); drawers(4, 6); }
module drawers(size, top_z, stroke = Symbol_stroke, depth = Label_depth,
               ratio = Drawers_ratio, rows = Drawers_rows) {
    pw = size * ratio - stroke;   // as in hanger(): the pen is centred on the path
    ph = size - stroke;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                for (s = [-1, 1]) {                       // the carcass
                    stroke_line([-pw / 2, s * ph / 2], [pw / 2, s * ph / 2], stroke);
                    stroke_line([s * pw / 2, -ph / 2], [s * pw / 2, ph / 2], stroke);
                }
                for (i = [1 : rows - 1]) {                // the fronts
                    y = -ph / 2 + i * ph / rows;
                    stroke_line([-pw / 2, y], [pw / 2, y], stroke);
                }
            }
}

// A place setting cut into the top face — a plate between a knife and a fork,
// drawn with the same pen as hanger(), <size> mm tall and <ratio> x that wide,
// centred on the origin. The cutlery is two plain strokes: a tine or a blade
// would be finer than a nozzle at this size, and plate-plus-two-lines reads as a
// table anyway. Subtract it like label():
//   difference() { footprint(160, 90, 6); place_setting(5, 6); }
module place_setting(size, top_z, stroke = Symbol_stroke, depth = Label_depth,
                     ratio = Setting_ratio) {
    pw = size * ratio - stroke;   // as in hanger(): the pen is centred on the path
    ph = size - stroke;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                stroke_arc(ph / 2, 0, 360, stroke);            // the plate
                for (s = [-1, 1])                              // knife and fork
                    stroke_line([s * pw / 2, -ph / 2], [s * pw / 2, ph / 2], stroke);
            }
}

// A lit shade cut into the top face — a ring with rays coming off it, <n> of them,
// drawn with the same pen as hanger(), <size> mm across and centred on the origin.
// This is the smallest symbol of the set (the top of a floor-lamp shade is 11 mm
// across at 1:40), so it is a ring and not a bulb outline: anything with more detail
// than this closes up at one nozzle width. Subtract it like label():
//   difference() { footprint(45, 45, 9); rays(5, 9); }
module rays(size, top_z, stroke = Symbol_stroke, depth = Label_depth,
            n = Rays_count) {
    r     = (size - stroke) / 2;   // as in hanger(): the pen is centred on the path
    hub   = r * 0.45;              // the shade, seen from above
    start = r * 0.7;               // where a ray leaves it; every ray ends at the rim
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            union() {
                stroke_arc(hub, 0, 360, stroke);
                for (a = [0 : 360 / n : 359])
                    stroke_line(start * [cos(a), sin(a)], r * [cos(a), sin(a)],
                                stroke);
            }
}

// ---- magnets ----------------------------------------------------------------
// The pocket a <d> x <h> disc needs, printed mm — the disc plus the printer
// allowance. Use magnet_pocket_h() wherever a part has to keep material above a
// pocket (a basin floor, a lamp foot), never Magnet_h on its own.
function magnet_pocket_d(d = Magnet_d, fit = Magnet_fit) = d + fit;
function magnet_pocket_h(h = Magnet_h, fit_h = Magnet_fit_h) = h + fit_h;

// The narrowest a piece may be and still take a <d> disc: the pocket plus a wall
// of <inset> on each side. Parts that taper use it to keep their base wide enough.
function magnet_min_span(d = Magnet_d, fit = Magnet_fit, inset = Magnet_inset) =
    magnet_pocket_d(d, fit) + 2 * inset;

// The pad that gives a piece too thin for that span the span anyway (see magnet_pads):
// exactly as wide as the pocket needs, and tall enough to hold the pocket plus <cover>
// of material over its ceiling.
function magnet_pad_d(d = Magnet_d, fit = Magnet_fit, inset = Magnet_inset) =
    magnet_min_span(d, fit, inset);
function magnet_pad_h(h = Magnet_h, fit_h = Magnet_fit_h, cover = Magnet_pad_cover) =
    magnet_pocket_h(h, fit_h) + cover;

// The disc a <w_cm> x <d_cm> footprint actually gets: the one asked for where the
// piece is wide enough, else the small one. This is what makes a wardrobe take a
// 4x1 and a partition wall a 2x1 from the same magnets() call.
function magnet_d_for(w_cm, d_cm, d = Magnet_d, small = Magnet_d_small,
                      fit = Magnet_fit, inset = Magnet_inset) =
    min(cm(w_cm), cm(d_cm)) >= magnet_min_span(d, fit, inset) ? d : small;

// True when <w_cm> x <d_cm> is too thin across its SHORT axis to hold the pocket it
// would get, so the only way it can carry one is on a pad (see magnet_pads).
function magnet_pad_needed(w_cm, d_cm, d = Magnet_d, fit = Magnet_fit,
                           inset = Magnet_inset) =
    let (dia = magnet_d_for(w_cm, d_cm, d, Magnet_d_small, fit, inset))
    min(cm(w_cm), cm(d_cm)) < magnet_min_span(dia, fit, inset);

// How many magnet pockets of <n> requested actually fit in a <w_cm> x <d_cm>
// footprint: they sit in a row on the longer axis, keep <inset> of wall to the
// outside and <gap> of wall to each other. The disc is sized by magnet_d_for(),
// so a piece too narrow for <d> is measured for the small one before it is given
// up on. 0 = too small for even that.
// <pad> drops the short-axis test: a piece that is padded (magnet_pads) is as wide as
// a pocket needs where it counts, so only the row along the longer axis still limits
// it. The pad is a disc of exactly magnet_min_span across, and the row keeps <inset>
// plus half a pocket clear of both ends — so a pad can never reach past the piece.
function magnet_count(w_cm, d_cm, n = 1, d = Magnet_d, fit = Magnet_fit,
                      inset = Magnet_inset, gap = Magnet_gap, pad = false) =
    let (od    = magnet_pocket_d(magnet_d_for(w_cm, d_cm, d, Magnet_d_small,
                                              fit, inset), fit),
         short = min(cm(w_cm), cm(d_cm)),
         span  = max(cm(w_cm), cm(d_cm)) - 2 * inset - od)
    ((!pad && short < od + 2 * inset) || span < 0)
        ? 0 : min(n, floor(span / (od + gap)) + 1);

// Where the <n> pockets of a <w_cm> x <d_cm> footprint go: a row along its longer
// axis, centred on the piece, as [x, y] printed mm from its centre — as many as
// magnet_count() allows, so an empty list on a piece that gets none. magnets() cuts
// this row and magnet_pads() thickens it, and both read it from here, so the two can
// never drift apart.
function magnet_row(w_cm, d_cm, n = 1, d = Magnet_d, fit = Magnet_fit,
                    inset = Magnet_inset, gap = Magnet_gap,
                    spread = Magnet_spread, pad = false) =
    let (od      = magnet_pocket_d(magnet_d_for(w_cm, d_cm, d, Magnet_d_small,
                                                fit, inset), fit),
         count   = magnet_count(w_cm, d_cm, n, d, fit, inset, gap, pad),
         along_x = cm(w_cm) > cm(d_cm),
         // centre-to-centre room, shrunk so the row does not hug the ends
         span    = (max(cm(w_cm), cm(d_cm)) - 2 * inset - od) * spread,
         step    = count > 1 ? span / (count - 1) : 0)
    [ for (i = [0 : count - 1])
        let (p = count > 1 ? -span / 2 + i * step : 0)
        along_x ? [p, 0] : [0, p] ];

// A single pocket in the bottom face, at <x>,<y> printed mm from the centre of
// the piece (unlike groove(), which takes real-world cm — a magnet is hardware).
module magnet_pocket(x = 0, y = 0, d = Magnet_d, h = Magnet_h, fit = Magnet_fit,
                     fit_h = Magnet_fit_h) {
    translate([x, y, -0.01])
        cylinder(h = magnet_pocket_h(h, fit_h) + 0.01, d = magnet_pocket_d(d, fit));
}

// <n> pockets spread along the longer axis of a <w_cm> x <d_cm> footprint,
// centred on the piece. Subtract it from the solid:
//   difference() { footprint(160, 200, 6); magnets(160, 200, 2); }
// The disc is the biggest of the two that fits (magnet_d_for) and the count is
// clamped to what fits, so the same call is safe on any piece at any scale. A piece
// that drops to the small disc says so, because it changes which magnet you drop in.
// <pad> is for a piece too thin to hold a pocket on its own — a wall ribbon: it cuts
// the row anyway, and the part unions magnet_pads() with the same arguments into its
// solid to carry it. Without it such a piece is left solid, with a warning.
module magnets(w_cm, d_cm, n = 1, d = Magnet_d, h = Magnet_h, fit = Magnet_fit,
               inset = Magnet_inset, gap = Magnet_gap, spread = Magnet_spread,
               pad = false) {
    dia   = magnet_d_for(w_cm, d_cm, d, Magnet_d_small, fit, inset);
    count = magnet_count(w_cm, d_cm, n, d, fit, inset, gap, pad);
    padded = pad && magnet_pad_needed(w_cm, d_cm, d, fit, inset);
    if (count < n)
        echo(str("WARNING: ", w_cm, "x", d_cm, " cm at 1:", Scale, " fits ",
                 count, " of ", n, " ", dia, "x", h, " mm magnets"));
    else if (padded)
        echo(str("NOTE: ", w_cm, "x", d_cm, " cm at 1:", Scale,
                 " is too thin to hold a pocket — cut for ", count, " ", dia, "x", h,
                 " mm on a ", magnet_pad_d(dia, fit, inset), " mm pad"));
    else if (dia != d)
        echo(str("NOTE: ", w_cm, "x", d_cm, " cm at 1:", Scale, " is too narrow for a ",
                 d, " mm disc — cut for ", count, " ", dia, "x", h, " mm"));
    for (p = magnet_row(w_cm, d_cm, n, d, fit, inset, gap, spread, pad))
        magnet_pocket(p[0], p[1], dia, h, fit);
}

// The material a piece too thin for a pocket needs, under every pocket magnets(pad =
// true) cuts in it: as wide as magnet_min_span(), so the pocket keeps its full wall
// all round, and only as tall as the pocket plus <cover> — with a 45 deg chamfer back
// to the piece above that, so nothing steps or overhangs. Add it to the solid, and
// give it the same arguments as the magnets() call it goes with:
//   difference() {
//       union() { footprint(200, 11.5, 7, r = 0); magnet_pads(200, 11.5, 2); }
//       magnets(200, 11.5, 2, pad = true);
//   }
// A piece that is wide enough already gets nothing, so the pair is safe on any piece
// at any scale.
module magnet_pads(w_cm, d_cm, n = 1, d = Magnet_d, h = Magnet_h, fit = Magnet_fit,
                   inset = Magnet_inset, gap = Magnet_gap, spread = Magnet_spread,
                   fit_h = Magnet_fit_h, cover = Magnet_pad_cover,
                   chamfer = Magnet_pad_chamfer) {
    if (magnet_pad_needed(w_cm, d_cm, d, fit, inset)) {
        dia = magnet_d_for(w_cm, d_cm, d, Magnet_d_small, fit, inset);
        for (p = magnet_row(w_cm, d_cm, n, d, fit, inset, gap, spread, true))
            magnet_pad(p[0], p[1], dia, h, fit, inset, fit_h, cover, chamfer);
    }
}

// One pad, standing on the bottom face at <x>,<y> printed mm from the centre of the
// piece — the same coordinates magnet_pocket() takes.
module magnet_pad(x = 0, y = 0, d = Magnet_d, h = Magnet_h, fit = Magnet_fit,
                  inset = Magnet_inset, fit_h = Magnet_fit_h,
                  cover = Magnet_pad_cover, chamfer = Magnet_pad_chamfer) {
    pd = magnet_pad_d(d, fit, inset);
    ph = magnet_pad_h(h, fit_h, cover);
    translate([x, y, 0]) {
        cylinder(h = ph, d = pd);
        translate([0, 0, ph])
            cylinder(h = chamfer, d1 = pd, d2 = max(0.01, pd - 2 * chamfer));
    }
}

// A shallow groove on the top face, used to hint at fronts, doors and drawers.
// Coordinates are real-world cm, measured from the centre of the piece.
module groove(x_cm, y_cm, w_cm, d_cm, top_z, depth = Label_depth) {
    translate([cm(x_cm), cm(y_cm), top_z - depth])
        linear_extrude(height = depth + 0.01)
            square([cm(w_cm), cm(d_cm)], center = true);
}

// ---- appliance fronts -------------------------------------------------------
// A front-loader (a washer, a dryer) reads from a low angle by what is on its FRONT
// (-Y) face, not its top: a round porthole door under a control fascia. These cut
// into the front face of a footprint() box <depth_cm> deep. A height <z> is a printed
// mm up that face — 0 at the floor, the piece's printed height at the top — so a
// stacked pair is just two bands. Subtract them from the solid.

// A round porthole door recessed into the front (-Y) face: two concentric discs —
// the door surround and, sunk a touch deeper, the glass — centred at height <z> up
// the face and <d> printed mm across. A shallow recess on a vertical wall, so its
// short ceiling prints as a bridge without support.
module porthole(d, z, depth_cm, cut = 0.5, glass_frac = 0.68, glass_cut = 0.4) {
    translate([0, -cm(depth_cm) / 2 - 0.1, z])
        rotate([-90, 0, 0]) {
            cylinder(h = cut + 0.1, d = d);                            // the door
            cylinder(h = cut + glass_cut + 0.1, d = d * glass_frac);   // the glass
        }
}

// A rectangular recess in the front (-Y) face — a control fascia, a detergent
// drawer, a seam between stacked cases — <w> x <h> printed mm, centred at <x>,<z>
// printed mm on the face of a piece <depth_cm> deep.
module front_recess(x, z, w, h, depth_cm, cut = Label_depth) {
    translate([x, -cm(depth_cm) / 2 - 0.1 + (cut + 0.1) / 2, z])
        cube([w, cut + 0.1, h], center = true);
}

// One front-loader's face, cut into the front (-Y) face of a footprint() box <w_cm>
// wide and <depth_cm> deep: a slim control fascia near the top of the unit's band, a
// porthole door filling the space below it, and — with <drawer> — a detergent drawer
// tucked under the fascia on the left (the washer has one, the dryer does not, which
// is what tells the two 60x60 boxes apart). The unit spans printed-mm heights
// <z0>..<z1> up the face, so a stacked washer-dryer is two calls at two bands. The cm
// proportions below are for an 85 cm case; they scale with the band. Subtract it.
module appliance_front(w_cm, depth_cm, z0, z1, drawer = false,
                       fascia_drop = 5, fascia_h = 3, side = 6, gap = 2,
                       door_frac = 0.6, drawer_w = 18, drawer_h = 2.5) {
    face_w   = cm(w_cm);
    fascia_z = z1 - rise(fascia_drop);        // fascia centre, printed mm
    f_h      = rise(fascia_h);
    fascia_w = cm(w_cm - 2 * side);
    front_recess(0, fascia_z, fascia_w, f_h, depth_cm);          // the control fascia
    if (drawer) {                                                // the detergent drawer
        dd_w = cm(drawer_w);
        dd_h = rise(drawer_h);
        front_recess(-(fascia_w - dd_w) / 2,
                     fascia_z - f_h / 2 - rise(1) - dd_h / 2, dd_w, dd_h, depth_cm);
    }
    door_top = fascia_z - f_h / 2 - rise(gap);                   // the porthole door,
    door_d   = min(door_frac * face_w, (door_top - z0) - 2 * Symbol_margin); // centred
    porthole(door_d, (z0 + door_top) / 2, depth_cm);            // in the space below
}
