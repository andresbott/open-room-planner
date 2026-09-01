// hobby / treadmill — a running machine: a low deck with a belt sunk down its middle between
// two side rails, and a tall console standing at the back where the display and handrails are.
// Those are the two things that say treadmill and not "another low slab" (a bench, a bed): the
// BELT is a real recess with slats across it, not a rectangle drawn on top, and the CONSOLE is a
// board that stands up out of the deck the way the dressing table's mirror does (cushion() in
// lib/common.scad), tall enough to read from across the table.
//
// The belt runs down the −Y..+Y length between raised side rails, with the slats cut ACROSS it
// (the way the tread of a belt lies, and the way a low angle reads a running surface). The
// console stands at the +Y (back) end so it does not hide the belt, and its display is a recess
// on the −Y face — pointing at the runner, which is also where a low angle sees it. No handrail
// bars stand off it: a rail at 1:40 is a thin spike that snaps (§1.3), so the console is one
// board and the rails are the raised deck edges, both cut-and-relief rather than protrusions.
//
// It prints the right way up with nothing to support: the deck is a solid slab, the belt a recess
// that opens upward (vertical walls, no overhang), and the console a tapered board that leans in
// as it rises (cushion()'s draft), so every layer lands on the one below. The magnet pockets sit
// in the deck floor under the belt.
//
// Width/Depth are the real-world footprint in cm — a treadmill is about 85 x 200 — and Height the
// real height of the DECK (the running surface stands ~15-20 cm off the floor), shrunk by the
// plan scale (see printed_h() in lib/common.scad); the console stands its own real height on top,
// the way the dressing table's mirror does.

include <../lib/common.scad>

Width  = 85;   // cm — across the deck
Depth  = 200;  // cm — the length (the run)
Height = 18;   // cm — the deck (the running surface height); the console rises above it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// -- The belt -----------------------------------------------------------------
Show_belt = true;
Belt_w      = 50;  // cm — the belt, narrower than the deck so a side rail is left each side
Belt_depth  = 3;   // cm the belt is sunk below the rails
Belt_end    = 8;   // cm of rail left at the front end (and before the console) round the belt
// The slats across the belt, standing in for the tread of the running surface.
Slat_pitch  = 12;  // cm from one slat to the next ...
Slat_groove = 3;   // ... the slot cut for each ...
Slat_cut    = 1;   // ... and cm deeper than the belt floor it goes

// -- The console --------------------------------------------------------------
Show_console = true;
Console_w     = 72;   // cm — the board across the back, narrower than the deck
Console_d     = 12;   // cm — board depth (front-to-back); thick enough to stand sturdily (3 mm)
Console_h     = 115;  // cm the board stands above the deck (~130 cm overall)
Console_taper = 1;    // printed mm the board pulls in toward the top (draft) — a tall thin panel
Console_r     = Corner_radius;
// The display, a recess in the console's front (−Y) face — where the runner reads it.
Disp_w      = 0.55;  // fraction of the console width
Disp_h      = 0.22;  // fraction of the console height
Disp_centre = 0.62;  // height of the display centre, 0..1 up the board
Disp_cut    = 0.6;   // printed mm the display is sunk into the face (plus the board's taper)

// Magnet pockets in the bottom face (0 = none), in a row along the length. Two keep the deck
// from pivoting; they sit in the deck floor under the belt (see Magnet_* in lib/common.scad).
Magnets = 2;

// ---- belt extent, real cm ---------------------------------------------------
function belt_y0()  = -Depth / 2 + Belt_end;                 // the front of the belt ...
function belt_y1()  =  Depth / 2 - Console_d - Belt_end;     // ... and its back, before the console
function belt_cy()  = (belt_y0() + belt_y1()) / 2;
function belt_len() = belt_y1() - belt_y0();

treadmill();

module treadmill() {
    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            if (Show_belt && belt_len() > 0) belt();
            if (Magnets > 0) magnets(Width, Depth, Magnets);
        }
        if (Show_console) console();
    }
}

// The belt: a recessed channel down the middle of the deck with slats cut across its floor.
module belt() {
    translate([0, cm(belt_cy()), Print_h - rise(Belt_depth)])
        linear_extrude(height = rise(Belt_depth) + 0.1)
            footprint_2d(Belt_w, belt_len());
    if (Slat_pitch > 0) belt_slats();
}

// The slats: slots across the belt (parallel to the deck's width), spaced down the run and kept
// off the belt ends — what is left standing between them is the tread.
module belt_slats() {
    usable = belt_len() - 2 * Belt_end / 2;
    n      = max(1, floor(usable / Slat_pitch) + 1);
    span   = (n - 1) * Slat_pitch;
    z      = Print_h - rise(Belt_depth) - rise(Slat_cut);
    for (i = [0 : n - 1]) {
        y = cm(belt_cy()) + cm(n > 1 ? -span / 2 + i * Slat_pitch : 0);
        translate([-cm(Belt_w) / 2, y - cm(Slat_groove) / 2, z])
            cube([cm(Belt_w), cm(Slat_groove), rise(Belt_depth) + rise(Slat_cut) + 0.1]);
    }
}

// The console: a tapered board standing on the back of the deck, with the display recessed into
// its front (−Y) face — the dressing table's mirror, squared off for a screen.
module console() {
    cy     = Depth / 2 - Console_d / 2;                  // board centre, real cm
    face_y = cm(cy) - cm(Console_d) / 2;                 // its front face
    difference() {
        translate([0, cm(cy), 0])
            cushion(Console_w, Console_d, Print_h, Console_h, Console_taper, Console_r);
        translate([-cm(Console_w) * Disp_w / 2, face_y - 0.1,
                   Print_h + rise(Console_h) * Disp_centre - rise(Console_h) * Disp_h / 2])
            cube([cm(Console_w) * Disp_w, Disp_cut + Console_taper + 0.1,
                  rise(Console_h) * Disp_h]);
    }
}
