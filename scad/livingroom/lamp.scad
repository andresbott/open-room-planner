// livingroom / lamp — a standing (floor) lamp token, in four shapes: a drum-shaded
// floor lamp, a cone uplighter, a paper globe and a tripod. A lit shade is engraved
// on top wherever the shade is wide enough to read it.
//
// A standing lamp is mostly air, and the little of it that is solid is finer than a
// printer can draw at 1:40: a 5 cm stem is 1.25 mm across, and the shade hangs a long
// way over a small foot. The token keeps the two dimensions a plan cares about — the
// shade, which is the widest part and so the space the lamp takes, and the foot it
// stands on — and redraws everything in between so it prints as one solid piece,
// upright and support-free:
//   - the stem is thickened to a printable minimum, and always kept long enough to
//     read as a stem (Stem_min / Stem_h)
//   - a shade only ever WIDENS at 45 deg, so no layer overhangs the one below it; a
//     shade too wide to flare in the height it has is narrowed, with a warning.
//     Closing in again is free, so what a real shade does at the bottom — reach its
//     full width straight off the stem — is done on the way to the top instead
//   - the tripod legs lean IN as they rise, instead of standing on three dots
//
// Shade/Base are real-world diameters in cm (a tripod's Base is the leg spread) and
// Height the real height of the lamp — a floor lamp stands about 160 cm, over head
// height for the furniture around it — shrunk by the plan scale like everything else
// (see printed_h() in lib/common.scad). A table lamp is the same part at Height = 50
// with a smaller shade.

include <../lib/common.scad>

Type   = "drum";  // drum | cone | globe | tripod
Shade  = 45;      // shade diameter, cm — the widest part of the lamp
Base   = 40;      // foot diameter, cm (tripod: the spread of the legs) — a broad foot,
                  // for a stable, well-stuck print of a tall, top-heavy piece
Height = 160;     // cm — a floor lamp (50 for a table lamp)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// Real dimensions in cm that come out too fine to print at 1:40, each with the
// printed minimum it is held to.
Stem     = 5;    // stem diameter, cm
Leg      = 5;    // tripod leg and foot-arm width, cm
Stem_min = 2.4;  // printed mm — six perimeters at 0.4: a pole this thick stands up
                 // to the print and to handling (mirrored as LAMP_STEM_MIN)
Leg_min  = 1.6;  // printed mm
Stem_h   = 40;   // cm of bare stem kept under the shade

// The foot: Foot_h is real cm, Foot_roof printed mm. It is a puck and not a plate
// wherever a magnet goes in it: a pocket is wider than the stem, so the foot has to
// be deep enough to hold the pocket and still roof it over, or the stem would be
// printed hollow over the hole.
Foot_h    = 3;
Foot_roof = 0.6;
// The tripod hub — the disc the legs and the magnet pocket meet on — as a share of
// the leg spread. Wider than this and it swallows the arms it sits between.
Hub_share = 0.6;

// The shade, in printed mm and shares. Everything here is measured off the 45 deg
// flare the shade needs to get to its full width (see flare()), which the shade
// DIAMETER sets — so these stay printed mm, like the flare itself.
Drum_wall = 1.5;   // shade left above the flare — the band you read as a shade
Drum_top  = 0.85;  // how far it closes in over that: an empire shade, not a cylinder
Cone_deep = 1.6;   // an uplighter is deeper than the flare needs to be, so its wall
                   // ends up steeper than 45 deg — which only helps it print
Globe_rise = 0.7;  // where a globe is widest, as a share of its own height

Show_rays = true;
// Magnet pockets in the bottom face (0 = none). A lamp foot is a small footprint — 10 mm
// across at 1:40 for a 40 cm base — comfortably wide enough for a 4 mm disc, with the puck
// kept deep enough to roof it (see foot_h()).
Magnets = 1;

lamp();

module lamp() {
    if (shade_d() < cm(Shade) - 0.001)
        echo(str("WARNING: a ", Shade, " cm shade cannot flare 45 deg in ", Height,
                 " cm of lamp at 1:", Scale, " — drawn ",
                 shade_d() * Scale / 10, " cm wide instead (give it more: LAMP_H)"));
    difference() {
        union() {
            foot();
            if (Type == "tripod") legs();
            else                  stem();
            shade();
        }
        if (Show_rays && rays_size(patch(), patch()) >= Symbol_min)
            rays(rays_size(patch(), patch()), Print_h);
        if (Magnets > 0)
            magnets(foot_cm(), foot_cm(), Magnets);
    }
}

// ---- the pieces of a lamp ----------------------------------------------------

// The puck the lamp stands on — on a tripod, the hub plus an arm out to each foot.
module foot() {
    linear_extrude(height = foot_h())
        union() {
            circle(d = foot_d());
            if (Type == "tripod")
                for (a = [90 : 120 : 359])
                    stroke_line([0, 0], leg_foot(a), leg_w());
        }
}

// The stem, from the foot up to the underside of the shade.
module stem() {
    translate([0, 0, foot_h() - 0.01])
        cylinder(h = max(0.02, shade_z() - foot_h() + 0.02), d = stem_d());
}

// Three legs leaning in from their feet up to the shade, where they merge into one
// stem. Leaning in means every layer lands on the one below it; a real tripod's three
// points would have the printer start the piece on three 1.6 mm dots and cantilever
// inwards from there.
module legs() {
    for (a = [90 : 120 : 359])
        hull() {
            translate(concat(leg_foot(a), [foot_h() - 0.01]))
                cylinder(h = 0.01, d = leg_w());
            translate([0, 0, shade_z() - 0.01]) cylinder(h = 0.01, d = stem_d());
        }
}

// The shade: a cone off the stem, and then — for the shapes that have anything left
// above it — the way it closes in again, a little for a drum, all the way for a globe.
module shade() {
    translate([0, 0, shade_z()]) {
        cylinder(h = Type == "cone" ? shade_h() : flare(),
                 d1 = stem_d(), d2 = shade_d());
        if (shade_rest() > 0.01)
            translate([0, 0, flare()])
                cylinder(h = shade_rest(), d1 = shade_d(), d2 = top_d());
    }
}

// ---- what fits in the height the lamp has -----------------------------------

function stem_d() = max(cm(Stem), Stem_min);
function leg_w()  = max(cm(Leg), Leg_min);
// where a tripod leg meets the floor, in printed mm from the centre
function leg_foot(a) = (cm(Base) - leg_w()) / 2 * [cos(a), sin(a)];

// The foot, printed mm: the real base, or on a tripod the hub the legs stand on.
function foot_d()  = Type == "tripod" ? max(stem_d() * 1.8, cm(Base) * Hub_share)
                                      : cm(Base);
// magnets() measures in real cm, so the foot goes back through the scale to ask for
// a pocket in it.
function foot_cm() = foot_d() * Scale / 10;
// Deep enough to roof a pocket over — but only when one actually fits, so a foot too
// small for the hardware stays as thin as it looks.
function foot_h()  = min(magnet_count(foot_cm(), foot_cm(), Magnets) > 0
                             ? max(rise(Foot_h), magnet_pocket_h() + Foot_roof)
                             : rise(Foot_h),
                         Print_h / 3);

// What is left above the foot, and how much of it the shade may take: a stem too
// short to see would leave the shade sitting on the floor.
function room()       = Print_h - foot_h();
function shade_room() = room() - min(rise(Stem_h), room() * 0.25);
// The widest the shade can get in that room at 45 deg. A globe has to close again
// above its widest point, so it only gets Globe_rise of the room on the way up.
function shade_d() = min(cm(Shade),
                         stem_d() + 2 * shade_room() * (Type == "globe" ? Globe_rise
                                                                        : 1));
// The 45 deg flare onto the full width — as tall as it is wide, the steepest a
// printer takes without support, and the floor under every shade height below.
function flare() = (shade_d() - stem_d()) / 2;
function shade_h() =
      Type == "cone"   ? min(shade_room(), flare() * Cone_deep)
    : Type == "globe"  ? flare() / Globe_rise
    : Type == "tripod" ? flare()      // nothing above the flare: the legs get the rest
                       : min(shade_room(), flare() + Drum_wall);
function shade_z()    = Print_h - shade_h();
function shade_rest() = Type == "cone" ? 0 : shade_h() - flare();
// what the shade closes back in to at the top
function top_d() = Type == "globe" ? stem_d()
                 : shade_rest() > 0.01 ? shade_d() * Drum_top : shade_d();
// the patch of top face a symbol may use — on a globe that is the hole the stem would
// come through, far too small for one
function patch() = top_d() - 2 * Symbol_margin;
