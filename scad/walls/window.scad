// walls / window — a wall segment with a window in it: the ribbon drops to a sill
// across the opening and stands full height on the pier either side, with the
// glass line engraved along the sill. It butts between plain segments (wall.scad),
// so a run reads as one wall with a hole in it:
//   [ wall 100 ][ window 100 ][ wall 50 ]
// and the opening reads from a low angle and under your fingers, not just from
// directly above.
//
// Thickness/Width/Reveal are real-world cm, Height/Sill_h PRINTED mm.
//   Width   the window opening — the 1/8 m widths windows are sold in
//   Reveal  the pier of solid wall kept either side, so the piece stays in one
//           part and has somewhere to put a magnet. The segment is therefore
//           Width + 2*Reveal long.
// Height matches wall.scad on purpose — a plain segment and an opening segment have
// to read as the same wall — which means it is a printed height, the catalogue's one
// exception to real, scaled heights (see the note in wall.scad).
//
// Unlike wall.scad this carries no engraved number — a pier is 3.1 mm long at 1:40,
// too short for a legible one (see wall_label) — so a window is told apart by its
// shape, and its thickness by the neighbours it butts against.

include <../lib/common.scad>

Thickness = 11.5;  // cm — 11.5 partition, 17.5/24 load-bearing
Width     = 100;   // cm — the window opening
Reveal    = 12.5;  // cm — pier of wall either side of it
Height    = 7;     // PRINTED mm — as wall.scad
Sill_h    = 2.5;   // printed mm — what is left under the opening

// The glass, drawn as a plan draws it: one line down the middle of the sill, the
// full width of the opening. It is what tells a window from a door (door.scad has
// a leaf and a swing arc instead, on a lower threshold).
Show_glass = true;

// Magnet pockets in the bottom face, per pier (0 = none). One each, so the piece
// cannot pivot — but at 1:40 a pier is only 3.1 mm long and 2.9–6 mm thick, too
// small for even the 2 mm disc with a wall around it, so magnets() cuts nothing and
// says so in the render log: an opening segment is held by the run it butts into.
// Set OPENING_MAGNETS=0 to stop asking (see Magnet_* in lib/common.scad).
Magnets = 1;

window();

module window() {
    difference() {
        union() {
            // the sill runs the whole length; the piers stand on it at both ends
            footprint(length(), Thickness, Sill_h, r = 0);
            for (s = [-1, 1])
                translate([s * cm(Width + Reveal) / 2, 0, 0])
                    footprint(Reveal, Thickness, Height, r = 0);
        }
        if (Show_glass) glass(Sill_h);
        if (Magnets > 0) pier_magnets();
    }
}

// Total segment length in cm — the opening plus a pier at each end.
function length() = Width + 2 * Reveal;

// The glass line cut into the sill: the same pen the symbols in lib/common.scad
// are drawn with, run down the centre of the opening.
module glass(top_z, stroke = Symbol_stroke, depth = Label_depth) {
    x = cm(Width) / 2 - stroke / 2;   // the pen is centred on the path
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            stroke_line([-x, 0], [x, 0], stroke);
}

// One pocket centred in each pier. magnets() measures the piece it is given, so it
// is handed a pier — not the whole segment — and picks the disc that fits it.
module pier_magnets() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnets(Reveal, Thickness, Magnets);
}
