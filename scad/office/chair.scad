// office / chair — a swivel office-chair token: a round seat with a small raised
// back cushion marking the rear (+Y) edge, reading as a chair back from a low
// angle.
//
// Diameter is the real-world seat/base footprint in cm — a swivel chair base runs
// around 50 cm across. The heights are real cm: Height is the top of the backrest —
// how tall the chair is — and Seat the seat it rises from. The block is the seat;
// the back stands the rest on top of it (see printed_h() / rise() in
// lib/common.scad).

include <../lib/common.scad>

Diameter = 50;  // cm
Height   = 95;  // cm — top of the backrest
Seat     = 47;  // cm — seat height, wound up to desk height

// the printed height of the seat block, mm — the backrest stands the rest on it
Seat_z = printed_h(Seat);

Show_back = true;
// The back cushion, in real-world cm, set back from the rim so its raised corners
// stay inside the round seat. cushion() tapers it, so it prints without support.
Back_w   = 20;  // cm
Back_d   = 8;   // cm
Back_gap = 5;   // cm kept between the pad and the rim
Back_h   = Height - Seat;
// Magnet pockets in the bottom face (0 = none). A round base is the same in every
// direction, so it only needs one central pocket; 50 cm is 12.5 mm across at
// 1:40 — enough for one 4 mm disc with its required insets, see Magnet_* in
// lib/common.scad.
Magnets = 1;

chair();

module chair() {
    r  = Diameter / 2;
    py = r - Back_gap - Back_d / 2;  // back cushion centre, toward the rear (+Y) edge
    union() {
        difference() {
            footprint_round(Diameter, Seat_z);
            if (Magnets > 0)
                magnets(Diameter, Diameter, Magnets);
        }
        // the raised back reads as a chair back from a low angle
        if (Show_back)
            translate([0, cm(py), 0])
                cushion(Back_w, Back_d, Seat_z, Back_h);
    }
}
