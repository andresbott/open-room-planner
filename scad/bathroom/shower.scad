// bathroom / shower — a shower-tray token: a real recessed pan, not a flat block
// with a line drawn on it. A flat rim runs round a sunken floor, and a round
// drain is sunk into that floor, so the piece reads as a shower tray from above
// and at a low angle. An optional low kerb stands in for a walk-in enclosure's
// upstand.
//
// Width/Depth are the real-world tray footprint in cm — 90x90 is the common
// square tray, 80x120 a common rectangular one; the Makefile builds a range of
// standard sizes. Height is the real height of the tray — the pan plus the waste
// build-up under it — shrunk by the plan scale like the footprint (see printed_h()
// in lib/common.scad). It is the lowest piece of the set by a long way, and the only
// one that can reach Height_min.

include <../lib/common.scad>

Width  = 90;  // cm
Depth  = 90;  // cm
Height = 10;  // cm — the pan and the waste under it: floor level

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_tray = true;   // recess the pan floor and sink the drain into it
// The flat rim left around the sunken floor and how far the floor drops below it,
// both real cm. There is not much height to give away here, so the recess is clamped
// to what the tray leaves over a magnet pocket — see tray_h(), which warns when it
// had to take any of it back.
Rim_w      = 5;    // cm, flat rim around the pan
Tray_depth = 4;    // cm, how far the floor sits below the rim
Tray_floor = 0.6;  // printed mm kept under the pan floor, over a magnet pocket
Tray_r     = 1.5;  // mm, internal corner rounding of the pan floor — a moulded
                   // tray curves into its corners, so this is softer than the
                   // block's own Corner_radius

// The drain, centred in the floor: a round gully sunk below the floor, ringed by
// a shallow groove standing in for the cover seated around it — a hole plus a
// ring reads as a drain at this size, where a fine grate just closes up into a
// blob. The gully diameter and the ring gap are real cm; the sink depth is
// printed mm (a drawing detail, like Symbol_stroke — it does not scale).
Drain_d    = 12;   // cm, drain-gully diameter
Drain_sink = 0.6;  // mm, how far the gully drops below the pan floor
Flange_gap = 3;    // cm, ring set out around the gully — the seated cover's edge

// A low kerb along the two open edges (+X, +Y), standing in for a walk-in
// enclosure's upstand rather than a full glass screen (which would be a
// fraction of a mm thick at this scale — nothing to print). Off by default:
// keep the token a flat, printable pan; it self-tapers like cushion() so it
// needs no support even switched on, and it rises from the sunken floor so
// there is no gap under it.
Show_enclosure  = false;
Enclosure_w     = 10;   // cm, kerb width — chunky on purpose, see above
Enclosure_h     = 10;   // cm, standing above the rim
Enclosure_taper = 0.4;  // mm, top pulled in so the kerb slopes, not steps
Enclosure_r     = 0.5;  // mm, corner rounding — smaller than Cushion_radius,
                         // the kerb is too thin for the usual pillow rounding

// Magnet pocket in the bottom face (0 = none). The tray is near-square, so one
// central pocket is enough to stop it pivoting; at 90 cm the footprint is 22.5 mm
// at 1:40 — comfortably wide enough for the 4 mm disc, and the pan floor above
// it stays solid (see Magnet_* in lib/common.scad).
Magnets = 1;

shower();

module shower() {
    if (Show_tray && tray_h() < rise(Tray_depth) - 0.001)
        echo(str("WARNING: a ", Tray_depth, " cm pan does not fit in a ", Height,
                 " cm tray over ", tray_under(), " mm of magnet pocket — sunk ",
                 rise_cm(tray_h()), " cm instead (give it more: SHOWER_H)"));
    union() {
        difference() {
            footprint(Width, Depth, Print_h);
            if (Show_tray) {
                tray(Print_h);
                drain(Print_h - tray_h());   // the drain sits in the sunken floor
            }
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);
        }
        if (Show_enclosure)
            enclosure(Print_h);
    }
}

// How deep the pan actually gets: what is left of the tray's height once the floor
// under it — the drain's gully, and a magnet pocket below that where one fits — has
// had its share. Same clamp as bathtub.scad's basin_h().
function tray_under() = magnet_count(Width, Depth, Magnets) > 0
                            ? magnet_pocket_h() : 0;
function tray_h() = max(0, min(rise(Tray_depth),
                              Print_h - tray_under() - Tray_floor - Drain_sink));

// The sunken pan floor: a rounded-rectangle pocket inset Rim_w from the tray
// edge, tray_h() deep, with softly rounded internal corners so it reads as a
// moulded tray rather than a milled slot.
module tray(top_z, inset = Rim_w, depth = tray_h(), r = Tray_r) {
    if (depth > 0)
        translate([0, 0, top_z - depth])
            linear_extrude(height = depth + 0.01)
                offset(r = r) offset(delta = -r)
                    offset(delta = -cm(inset)) footprint_2d(Width, Depth);
}

// The drain in the middle of the floor: a round gully sunk Drain_sink below the
// floor, with a shallow ring groove set Flange_gap out around it (cut Label_depth
// deep) for the cover edge — a hole inside a ring, so it reads as a drain and not
// a stray pocket.
module drain(floor_z, d = Drain_d, sink = Drain_sink, gap = Flange_gap,
             stroke = Symbol_stroke, flange = Label_depth) {
    r = cm(d) / 2;
    translate([0, 0, floor_z - sink])           // the gully
        linear_extrude(height = sink + 0.01)
            circle(r = r);
    translate([0, 0, floor_z - flange])         // the cover ring around it
        linear_extrude(height = flange + 0.01)
            stroke_arc(r + cm(gap), 0, 360, stroke);
}

// A low kerb along the two open edges of the tray (+X, +Y) — the sides a walk-in
// shower has no fixed room wall behind. Built with cushion() on each edge so it
// self-tapers the same way a pillow does, then clipped to the tray outline so it
// keeps the rounded corner instead of overhanging it (the same trick legs() uses
// in diningroom/table.scad). It rises from the sunken floor when the tray is
// recessed, so it fills the pan under the kerb instead of bridging over it.
module enclosure(top_z, h = Enclosure_h, w = Enclosure_w, taper = Enclosure_taper,
                 r = Enclosure_r) {
    base_z = Show_tray ? top_z - tray_h() : top_z;
    // fill the recess, then stand h above the rim — in real cm, as cushion() takes
    total  = rise_cm(top_z - base_z) + h;
    intersection() {
        translate([0, 0, base_z - 0.02])
            linear_extrude(height = rise(total) + 0.5) footprint_2d(Width, Depth);
        union() {
            translate([cm(Width) / 2 - cm(w) / 2, 0, 0])
                cushion(w, Depth, base_z, total, taper, r);
            translate([0, cm(Depth) / 2 - cm(w) / 2, 0])
                cushion(Width, w, base_z, total, taper, r);
        }
    }
}
