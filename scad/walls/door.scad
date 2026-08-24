// walls / door — a wall segment with a doorway in it, and the floor the leaf sweeps.
// The piers stand full height like wall.scad; across the opening the ribbon drops to
// a threshold, and that same low plate carries on into the room as the quarter circle
// the door swings through. So the piece OCCUPIES the swing: nothing can be put where
// the door has to open, because the token is already there.
//
//   [ wall 100 ][ door 87.5 left ][ wall 50 ]
//
// Thickness/Width/Reveal/Frame are real-world cm, Height/Threshold_h PRINTED mm.
//   Width   the masonry opening (Rohbaumass, DIN 18101): 62.5 / 75 / 87.5 / 100 /
//           112.5 cm, for the 61 / 73.5 / 86 / 98.5 / 111 cm leaves sold to fit them
//   Frame   how much of the opening the frame takes, so the leaf — and with it the
//           radius of the swing — is Width - Frame (15 mm in DIN 18101)
//   Reveal  the pier of solid wall kept either side, as window.scad
// A window sill and a door threshold are deliberately different heights, so the two
// tell apart under your fingers as well as by their shape. Height is printed mm, as
// wall.scad — the catalogue's one exception to real, scaled heights (see the note
// there).
//
// Hand is which END the leaf is hinged on; it always swings towards the -Y face.
// Turning the segment around in the plan swaps both, so the two variants cover all
// four hands: left + turned = hinged right, opening into the other room. The swing
// plate never reaches past the far jamb (the leaf is narrower than the opening), so a
// door segment still butts flush between plain ones.

include <../lib/common.scad>

Thickness = 11.5;   // cm — 11.5 partition, 17.5/24 load-bearing
Width     = 87.5;   // cm — the masonry opening
Frame     = 1.5;    // cm — opening less leaf (DIN 18101)
Reveal    = 12.5;   // cm — pier of wall either side of it
Height    = 7;      // PRINTED mm — as wall.scad
Threshold_h = 1.5;  // printed mm — lower than a window sill (see window.scad)

Hand = "left";      // "left" or "right" — which end carries the hinge

// The floor the leaf sweeps: a quarter disc of the leaf's width, at threshold
// height, hinged in the jamb. With it the outline of the piece IS the swing arc a
// plan would draw, so nothing has to be engraved to show it. Turn it off for a plain
// opening — the arc is then cut into the threshold instead, as far as the wall
// thickness allows.
Swing_plate = true;
// The closed leaf, engraved along the face it sits against.
Show_leaf = true;

// Magnet pockets in the bottom face, per pier (0 = none) — as window.scad. The swing
// plate is only Threshold_h thick, too thin to sink a pocket into, so the piers are
// the only place one could go — and at 1:40 a 12.5 cm pier is 3.1 mm long, too small
// for even the 2 mm disc: nothing is cut, and the render log says so.
Magnets = 1;

door();

module door() {
    difference() {
        union() {
            // the threshold runs the whole length; the piers stand on it
            footprint(length(), Thickness, Threshold_h, r = 0);
            if (Swing_plate) swing_plate(Threshold_h);
            for (s = [-1, 1])
                translate([s * cm(Width + Reveal) / 2, 0, 0])
                    footprint(Reveal, Thickness, Height, r = 0);
        }
        if (Show_leaf) leaf(Threshold_h);
        if (!Swing_plate) swing_arc(Threshold_h);
        if (Magnets > 0) pier_magnets();
    }
}

// Total segment length in cm — the opening plus a pier at each end.
function length() = Width + 2 * Reveal;
// The leaf, and so the radius the door sweeps, in cm.
function leaf_w() = max(0, Width - Frame);
// +1 when the hinge is at the +X end, -1 at the -X end; the leaf sweeps the other way.
function hinge_dir() = Hand == "right" ? 1 : -1;
// The hinge, in printed mm: in the jamb, at the face the door opens towards.
function hinge() = [hinge_dir() * cm(Width) / 2, -cm(Thickness) / 2];

// The quarter of floor the leaf sweeps, standing <h> printed mm proud of the board:
// a disc of the leaf's width around the hinge, kept to the quadrant the door opens
// into. It meets the threshold along the wall face, so the two are one plate.
module swing_plate(h) {
    r = cm(leaf_w());
    translate(concat(hinge(), 0))
        linear_extrude(height = h)
            intersection() {
                circle(r = r);
                translate([hinge_dir() > 0 ? -r : 0, -r]) square([r, r]);
            }
}

// The closed leaf cut into the threshold, drawn with the same pen as the symbols in
// lib/common.scad: a stroke from jamb to jamb, against the face it swings off.
module leaf(top_z, stroke = Symbol_stroke, depth = Label_depth) {
    x = cm(Width) / 2 - stroke / 2;
    y = -(cm(Thickness) / 2 - Symbol_margin - stroke / 2);
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            stroke_line([-x, y], [x, y], stroke);
}

// The swing engraved instead of occupied (Swing_plate = false): the arc leaving the
// hinge, turning across the wall — as much of the quarter circle as fits inside the
// opening. A wall too thin to turn in loses it rather than printing a blob.
module swing_arc(top_z, stroke = Symbol_stroke, depth = Label_depth) {
    y = -(cm(Thickness) / 2 - Symbol_margin - stroke / 2);
    r = min(cm(Thickness) - 2 * Symbol_margin - stroke, cm(Width) / 2);
    if (r >= 2 * stroke)
        translate([0, 0, top_z - depth])
            linear_extrude(height = depth + 0.01)
                translate([hinge_dir() * (cm(Width) / 2 - stroke / 2), y])
                    stroke_arc(r, hinge_dir() > 0 ? 180 : 0, 90, stroke);
    else
        echo(str("WARNING: a ", Thickness, " cm wall at 1:", Scale,
                 " is too thin for a door swing arc — leaf only"));
}

// One pocket centred in each pier, as window.scad.
module pier_magnets() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnets(Reveal, Thickness, Magnets);
}
