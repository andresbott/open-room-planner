// kitchen / oven_column — a tall housing for the built-in appliances: an oven with a combi
// microwave stacked over it, a door under them and a door above. The kitchen already has a
// slot-in cooker at counter height (cooker.scad); this is the other way a modern kitchen is
// built, with the oven up at eye level in a column of its own, and it is the piece that lets
// a plan show one.
//
// Three tall 60x60 units now stand next to each other in the set, so what tells them apart
// has to be on their fronts, and is:
//
//     larder (cabinet.scad)   three even courses of plain door
//     fridge (fridge.scad)    two doors, split about a third of the way up
//     this                    two GLAZED APERTURES in the middle of the column, one over
//                             the other, with a plain door above and below them
//
// An aperture is a SHADOW GAP round a case, and then two cuts in that case: a control fascia
// along its top and the glass door under it. The gap is the part that does the work — a slot
// only Case_gap wide but Case_cut deep, cut right round the appliance, so the case is left
// standing flush at the housing face the way a real built-in appliance does, with a black
// line round it. The first version of this recessed the whole case into the face instead and
// came out as a shaker door with a moulding round it: a broad, shallow recess in a vertical
// face barely shades at all, while a narrow deep slot reads as a line from across the room.
// Narrow is also what makes it printable at that depth — the ceiling it leaves to bridge is
// one gap wide, not the width of the column.
//
// The appliance cases therefore stand a touch PROUD of the plain door fronts above and below
// them, which are recessed the usual Front_relief. That is the right way round: in a real
// kitchen the oven is the thing that sticks out.
//
// There is no worktop slab (Slab = 0): a housing's fronts run the full height, like a
// larder's. There is no handle either, for the reason Grip_h gives in lib/common.scad — a
// bar across an oven door is 1 mm at this scale and snaps off in the box — so the fascia's
// own lower lip is the handle, as it is on a real handleless kitchen.
//
// Width/Depth are the real-world footprint in cm: a 60x60 tall housing, the same module as
// the larder beside it. Height is the real carcass height, shrunk by the plan scale like the
// footprint (see printed_h() in lib/common.scad). Oven_z is how far off the floor the oven's
// case starts — the thing that actually decides whether the column reads as eye-level — and
// Oven_h / Micro_h are the two appliances' own case heights, all in real cm.
//
// Two variants fall out of those knobs: Micro_h = 0 drops the microwave for a SINGLE-OVEN
// column (a tall plain door over the oven), and Warming_h > 0 turns the top slice of the band
// under the oven into one shallow WARMING DRAWER — the two other ways a real oven housing is
// fitted.
//
// It prints the right way up: everything on the face is a cut, and the magnet pocket opens
// at the plinth like every other unit in the run.

include <../lib/common.scad>

Width  = 60;   // cm
Depth  = 60;   // cm
Height = 200;  // cm — a full-height housing, the same as the larder next to it

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// No worktop: a housing's fronts run the full height of the carcass (see above).
Slab = 0;

Show_fronts = true;
// The two appliances, real cm. Oven_z is measured off the FLOOR, so it says where the oven
// lands in the room and not merely where it lands on the face.
Oven_z  = 60;  // cm off the floor to the underside of the oven's case ...
Oven_h  = 60;  // ... the oven's own case height ...
Micro_h = 45;  // ... and the combi microwave's on top of it (Micro_h=0 -> a single-oven column)
// A warming drawer under the oven, real cm (0 = a plain door there instead). It is the top
// slice of the band below the oven turned into one shallow, handleless drawer front — what a
// real single-oven housing carries where the microwave is not.
Warming_h = 0;  // cm
// Each aperture's control fascia, real cm of its own height — deeper than the run's
// Fascia_h, because on an oven it is the whole display-and-dial band.
Bay_fascia = 8;  // cm
// The shadow gap round an appliance's case, real cm — the same order as the gap round a door
// front, so the two line up down the column ...
Case_gap  = 2;   // cm
// ... and the surround left round the glass door inside the case, which is what stops the
// glass reading as the whole appliance.
Door_edge = 3;   // cm
// How deep the cuts go, printed mm — print detail, so they do not scale. The shadow gap is
// the deep one (see the header); the glass is Front_relief + Glass_cut in from the case face,
// so it sits at the same depth as a door front's grip rail and a touch more.
Case_cut  = 1.6;  // mm the shadow gap round a case is cut ...
Glass_cut = 1.0;  // ... and the glass door, below the case's own face
// The plain doors above and below: one course per Door_height cm, as the larder does, so a
// taller column comes out with more of them rather than with two stretched ones.
Door_height = 70;  // cm

// Magnet pockets in the bottom face (0 = none). Near-square and standing on the same plinth
// as the rest of the kitchen, so one central pocket holds it: 54 cm of plinth front to back
// is 13.5 mm at 1:40, plenty for a 4 mm disc (see unit_plinth_d() and Magnet_* in
// lib/common.scad).
Magnets = 1;

oven_column();

// The band of carcass face the whole stack has to fit in, printed mm.
function face_z0() = unit_face_z0(Width, Depth, Print_h, Slab);
function face_z1() = unit_face_z1(Width, Depth, Print_h, Slab);
// The shadow gap between the two appliance cases — the one part of the stack that is print
// detail rather than furniture, so it is not squeezed with the rest.
function bay_gap()  = cm(Front_gap);
// What each of the three real-world bands would like, printed mm: the door under the oven
// (whatever is left between the toe kick and Oven_z), then the two appliances.
function want_low()   = max(0, rise(Oven_z) - face_z0());
function want_oven()  = rise(Oven_h);
function want_micro() = rise(Micro_h);
function want_all()   = want_low() + want_oven() + want_micro();
// The room there is for those three, and the factor they all shrink by when there is not
// enough — a squashed column keeps its proportions rather than losing its top door and then
// its microwave.
function bay_room()  = max(0, face_z1() - face_z0() - bay_gap());
function squeeze()   = want_all() > bay_room() && want_all() > 0
                           ? bay_room() / want_all() : 1;
// ... and what each band actually gets, printed mm up from the floor.
function low_z1()   = face_z0() + want_low() * squeeze();
function oven_z1()  = low_z1() + want_oven() * squeeze();
function micro_z0() = oven_z1() + bay_gap();
function micro_z1() = micro_z0() + want_micro() * squeeze();
// A band needs more than a shadow gap of height before a front cut into it means anything.
function band_min() = bay_gap() + Symbol_stroke;
// One course of plain door per Door_height cm of a band <h> printed mm tall.
function courses(h) = max(1, round(rise_cm(h) / Door_height));
// The two variant knobs: is there a microwave over the oven, is there a warming drawer under
// it — and how tall that drawer comes out, clamped to the band below the oven and squeezed
// with everything else so a short column keeps its proportions.
function has_micro()   = Micro_h > 0;
function has_warming() = Warming_h > 0;
function warm_h() = has_warming()
                        ? min(rise(Warming_h) * squeeze(), max(0, low_z1() - face_z0()))
                        : 0;

module oven_column() {
    if (squeeze() < 1)
        echo(str("WARNING: an oven at ", Oven_z, " cm with a ", Oven_h, " cm case under a ",
                 Micro_h, " cm microwave does not fit a ", Height,
                 " cm column — the three bands cut back to ",
                 rise_cm(want_low() * squeeze()), " / ", rise_cm(want_oven() * squeeze()),
                 " / ", rise_cm(want_micro() * squeeze()),
                 " cm (give it more: OVEN_COLUMN_H)"));
    difference() {
        base_unit(Width, Depth, Print_h, Slab);
        if (Show_fronts) fronts();
        if (Magnets > 0) magnets(Width, unit_plinth_d(Width, Depth), Magnets);
    }
}

// The face, bottom to top: a plain door under the oven, the oven, the microwave, a plain
// door over them. A band too shallow to hold a front is left plain and says so — better a
// flat patch of carcass than a hairline pretending to be a door.
module fronts() {
    z0 = face_z0();
    z1 = face_z1();
    // below the oven: plain door(s) up to door_top, then — if asked — a warming drawer as the
    // top slice of the band, the shallow front sitting directly under the oven.
    door_top = low_z1() - warm_h();
    if (door_top - z0 >= band_min())
        unit_fronts(Width, Depth, z0, door_top, 1, courses(door_top - z0), Slab);
    else if (door_top > z0)
        echo(str("NOTE: ", rise_cm(door_top - z0),
                 " cm is left under the oven — too little for a door front, left plain"));
    if (has_warming() && warm_h() >= band_min())
        unit_fronts(Width, Depth, door_top, low_z1(), 1, 1, Slab);
    else if (has_warming() && warm_h() > 0)
        echo(str("NOTE: a ", rise_cm(warm_h()), " cm warming drawer at 1:", Scale,
                 " is too shallow for a front — left plain"));
    // the oven, and the microwave over it unless this is a single-oven column
    appliance_bay(low_z1(), oven_z1());
    if (has_micro())
        appliance_bay(micro_z0(), micro_z1());
    if (z1 - micro_z1() >= band_min())
        unit_fronts(Width, Depth, micro_z1(), z1, 1, courses(z1 - micro_z1()), Slab);
    else if (z1 > micro_z1())
        echo(str("NOTE: ", rise_cm(z1 - micro_z1()),
                 " cm is left at the top of the column — too little for a door front, left plain"));
}

// One built-in appliance's face, between <zb> and <zt> printed mm up the carcass face: the
// shadow gap round its case, then the control fascia along the top of that case and the glass
// door in what is left below (see the header for why it is built that way round). The
// aperture keeps the same Front_gap to the sides as a door front, so the column's face lines
// up with the run's.
module appliance_bay(zb, zt, fascia_cm = Bay_fascia) {
    fd = unit_face_d(Width, Depth, Slab);
    w  = cm(Width) - 2 * cm(Front_gap);   // the aperture ...
    h  = zt - zb;
    z  = (zb + zt) / 2;
    cw = w - 2 * cm(Case_gap);            // ... and the appliance's case standing inside it
    ch = h - 2 * cm(Case_gap);
    if (cw < Symbol_stroke || ch < Symbol_stroke)
        echo(str("WARNING: ", Width, " cm at 1:", Scale, " leaves ", cw, " x ", ch,
                 " mm for an appliance case — too small, left plain"));
    else {
        // the shadow gap: the ring between the aperture and the case, cut deep. The inner cut
        // is deliberately thicker than the outer one, so it takes the whole middle back out
        // and what is subtracted from the column is a frame and not a slab.
        difference() {
            front_recess(0, z, w, h, fd, Case_cut);
            front_recess(0, z, cw, ch, fd, Case_cut + 1);
        }
        fh = min(rise(fascia_cm), ch / 3);                              // the fascia
        if (fh >= Symbol_stroke)
            front_recess(0, z + ch / 2 - fh / 2, cw, fh, fd, Front_relief + Grip_cut);
        band = ch - (fh >= Symbol_stroke ? fh : 0);   // what is left of the case for the door
        gw   = cw - 2 * cm(Door_edge);                                  // the glass door
        gh   = band - 2 * cm(Door_edge);
        if (gw >= Symbol_stroke && gh >= Symbol_stroke)
            front_recess(0, z - ch / 2 + band / 2, gw, gh, fd,
                         Front_relief + Glass_cut);
        else
            echo(str("NOTE: a ", rise_cm(band), " cm appliance door at 1:", Scale,
                     " has no room for glass inside a ", Door_edge,
                     " cm surround — case only"));
    }
}
