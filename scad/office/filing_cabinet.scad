// office / filing_cabinet — a drawer pedestal: a narrow, deep carcass on a recessed
// plinth, with a stack of drawer fronts on its FRONT (-Y) face, each with a recessed
// finger pull along its top — the metal-office look, and the one detail that tells a
// filing pedestal from the chest of drawers it shares a shape with.
//
// It used to be a plain block with the drawers() pictogram engraved on its TOP face —
// the labelled brick AGENTS.md §1.1 warns against: a 0.4 mm groove on the one face a
// low angle sees least of said nothing, and the box read as a box. A filing cabinet's
// drawers are on the front, where you pull them, so that is where they went — real
// recesses in the face (base_unit()/unit_fronts() in lib/common.scad), the same body
// the kitchen cabinets stand on, over a toe kick so it reads as furniture on the floor
// and not a brick sunk into it.
//
// The pull is the handleless grip rail unit_fronts() cuts by default, not the knob a
// bedside chest gets: a filing pedestal has a long recessed finger pull, and a cut
// reads truer here than a 1 mm knob that would snap off in the box (§1.3).
//
// Width/Depth are the real-world footprint in cm: a filing pedestal is narrow and deep,
// 40 wide by 55 deep, so a hanging file runs front-to-back. Height is the real carcass
// height — a three-drawer pedestal is built to slide under a desk top — shrunk by the
// plan scale like the footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 40;  // cm
Depth  = 55;  // cm
Height = 72;  // cm — a pedestal, under a 74 cm desk top

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The cabinet top, in real cm — a thin slab standing a little proud of the carcass, so
// the piece has a lid over its top drawer rather than the drawer running off the top edge.
Top_h = 3;

Show_drawers = true;
Drawers      = 3;  // fronts up the face — a two- or three-drawer pedestal

// Magnet pockets in the bottom face (0 = none). One central pocket: the piece is small
// enough that it does not need a second to stop it pivoting, and it goes in the plinth —
// the footprint that really meets the board (see unit_plinth_d() and Magnet_* in
// lib/common.scad). The 40 cm width is 10 mm at 1:40 — wide enough for a 4 mm disc.
Magnets = 1;

filing_cabinet();

module filing_cabinet() {
    difference() {
        base_unit(Width, Depth, Print_h, Top_h);
        if (Show_drawers)
            unit_fronts(Width, Depth,
                        unit_face_z0(Width, Depth, Print_h, Top_h),
                        unit_face_z1(Width, Depth, Print_h, Top_h),
                        1, Drawers, Top_h);
        if (Magnets > 0)
            magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}
