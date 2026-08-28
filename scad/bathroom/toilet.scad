// bathroom / toilet — a toilet: a rounded bowl at the front fused to a rectangular cistern
// at the back, with the PAN SUNK FOR REAL into the bowl and the flush plate recessed into
// the top of the cistern.
//
// The pan used to be a ring engraved round the top of the bowl — a 0.6 mm line standing in
// for the one thing a toilet is unmistakably read by from above, which is a hole. It is now
// a real hollow (see hollow() in lib/common.scad, the same cut a basin and a bath get), so
// what is left standing round it is the seat, and the token reads as a toilet from across
// the table and under a fingertip. Nothing is engraved on the piece at all any more: the
// step up to the cistern marks the join, the hollow marks the pan, and the flush plate is a
// recess in the one face it is on in the room — the top of the tank.
//
// Width/Depth are the real-world footprint in cm: a compact toilet is about 40 wide and
// 70 deep overall, bowl and cistern together. Height is the real height over the cistern —
// the tallest part of the piece, the seat sits far lower — shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad).

include <../lib/common.scad>

Width  = 40;  // cm
Depth  = 70;  // cm
Height = 78;  // cm — over the cistern (the seat is at about 40)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_pan = true;
// How the footprint splits front-to-back: a rounded bowl at the front (-Y) fused to a
// rectangular cistern at the back (+Y), both Width wide, adding up to Depth. The bowl only
// stands Seat high — the cistern behind it is the piece's full Height — so the token steps
// down at the join, and the pan is sunk into the low part.
Cistern_depth = 18;  // cm — depth of the tank block
Seat          = 40;  // cm — the bowl: seat height
// The pan, in real cm: how much of the bowl's top is left as seat all round it, and how far
// it dishes down. It is clamped to whatever the bowl leaves over a magnet pocket — see
// pan_h(), which warns when it had to give any of it up, as bathtub.scad does.
Seat_w    = 7;    // cm of seat left round the pan ...
Seat_back = 10;   // ... and extra at the cistern end, where a real seat has its hinges
Pan_depth = 15;   // cm the pan dishes down
Pan_floor = 1.2;  // printed mm of material kept under it, over a magnet pocket
Pan_r     = 0.6;  // printed mm, rounding of the pan — the bowl is round anyway, this is
                  // only what keeps its cap from coming to a point

// the printed height of the bowl, mm — the cistern stands the rest
Seat_z = printed_h(Seat);

Show_flush = true;
// The flush plate, in real cm — a rounded pad recessed into the top of the cistern, which is
// where a close-coupled toilet's buttons are and the only detail on the piece a plan view
// looks straight down on.
Flush_w    = 12;
Flush_d    = 7;
Flush_cut  = 0.5;  // mm it is sunk into the cistern top

// Magnet pockets in the bottom face (0 = none). One central pocket is enough
// for a piece this compact. The 40 cm width is only 10 mm at 1:40 — still room
// for the standard 4 mm disc, and narrower than that magnets() drops to the
// 2 mm one on its own (see Magnet_* in lib/common.scad).
Magnets = 1;

// ---- what fits in the bowl --------------------------------------------------
function bowl_depth() = Depth - Cistern_depth;
function bowl_cy()    = -Depth / 2 + bowl_depth() / 2;
// The pan's outline: the bowl's own shape, a seat's width narrower all round and narrower
// again at the cistern end, pushed forward so all of that extra lands at the back — the same
// way bathtub.scad sets its tap deck out.
function pan_w() = max(0, Width - 2 * Seat_w);
function pan_d() = max(0, bowl_depth() - 2 * Seat_w - Seat_back);
// How deep it really dishes, printed mm: what is left of the bowl's height once the floor —
// and a magnet pocket under it, where one fits — has had its share.
function pan_under() = magnet_count(Width, Depth, Magnets) > 0 ? magnet_pocket_h() : 0;
function pan_h() = max(0, min(rise(Pan_depth), Seat_z - pan_under() - Pan_floor));

toilet();

module toilet() {
    cistern_y = Depth / 2 - Cistern_depth / 2;
    seam_y    = Depth / 2 - Cistern_depth;
    if (Show_pan && pan_h() < rise(Pan_depth) - 0.001)
        echo(str("WARNING: a ", Pan_depth, " cm pan does not fit in a ", Seat,
                 " cm bowl over ", pan_under(), " mm of magnet pocket — sunk ",
                 rise_cm(pan_h()), " cm instead (give it more: TOILET_SEAT)"));
    difference() {
        union() {
            translate([0, cm(cistern_y), 0])
                footprint(Width, Cistern_depth, Print_h);
            translate([0, cm(bowl_cy()), 0])
                linear_extrude(height = Seat_z) bowl_2d(Width, bowl_depth());
            // weld: a thin strip straddling the seam, so the bowl and cistern
            // fuse into one solid instead of two blocks that merely touch —
            // they would otherwise only share a coincident face, which CGAL
            // can leave as two separate volumes. It is only as tall as the bowl,
            // the lower of the two.
            translate([0, cm(seam_y), Seat_z / 2])
                cube([cm(Width) - 0.2, 0.1, Seat_z], center = true);
        }
        // the pan, sunk into the bowl; the step up to the cistern marks the join on its own
        if (Show_pan) pan();
        if (Show_flush) flush();
        if (Magnets > 0)
            magnets(Width, Depth, Magnets);
    }
}

// The pan: a real hollow sunk into the top of the bowl, its walls sloping out on the way up
// so nothing overhangs and the light gets into it. What is left standing round it is the seat.
module pan() {
    if (pan_w() > 0 && pan_d() > 0)
        translate([0, cm(bowl_cy() - Seat_back / 2), 0])
            hollow(Seat_z, pan_h())
                bowl_2d(pan_w(), pan_d(), Pan_r);
}

// The flush plate: a rounded pad recessed into the top of the cistern.
module flush() {
    w = min(Flush_w, Width - 2 * plan_cm(Symbol_margin));
    d = min(Flush_d, Cistern_depth - 2 * plan_cm(Symbol_margin));
    if (w > 0 && d > 0)
        translate([0, cm(Depth / 2 - Cistern_depth / 2), Print_h - Flush_cut])
            linear_extrude(height = Flush_cut + 0.01)
                footprint_2d(w, d, min(Corner_radius, cm(d) / 2 - 0.05));
}

// The bowl outline: a square-backed rectangle (so it seats flush against the
// cistern) hulled with a semicircular cap at the front — the cap spends half
// the width on depth, so the whole shape still measures d_cm front-to-back.
// Centred like footprint_2d(), <w_cm> wide. The pan is cut with the same call one
// size down, so the seat left round it follows the curve of the bowl.
module bowl_2d(w_cm, d_cm, r = Corner_radius) {
    w      = cm(w_cm);
    d      = cm(d_cm);
    cap_r  = w / 2;
    rect_d = max(0.01, d - cap_r);
    rr     = max(0, min(r, min(w, rect_d) / 2 - 0.01));
    hull() {
        translate([0, d / 2 - rect_d / 2])
            offset(r = rr) offset(delta = -rr)
                square([w, rect_d], center = true);
        translate([0, d / 2 - rect_d])
            circle(r = cap_r);
    }
}
