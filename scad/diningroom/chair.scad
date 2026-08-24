// diningroom / chair — a dining chair token: a seat block with a raised
// backrest hint along the rear edge, and a thin seat pad in front of it.
//
// Width/Depth are the real-world seat footprint in cm. The heights are real cm
// too: Height is the top of the backrest — how tall the chair is — and Seat the
// seat it rises from. The block is the seat; the backrest stands the rest on top of
// it (see printed_h() / rise() in lib/common.scad).

include <../lib/common.scad>

Width  = 45;  // cm
Depth  = 45;  // cm
Height = 90;  // cm — top of the backrest
Seat   = 45;  // cm — seat height

// the printed height of the seat block, mm — the backrest stands the rest on it
Seat_z = printed_h(Seat);

Show_back = true;
// Backrest along the rear edge (+Y), real-world cm — narrower than the seat and
// set back from the edge, the way a chair's back rail sits inside its footprint.
// It rises the whole way from the seat to Height, so the back reads far taller than
// the seat pad from a low angle.
Back_w   = 34;
Back_d   = 16;
Back_gap = 2;
Back_h   = Height - Seat;

Show_seat = true;
// A thin seat pad filling the front of the seat, stopping just short of the
// backrest — real cm, a hand's thickness of upholstery, so it reads as a separate
// part of the same chair and not as a second backrest.
Seat_w   = 34;
Seat_d   = 22;
Seat_gap = 4;
Seat_h   = 3;

// Magnet pockets in the bottom face (0 = none). A 45 cm square is 11.25 mm across
// at 1:40 — comfortably wide enough for a 4 mm disc.
Magnets = 1;

chair();

module chair() {
    // both pads sit centred on X, offset along Y: the seat toward the front
    // (-Y), the backrest toward the rear (+Y), each kept off its edge by a gap.
    back_y =  (Depth / 2 - Back_gap - Back_d / 2);
    seat_y = -(Depth / 2 - Seat_gap - Seat_d / 2);
    union() {
        difference() {
            footprint(Width, Depth, Seat_z);
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_seat)
            translate([0, cm(seat_y), 0])
                cushion(Seat_w, Seat_d, Seat_z, Seat_h);
        if (Show_back)
            translate([0, cm(back_y), 0])
                cushion(Back_w, Back_d, Seat_z, Back_h);
    }
}
