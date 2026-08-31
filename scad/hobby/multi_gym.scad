// hobby / multi_gym — a multi-station weight machine: a tall frame with a WEIGHT STACK at one
// end and a seat in front of it. The stack is what says "gym" and nothing else — a column of
// plates, drawn as real horizontal relief on its front face, not a grid engraved on top — so it
// is the tallest, most-detailed thing on the piece and the first a low angle lands on. Around it:
// a frame wall braces the stack and carries a top bar (the high pulley), and a seat with a back
// sits out front where you work.
//
// It is deliberately NOT a wardrobe, which its silhouette could drift toward: the frame's face is
// sunk to a recessed field (a rack, not a slab), the stack stands PROUD of it as its own column,
// and the seat breaks the front. What tells it apart at a glance is the stack's plate lines and
// the seat.
//
// No cables, no pulleys, no press arms: a bar or a cable at 1:40 is a thread that will not print
// and snaps if it does (§1.3), so the machine is its masses and its frame — the parts with real
// bulk — and the working bits are left to the imagination, the way the washbasin leaves off its
// tap. Everything prints the right way up with nothing to support: the frame and stack are solid
// columns rising straight from the floor, the top bar sits ON the frame (carried, not bridged),
// the plate lines and the frame's field are shallow recesses in vertical faces, and the seat pad
// is a tapered cushion. The magnet pockets sit under the frame wall — the broad base at the back.
//
// Width/Depth are the real-world footprint in cm — a home multi-gym is about 110 x 95 — and
// Height its real overall height (a tall frame, ~210 cm), shrunk by the plan scale (see
// printed_h() in lib/common.scad). The seat and the stack are real heights within that.

include <../lib/common.scad>

Width  = 110;  // cm — across
Depth  = 95;   // cm — front-to-back
Height = 210;  // cm — the overall frame height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// -- The frame ----------------------------------------------------------------
// A wall across the back that braces the stack and stands the machine up. Deep enough at 1:40
// (6.5 mm) to bury a full magnet, so it is the base the pockets go in.
Frame_d = 26;   // cm — the frame's depth (front-to-back)
Frame_h = 140;  // cm — how tall the frame wall stands (the stack rises above it)
Show_frame_field = true;
Frame_field = 8;  // cm border left round a recessed field on the frame face — a rack, not a slab

Show_bar = true;
Bar_h    = 16;  // cm — the top bar (high pulley housing) sitting on the frame ...
Bar_gap  = 8;   // ... inset this far from each end of the frame

// -- The weight stack ---------------------------------------------------------
Stack_w    = 40;   // cm — the stack column, across ...
Stack_d    = 32;   // ... and front-to-back (it stands proud of the frame) ...
Stack_h    = 195;  // ... and how tall it rises (above the frame wall)
Stack_edge = 7;    // cm in from the left edge the stack sits
Show_plates = true;
Plate_top   = 150;  // cm up the stack the plates reach ...
Plate_n     = 9;    // ... how many are in it ...
Plate_line  = 2;    // ... the cm of face each gap between plates takes ...
Plate_cut   = 0.5;  // ... and the printed mm it is cut in (drawing detail, does not scale)
Plate_margin = 3;   // cm kept off the sides of the stack face

// -- The seat station ---------------------------------------------------------
Show_seat = true;
Seat_x  = 10;   // cm right of centre the seat sits (clear of the stack on the left)
Seat_y  = 5;    // cm — the seat back's position front-to-back (the seat sticks out in front)
Seat_w  = 48;   // cm — the seat ...
Seat_d  = 44;   // ...
Seat_h  = 48;   // ... at this real height ...
Seat_cush = 7;  // ... with a cushion this proud
Back_w  = 46;   // cm — the backrest board, across ...
Back_d  = 12;   // ... its thickness ...
Back_h  = 52;   // ... and how far it rises above the seat

// Magnet pockets in the bottom face (0 = none), in a row along the width. They sit under the
// frame wall — the broad base at the back — so the disc is chosen and placed on the face that
// really meets the board (see Magnet_* in lib/common.scad). Two keep a wide piece from pivoting.
Magnets = 2;

// ---- placement, real cm -----------------------------------------------------
function frame_cy() = Depth / 2 - Frame_d / 2;                 // frame wall centre
function stack_cx() = -Width / 2 + Stack_edge + Stack_w / 2;   // stack centre
function stack_cy() = Depth / 2 - Stack_d / 2;
function stack_face_y() = Depth / 2 - Stack_d;                 // the stack's front (−Y) face

multi_gym();

module multi_gym() {
    union() {
        difference() {
            frame();
            if (Show_frame_field) frame_field();
            if (Magnets > 0)
                translate([0, cm(frame_cy()), 0]) magnets(Width, Frame_d, Magnets);
        }
        if (Show_bar) bar();
        difference() {
            weight_stack();
            if (Show_plates) plates();
        }
        if (Show_seat) seat_station();
    }
}

// The frame wall across the back.
module frame() {
    translate([0, cm(frame_cy()), 0]) footprint(Width, Frame_d, rise(Frame_h));
}

// A recessed field in the frame's front (−Y) face, so it reads as a rack and not a solid slab.
module frame_field() {
    translate([0, cm(frame_cy() - Frame_d / 2) - 0.1, rise(Frame_h) / 2])
        cube([cm(Width - 2 * Frame_field), Front_relief + 0.1,
              rise(Frame_h) - 2 * rise(Frame_field)], center = true);
}

// The top bar, sitting on the frame wall — the high pulley housing. Carried by the wall, so it
// prints without bridging.
module bar() {
    translate([0, cm(frame_cy()), rise(Frame_h)])
        footprint(Width - 2 * Bar_gap, Frame_d, rise(Bar_h));
}

// The weight stack: a column standing proud of the frame at the left, rising above it.
module weight_stack() {
    translate([cm(stack_cx()), cm(stack_cy()), 0])
        footprint(Stack_w, Stack_d, rise(Stack_h));
}

// The plates: horizontal grooves down the stack's front (−Y) face, Plate_n of them up to
// Plate_top — the masses you pin the pin into.
module plates() {
    top = rise(Plate_top);
    for (i = [1 : Plate_n - 1]) {
        z = top * i / Plate_n;
        translate([cm(stack_cx()) - cm(Stack_w - 2 * Plate_margin) / 2,
                   cm(stack_face_y()) - 0.1, z - rise(Plate_line) / 2])
            cube([cm(Stack_w - 2 * Plate_margin), Plate_cut + 0.1, rise(Plate_line)]);
    }
}

// The seat station: a backrest board rising from the floor with the seat slung in front of it,
// a cushion on top — a chair, in front of the frame, where you sit to press.
module seat_station() {
    back_y = Seat_y;
    seat_y = back_y - Back_d / 2 - Seat_d / 2;
    translate([cm(Seat_x), cm(back_y), 0])                     // the backrest board
        footprint(Back_w, Back_d, rise(Seat_h + Back_h));
    translate([cm(Seat_x), cm(seat_y), 0]) {                   // the seat, in front
        footprint(Seat_w, Seat_d, rise(Seat_h));
        cushion(Seat_w, Seat_d, rise(Seat_h), Seat_cush);
    }
}
