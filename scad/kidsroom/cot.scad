// kidsroom / cot — a baby's cot (crib): an open barred frame with a mattress lying
// low inside it. It replaces a first-generation token that was a plain block with the
// bars scratched onto its top face — the one face a photograph of the plan sees least
// of and a fingertip never feels. A cot is recognised across a room by two things: the
// row of vertical bars down its long sides, and the little mattress sunk between the
// rails. Both are built here for real, where a low angle across the table can see them.
//
// The bars are the RIBS left standing between a row of full-depth openings cut through
// each LONG side — the front (-Y) and the back (+Y), because a cot is barred on both —
// between a solid end panel at each short end and under a top rail that caps them. Cut
// the GAPS and leave the bars, rather than add bars: every bar comes out a solid
// vertical prism with nothing thin enough to snap off (§1.3), and from a low angle the
// light goes straight through the openings, so the piece reads as a cage and not as a
// box. There are far fewer bars than a real cot's fifteen-odd — at 1:40 a 2.5 cm
// spindle is half a millimetre and closes up at one nozzle — so the count is thinned to
// what still reads (about eight openings), widened and warned about if even those will
// not fit; that is what a cot looks like at this size anyway.
//
// The mattress is a real sunken well in the top, the way bathroom/bathtub.scad sinks
// its basin: a rim of top rail all round, the walls sloping out so the light reaches in
// instead of leaving a dark slot, and a soft cushion() pad lying on the floor of it,
// well below the top of the bars — so you look down past the rails onto the mattress,
// the way you do into a cot. Not an engraved rectangle, and not a pad stuck on a flat
// lid: a hollow with something soft in it.
//
// Deliberately left off: legs — at 1:40 four cot legs are spikes that snap and would
// rob the base of the broad bottom face a magnet needs, so the lower frame is kept
// solid and reads as the valance a modern cot has; knobs, finials and a drop-side latch
// (all sub-millimetre spikes); and any engraved size — a cot is essentially one size,
// so the form is left to carry it.
//
// Width/Length are the real cot footprint in cm — a cot mattress is 60 x 120, a cot-bed
// 70 x 140. Length is the barred long side, so it runs along X and the front (-Y) face
// is the long one the camera meets first. Height is the real height over the top rail —
// about 90 cm, waist height on an adult, so a cot stands taller than a bed — shrunk by
// the plan scale like the footprint (see printed_h() in lib/common.scad).
//
// It prints THE RIGHT WAY UP, no supports: the bars are vertical prisms standing on the
// base and hanging from the rail, the top rail only ever bridges the ~1.5 mm gap
// between two bars, the well walls slope out, the mattress pad tapers, and the magnet
// pocket opens in the solid base at the bottom.
//
// In section, across the cot at a bar (short axis, front -Y on the left):
//
//    ___                     ___        the top rail, capping the bars all round ...
//   | b |    mattress well   | b |      ... a bar each side (b), the open well between,
//   | a |    ___________     | a |          sloping out to catch the light ...
//   | r |   | mattress  |    | r |      ... the soft pad, lying low on the well floor ...
//   |___|___|___________|____|___|
//   |__________________________|        ... the solid base, a magnet buried in it

include <../lib/common.scad>

Width  = 60;   // cm — the short side (front-to-back)
Length = 120;  // cm — the barred long side
Height = 90;   // cm — over the top rail

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_bars     = true;   // the barred long sides
Show_well     = true;   // the sunken mattress well
Show_mattress = true;   // the soft pad lying in the well

// The frame, in real cm. The mattress well is sunk inside this rim, and what is left
// standing round it is the cot: an end panel at each short end, a barred rail down each
// long side, a rail across the top and a solid base under it all.
End_wall = 8;   // cm — the solid end panels (head / foot), and the well's inset there
Side_rail = 7;  // cm — the barred long sides' thickness (each bar this thick), and the
                //      well's inset there
Bar_start = 12; // cm — where the barred sides begin, kept low so the long face reads as
                //      barred over most of its height, on a short solid base
Floor_h   = 38; // cm — the mattress platform (the well floor): set high, the way a
                //      newborn cot's base is, so the mattress sits up where a low angle
                //      sees it with the bars still rising clear above it
Rail_top  = 8;  // cm — the top rail capping the bars, so no bar ends in a free spike

// The bars, in real cm. The openings are cut and the bars left between them; the count
// comes from the target pitch and is clamped so a rib never thins below Bar_min and an
// opening never below Gap_min — widened, with a NOTE, when the run is too short.
Bar_pitch = 12; // cm — target centre-to-centre of the openings
Gap_w     = 6;  // cm — target width of one opening (a real cot keeps these <= 6 cm)
Bar_min   = 3;  // cm — the thinnest a bar rib may be squeezed to
Gap_min   = 3;  // cm — the narrowest an opening may be squeezed to

// The mattress, in real cm: a soft pad lying on the well floor, inset from the bars and
// standing well below the top of them, so the bars show above it.
Mattress_h   = 14;  // cm the pad stands above the well floor
Mattress_gap = 1.5; // cm the pad is inset from the well floor all round

// The well's walls, as a fraction of its opening (like Hollow_floor): near 1 for a
// near-vertical well the mattress fills, so the pad is not left in the bottom of a
// funnel. The material kept over a magnet pocket under the well floor, in printed mm.
Well_floor_frac = 0.9;
Base_floor      = 1.2;  // mm

// Magnet pockets in the bottom face, in a row along the length (0 = none). Two keep the
// piece from pivoting; the base is the whole footprint, so the row has the run of it,
// and 60 cm of width is 15 mm at 1:40 — wide enough for the disc (see Magnet_* in
// lib/common.scad).
Magnets = 2;

// ---- what fits in the height the cot has ------------------------------------
// The material a magnet pocket needs under the well floor, printed mm.
function base_over() = (Magnets > 0 && magnet_count(Length, Width, Magnets) > 0)
                           ? magnet_pocket_h() : 0;
// The top rail and the least a bar zone is worth cutting, printed mm.
function top_rail_h() = min(rise(Rail_top), Print_h / 3);
function bar_min_h()  = rise(2);
// The bar zone, printed mm: from the feet (a short solid base) up to the underside of
// the top rail. The feet stay above the bottom face so the base is a clean slab for the
// magnet, and below the rail so no bar ends in a free spike.
function bar_z1() = Print_h - top_rail_h();
function bar_z0() = max(rise(2), min(rise(Bar_start), bar_z1() - bar_min_h()));
// The mattress platform — the well floor, printed mm up from the bottom: high as Floor_h
// asks, but always over the magnet's cover and above the bar feet, and never so high
// that the mattress cannot clear under the top rail. Below it the piece stays solid, so
// the magnet has its material and the lower bars have the base showing behind them.
function floor_min_z() = max(base_over() + Base_floor, bar_z0() + rise(2));
function floor_z() = max(floor_min_z(), min(rise(Floor_h), bar_z1() - rise(2)));
// The mattress pad's height, printed mm: what Mattress_h asks, clamped so its top stays
// below the top of the bars.
function mattress_h() = max(0, min(rise(Mattress_h), bar_z1() - floor_z() - rise(2)));
// The well: sunk from the top down to the floor, its opening inset by the frame, its
// floor a fraction of that so the walls slope out.
function well_depth()   = Print_h - floor_z();
function well_open_w()  = Length - 2 * End_wall;
function well_open_d()  = Width  - 2 * Side_rail;
function well_floor_w() = Well_floor_frac * well_open_w();
function well_floor_d() = Well_floor_frac * well_open_d();

// ---- the bars ---------------------------------------------------------------
// The barred field between the two end panels, and how it is split into openings.
function bar_field() = Length - 2 * End_wall;
function bar_want()  = max(1, round(bar_field() / Bar_pitch));
function n_gaps()    = max(1, min(bar_want(),
                                  floor(bar_field() / (Bar_min + Gap_min))));
function gap_cell()  = bar_field() / n_gaps();
function gap_w()     = max(Gap_min, min(Gap_w, gap_cell() - Bar_min));

cot();

module cot() {
    if (Show_well && abs(floor_z() - rise(Floor_h)) > 0.01)
        echo(str("NOTE: a ", Height, " cm cot at 1:", Scale, " x", Height_scale,
                 " Height_scale could not seat its mattress platform at ", Floor_h,
                 " cm — put it at ", rise_cm(floor_z()),
                 " cm instead (give it more height: COT_H)"));
    if (Show_well && Show_mattress && mattress_h() < rise(Mattress_h) - 0.01)
        echo(str("NOTE: a ", Height, " cm cot at 1:", Scale, " x", Height_scale,
                 " Height_scale has no room for a ", Mattress_h,
                 " cm mattress under the bars — thinned it to ", rise_cm(mattress_h()),
                 " cm (give it more height: COT_H)"));
    if (Show_bars && bar_z1() - bar_z0() >= bar_min_h() && n_gaps() < bar_want())
        echo(str("NOTE: a ", Length, " cm cot at 1:", Scale, " fits ", n_gaps(),
                 " of ", bar_want(), " openings at a ", Bar_pitch,
                 " cm pitch — spread them wider"));
    union() {
        difference() {
            footprint(Length, Width, Print_h);
            if (Show_well) well();
            if (Show_bars) bars();
            if (Magnets > 0) magnets(Length, Width, Magnets);
        }
        if (Show_well && Show_mattress) mattress();
    }
}

// The mattress well: a hollow sunk from the top face down to the base, its opening set
// in from every edge by the frame and its floor a touch smaller so the walls slope out
// on the way up — the same sunken-basin shape as bathtub.scad, at cot scale.
module well() {
    hollow(Print_h, well_depth(), Well_floor_frac)
        footprint_2d(well_open_w(), well_open_d());
}

// The bars: a row of full-depth openings cut through the long (-Y / +Y) sides, in the
// bar zone only — above the solid base, below the top rail — and between the end panels,
// so the ribs left standing are the bars and the rail, base and panels stay whole. Each
// opening runs clear through the piece, so the front and back bars line up and the light
// comes through; the top rail spans the ~one-nozzle gap between two bars as a short
// bridge, and nothing else has to.
module bars() {
    z0 = bar_z0();
    z1 = bar_z1();
    if (z1 - z0 < bar_min_h())
        echo(str("WARNING: a ", Height, " cm cot at 1:", Scale, " x", Height_scale,
                 " Height_scale has no room for bars over its rails — sides left solid"));
    else {
        field = bar_field();
        n     = n_gaps();
        cell  = field / n;
        gw    = gap_w();
        for (i = [0 : n - 1])
            translate([cm(-field / 2 + cell * (i + 0.5)), 0, (z0 + z1) / 2])
                cube([cm(gw), cm(Width) + 2, z1 - z0], center = true);
    }
}

// The mattress: a soft cushion() pad lying on the well floor, inset from it all round so
// a rim of the floor and the bars show around it, and standing Mattress_h above it —
// low, so the bars rise clear over the sleeper. Added after the well is carved, so the
// hollow does not eat it.
module mattress() {
    mw = well_floor_w() - 2 * Mattress_gap;
    md = well_floor_d() - 2 * Mattress_gap;
    if (mw > 0 && md > 0 && mattress_h() > 0)
        cushion(mw, md, floor_z(), rise_cm(mattress_h()));
    else
        echo(str("NOTE: a ", Width, "x", Length, " cm cot at 1:", Scale,
                 " leaves no room for a mattress inside its frame — left it out"));
}
