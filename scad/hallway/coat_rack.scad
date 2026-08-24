// hallway / coat_rack — a slim, tall coat stand (hall tree) token, with a row
// of pegs engraved near one edge and nothing else.
//
// Width/Depth are the real-world footprint in cm: a coat stand's base is slim,
// 40 x 40 cm here — just enough to keep a tall piece from tipping. Height is its
// real height — the hooks have to be reachable above a hanging coat — shrunk by the
// plan scale like the footprint (see printed_h() in lib/common.scad): a slim piece
// standing as tall as the wardrobes.

include <../lib/common.scad>

Width  = 40;   // cm
Depth  = 40;   // cm
Height = 180;  // cm — up at hook height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_pegs = true;
// Magnet pockets in the bottom face (0 = none). A 40 cm side is 10 mm
// across at 1:40 — wide enough for a 4 mm disc.
Magnets = 1;

// The peg row, printed mm — a simplified plan-view symbol for the hooks near
// the top of the stand, drawn as small filled dots near one edge instead of
// with stroke_line()/stroke_arc(): a hook this small would close up at one
// nozzle width, a dot still reads.
Peg_count = 4;    // dots in the row — 3-4 reads as pegs, more looks like a seam
Peg_d     = 1;    // dot diameter
Peg_gap   = 0.5;  // gap between dots

coat_rack();

module coat_rack() {
    difference() {
        footprint(Width, Depth, Print_h);
        // the pegs sit near one edge, as a real coat stand's hooks would
        if (Show_pegs)
            pegs(Print_h);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The peg row cut into the top face, near the +Y edge — the custom-pictogram
// pattern from lib/common.scad's header: a shallow cut at the same depth as
// label(), centred on the origin, built from plain circles.
module pegs(top_z, depth = Label_depth, n = Peg_count, d = Peg_d, gap = Peg_gap) {
    step  = d + gap;
    row_y = cm(Depth) / 2 - Symbol_margin - d / 2;
    translate([0, 0, top_z - depth])
        linear_extrude(height = depth + 0.01)
            for (i = [0 : n - 1])
                translate([-(n - 1) * step / 2 + i * step, row_y])
                    circle(d = d);
}
