// bedroom / bed — a made bed: a headboard standing at the head end, the pillows in front of
// it and the duvet raised over the rest of the mattress, with the size engraved on the duvet.
//
// In section, along the bed (the head end, +Y, on the right):
//
//                          ____        the headboard, its field sunk on BOTH faces so it
//        ______________   |    |       reads as a frame from either side ...
//    ___/              \__|    |       ... the pillows, standing highest ...
//   |     the duvet        |   |       ... the duvet over the rest of the mattress ...
//   |______________________|___|       ... the mattress, which is the footprint
//
// It used to be the mattress and the pillows alone: a 40 x 50 x 12.5 mm slab with two pads on
// it, which read as a bed from above and as a doorstop from the side. The headboard is what a
// bed is recognised by in a room, and the duvet is what makes the mattress read as made
// rather than as a plinth — both are real, and both print the right way up: the board rises
// straight from the mattress, the duvet and the pillows are cushion() pads that taper, and
// the board's two field recesses leave a solid web between them.
//
// The size goes on the DUVET, not on the mattress: the duvet covers the part of the mattress
// the label used to sit on, and its top is now the biggest flat surface on the piece.
//
// Width/Length are the real-world mattress size in cm (IKEA naming, e.g. 160x200) and the
// footprint the plan is drawn from — the headboard stands inside the head end of it, as a real
// frame's does beyond the mattress, so the number engraved on the piece is still the number
// you plan with. Height is the real height of the made bed — the top of the mattress, the
// surface you sit on — shrunk by the plan scale like the footprint (see printed_h() in
// lib/common.scad), so a bed is one of the lowest pieces of the set.

include <../lib/common.scad>

Width  = 160;  // cm
Length = 200;  // cm
Height = 50;   // cm — top of the mattress

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_head = true;
// The headboard, in real cm: a panel across the head end (+Y), flush with the edge, rising
// Head_h above the mattress — about 95 cm off the floor all told, where a real one is. Its
// field is sunk from the front and the back, so a bed standing away from the wall reads the
// same from behind (see back_recess() in lib/common.scad).
Head_d      = 12;   // cm of the length the board takes
Head_h      = 45;   // cm it stands above the mattress
Head_stile  = 10;   // cm of frame left at each side of the sunken field ...
Head_rail_b = 5;    // ... under it ...
Head_rail_t = 6;    // ... and over it
Head_cut    = 0.6;  // mm the field is sunk into each face of the board
Head_r      = Corner_radius;  // corner rounding of the board

Show_pillows = true;
// Pillows at the head end, in real cm — an IKEA 80x50 one, narrowed to whatever the mattress
// leaves, standing Pillow_h proud of it. They are the tallest thing on the bed, so they read
// over the duvet.
Pillow_w   = 80;
Pillow_d   = 50;
Pillow_gap = 4;   // mattress left around and between the pillows
Pillow_h   = 10;
// Mattresses this wide (cm) get two pillows instead of one.
Pillow_pair_from = 120;

Show_duvet = true;
// The duvet, in real cm: a pad over the rest of the mattress, a hand lower than the pillows,
// with a rim of mattress showing round it — which is the sheet, and what keeps the duvet from
// reading as a second slab at the full footprint.
Duvet_h   = 6;
Duvet_rim = 4;   // cm of mattress left at the sides and the foot
Duvet_gap = 3;   // cm between the duvet and the pillows

Show_label = true;

// Magnet pockets in the bottom face, in a row along the length (0 = none). Two keep the piece
// from pivoting on the board; the bottom face is the whole footprint, so the row has the run
// of it (see Magnet_* in lib/common.scad).
Magnets = 2;

// ---- what the mattress is divided into --------------------------------------
// The mattress in front of the headboard: its +Y edge, real cm from the centre.
function mattress_back() = Length / 2 - (Show_head ? Head_d : 0);
// The pillows: how many, how wide each, and where their centres sit.
function pillows()  = Width >= Pillow_pair_from ? 2 : 1;
function pillow_w() = min(Pillow_w, (Width - (pillows() + 1) * Pillow_gap) / pillows());
function pillow_cy() = mattress_back() - Pillow_gap - Pillow_d / 2;
function pillow_cx(i) = (i - (pillows() - 1) / 2) * (pillow_w() + Pillow_gap);
// The duvet: from the foot to just short of the pillows, with a rim left all round.
function duvet_back()  = (Show_pillows ? pillow_cy() - Pillow_d / 2 - Duvet_gap
                                       : mattress_back() - Duvet_rim);
function duvet_front() = -Length / 2 + Duvet_rim;
function duvet_d()  = max(0, duvet_back() - duvet_front());
function duvet_cy() = (duvet_back() + duvet_front()) / 2;
function duvet_w()  = max(0, Width - 2 * Duvet_rim);
// The face the size is engraved on: the top of the duvet, or the mattress without one.
function label_z() = Show_duvet && duvet_d() > 0 ? Print_h + rise(Duvet_h) : Print_h;

bed();

module bed() {
    txt = str(Width, "x", Length);
    // the patch the label has: the duvet's top, or the same stretch of bare mattress in
    // front of the pillows when there is no duvet — either way it is the piece's widest
    // clear surface
    patch_w = Show_duvet && duvet_d() > 0 ? cm(duvet_w()) : cm(Width);
    size = label_size(patch_w - 2 * Symbol_margin, cm(duvet_d()) - 2 * Symbol_margin, txt);
    difference() {
        union() {
            footprint(Width, Length, Print_h);
            if (Show_head) head();
            if (Show_duvet && duvet_d() > 0)
                translate([0, cm(duvet_cy()), 0])
                    cushion(duvet_w(), duvet_d(), Print_h, Duvet_h);
            if (Show_pillows)
                for (i = [0 : pillows() - 1])
                    translate([cm(pillow_cx(i)), cm(pillow_cy()), 0])
                        cushion(pillow_w(), Pillow_d, Print_h, Pillow_h);
        }
        if (Show_label && size >= Symbol_min)
            translate([0, cm(duvet_cy()), 0]) label(txt, label_z(), size);
        if (Show_head) head_field();
        if (Magnets > 0)
            magnets(Width, Length, Magnets);
    }
}

// The headboard: a panel across the head end, standing straight up off the mattress.
module head() {
    translate([0, cm(Length / 2 - Head_d / 2), Print_h - 0.01])
        linear_extrude(height = rise(Head_h) + 0.01)
            footprint_2d(Width, Head_d, Head_r);
}

// Its sunken field, cut into both faces: what is left standing is a stile each side, a rail
// under it and a deeper one over it — the same frame the dining chair's back gets, at bed
// scale. The web between the two cuts is what carries the board, so they are kept to Head_cut.
module head_field() {
    fw  = cm(Width - 2 * Head_stile);
    fh  = rise(Head_h - Head_rail_b - Head_rail_t);
    cz  = Print_h + rise(Head_rail_b) + fh / 2;
    web = cm(Head_d) - 2 * Head_cut;
    if (fw < Symbol_stroke || fh < Symbol_stroke || web < Symbol_stroke)
        echo(str("WARNING: a ", Width, "x", Head_d, " cm headboard at 1:", Scale,
                 " has no room for a field — left solid"));
    else
        translate([0, cm(Length / 2 - Head_d / 2), 0]) {
            front_recess(0, cz, fw, fh, Head_d, Head_cut);
            back_recess(0, cz, fw, fh, Head_d, Head_cut);
        }
}
