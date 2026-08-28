// walls / sliding_door — a wall segment with a sliding glazed opening in it: a patio
// door. It sits between window.scad and door.scad, and what defines it is what it does
// NOT do. Like a door the ribbon drops to a threshold you walk over, not to a sill you
// look over — but a sliding leaf runs along the wall instead of swinging into the room,
// so unlike door.scad the piece takes no floor beyond the wall itself: you can plan a
// sofa right up against it, which is half the reason to fit one.
//
//   [ wall 100 ][ sliding_door 200 ][ wall 50 ]
//
// Thickness/Width/Reveal are real-world cm, Height/Threshold_h PRINTED mm.
//   Width   the structural opening — the 1/8 m series, 150 to 300 cm (150 is a narrow
//           two-panel slider, 300 a wide one)
//   Reveal  the pier of solid wall kept either side, as window.scad
//   Panels  how many leaves share the opening — 2 is the usual slider, 3 a wide one
//
// How it reads: a plan draws a slider as one line per leaf, each running its share of
// the opening, the leaves offset onto two tracks across the wall so they overlap where
// they meet. That is what is engraved — so the three openings tell apart from above at a
// glance, and by touch too:
//   window        one centred glass line       on a sill        (4.5 mm)
//   door          a leaf plus the floor it sweeps, occupied     (2.7 mm threshold)
//   sliding_door  a line per leaf on two tracks, no floor taken (2.7 mm threshold)
// Turning the segment round in the plan swaps which leaf is on the inner track, which is
// the only handedness a slider has — so unlike door.scad there is no Hand and no pair of
// variants to build.
//
// It carries no engraved number, for the same reason window.scad does not: the threshold
// is where a number would have to go and the tracks have it, and between them there is
// less than a legible cap height on any wall this thin. A slider is told apart by its
// shape, and its size by the file it came from.

include <../lib/common.scad>

Thickness   = 11.5;  // cm — 11.5 partition, 17.5/24 load-bearing
Width       = 200;   // cm — the structural opening
Reveal      = 20;    // cm — pier of wall either side of it (as window.scad)
Height      = 25;    // PRINTED mm — as wall.scad
Threshold_h = 2.7;   // printed mm — a door's threshold, not a window's parapet

Panels        = 2;   // leaves sharing the opening
Panel_overlap = 5;   // cm — how far they overlap at the meeting stile

// The leaves on their tracks, engraved along the threshold (see leaves()).
Show_leaves = true;

// Magnet pockets in the bottom face, one per pier (0 = none) — exactly as window.scad:
// at the two ends where the segment butts its neighbours, which is what sets Reveal (a
// pocket needs 4.3 mm of floor at 1:40, so a pier of at least 17.2 cm). The 11.5 cm
// partition is still too thin across, so its pockets sit on pads (magnet_pads() in
// lib/common.scad).
Magnets = 1;

sliding_door();

module sliding_door() {
    difference() {
        union() {
            // the threshold runs the whole length; the piers stand on it at both ends
            footprint(length(), Thickness, Threshold_h, r = 0);
            for (s = [-1, 1])
                translate([s * cm(Width + Reveal) / 2, 0, 0])
                    footprint(Reveal, Thickness, Height, r = 0);
            if (Magnets > 0) pier_pads();
        }
        if (Show_leaves) leaves(Threshold_h);
        if (Magnets > 0) pier_magnets();
    }
}

// Total segment length in cm — the opening plus a pier at each end.
function length() = Width + 2 * Reveal;

// The two tracks the leaves run on, as printed mm either side of the wall's centre
// line: a quarter of the thickness out, or as far out as the margin allows on a wall too
// thin for that.
function track_y(stroke = Symbol_stroke) =
    min(cm(Thickness) / 4, cm(Thickness) / 2 - Symbol_margin - stroke / 2);
// ... and whether the pair can be told apart at all: a nozzle's worth of material has to
// survive between the two grooves, else they close up into one fat line and the piece
// would read as a window.
function tracks_fit(stroke = Symbol_stroke) = 2 * track_y(stroke) - stroke >= stroke;

// The leaves cut into the threshold, drawn with the same pen as the symbols in
// lib/common.scad: one stroke per panel, each running its share of the opening and
// overlapping its neighbour by Panel_overlap, on alternating tracks. A wall too thin for
// two tracks falls back to a single centred line and says so — better one honest line
// than two that merge.
module leaves(top_z, stroke = Symbol_stroke, depth = Label_depth) {
    w   = cm(Width);
    ov  = cm(Panel_overlap);
    off = track_y(stroke);
    if (!tracks_fit(stroke))
        echo(str("WARNING: a ", Thickness, " cm wall at 1:", Scale,
                 " is too thin for two slider tracks — one line instead"));
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            if (tracks_fit(stroke))
                for (i = [0 : Panels - 1]) {
                    // the pen is centred on the path, so the outer ends stop half a
                    // stroke short of the jambs; the inner ones run on past each other
                    x0 = -w / 2 + i * w / Panels - (i > 0 ? ov / 2 : -stroke / 2);
                    x1 = -w / 2 + (i + 1) * w / Panels
                                + (i < Panels - 1 ? ov / 2 : -stroke / 2);
                    stroke_line([x0, (i % 2 == 0 ? -1 : 1) * off],
                                [x1, (i % 2 == 0 ? -1 : 1) * off], stroke);
                }
            else
                stroke_line([-w / 2 + stroke / 2, 0], [w / 2 - stroke / 2, 0], stroke);
}

// One pocket centred in each pier, and the material a wall too thin to hold one needs
// under it — both exactly as window.scad.
module pier_magnets() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnets(Reveal, Thickness, Magnets, pad = true);
}

module pier_pads() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnet_pads(Reveal, Thickness, Magnets);
}
