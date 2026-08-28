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
//           part and has somewhere to put a magnet — which is what sets it, see
//           Magnets. The segment is therefore Width + 2*Reveal long.
// Height matches wall.scad on purpose — a plain segment and an opening segment have
// to read as the same wall — which means it is a printed height, the catalogue's one
// exception to real, scaled heights (see the note in wall.scad).
//
// Like wall.scad it carries its size engraved on one face — the opening width here,
// rather than the segment length — and for the same reason: the outside of the parapet is
// a 20 mm tall, full-length surface, the one big flat face a window segment has, and it
// is that whatever the wall thickness. The alternatives are all too small at 1:40: a pier
// is 5 mm long, and the sill top has the glass line down it and under a millimetre of
// band left either side. Thickness is not engraved, on a window or on a wall: it reads
// off the ribbon and off the neighbours the segment butts against.

include <../lib/common.scad>

Thickness = 11.5;  // cm — 11.5 partition, 17.5/24 load-bearing
Width     = 100;   // cm — the window opening
Reveal    = 20;    // cm — pier of wall either side of it (see Magnets)
Height    = 25;    // PRINTED mm — as wall.scad
Sill_h    = 20;    // printed mm — the parapet under the opening: a real 80 cm at 1:40

// The glass, drawn as a plan draws it: one line down the middle of the sill, the
// full width of the opening. It is what tells a window from a door (door.scad has
// a leaf and a swing arc instead, on a lower threshold).
Show_glass = true;

// Engrave the opening width on the outside (-Y) face of the parapet — centred on the
// opening and half way up, so it clears the magnet pads at the foot. Shrunk to fit that
// face, and left off with a warning if it ever cannot (a very low sill, or a smaller
// scale), exactly as wall.scad does with its length.
Show_label = true;

// Magnet pockets in the bottom face, one per pier (0 = none): at the two ends, where the
// segment butts its neighbours, so it cannot pivot — and holding it down there rather
// than under the sill, which is the part meant to read as a hole. The piers are
// therefore what sets Reveal: at 1:40 a pocket needs a 4.3 mm square of floor, so a pier
// has to be at least 17.2 cm long, and 20 cm is the first round number past it. Across
// the thickness the 11.5 cm partition is still too thin, so it gets a pad under each
// pocket (magnet_pads() in lib/common.scad); the thicker walls take the pocket as they
// are. Set OPENING_MAGNETS=0 to leave every pier solid — an opening segment is also held
// by the run it butts into (see Magnet_* in lib/common.scad).
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
            if (Magnets > 0) pier_pads();
        }
        if (Show_glass) glass(Sill_h);
        if (Show_label) width_label();
        if (Magnets > 0) pier_magnets();
    }
}

// The opening width cut into the face of the parapet. Sized to that face — no taller
// than the sill, no longer than the opening — and dropped below the legibility floor
// rather than printed as a blob (cf. wall_label() in wall.scad).
module width_label() {
    txt  = str(Width);
    h    = Sill_h        - 2 * Symbol_margin;   // room up the face of the parapet
    w    = cm(Width)     - 2 * Symbol_margin;   // ... along the opening
    size = label_size(w, h, txt);
    if (size >= Symbol_min)
        label_front(txt, Thickness, z = Sill_h / 2, size = size);
    else
        echo(str("WARNING: a ", Width, " cm window on a ", Sill_h,
                 " mm sill at 1:", Scale, " has no face left to engrave its width"));
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
            magnets(Reveal, Thickness, Magnets, pad = true);
}

// ... and the material those pockets need on a wall too thin to hold one — nothing on
// a wall that is thick enough. Same arguments as pier_magnets(), so the two line up.
module pier_pads() {
    for (s = [-1, 1])
        translate([s * cm(Width + Reveal) / 2, 0, 0])
            magnet_pads(Reveal, Thickness, Magnets);
}
