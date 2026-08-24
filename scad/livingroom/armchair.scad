// livingroom / armchair — a one-seat token: a raised back cushion along the rear
// edge and an arm cushion down each side, the single-seat sibling of the sofa.
//
// Width/Depth are the real-world footprint in cm: a compact one-seat armchair,
// close enough to square that the back and arm cushions below are what tell the
// front from the back on the plan, not the outline. The heights are real cm too:
// Height is the top of the back — how tall the chair is — Arm the top of the arms
// and Seat the seat they rise from. The block is the seat; the cushions stand the
// rest on top of it (see printed_h() / rise() in lib/common.scad).

include <../lib/common.scad>

Width  = 80;  // cm
Depth  = 80;  // cm
Height = 80;  // cm — top of the back cushion
Arm    = 62;  // cm — top of the arms
Seat   = 42;  // cm — seat height

// printed mm: the seat block the cushions stand on, and how far (cm) the back and
// the arms rise off it to reach Height / Arm
Seat_z = printed_h(Seat);
Pad_h  = Height - Seat;
Arm_h  = Arm - Seat;

Show_cushions = true;
// Back and arm cushions, in real-world cm — a backrest along the rear edge (+Y)
// and an arm rail down each side, narrowed to whatever the seat leaves between
// them (as bed.scad narrows its pillows with Pillow_gap).
Back_d      = 14;  // back cushion depth (front-to-back)
Arm_w       = 10;  // arm cushion width (side-to-side)
Cushion_gap = 4;    // seat left around and between the cushions
// One central magnet pocket in the bottom face: the seat is small and near-square
// (80 cm is 20 mm at 1:40), so a single pocket already stops it pivoting; see
// Magnet_* in lib/common.scad.
Magnets = 1;

armchair();

module armchair() {
    // the back cushion sits between the two arms, with a gap to each
    back_w = Width - 2 * Arm_w - 4 * Cushion_gap;
    back_y = Depth / 2 - Cushion_gap - Back_d / 2;
    // the arms run the depth of the seat, inset from the front and back edges
    arm_d  = Depth - 2 * Cushion_gap;
    arm_x  = Width / 2 - Cushion_gap - Arm_w / 2;
    union() {
        difference() {
            footprint(Width, Depth, Seat_z);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_cushions) {
            // back cushion along the rear edge
            translate([0, cm(back_y), 0])
                cushion(back_w, Back_d, Seat_z, Pad_h);
            // an arm cushion down each side
            for (s = [-1, 1])
                translate([cm(s * arm_x), 0, 0])
                    cushion(Arm_w, arm_d, Seat_z, Arm_h);
        }
    }
}
