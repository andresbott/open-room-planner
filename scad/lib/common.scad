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
//                 magnet pocket (magnet_pocket_h() — 2.2 mm for the standard disc)
//                 plus 1.2 mm of material over it. Only the floor-level pieces — a
//                 shower tray — reach it. Raise it with the disc if you fit a
//                 deeper magnet than Magnet_h.
// The Makefile mirrors both as HEIGHT_SCALE / HEIGHT_MIN.
Height_scale = 1;
Height_min   = 3.4;  // mm

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

// Sunken hollows — a bath basin, a sink bowl, a hob burner (see hollow()). How wide
// the flat floor of a hollow is, as a fraction of its rim: the walls slope out from it
// on the way up, so nothing overhangs and the light gets in. 1 would give straight
// sides, 0 a crater with a point at the bottom.
Hollow_floor = 0.62;

// Fitted units — a kitchen run, an island, a larder (see base_unit()/unit_fronts()).
// The proportions live here rather than in each part, so every unit in the set shares
// one plinth height and one worktop lip and a run of them lines up. Depths and heights
// are real-world cm, like any other furniture dimension.
Unit_top  = 4;   // cm of a unit's height the worktop slab takes ...
Unit_lip  = 2;   // ... and how far that slab overhangs the carcass at the front
Unit_kick = 6;   // cm the plinth is set back under the carcass — the toe kick ...
Unit_foot = 10;  // ... and how tall the plinth is
// Door and drawer fronts. A front is recessed into the face rather than left standing
// proud of it: what the eye reads is the shadow gap between fronts, and cutting it
// keeps the face flat — nothing to overhang on the printer, nothing to catch in the box.
Front_gap    = 2;    // cm of shadow gap around every front
Front_relief = 0.5;  // mm a front is recessed into the face
// The grip: a slot along the top of a front, standing in for a handle. A real handle is
// a 1 mm bar at 1:40 — a pimple that snaps off and catches on whatever the piece is
// stored with, the same reason washbasin.scad leaves its tap off — so the token gets
// the handleless grip rail instead, which is a cut and not a spike.
Grip_h   = 3;    // cm of the top of a front its grip slot takes ...
Grip_cut = 0.4;  // ... and mm it is cut deeper than the front around it
// A control fascia (see unit_fascia()) — the slim band that gives an integrated machine
// away above the counter line, and what a cooker's knobs sit on.
Fascia_h = 5;    // cm of the top of a face the fascia takes

// Pieces that stand on legs rather than on their whole footprint (see legged_block()):
// a dining chair, a bench, a buffet, a glazed cabinet. Real cm — furniture, not ink.
Leg_w   = 8;   // cm — a corner post, seen on both faces it turns ...
Leg_set = 3;   // ... and how far the rail between two posts is set back behind them
Leg_top = 4;   // cm of the height the top slab takes, standing proud all round

// Open bays cut into a front face (see front_bays()) — a shelf unit, a glazed case, a
// wardrobe frame. Real cm: what the shelves stand for is furniture.
Bay_depth = 7;  // cm a bay is sunk into the face ...
Bay_rib   = 2;  // ... and the shelf left standing at the face between two of them

// A slab on open legs (see slab_on_legs()) — a table, a console. Real cm.
Legs_inset = 2;   // cm the legs are set in from the edge, so the slab stands proud ...
Legs_gap   = 20;  // ... and the clear span that has to be left between two of them

// Corner rounding of a footprint, in printed mm (not scaled — it is a print
// detail, not a real-world dimension).
Corner_radius = 0.6;

// Magnet pockets, in printed mm — hardware, not a real-world dimension, so they
// stay the same at any scale. The pocket opens at the BOTTOM face so the magnet
// touches the steel directly (no plastic in the gap: a 0.4 mm layer over a small
// disc costs half its pull) and needs no bridging — drop it in after printing.
// Two discs cover the whole catalogue: 4x2 (~180 g of pull) on anything wide enough for
// it, 2x1 (~20 g) on the pieces that are not — at 1:40, the wall segments. magnets()
// picks between them per piece (see magnet_d_for), so a part just asks for pockets and
// gets the biggest disc that fits. A piece too thin for even the 2x1 — the 11.5 cm
// partition ribbon, at this scale — is not left without one: it gets the material it
// needs instead, a low pad under each pocket (see magnet_pads below).
// The two are NOT the same height, so a pocket's depth follows its diameter
// (magnet_h_for): 2.2 mm deep under a piece of furniture, 1.2 under a wall. That is why
// Height_min is what it is — the shallowest piece still has to bury a 2 mm disc.
// Keep every magnet the same way up so neighbouring pieces repel gently instead of
// snapping together and skewing the layout.
Magnet_d       = 4;    // magnet diameter — the standard disc
Magnet_d_small = 2;    // ... and the one for pieces too narrow for it
Magnet_h       = 2;    // how tall the standard disc is
Magnet_h_small = 1;    // ... and the small one
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

// A reclined backrest along the back (+Y) edge — the leaning relative of cushion(),
// for the one pad that must not stand straight. Its wall (+Y) side stays flush, so a
// piece still butts a wall, while its seat-facing (-Y) face slopes back on the way up,
// the way you lean into a sofa. It hulls a <d_cm>-deep base to a shallower top set back
// by <recline_cm> real cm: the top's back edge stays over the base's, so every layer
// steps BACK, never out, and it prints upright with nothing to support. <w_cm> wide,
// centred in x on the origin; its back edge sits <rear_cm> real cm from the origin in
// +Y and it rises <h_cm> real cm above <base_z> printed mm. The top keeps at least
// <min_frac> of the base depth, so a deep recline cannot pinch it to nothing — it
// clamps and says so. Add it to the solid like cushion():
//   translate([cm(x), 0, 0]) backrest(50, 22, seat_z, 45, 40, 12);
module backrest(w_cm, d_cm, base_z, rear_cm, h_cm, recline_cm,
                taper = Cushion_taper, r = Cushion_radius, min_frac = 0.4) {
    h     = rise(h_cm);
    top_d = max(d_cm * min_frac, d_cm - recline_cm);
    if (d_cm - recline_cm < d_cm * min_frac)
        echo(str("NOTE: a ", recline_cm, " cm recline over a ", d_cm,
                 " cm backrest would pinch its top away — leaned it to ",
                 d_cm - top_d, " cm instead (give it a deeper back: Back_d)"));
    hull() {
        translate([0, cm(rear_cm - d_cm / 2), base_z - 0.01])
            linear_extrude(height = 0.01) footprint_2d(w_cm, d_cm, r);
        translate([0, cm(rear_cm - top_d / 2), base_z + h])
            linear_extrude(height = 0.01)
                offset(delta = -taper) footprint_2d(w_cm, top_d, r);
    }
}

// A throw pillow — a chunky square cushion turned 45 deg so it reads as a diamond from
// above, the way one is tossed into the corner of a sofa (the white ones in a catalogue
// photo). It is a cushion() with near-vertical sides and softened corners: standing tall
// on almost-vertical walls it reads unambiguously as RAISED (a shallow dome, viewed from
// above, flips to a crater under the render light), and a cushion prints straight up with
// nothing to support. <s_cm> is its side in real cm, centred on the origin; make it tall
// (h_cm ~ half its side) so it comes out a plump lump rather than a flat tile, and give
// two of them room not to merge. Translate it onto the seat and add it to the solid.
module pillow(s_cm, base_z, h_cm = Cushion_rise, taper = Cushion_taper,
              r = Cushion_radius * 1.5) {
    rotate([0, 0, 45]) cushion(s_cm, s_cm, base_z, h_cm, taper, r);
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
// 4x2 and a partition wall a 2x1 from the same magnets() call.
function magnet_d_for(w_cm, d_cm, d = Magnet_d, small = Magnet_d_small,
                      fit = Magnet_fit, inset = Magnet_inset) =
    min(cm(w_cm), cm(d_cm)) >= magnet_min_span(d, fit, inset) ? d : small;

// ... and how tall that disc is, so the pocket is cut as deep as the magnet that goes
// in it and no deeper. The pair to magnet_d_for(): feed it what that returned.
function magnet_h_for(dia, d = Magnet_d, h = Magnet_h, h_small = Magnet_h_small) =
    dia >= d ? h : h_small;

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
// that drops to the small disc says so, because it changes which magnet you drop in —
// and the two are different heights, so the pocket is cut to the one the piece got
// (magnet_h_for), never to the standard depth regardless.
// <pad> is for a piece too thin to hold a pocket on its own — a wall ribbon: it cuts
// the row anyway, and the part unions magnet_pads() with the same arguments into its
// solid to carry it. Without it such a piece is left solid, with a warning.
module magnets(w_cm, d_cm, n = 1, d = Magnet_d, h = Magnet_h, fit = Magnet_fit,
               inset = Magnet_inset, gap = Magnet_gap, spread = Magnet_spread,
               pad = false, h_small = Magnet_h_small) {
    dia   = magnet_d_for(w_cm, d_cm, d, Magnet_d_small, fit, inset);
    dh    = magnet_h_for(dia, d, h, h_small);
    count = magnet_count(w_cm, d_cm, n, d, fit, inset, gap, pad);
    padded = pad && magnet_pad_needed(w_cm, d_cm, d, fit, inset);
    if (count < n)
        echo(str("WARNING: ", w_cm, "x", d_cm, " cm at 1:", Scale, " fits ",
                 count, " of ", n, " ", dia, "x", dh, " mm magnets"));
    else if (padded)
        echo(str("NOTE: ", w_cm, "x", d_cm, " cm at 1:", Scale,
                 " is too thin to hold a pocket — cut for ", count, " ", dia, "x", dh,
                 " mm on a ", magnet_pad_d(dia, fit, inset), " mm pad"));
    else if (dia != d)
        echo(str("NOTE: ", w_cm, "x", d_cm, " cm at 1:", Scale, " is too narrow for a ",
                 d, " mm disc — cut for ", count, " ", dia, "x", dh, " mm"));
    for (p = magnet_row(w_cm, d_cm, n, d, fit, inset, gap, spread, pad))
        magnet_pocket(p[0], p[1], dia, dh, fit);
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
                   chamfer = Magnet_pad_chamfer, h_small = Magnet_h_small) {
    if (magnet_pad_needed(w_cm, d_cm, d, fit, inset)) {
        dia = magnet_d_for(w_cm, d_cm, d, Magnet_d_small, fit, inset);
        // as tall as the pocket it carries, which is the disc the piece got — a pad is
        // only ever under a small one, so it stays the low foot it was
        dh  = magnet_h_for(dia, d, h, h_small);
        for (p = magnet_row(w_cm, d_cm, n, d, fit, inset, gap, spread, true))
            magnet_pad(p[0], p[1], dia, dh, fit, inset, fit_h, cover, chamfer);
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

// The same recess in the BACK (+Y) face, for a panel that is seen from both sides — a
// chair back, a room divider. Recess both faces of a thin upright and the web left
// between them still prints solid, with nothing to bridge: what reads from either side
// is a frame round a sunken field, which is what a chair back is.
module back_recess(x, z, w, h, depth_cm, cut = Label_depth) {
    mirror([0, 1, 0]) front_recess(x, z, w, h, depth_cm, cut);
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

// ---- sunken hollows ---------------------------------------------------------

// A hollow sunk <depth> mm into a top face at <top_z>: the 2D outline given as its
// child at the face, narrowing to a smaller copy of it <depth> below — so the walls
// slope out on the way up, nothing overhangs the printer, the light gets into the
// hollow instead of leaving a dark slot, and a drain has a flat floor to sit on. A
// bath basin, a sink bowl and a hob burner are all this one shape at three sizes.
// Subtract it from the solid:
//   difference() { footprint(80, 60, h); hollow(h, 4.5) footprint_2d(50, 34, 1); }
// <floor> is the flat floor as a fraction of the rim, so the child has to be centred
// on the origin — translate the whole call to move a hollow, never the child.
module hollow(top_z, depth, floor = Hollow_floor) {
    if (depth > 0)
        hull() {
            translate([0, 0, top_z - depth])
                linear_extrude(height = 0.01) scale(floor) children();
            translate([0, 0, top_z])
                linear_extrude(height = 0.01) children();
        }
}

// ---- fitted units -----------------------------------------------------------
// A fitted unit is not a brick, and printing it as one is what makes a kitchen the
// flattest room on the plan. What you see standing in front of one is a worktop slab
// overhanging a carcass, the carcass standing on a plinth set back further still, and
// a grid of door and drawer fronts on the face between the two. base_unit() builds
// that body, unit_fronts() draws the fronts on it and unit_fascia() the control band
// of a machine built into the run — the same idea as appliance_front() above: the
// piece is read from a low angle, so the detail goes where a low angle can see it.
//
// In section, across a base unit (its front, -Y, on the left):
//
//     |‾‾‾‾‾‾‾‾‾‾|     the worktop slab, at the full footprint ...
//    /           |     ... a 45 deg flare down to ...
//    |           |     ... the carcass, set back Unit_lip: the face the fronts are
//    |           |         cut into ...
//     \          |     ... another flare down to ...
//     |          |     ... the plinth, set back Unit_kick — the toe kick, in shadow
//    ----------------       at the floor
//
// Every step outwards on the way up is a 45 deg flare, so a unit prints the right way
// up with nothing to support and nothing to bridge, and the magnet pocket still opens
// at the floor — in the plinth, which is the face that really touches the board, so
// that is the footprint to hand magnets() (see unit_plinth_d()).
//
// A flare is as TALL as the step it covers is deep, in printed mm: 45 deg is a fact
// about the printer, not a real-world dimension, so the flares are the one height in
// the set that Height_scale leaves alone.
//
// <top_cm> is how much of the height the worktop slab takes. Pass 0 for a piece with
// no worktop of its own, whose fronts run the full height instead — a larder, a
// fridge, an integrated dishwasher under someone else's counter; everything here
// takes it, so a part passes the same value throughout.

// The plinth's set-back and the slab's overhang, in real cm: what Unit_kick and
// Unit_lip ask for, clamped so neither can eat a shallow piece (a 30 cm wall unit
// keeps a carcass) and so the overhang never reaches past the set-back under it.
function unit_back(w_cm, d_cm) = min(Unit_kick, min(w_cm, d_cm) / 4);
function unit_over(w_cm, d_cm, top_cm = Unit_top) =
    top_cm > 0 ? min(Unit_lip, unit_back(w_cm, d_cm)) : 0;
// What is left of a <h> mm-tall unit once the two flares have had their share — which
// together always come to cm(unit_back()), however the step is split between them.
function unit_room(w_cm, d_cm, h) = max(0, h - cm(unit_back(w_cm, d_cm)));
// The slab and the plinth, printed mm: their real heights, but never more than a third
// of that room each — so a piece too short for the whole stack still comes out solid,
// with a carcass left between the two, instead of inside out.
function unit_slab(w_cm, d_cm, h, top_cm = Unit_top) =
    min(rise(top_cm), unit_room(w_cm, d_cm, h) / 3);
function unit_foot(w_cm, d_cm, h) =
    min(rise(Unit_foot), unit_room(w_cm, d_cm, h) / 3);
// The band of carcass face the fronts go in, printed mm up from the floor: from the
// top of the toe-kick flare to the underside of the slab's.
function unit_face_z0(w_cm, d_cm, h, top_cm = Unit_top) =
    unit_foot(w_cm, d_cm, h) + cm(unit_back(w_cm, d_cm) - unit_over(w_cm, d_cm, top_cm));
function unit_face_z1(w_cm, d_cm, h, top_cm = Unit_top) =
    h - unit_slab(w_cm, d_cm, h, top_cm) - cm(unit_over(w_cm, d_cm, top_cm));
// The depth to hand front_recess() so its cut lands on the CARCASS face and not out
// where the footprint's front edge is: the piece less the set-back at each end of it.
function unit_face_d(w_cm, d_cm, top_cm = Unit_top) =
    d_cm - 2 * unit_over(w_cm, d_cm, top_cm);
// The footprint a unit actually stands on — its plinth, set back at the front, or all
// round on an island. Hand it to magnets(), so the disc is chosen and the pockets are
// placed on the face that really meets the board.
function unit_plinth_d(w_cm, d_cm)   = d_cm - unit_back(w_cm, d_cm);
function island_plinth_w(w_cm, d_cm) = w_cm - 2 * unit_back(w_cm, d_cm);
function island_plinth_d(w_cm, d_cm) = d_cm - 2 * unit_back(w_cm, d_cm);

// A footprint outline with its FRONT (-Y) edge set back <set_cm> real cm and its back
// edge left where it was — a carcass under a worktop's overhang, a plinth under a
// carcass. The rounding is clamped to what is left, so a deep set-back cannot round
// a shallow outline away to nothing.
module footprint_front_2d(w_cm, d_cm, set_cm, r = Corner_radius) {
    d = max(0.1, d_cm - set_cm);
    translate([0, cm(set_cm) / 2])
        footprint_2d(w_cm, d, min(r, max(0, min(cm(w_cm), cm(d)) / 2 - 0.05)));
}

// ... and one pulled in <in_cm> all round, for a piece stepped on every side. offset()
// keeps the corners round, so there is nothing to re-round.
module footprint_inset_2d(w_cm, d_cm, in_cm, r = Corner_radius) {
    offset(delta = -cm(in_cm)) footprint_2d(w_cm, d_cm, r);
}

// A 45 deg blend from one outline to the next, <h> mm tall: the hull between its first
// child at the bottom and its second at the top. <h> is not free — it is the
// horizontal step between the two outlines, which is what makes the blend 45 deg.
module flare(h) {
    hull() {
        linear_extrude(height = 0.01) children(0);
        translate([0, 0, h]) linear_extrude(height = 0.01) children(1);
    }
}

// A base unit's body: <w_cm> x <d_cm> at the full footprint, <h> printed mm tall, as
// the slab / carcass / plinth stack drawn above — for a unit that stands against a
// wall, so only its front is stepped and its back stays flush for the next one to butt
// against. See island_unit() for one that stands out in the room.
module base_unit(w_cm, d_cm, h, top_cm = Unit_top, r = Corner_radius) {
    back = unit_back(w_cm, d_cm);
    over = unit_over(w_cm, d_cm, top_cm);
    foot = unit_foot(w_cm, d_cm, h);
    slab = unit_slab(w_cm, d_cm, h, top_cm);
    z0   = unit_face_z0(w_cm, d_cm, h, top_cm);   // the carcass face, bottom ...
    z1   = unit_face_z1(w_cm, d_cm, h, top_cm);   // ... and top
    union() {
        linear_extrude(height = foot + 0.01)             // the plinth
            footprint_front_2d(w_cm, d_cm, back, r);
        if (back > over)                                 // out to the carcass
            translate([0, 0, foot])
                flare(cm(back - over)) {
                    footprint_front_2d(w_cm, d_cm, back, r);
                    footprint_front_2d(w_cm, d_cm, over, r);
                }
        translate([0, 0, z0])                            // the carcass
            linear_extrude(height = max(0.01, z1 - z0))
                footprint_front_2d(w_cm, d_cm, over, r);
        if (over > 0)                                    // out to the slab
            translate([0, 0, z1])
                flare(cm(over)) {
                    footprint_front_2d(w_cm, d_cm, over, r);
                    footprint_2d(w_cm, d_cm, r);
                }
        if (slab > 0)                                    // the worktop slab
            translate([0, 0, h - slab])
                linear_extrude(height = slab) footprint_2d(w_cm, d_cm, r);
    }
}

// An island's body: the same stack, stepped on ALL FOUR sides — an island stands in
// the room, so its slab overhangs and its plinth is set back everywhere, not just at
// the front. The fronts still go on the front (-Y) face, the side it is read from.
module island_unit(w_cm, d_cm, h, top_cm = Unit_top, r = Corner_radius) {
    back = unit_back(w_cm, d_cm);
    over = unit_over(w_cm, d_cm, top_cm);
    foot = unit_foot(w_cm, d_cm, h);
    slab = unit_slab(w_cm, d_cm, h, top_cm);
    z0   = unit_face_z0(w_cm, d_cm, h, top_cm);
    z1   = unit_face_z1(w_cm, d_cm, h, top_cm);
    union() {
        linear_extrude(height = foot + 0.01)
            footprint_inset_2d(w_cm, d_cm, back, r);
        if (back > over)
            translate([0, 0, foot])
                flare(cm(back - over)) {
                    footprint_inset_2d(w_cm, d_cm, back, r);
                    footprint_inset_2d(w_cm, d_cm, over, r);
                }
        translate([0, 0, z0])
            linear_extrude(height = max(0.01, z1 - z0))
                footprint_inset_2d(w_cm, d_cm, over, r);
        if (over > 0)
            translate([0, 0, z1])
                flare(cm(over)) {
                    footprint_inset_2d(w_cm, d_cm, over, r);
                    footprint_2d(w_cm, d_cm, r);
                }
        if (slab > 0)
            translate([0, 0, h - slab])
                linear_extrude(height = slab) footprint_2d(w_cm, d_cm, r);
    }
}

// A grid of door / drawer fronts cut into the front (-Y) face of a unit: <cols> across
// its width by <rows> up the band between <z0> and <z1> printed mm, each front
// recessed <relief> mm inside a shadow gap, with a grip slot along its top. The cut
// lands on the carcass face, wherever the body set that back — hand it the same
// <top_cm>. An uneven split is two calls at two bands (a fridge door over a freezer
// one), the way appliance_front() stacks a washer and a dryer. Subtract it.
//
// <face_cm> overrides which plane the cut lands on, for a body that is not the fitted
// unit stack: pass the depth the recessed face belongs to and <top_cm> is ignored (a
// legged_block()'s rail face is Depth - 2 * its set-back). Pass <w_cm> as the width the
// grid has to fill, which on a legged body is the field between the two posts, not the
// whole piece — the grid is centred, so it lands in the field either way.
//
// <knob_cm> puts a round knob of that real diameter on each front INSTEAD of the grip
// slot — <knob_n> of them, spread across the front. A fitted kitchen is handleless and
// reads by its grip rail; a chest of drawers or a bedside table has knobs, and that is
// most of what tells the two apart at 1:40. A knob is a dimple and not a bud, for the
// reason Grip_h gives: a 1 mm spike snaps off in the box.
module unit_fronts(w_cm, d_cm, z0, z1, cols = 1, rows = 1, top_cm = Unit_top,
                   gap_cm = Front_gap, relief = Front_relief, grip = true,
                   face_cm = 0, knob_cm = 0, knob_n = 1) {
    face_d = face_cm > 0 ? face_cm : unit_face_d(w_cm, d_cm, top_cm);
    gap    = cm(gap_cm);
    cell_w = cm(w_cm) / cols;
    cell_h = (z1 - z0) / rows;
    fw     = cell_w - gap;                    // one front ...
    fh     = cell_h - gap;
    gh     = min(rise(Grip_h), fh / 3);       // ... and the grip slot along its top
    if (fw < Symbol_stroke || fh < Symbol_stroke)
        echo(str("WARNING: ", w_cm, "x", d_cm, " cm at 1:", Scale, " has no room for ",
                 cols, "x", rows, " fronts on its face"));
    else
        for (i = [0 : cols - 1], j = [0 : rows - 1]) {
            x = -cm(w_cm) / 2 + cell_w * (i + 0.5);
            z = z0 + cell_h * (j + 0.5);
            front_recess(x, z, fw, fh, face_d, relief);
            if (knob_cm > 0)
                front_knobs(x, z, fw, fh, face_d, knob_cm, knob_n, relief);
            else if (grip && gh >= Symbol_stroke)
                front_recess(x, z + fh / 2 - gh / 2, fw, gh, face_d, relief + Grip_cut);
        }
}

// <n> round knob dimples on one front — a <w> x <h> printed-mm panel centred at <x>,<z>
// on the face of a piece <depth_cm> deep, already recessed <relief> into it. The knob is
// as wide as asked for, or as wide as the front can carry with material round it; one is
// centred and a pair sits on the quarter points. Cut, like everything else on a face.
module front_knobs(x, z, w, h, depth_cm, knob_cm, n = 1, relief = Front_relief,
                   cut = Grip_cut) {
    d = min(cm(knob_cm), w / 3, h / 2);
    if (d >= Symbol_stroke)
        for (i = [0 : n - 1])
            translate([x + (n == 1 ? 0 : (i - (n - 1) / 2) * w / 2),
                       -cm(depth_cm) / 2 - 0.1, z])
                rotate([-90, 0, 0])
                    cylinder(h = relief + cut + 0.1, d = d);
}

// A grid of open bays cut into the front (-Y) face: <rows> of them up the band between <z0>
// and <z1> printed mm, <cols> across, each sunk <depth_cm> into the face, with the shelf left
// standing at the face as a rib between every pair and a mullion between columns. An open
// shelf unit, a glazed case and a wardrobe frame's hanging space are all this one cut, and it
// is what makes them read as open instead of as a block with lines drawn on it. Subtract it.
//
// The bays come out EQUAL. A piece whose bays are not — a wardrobe frame, with a tall hanging
// space under a rail and a shelf over it — cuts them one at a time instead (see
// bedroom/ikea_pax.scad).
//
// A rib is a ledge as deep as the bay it divides, so it prints as a short unsupported
// overhang: keep <depth_cm> to a couple of mm at the plan scale and it comes out clean. Cut a
// bay right THROUGH to a back panel and the ribs become bridges instead, which is why the one
// part that does that prints on its back (livingroom/bookshelf.scad).
//
// <face_cm> is the depth whose front face the cut lands on, as in unit_fronts() — pass a
// legged or set-back body's face depth, or leave it 0 for the piece's own front.
module front_bays(w_cm, d_cm, z0, z1, rows = 1, cols = 1, depth_cm = Bay_depth,
                  rib_cm = Bay_rib, mullion_cm = 0, face_cm = 0) {
    face  = face_cm > 0 ? face_cm : d_cm;
    rib   = cm(rib_cm);
    mull  = cm(mullion_cm > 0 ? mullion_cm : rib_cm);
    bay_h = (z1 - z0 - (rows - 1) * rib) / rows;
    bay_w = (cm(w_cm) - (cols - 1) * mull) / cols;
    if (bay_w < Symbol_stroke || bay_h < Symbol_stroke)
        echo(str("WARNING: ", w_cm, " cm at 1:", Scale, " leaves ", bay_w, " x ", bay_h,
                 " mm per bay over ", cols, "x", rows, " — too thin, bays skipped"));
    else
        for (i = [0 : cols - 1], j = [0 : rows - 1])
            front_recess(-cm(w_cm) / 2 + bay_w / 2 + i * (bay_w + mull),
                         z0 + bay_h / 2 + j * (bay_h + rib),
                         bay_w, bay_h, face, cm(depth_cm));
}

// A control fascia across the front (-Y) face: a strip <h_cm> real cm tall whose TOP
// edge sits at <z> printed mm, kept a shadow gap in from the sides. What is left for a
// fronts grid under it is z0 .. z - rise(h_cm).
module unit_fascia(w_cm, d_cm, z, h_cm = Fascia_h, top_cm = Unit_top,
                   gap_cm = Front_gap, relief = Front_relief) {
    h = rise(h_cm);
    front_recess(0, z - h / 2, cm(w_cm) - 2 * cm(gap_cm), h,
                 unit_face_d(w_cm, d_cm, top_cm), relief);
}

// ---- a slab on open legs ----------------------------------------------------
// A table is read by the AIR under its top, and that is the one thing a solid token cannot
// fake: printed upright the slab would have to bridge between the legs. So the handful of
// pieces whose openness is the point — a dining table, a garden table, a hall console — are
// modelled as a slab with legs standing under it and PRINTED FACE DOWN, top face on the bed.
// Upside down the piece only ever rises from its widest face, so nothing overhangs, nothing
// bridges, and the magnet pockets open upwards for the discs to drop into. The model itself
// stays the right way up like every other part (pockets at z = 0); flip it in the slicer.
//
// Everything else is better off solid and read by its frame — see legged_block() below.
//
// A leg has to be wide enough to bury a magnet (magnet_span_cm(), 25 cm of real furniture at
// 1:40), which on a small top is most of what decides how it looks: slab_leg() clamps to that
// first and slab_leg_gap() reports what clear span is left, so a part can warn when the legs
// have crowded out the air they were there to show.

// The narrowest a foot may be, in real cm, and still bury a <d> disc — with a hair of slack so
// rounding cannot tip it under and drop the piece to the small disc.
function magnet_span_cm(d = Magnet_d) = plan_cm(magnet_min_span(d) + 0.1);

// A leg's real width: what was asked for, never narrower than <min_cm> (what a pocket in its
// foot needs), never so wide that the clear span between two closes below <gap_cm>, and never
// past the middle of the piece however the numbers are set.
function slab_leg(w_cm, d_cm, want_cm, min_cm = 0, inset_cm = Legs_inset,
                  gap_cm = Legs_gap) =
    min(min(w_cm, d_cm) / 2 - inset_cm,
        max(min_cm, min(want_cm, (min(w_cm, d_cm) - 2 * inset_cm - gap_cm) / 2)));
// The clear span left between two legs on the tighter side, real cm. A magnet's own minimum
// wins over <gap_cm>, so on a small top this comes out under it — worth saying so.
function slab_leg_gap(w_cm, d_cm, leg_cm, inset_cm = Legs_inset) =
    min(w_cm, d_cm) - 2 * inset_cm - 2 * leg_cm;
// Where a leg's centre sits along one axis, real cm from the centre of the piece.
function slab_leg_x(w_cm, leg_cm, inset_cm = Legs_inset) =
    w_cm / 2 - inset_cm - leg_cm / 2;

// Where the legs go, as a 2D union: at the four corners, or — with <round> — at 45 deg round
// the rim of a round top, which is where a round table's legs are.
module slab_legs_2d(w_cm, d_cm, leg_cm, round = false, inset_cm = Legs_inset) {
    r = max(0, min(Corner_radius, cm(leg_cm) / 2 - 0.05));
    union() {
        if (round)
            for (a = [45 : 90 : 315])
                translate((cm(w_cm) / 2 - cm(inset_cm) - cm(leg_cm) / 2)
                              * [cos(a), sin(a)])
                    circle(d = cm(leg_cm));
        else
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx * cm(slab_leg_x(w_cm, leg_cm, inset_cm)),
                           sy * cm(slab_leg_x(d_cm, leg_cm, inset_cm))])
                    footprint_2d(leg_cm, leg_cm, r);
    }
}

// The body: the slab at the full footprint — its outline given as the child, so a round top
// and a rectangular one come out of the same call — with a leg standing under each corner.
// The legs are clipped to that outline, so a leg on a rounded corner or a round rim keeps the
// curve instead of poking out through it.
module slab_on_legs(w_cm, d_cm, h, leg_cm, top_cm, round = false,
                    inset_cm = Legs_inset) {
    slab = min(rise(top_cm), h / 2);
    union() {
        // clipped in 2D and extruded once — intersecting a 3D body with a 2D outline is not
        // a thing OpenSCAD does, and doing it flat is cheaper anyway
        linear_extrude(height = h - slab + 0.01)
            intersection() {
                children(0);
                slab_legs_2d(w_cm, d_cm, leg_cm, round, inset_cm);
            }
        translate([0, 0, h - slab]) linear_extrude(height = slab) children(0);
    }
}

// One pocket per foot, in diagonal order, so the two a table normally gets sit corner to
// opposite corner and cannot let the piece pivot on the board. The shared magnets() rows along
// one axis of a single rectangle and would lay that row out over the space between the legs —
// air — so each foot gets its own call on its own footprint, as office/desk.scad does.
module slab_leg_pockets(w_cm, d_cm, leg_cm, n = 1, round = false,
                        inset_cm = Legs_inset) {
    count = min(n, 4);
    order = [[-1, -1], [1, 1], [-1, 1], [1, -1]];
    angle = [45, 225, 135, 315];
    if (n > count)
        echo(str("WARNING: a slab on legs has four feet — ", n,
                 " pockets asked for, ", count, " cut"));
    for (i = [0 : count - 1])
        if (round)
            translate((cm(w_cm) / 2 - cm(inset_cm) - cm(leg_cm) / 2)
                          * [cos(angle[i]), sin(angle[i])])
                magnets(leg_cm, leg_cm, 1);
        else
            translate([order[i][0] * cm(slab_leg_x(w_cm, leg_cm, inset_cm)),
                       order[i][1] * cm(slab_leg_x(d_cm, leg_cm, inset_cm))])
                magnets(leg_cm, leg_cm, 1);
}

// ---- legs -------------------------------------------------------------------
// A piece of furniture that is not fitted stands on legs, and a token that ignores that
// is a brick: a chair, a bench, a buffet, a glazed cabinet all read by the frame you see
// at their corners. legged_block() gives them one without giving up a solid print — the
// four corners stay at the full footprint as posts, the rail between each pair is set
// back behind them, and the top closes over the lot as a slab standing proud all round.
// From any side you read two legs with a rail between them; underneath it is still one
// broad face for a magnet pocket, and every layer is either straight up or a 45 deg
// flare, so it prints the right way up with nothing to support.
//
// In section, across a legged block:
//
//     |‾‾‾‾‾‾‾‾‾‾‾‾|      the top slab, at the full footprint ...
//    /              \     ... a 45 deg flare down to ...
//    |  |‾‾‾‾‾‾‾‾|  |     ... the rail, set back Leg_set behind ...
//    |  |        |  |     ... the corner posts, Leg_w wide, which are the only
//    |__|        |__|         part of the body at the full footprint
//
// This is frame-and-panel, not an open-legged table: at 1:40 real air between four legs
// means the top has to bridge between them, and the two parts of the set that want
// genuine air under a slab print UPSIDE DOWN instead (diningroom/table.scad,
// office/desk.scad). Everything else is better off solid and read by its frame.
//
// Fronts go on the rail face, so hand unit_fronts() the field between the posts and
// legged_face_d() — see diningroom/sideboard.scad.

// The set-back and the post, in real cm: what Leg_set / Leg_w ask for, clamped so a
// shallow piece keeps a rail, a post can never be so fat that the two on one side meet,
// and a post always stands at least as proud as the rail is set back.
function legged_set(w_cm, d_cm, set_cm = Leg_set) =
    min(set_cm, min(w_cm, d_cm) / 6);
function legged_leg(w_cm, d_cm, leg_cm = Leg_w, set_cm = Leg_set) =
    max(legged_set(w_cm, d_cm, set_cm), min(leg_cm, min(w_cm, d_cm) / 3));
// The top of the rail face, printed mm up from the floor: under the slab and under the
// flare that spreads out to it. The bottom of it is the floor — the posts run the whole
// way down, so a part puts its own bottom rail in by starting its fronts above it.
function legged_face_z1(w_cm, d_cm, h, top_cm = Leg_top, set_cm = Leg_set) =
    max(0, h - min(rise(top_cm), h / 2) - cm(legged_set(w_cm, d_cm, set_cm)));
// The depth to hand front_recess()/unit_fronts() so the cut lands on the RAIL face and
// not out where the posts are, and the field of rail left between the two posts.
function legged_face_d(w_cm, d_cm, set_cm = Leg_set) =
    d_cm - 2 * legged_set(w_cm, d_cm, set_cm);
function legged_field_w(w_cm, d_cm, leg_cm = Leg_w, set_cm = Leg_set) =
    w_cm - 2 * legged_leg(w_cm, d_cm, leg_cm, set_cm);
// The footprint the piece really stands on: the rail's, which is the broad part of the
// bottom face — hand it to magnets(), as a fitted unit hands over its plinth's.
function legged_floor_w(w_cm, d_cm, set_cm = Leg_set) =
    w_cm - 2 * legged_set(w_cm, d_cm, set_cm);
function legged_floor_d(w_cm, d_cm, set_cm = Leg_set) =
    d_cm - 2 * legged_set(w_cm, d_cm, set_cm);

// The body's outline below the slab: the rail, set back all round, plus a post at each
// corner back out at the full footprint. The posts are clipped to the footprint, so they
// keep its rounded corners instead of squaring them off.
module legged_2d(w_cm, d_cm, leg_cm = Leg_w, set_cm = Leg_set, r = Corner_radius) {
    leg = legged_leg(w_cm, d_cm, leg_cm, set_cm);
    union() {
        footprint_inset_2d(w_cm, d_cm, legged_set(w_cm, d_cm, set_cm), r);
        intersection() {
            footprint_2d(w_cm, d_cm, r);
            union() {
                for (sx = [-1, 1], sy = [-1, 1])
                    translate([sx * (cm(w_cm) - cm(leg)) / 2,
                               sy * (cm(d_cm) - cm(leg)) / 2])
                        square([cm(leg), cm(leg)], center = true);
            }
        }
    }
}

// The whole body: <w_cm> x <d_cm> at the full footprint, <h> printed mm tall, built as
// the post / rail / slab stack drawn above.
module legged_block(w_cm, d_cm, h, leg_cm = Leg_w, set_cm = Leg_set,
                    top_cm = Leg_top, r = Corner_radius) {
    set  = legged_set(w_cm, d_cm, set_cm);
    slab = min(rise(top_cm), h / 2);
    z1   = legged_face_z1(w_cm, d_cm, h, top_cm, set_cm);
    union() {
        linear_extrude(height = z1 + 0.01)                 // the posts and the rail
            legged_2d(w_cm, d_cm, leg_cm, set_cm, r);
        if (set > 0)                                       // out to the slab
            translate([0, 0, z1])
                flare(cm(set)) {
                    legged_2d(w_cm, d_cm, leg_cm, set_cm, r);
                    footprint_2d(w_cm, d_cm, r);
                }
        if (slab > 0)                                      // the top slab
            translate([0, 0, h - slab])
                linear_extrude(height = slab) footprint_2d(w_cm, d_cm, r);
    }
}
