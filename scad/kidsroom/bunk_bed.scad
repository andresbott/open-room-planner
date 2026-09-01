// kidsroom / bunk_bed — two single beds stacked into one frame: a lower mattress deck
// near the floor, an upper mattress deck above it, and the OPEN sleeping gap between
// them — which is the whole point of a bunk and the one thing the old token threw away.
//
// It used to be a plain footprint() box with the ladder and the size ENGRAVED ON THE TOP
// FACE: a labelled brick, exactly what a token must not be (a bunk is unmistakable by its
// two levels, so it needs no size on it, and a ladder is a thing you climb, not a line
// drawn on a lid). This models the form instead. The long side of the bed is the FRONT
// (-Y) face — the side you climb in from and the side a low camera sees — and the two
// sleeping spaces are cut into it as deep recesses back to a solid panel, the way
// livingroom/bookshelf.scad carves its shelves: solid end frames left at each side, a
// back panel left at +Y, a base under the lower bunk, a deck slab between the bunks and a
// frame rail across the top. Each bunk is then fitted with a mattress slab on its deck and a
// front side rail — taller on the upper bunk, a guard rail — so an open bay reads as a bed and
// not a shelf. The ladder is real relief — recessed rungs cut into the
// front of the end frame at one end, like pool.scad's Kind=ladder flight — not ink.
//
// The under-bunk space is a RECESS in a vertical face, NOT open air: an upper deck left
// cantilevering over true air would have to bridge the length of the bed. Cut back to the
// +Y panel it is a short ceiling instead, and every divider is a plain wall.
//
// PRINTS ON ITS BACK — the -Y front face laid flat on the bed, like bookshelf.scad. Upright,
// each deck's underside and the roof of each sleeping gap would be an unsupported overhang;
// on its back every deck stands as a vertical wall, every gap opens straight up, and nothing
// bridges. The model itself is authored the right way up (bottom on z = 0, magnet pockets
// opening down); tip it onto its back in the slicer.
//
// Front elevation (-Y face, the side you see), X across, Z up; ladder end at +X:
//
//     |======================|####|   the top frame rail (Height is over it) · ladder
//     |                      |####|   rungs cut into the end frame's front ...
//     |    upper bunk gap    |####|   ... open sleeping space, recessed to the +Y panel
//     |______________________|####|
//     |    upper deck slab    ####|   the upper mattress
//     |----------------------|    |
//     |    lower bunk gap     |   |   open sleeping space, the lower mattress at its floor
//     |______________________|   |
//     |  base / lower deck (carries the magnets)  |
//     |__________________________________________|
//
// Width/Length are the real single-bed footprint in cm (90 x 200): Length runs along the
// wall (its long -Y side faces the room), Width is how far it reaches into the room. Height
// is the real height over the top frame rail, shrunk by the plan scale like the footprint
// (printed_h() in lib/common.scad), so a bunk stands as tall as a wardrobe on a bed's
// footprint — which is what a bunk is. The two sleeping gaps share whatever height is left
// once the base, deck and top rail have taken theirs; if a squashed Height leaves too little
// they are clamped and the render log says so.

include <../lib/common.scad>

Width  = 90;   // cm — single-bed width (reaches into the room, +Y is the wall side)
Length = 200;  // cm — single-bed length (runs along the wall; its -Y side faces the room)
Height = 165;  // cm — over the top frame rail

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_gaps   = true;   // the two open sleeping spaces (a plain solid frame without them)
Show_ladder = true;   // recessed rungs up the front of one end frame

// The frame, in real cm. The two end frames are full-depth, full-height panels — the corner
// posts that carry both decks; the ladder lives on the wider one. The back panel is left at
// +Y so the piece butts a wall and the sleeping gaps have a wall to stop against, not open
// air. The base is the solid lower deck (the lower mattress and the block that buries the
// magnets); the deck slab is the upper mattress; the top rail closes the frame.
End_w      = 14;   // cm — the plain end frame (-X): a solid bed end
Ladder_end = 40;   // cm — the end frame that carries the ladder (+X), so rungs cut solid
Back_w     = 8;    // cm — back panel left at +Y
Base_h     = 30;   // cm — floor to the lower mattress (a solid base, over the magnets)
Deck_th    = 15;   // cm — the upper deck slab (mattress + frame)
Top_rail   = 10;   // cm — the top frame rail that closes the frame (Height is over it)
Gap_ratio  = 0.52; // share of the leftover height the LOWER gap gets (the rest is the upper)

// Each bunk carries a real bed and not an empty shelf bay: a mattress slab lying on its deck
// and a front side rail standing over it — the upper bunk's rail taller, a guard rail. Real cm.
Matt_h     = 11;  // cm — a mattress lying on each deck
Rail_h     = 20;  // cm — the lower bunk's front side rail (stands clear over the mattress)
Guard_h    = 32;  // cm — the upper bunk's tall front guard rail (a bunk's safety rail)
Rail_depth = 6;   // cm — how deep the front rail runs back from the front (-Y) face

// The ladder, in real cm: a stack of rungs cut into the front (-Y) face of the +X end frame,
// from a little off the floor up to the upper mattress. It is relief, not a spike — grab
// rails and round-topped ladders are 1 mm loops over air at 1:40 (see pool.scad), so the
// rungs ARE the ladder, cut as grooves that print clean whichever way up.
Ladder_w     = 30;  // cm — the rungs' width (inside the ladder end frame)
Ladder_depth = 6;   // cm the rungs are recessed into the front face
Ladder_rungs = 5;   // rungs from the lift up to the top bunk
Ladder_lift  = 6;   // cm the lowest rung sits off the floor

// Magnet pockets in the bottom face, in a row along the length (0 = none). Two keep the piece
// from pivoting; the base is the whole footprint, so the row has the run of it (Magnet_* in
// lib/common.scad). The base keeps Base_h of material over the pockets.
Magnets = 2;

// ---- the levels the frame divides into, printed mm from the floor -------------
// The base, the deck slab and the top rail take their real heights; the two sleeping gaps
// split whatever is left, by Gap_ratio. Working in rise() keeps every share honest under
// Height_scale, and the leftover can only be positive (the three solid bands are shorter
// than the whole piece at any scale), so the gaps always get room — thin at a hard squash,
// which the render warns about.
function fixed_h()   = rise(Base_h) + rise(Deck_th) + rise(Top_rail);
function free_h()    = max(0, Print_h - fixed_h());
function lower_gap() = free_h() * Gap_ratio;
function upper_gap() = free_h() * (1 - Gap_ratio);
function z_lmatt()   = rise(Base_h);                 // lower mattress top / lower gap floor
function z_udeck0()  = z_lmatt() + lower_gap();      // upper deck underside / lower gap roof
function z_umatt()   = z_udeck0() + rise(Deck_th);   // upper mattress top / upper gap floor
function z_utop()    = z_umatt() + upper_gap();      // top rail underside / upper gap roof
// The sleeping width left between the two end frames, real cm (the mattress runs along it).
function inner_w()   = Length - End_w - Ladder_end;
// The depth a gap reaches, real cm: the whole width bar the back panel.
function gap_depth() = Width - Back_w;

bunk_bed();

module bunk_bed() {
    if (Show_gaps && (inner_w() <= 0 || gap_depth() <= 0))
        echo(str("WARNING: a ", Length, "x", Width, " cm bunk at 1:", Scale,
                 " has no room between its ", End_w, "+", Ladder_end,
                 " cm end frames / behind its ", Back_w,
                 " cm back panel — sleeping gaps skipped"));
    else if (Show_gaps && min(lower_gap(), upper_gap()) < Symbol_stroke)
        echo(str("WARNING: a ", Height, " cm bunk at 1:", Scale, " leaves only ",
                 rise_cm(free_h()), " cm over its base, deck and top rail for two sleeping",
                 " gaps — the openings came out too thin and were skipped (give it more:",
                 " BUNK_BED_H)"));
    union() {
        difference() {
            footprint(Length, Width, Print_h);
            if (Show_gaps && lower_gap() >= Symbol_stroke) gap_cut(z_lmatt(), z_udeck0());
            if (Show_gaps && upper_gap() >= Symbol_stroke) gap_cut(z_umatt(), z_utop());
            if (Show_ladder) ladder_cut(rise(Ladder_lift), z_umatt());
            if (Magnets > 0) magnets(Length, Width, Magnets);
        }
        // fit each open bunk with a real bed — a mattress and a front rail — so it reads as
        // somewhere you sleep and not as an empty shelf bay (the upper gets the taller guard)
        if (Show_gaps && lower_gap() >= Symbol_stroke) bunk_furniture(z_lmatt(), lower_gap(), Rail_h);
        if (Show_gaps && upper_gap() >= Symbol_stroke) bunk_furniture(z_umatt(), upper_gap(), Guard_h);
    }
}

// A bunk fitted with a bed: a mattress slab lying on the deck at <z_deck> (full width between
// the end frames, deep to the +Y back panel) and a front side rail <rail_h> cm tall standing at
// the -Y face over it. Both sit on the solid deck below and reach into the frame, so they add
// mass to the open bay with no floating part and print on the back like the rest (see header);
// each is clamped to the gap so the sleeping space stays open above them.
module bunk_furniture(z_deck, gap_h, rail_h) {
    if (inner_w() > 0 && gap_depth() > 0 && gap_h > 0) {
        xc   = (End_w - Ladder_end) / 2;              // centre of the inner span, real cm
        matt = min(rise(Matt_h), gap_h * 0.55);       // mattress, clamped to leave headroom
        rh   = min(rise(rail_h), gap_h * 0.9);        // rail, clamped to the opening
        rd   = min(cm(Rail_depth), cm(gap_depth()));
        y0   = -cm(Width) / 2;                        // the mattress: flush front to back panel
        y1   =  cm(Width) / 2 - cm(Back_w);
        translate([cm(xc), (y0 + y1) / 2, z_deck + matt / 2])
            cube([cm(inner_w()), y1 - y0, matt], center = true);
        translate([cm(xc), -cm(Width) / 2 + rd / 2, z_deck + rh / 2])   // the front rail
            cube([cm(inner_w()), rd, rh], center = true);
    }
}

// One sleeping gap: a slot cut into the front (-Y) face over printed-mm heights <za>..<zb>,
// spanning the width between the two end frames and reaching back to the +Y panel. Its mouth
// runs a hair past the front face so it opens clean; its far wall stops Back_w short of the
// back, so the panel is left whole. A recess in a vertical face — a short ceiling that prints
// as a wall on its back — never open air (see the header).
module gap_cut(za, zb) {
    if (inner_w() > 0 && gap_depth() > 0 && zb - za > 0) {
        xc      = (End_w - Ladder_end) / 2;              // centre of the inner span, real cm
        y_front = -cm(Width) / 2 - 0.1;                  // a hair past the front face
        y_back  =  cm(Width) / 2 - cm(Back_w);           // stop at the back panel
        translate([cm(xc), (y_front + y_back) / 2, (za + zb) / 2])
            cube([cm(inner_w()), y_back - y_front, zb - za], center = true);
    }
}

// The ladder: <n> rungs cut into the front (-Y) face of the +X end frame, evenly stacked
// over printed-mm heights <z0>..<z1>, each a groove half the pitch tall so the solid left
// between them reads as the rung you climb. Clamped to the end frame it sits on, so it can
// never cut past it into the sleeping gap; a groove finer than the pen is skipped.
module ladder_cut(z0, z1) {
    n   = max(1, Ladder_rungs);
    lw  = min(cm(Ladder_w), cm(Ladder_end) - 2 * Symbol_margin);   // fit inside the frame
    dep = cm(Ladder_depth);
    bx  = cm(Length) / 2 - cm(Ladder_end) / 2;          // centre of the ladder end frame
    pitch = (z1 - z0) / n;
    gh    = pitch * 0.5;
    if (lw >= Symbol_stroke && gh >= Symbol_stroke && dep > 0)
        for (i = [0 : n - 1])
            translate([bx, -cm(Width) / 2 - 0.1 + (dep + 0.1) / 2, z0 + pitch * (i + 0.5)])
                cube([lw, dep + 0.1, gh], center = true);
    else
        echo(str("NOTE: a ", Ladder_w, " cm ladder at 1:", Scale,
                 " came out finer than the pen — rungs skipped"));
}
