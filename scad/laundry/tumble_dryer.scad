// laundry / tumble_dryer — a front-loading tumble dryer token, the washing
// machine's near-twin: a round porthole door on its FRONT (-Y) face under a slim
// control fascia. No detergent drawer — that is the washer's, and leaving it off is
// what tells the two 60x60 laundry boxes apart. The door and fascia are cut into the
// front face; see appliance_front() in lib/common.scad.
//
// Width/Depth are the real-world footprint in cm: a standard front-loading dryer is
// 60 cm square. Height is the real height of the case — the same 85 cm as the washer
// it stacks on — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad).
//
// The front is the -Y edge; rotate the piece on the board to face it into the room.

include <../lib/common.scad>

Width  = 60;  // cm
Depth  = 60;  // cm
Height = 85;  // cm — the case, as the washer below it

Print_h = printed_h(Height);   // printed height, mm — Height at the plan scale

// The door + fascia on the front (-Y) face; no detergent drawer. See
// appliance_front() in lib/common.scad for the proportions.
Show_front = true;

// Magnet pockets in the bottom face (0 = none). See washing_machine.scad.
Magnets = 1;

tumble_dryer();

module tumble_dryer() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_front)
            appliance_front(Width, Depth, 0, Print_h, drawer = false);
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}
