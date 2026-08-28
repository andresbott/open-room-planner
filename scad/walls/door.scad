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
Reveal    = 20;     // cm — pier of wall either side of it (as window.scad)
Height    = 25;     // PRINTED mm — as wall.scad
Threshold_h = 2.7;  // printed mm — a step you walk over, not a parapet you look over:
                    // it stays put when the wall gets taller (cf. window.scad's Sill_h)

Hand = "left";      // "left" or "right" — which end carries the hinge

// The floor the leaf sweeps: a quarter disc of the leaf's width, at threshold
// height, hinged in the jamb. With it the outline of the piece IS the swing arc a
// plan would draw, so nothing has to be engraved to show it. Turn it off for a plain
// opening — the arc is then cut into the threshold instead, as far as the wall
// thickness allows.
Swing_plate = true;
// The closed leaf, engraved along the face it sits against.
Show_leaf = true;
// Engrave the opening width on the floor the leaf sweeps — the one big flat surface a
// door segment has, and the same number the file is named for, so a doorway can be
// picked out of the box by reading it. On a plain opening (Swing_plate = false) there
// is no plate, so it goes on the threshold behind the leaf line instead, as far as the
// wall thickness allows. Shrunk to fit either, and left off with a warning where that
// would come out a blob.
Show_label = true;

// Magnet pockets in the bottom face, one per pier (0 = none) — as window.scad: at the
// two ends, where the segment butts its neighbours, and not under the threshold or the
// swing plate, which are meant to read as floor. The piers are therefore what sets
// Reveal: 20 cm, the first round number past the 17.2 cm a pocket needs at 1:40. On the
// 11.5 cm partition the pier is still too thin across, so it gets a pad under each
// pocket (magnet_pads() in lib/common.scad); the thicker walls take it as they are.
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
            if (Magnets > 0) pier_pads();
        }
        if (Show_leaf) leaf(Threshold_h);
        if (!Swing_plate) swing_arc(Threshold_h);
        if (Show_label) door_label(Threshold_h);
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

// The opening width cut into the floor the leaf sweeps: out on the bisector of the
// quadrant, half a leaf from the hinge, where the plate is at its widest and the leaf
// line and the jambs are all well clear. Sized to the room left between there and the
// arc, and dropped below the legibility floor like every other engraving.
// Without a plate there is only the threshold to put it on: centred along the segment,
// in the band behind the leaf line, which on a thin wall is nothing at all.
module door_label(top_z) {
    txt = str(Width);
    if (Swing_plate) {
        r    = cm(leaf_w());
        c    = 0.5 * r;                                  // how far out it sits
        room = r - Symbol_margin - c * sqrt(2);          // ... and what is left past it
        size = label_size_free(room, txt);
        if (size >= Symbol_min)
            translate([hinge()[0] - hinge_dir() * c, hinge()[1] - c, 0])
                label(txt, top_z, size = size);
        else
            echo(str("WARNING: a ", Width, " cm door at 1:", Scale,
                     " leaves too little swing plate to engrave its width"));
    } else {
        // the leaf line runs along the front face; the number goes behind it
        y0   = -(cm(Thickness) / 2 - Symbol_margin - Symbol_stroke) + Symbol_margin;
        y1   = cm(Thickness) / 2 - Symbol_margin;
        w    = cm(Width) - 2 * Symbol_margin;
        size = label_size(w, y1 - y0, txt);
        if (size >= Symbol_min)
            translate([0, (y0 + y1) / 2, 0]) label(txt, top_z, size = size);
        else
            echo(str("WARNING: a ", Thickness, " cm wall at 1:", Scale,
                     " is too thin to engrave a door width on its threshold"));
    }
}

// One pocket centred in each pier, as window.scad.
module pier_magnets() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnets(Reveal, Thickness, Magnets, pad = true);
}

// ... and the material a wall too thin to hold one needs under it, as window.scad.
module pier_pads() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnet_pads(Reveal, Thickness, Magnets);
}
