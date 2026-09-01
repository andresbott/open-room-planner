// bathroom / bathtub — a bathtub token in the two common shapes: a built-in
// rectangular tub and a freestanding oval one.
//
// The basin is a real sunken hollow, not an engraved outline: at 1:40 a 0.4 mm
// groove vanishes in a photo taken from a low angle and says nothing at all
// under a fingertip, while a hollow a couple of mm deep reads as a bath from
// across the table. What is left standing round it is the rim — wider at the tap
// end, so the token also reads the right way round.
//
// A small faucet stands on that wider tap deck — a spout and two handle knobs — so the
// head of the bath is unmistakable. It is modelled as VERTICAL PRISMS standing off the
// deck, never a spout arching over the water: a real tap at 1:40 is a 1 mm spike over a
// hollow that will not print and snaps if it does (§1.3, the reason washbasin.scad leaves
// its tap off), while a prism up the print direction lands every layer on the one below.
//
// Width/Depth are the real-world footprint in cm; Width is the length you lie
// along. Common sizes (twbathtub.com, "Summary of common dimensions and
// installation heights of bathtubs"): rectangular 120..180 long x 70..80 wide,
// oval 95..180 x 58..80. Height is the real height of the rim — a bath stands about
// 58 cm off the floor — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad).

include <../lib/common.scad>

Oval   = false;  // true -> a freestanding oval tub; Width/Depth are its two axes
Width  = 170;    // cm
Depth  = 75;     // cm
Height = 58;     // cm — the rim, off the floor

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_basin = true;  // off -> a plain block: no hollow, no drain
// The rim, in real cm: the band of top face left standing all round the basin,
// plus the extra the tap end (+X) gets. A real tub has a deeper deck there, for
// the taps and the drain below them, and drawing it is what tells the two ends
// of the token apart.
Rim      = 8;   // cm
Tap_deck = 12;  // cm, added to the rim at the +X end only
// The basin hollow, in real cm — how deep you lie in the water, and how much
// narrower the bottom of the tub is than its rim. The walls slope out as they rise,
// the same way cushion() tapers: every layer lands on the one below it, and the
// hollow catches the light instead of reading as a dark slot.
Basin_depth = 40;
Basin_taper = 5;
Basin_r     = 1.2;  // printed mm, corner rounding of a rectangular basin — a bath
                    // bowl is softer than the carcass around it
// Material kept under the basin floor, on top of a magnet pocket where there is
// one. The hollow is clamped to whatever the token's height leaves — see
// basin_h(), which warns when it had to give any of it up.
Basin_floor = 1.2;
// The drain: a ring in the basin floor at the tap end, drawn with the same pen as
// the symbols in lib/common.scad (printed mm, so it does not scale). It is the
// only engraving on the piece — the rim is left plain, so the one circle on the
// token is unmistakably the drain, down in the bath.
Drain_r = 1;  // mm
// The faucet on the tap deck, at the +X (tap) end over the deeper deck: a spout and two
// handle knobs, all vertical prisms standing off the rim — see the header on why a bath
// tap is a prism and not a spout arching over the water. Real cm: the rises scale like any
// height, the footprints like any plan dimension.
Show_tap   = true;
Tap_h      = 18;  // cm the spout stands above the rim — tall, so it clearly reads as a spout ...
Tap_w      = 6;   // ... its body this wide across (Y) ...
Tap_reach  = 11;  // ... and this long toward the basin (X), so it reads as a spout, not a post
Handle_h   = 4;   // cm the two handle knobs stand — low, so the spout dominates ...
Handle_d   = 6;   // ... each this wide ...
Handle_gap = 22;  // ... the two of them this far apart (Y, centre to centre), flanking the spout
// Magnet pockets in the bottom face, in a row along the length (0 = none). Two
// keep the piece from pivoting on the board; 70 cm of depth is 17.5 mm at 1:40,
// plenty of room for a 4 mm disc. On an oval the count comes from the bounding
// box, which is generous towards the ends — the sizes the Makefile builds all
// still keep a wall round every pocket (see Magnet_* in lib/common.scad).
Magnets = 2;

bathtub();

module bathtub() {
    if (Show_basin && basin_h() < rise(Basin_depth) - 0.001)
        echo(str("WARNING: a ", Basin_depth, " cm basin does not fit in a ", Height,
                 " cm tub over ", basin_under(), " mm of magnet pocket — sunk ",
                 rise_cm(basin_h()), " cm instead (give it more: BATHTUB_H)"));
    union() {
        difference() {
            tub(Print_h);
            if (Show_basin) {
                basin(Print_h);
                drain(Print_h);
            }
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_tap) tap(Print_h);
    }
}

// The faucet, standing on the tap deck at the +X end: a spout — a rounded vertical prism
// elongated toward the basin, so it reads as a spout and not a post — and two handle knobs
// behind it. All stand off the deck as vertical prisms, buried a hair into it so they weld
// solid; nothing arches over the water, so nothing overhangs (see the header). The spout is
// kept clear of the basin edge so its foot lands on the solid rim, not over the hollow.
module tap(top_z) {
    inner   = basin_w() / 2 - Tap_deck / 2;    // real cm — the basin's +X edge
    outer   = Width / 2;                        // real cm — the tub's +X end
    spout_x = inner + Tap_reach / 2 + 2;        // just inside the deck from the basin
    knob_x  = outer - Handle_d / 2 - 2;         // near the outer end of the deck
    translate([cm(spout_x), 0, top_z - rise(2)])
        linear_extrude(height = rise(Tap_h) + rise(2))
            hull() for (sx = [-1, 1])            // a stadium: two round ends, so it never
                translate([sx * cm(Tap_reach - Tap_w) / 2, 0])   // collapses to nothing
                    circle(d = cm(Tap_w));
    for (s = [-1, 1])
        translate([cm(knob_x), s * cm(Handle_gap) / 2, top_z - rise(2)])
            cylinder(h = rise(Handle_h) + rise(2), d = cm(Handle_d));
}

// The body: the tub's real footprint, full height, in whichever shape.
module tub(h) {
    if (Oval) footprint_oval(Width, Depth, h);
    else      footprint(Width, Depth, h);
}

// The basin hollow: sunk basin_h() mm into the top face, cut as a hull between
// its opening and a smaller floor so the walls slope out on the way up. The cut
// runs a hair over the top face, so the rim comes out clean.
module basin(top_z, taper = Basin_taper) {
    if (basin_h() > 0)
        hull() {
            translate([0, 0, top_z - basin_h()])
                linear_extrude(height = 0.01) offset(delta = -cm(taper)) basin_2d();
            translate([0, 0, top_z])
                linear_extrude(height = 0.01) basin_2d();
        }
}

// The drain: a small ring in the basin floor, at the tap end under where the
// taps sit — engraved at the same depth as label(), like the other symbols. It
// is set in far enough to land on the flat floor: drawn any closer to the end it
// would run onto the sloping wall, which rises out from under it and leaves a
// notch in the wall instead of a ring on the floor.
module drain(top_z, r = Drain_r, stroke = Symbol_stroke, depth = Label_depth) {
    floor_z = top_z - basin_h();
    translate([basin_x() - cm(Basin_taper) - r - stroke - Symbol_margin, 0,
               floor_z - depth])
        linear_extrude(height = depth + 0.01) stroke_arc(r, 0, 360, stroke);
}

// The basin's outline: the tub's own shape, a rim narrower on every side and the
// tap deck narrower again along X, pushed off centre so all of that extra width
// lands at the +X end. Drawn as the same shape one size down rather than as an
// offset() of the body, so an oval basin stays a clean oval.
module basin_2d() {
    translate([-cm(Tap_deck) / 2, 0])
        tub_2d(basin_w(), basin_d(), basin_r());
}

// The tub's outline at <w_cm> x <d_cm>, in whichever shape — both come out of the
// same call, as top_2d() does in diningroom/table.scad.
module tub_2d(w_cm, d_cm, r = Corner_radius) {
    if (Oval) footprint_oval_2d(w_cm, d_cm);
    else      footprint_2d(w_cm, d_cm, r);
}

// ---- what fits in the height the tub has ------------------------------------

function basin_w() = max(0, Width - 2 * Rim - Tap_deck);
function basin_d() = max(0, Depth - 2 * Rim);
// A rectangular basin's corner rounding, clamped so a small basin cannot be
// rounded away to nothing: footprint_2d() erodes by r before growing back.
function basin_r() = max(0, min(Basin_r,
                                min(cm(basin_w()), cm(basin_d())) / 2 - 0.05));
// How deep the hollow actually gets: what is left of the height once the basin
// floor — and a magnet pocket under it, where one fits — has had its share.
function basin_under() = magnet_count(Width, Depth, Magnets) > 0
                             ? magnet_pocket_h() : 0;
function basin_h() = max(0, min(rise(Basin_depth),
                                Print_h - basin_under() - Basin_floor));
// The +X edge of the basin, printed mm from the centre of the piece — where the
// tap deck starts, and what the drain is placed off.
function basin_x() = cm(basin_w()) / 2 - cm(Tap_deck) / 2;
