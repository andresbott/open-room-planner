// hallway / coat_rack — a slim, tall coat stand (a hall tree): a splayed foot that
// steps up into a slim square post, capped by a small hat-rest knob, with a cluster of
// pegs suggested in relief near the top. It is a little MODEL of a stand, not a box with
// the hooks drawn on its lid — which is what the first version was, a 40x40x180 solid
// with four dots engraved on the top face, the one face a plan photograph sees least of.
//
// A coat stand is mostly a pole, and a pole is the thing this scale cannot draw: a real
// 5 cm newel is 1.25 mm across at 1:40 and a real hook is a 1 mm spike that snaps off in
// the box and cannot print in mid-air anyway. So the token keeps what a plan cares about
// — the FOOT it stands on and how TALL it is — and redraws the rest as form that prints
// upright and support-free:
//   - the foot is the full footprint at the floor and narrows to the post on the way up.
//     Narrowing upward, every layer lands inside the one below, so the splay prints clean
//     at any steepness (it is the one direction an overhang cannot happen) and the whole
//     40x40 bottom face is left flat and wide for the magnet, low in solid material.
//   - the post is thickened to a printable minimum and always kept long enough to read as
//     a post (Post / Post_min), exactly as livingroom/lamp.scad floors its stem.
//   - the top is a small knob, reached by a 45 deg flare OUT from the post — widening
//     upward is the overhang direction, so it is held to 45 deg (flare(): height == step)
//     and then capped flat. It reads as the hat rest a hall tree has and, unlike a lamp,
//     the stand does NOT spread into a wide shade up there.
//   - the hooks are short VERTICAL half-round bars up the post's front (-Y) and side
//     (+/-X) faces — a peg is a horizontal spike and forbidden (§1.3), but a half-round
//     prism running the print direction lands every layer squarely on the one below and
//     stands proud of a face with no overhang, the one thing that may (bathroom/cabinet
//     .scad's handle). Stacked near the top they read as the knobby head of a hall tree
//     from the low angle the plan is photographed at; the back (+Y) is left plain so the
//     stand can face a wall.
//
// Width/Depth are the real-world footprint in cm — a coat stand's base is slim, 40 x 40
// here, just enough to keep a tall piece from tipping. Height is the real height, up at
// hook height above a hanging coat — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so it stands as tall as the wardrobes. Prints UPRIGHT
// as modelled, on its 40 x 40 foot, with the magnet pocket opening at that bottom face.
//
// In section (front, -Y, to the left):
//
//        __            the knob cap, a 45 deg flare out from the post, capped flat
//       /  \
//     ||    |          the pegs: short vertical half-round bars up the post's faces
//     |o    |          ... near the top, under the cap
//     |o    |
//      |    |          the slim post (Post, floored to Post_min)
//      |    |
//     /      \         the foot splays out ...
//    |________|        ... to the full 40 x 40 base plate the magnet sits in

include <../lib/common.scad>

Width  = 40;   // cm
Depth  = 40;   // cm
Height = 180;  // cm — up at hook height

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

// The splayed foot: a flat base plate (raised to roof a magnet pocket where one is cut,
// as lamp.scad's foot is) that narrows to the post over a splay. Real cm, bar Foot_roof.
Foot_base  = 5;    // cm of flat base plate under the splay
Foot_splay = 12;   // cm the footprint narrows in to the post over
Foot_roof  = 0.6;  // printed mm of material kept over a magnet pocket in the base

// The post: a slim square column. A real newel is finer than a nozzle at 1:40, so its
// real width comes second to a printed floor (Post_min) — six perimeters at 0.4, a pole
// this thick stands up to the print and to handling, like lamp.scad's Stem_min.
Post     = 10;   // cm, the post's real square width
Post_min = 2.4;  // printed mm floor for it

// The top: a small hat-rest knob. A 45 deg flare out from the post to Cap, then a flat
// cap of Cap_top. Real cm; the flare's height is the step, so it stays in printed mm.
Show_cap = true;
Cap      = 20;   // cm, the knob's width — wider than the post, narrower than the foot
Cap_top  = 4;    // cm of flat cap above the flare

// The hooks: short vertical half-round bars — pegs — near the top of the post, on the
// front (-Y) and both side (+/-X) faces. Hardware, so the bar diameter is printed mm.
Show_hooks = true;
Hook_n     = 3;     // pegs stacked up the zone on each face
Hook_d     = 0.9;   // printed mm, the bar diameter (half buried in the post, half proud)
Hook_zone  = 0.42;  // the top fraction of the post the pegs occupy
Hook_fill  = 0.6;   // how much of each peg's slot the bar fills — the rest is the gap

// Magnet pocket in the bottom face (0 = none). The foot is the full 40 x 40 footprint —
// 10 mm across at 1:40, wide enough for the 4 mm disc; see Magnet_* in lib/common.scad.
Magnets = 1;

// ---- what fits in the height the stand has ----------------------------------
// The post's printed width: its real width, never under the printable floor.
function post_w() = max(cm(Post), Post_min);
// The post outline, at that printed width — plan_cm() takes the clamped printed mm back
// to the real cm footprint_2d() re-applies cm() to, so the square comes out post_w() mm.
function post_wcm() = plan_cm(post_w());

// The flat base plate, printed mm: its own height, but deep enough to roof a magnet
// pocket wherever one is actually cut — never more than a third of the piece.
function foot_base_h() =
    min(Print_h / 3,
        (Magnets > 0 && magnet_count(Width, Depth, Magnets) > 0)
            ? max(rise(Foot_base), magnet_pocket_h() + Foot_roof)
            : rise(Foot_base));
function foot_splay_h() = min(rise(Foot_splay), Print_h / 3);
function foot_h()       = foot_base_h() + foot_splay_h();

// The cap: a 45 deg flare out to Cap and a flat block over it — but only when Cap is
// wider than the post it stands on (at a tiny scale it may not be), else there is none.
function cap_w()       = max(cm(Cap), post_w());
function cap_flare_h() = (cap_w() - post_w()) / 2;    // 45 deg: the height IS the step
function cap_h()       = (Show_cap && cap_w() > post_w() + 0.01)
                             ? cap_flare_h() + rise(Cap_top) : 0;

// What is left for the post between the foot and the cap.
function post_h() = Print_h - foot_h() - cap_h();

coat_rack();

module coat_rack() {
    if (cm(Post) < Post_min - 0.001)
        echo(str("NOTE: a ", Post, " cm post is finer than ", Post_min, " mm at 1:",
                 Scale, " — printed ", post_w(), " mm instead (it still stands)"));
    if (post_h() < post_w())
        echo(str("WARNING: a ", Height, " cm stand at 1:", Scale, " x", Height_scale,
                 " leaves only ", rise_cm(max(0, post_h())),
                 " cm of post under the foot and cap (give it more: COAT_RACK_H)"));
    union() {
        difference() {
            union() {
                foot();
                post();
                if (cap_h() > 0) cap();
            }
            if (Magnets > 0)
                magnets(Width, Depth, Magnets);   // the full foot touches the board
        }
        // added last, so nothing cuts into them — the cabinet-handle rule
        if (Show_hooks)
            hooks();
    }
}

// ---- the pieces of a coat stand ---------------------------------------------

// The foot: the full footprint as a flat plate, then a splay narrowing in to the post.
// The splay narrows going up, so the outer face only ever leans IN as it rises — no
// layer overhangs the one below, whatever the splay's angle.
module foot() {
    linear_extrude(height = foot_base_h() + 0.01)
        footprint_2d(Width, Depth);
    translate([0, 0, foot_base_h()])
        flare(foot_splay_h()) {
            footprint_2d(Width, Depth);
            footprint_2d(post_wcm(), post_wcm());
        }
}

// The slim post, from the top of the foot up to the underside of the cap.
module post() {
    translate([0, 0, foot_h() - 0.01])
        linear_extrude(height = max(0.02, post_h() + 0.02))
            footprint_2d(post_wcm(), post_wcm());
}

// The hat-rest knob: a 45 deg flare out from the post, then a flat cap over it.
module cap() {
    translate([0, 0, foot_h() + post_h() - 0.01]) {
        flare(cap_flare_h() + 0.01) {
            footprint_2d(post_wcm(), post_wcm());
            footprint_2d(plan_cm(cap_w()), plan_cm(cap_w()));
        }
        translate([0, 0, cap_flare_h()])
            linear_extrude(height = rise(Cap_top) + 0.01)
                footprint_2d(plan_cm(cap_w()), plan_cm(cap_w()));
    }
}

// The pegs: a stack of short vertical half-round bars in the top of the post, on the
// front (-Y) and both side (+/-X) faces. A bar is a vertical prism — every layer lands
// on the one below, so it prints proud of the face with no support (as cabinet.scad's
// handle) — and it is a bump, not a horizontal spike, so there is nothing to snap off.
module hooks() {
    z0   = foot_h() + post_h() * (1 - Hook_zone);   // bottom of the peg zone ...
    z1   = foot_h() + post_h();                      // ... and the top, under the cap
    n    = max(1, Hook_n);
    slot = (z1 - z0) / n;
    len  = max(Hook_d, slot * Hook_fill);
    if (slot < Hook_d)
        echo(str("NOTE: a ", Height, " cm stand at 1:", Scale, " x", Height_scale,
                 " has no room for ", n, " pegs — stacked them at ", slot, " mm anyway"));
    f = post_w() / 2;   // the post's face, printed mm from the centre
    for (i = [0 : n - 1]) {
        zc = z0 + slot * (i + 0.5) - len / 2;
        translate([0,  -f, zc]) cylinder(h = len, d = Hook_d);   // front (-Y)
        translate([-f,  0, zc]) cylinder(h = len, d = Hook_d);   // sides (+/-X)
        translate([ f,  0, zc]) cylinder(h = len, d = Hook_d);
    }
}
