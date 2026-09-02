// hobby / photo_studio — a photographer's backdrop-and-lights set: a wide seamless
// backdrop that COVES down to the floor at its base, with a softbox light angled in from
// each front corner and a round posing stool in the middle. It is the corner of a home
// studio, seen from across the table.
//
// The backdrop is the point, and it is what tells this piece from the projector screen
// (hobby/projector_screen.scad), which is otherwise the same idea — a big upright board
// on a low base. Two things set it apart: the board is a plain sweep of paper, not a
// recessed 16:9 screen; and its base does not stop at the floor but curves forward into
// it as a real quarter-cove — the seamless "sweep" a cyclorama has, so there is no
// horizon line behind the subject. That concave cove is a genuine hollow of light, not an
// engraved hint, and it is the silhouette a low angle reads as a studio.
//
// In section, front (-Y) on the left:
//
//        |‾|          the backdrop paper: a thin upright panel, full width (backdrop())
//        | |
//       /  |          the COVE: a concave quarter-sweep from the paper down to the floor
//      /   |          (cove()) — the seamless curve, solid behind so it prints support-free
//   __/    |___
//  |___________|      the apron (the paper run on the floor) over a solid foot at the back
//
// The lights are softboxes, not stands: a real light stand is a tripod of 1 mm threads at
// 1:40 that will not print and snaps if it does (the reason projector_screen.scad has no
// tripod and lamp.scad no wire). Each is a rectangular box — a diffuser recessed into its
// front face — on a low foot, TURNED in plan to face the set, which is a yaw a printer
// does not care about and reads as a light aimed at the subject. Nothing leans forward,
// so nothing overhangs; the stool is a plain drum for the same reason (a seat on a thin
// pedestal is an overhanging rim).
//
// Width is the real backdrop width in cm — 200 (a 2 m paper) is the built size; the whole
// set fits within it. Depth is the floor the set takes front-to-back — the cove plus the
// run of paper the subject stands on. Height is the real backdrop height, the tallest
// thing here (the lights stand lower), shrunk by the plan scale (see printed_h() in
// lib/common.scad). It PRINTS UPRIGHT as modelled: every panel is vertical (draft-tapered
// like the projector board), the cove is concave so each layer nests over the one below,
// and the magnet pockets open at the floor under the solid back foot.

include <../lib/common.scad>

Width  = 200;  // cm — the backdrop width, and the width the whole set fits within
Depth  = 120;  // cm — floor front-to-back: the cove sweep plus the paper run in front
Height = 200;  // cm — the backdrop height (the tallest thing; the lights stand lower)

// the printed height, mm: the backdrop's Height at the plan scale
Print_h = printed_h(Height);

// -- The backdrop (paper + cove) ----------------------------------------------
Show_backdrop = true;
Paper_margin  = 8;    // cm the paper is inset each side of Width (its ends, on the roll)
Paper_d       = 8;    // cm — paper/panel thickness: a thin upright board, ~2 mm at 1:40
Paper_taper   = 0.5;  // printed mm the board pulls in toward the top (draft, prints upright)
Sweep_r       = 50;   // cm — radius of the concave cove from the paper base to the floor

// -- The back foot (buries the magnets) ---------------------------------------
// A solid block across the back, under the paper and cove, deep and tall enough to hold a
// 4x2 disc where the thin paper never could — the same trick projector_screen.scad uses.
Foot_d = 26;  // cm — deep enough for a 4 mm disc (~25 cm at 1:40), no deeper
Foot_h = 16;  // cm — floored to Height_min so the pocket fits at any Height_scale

// -- The apron (the paper run on the floor) -----------------------------------
Apron_h = 5;  // cm — a low floor slab in front of the cove; the lights and stool stand on it

// -- Softbox lights -----------------------------------------------------------
Show_lights = true;
Box_w      = 66;  // cm — the softbox face (width) ...
Box_h      = 92;  // ... its height ...
Box_d      = 12;  // ... and its thickness
Box_foot_w = 34;  // cm — the stand foot under it (w x d), a low base, not a tripod
Box_foot_d = 28;
Box_foot_h = 20;  // cm the foot lifts the box off the floor
Box_toe    = 35;  // deg each box is turned in plan to face the set
Box_margin = 6;   // cm the box foot is kept in from the side
Box_front  = 44;  // cm from the front edge to the box-foot centre
Diffuser_inset = 0.16;  // the diffuser recess border, as a fraction of the face
Diffuser_cut   = 0.6;   // printed mm the diffuser is sunk into the front face

// -- Posing stool -------------------------------------------------------------
Show_stool = true;
Stool_d     = 34;  // cm — a round drum stool (no thin legs — see the header)
Stool_h     = 46;  // cm — seat height
Stool_front = 30;  // cm from the front edge to the stool centre

// Magnet pockets in the bottom face, in a row along the width (0 = none). Two keep a wide,
// tall, light piece from pivoting; they go in the solid back foot (see Foot_* above).
Magnets = 2;

// ---- geometry (real cm anchors, back = +Y) ----------------------------------
function paper_front() = Depth / 2 - Paper_d;               // y of the paper's front face
function cove_front()  = paper_front() - Sweep_r;           // y where the cove meets floor
function foot_cy()     = Depth / 2 - Foot_d / 2;            // y centre of the back foot

photo_studio();

module photo_studio() {
    if (Depth < Paper_d + Sweep_r + 10)
        echo(str("WARNING: a ", Depth, " cm depth has no room for a ", Paper_d,
                 " cm paper + a ", Sweep_r, " cm cove + an apron — give it more (Depth)"));
    difference() {
        union() {
            foot();
            if (Show_backdrop) { backdrop(); cove(); }
            apron();
            if (Show_lights) softboxes();
            if (Show_stool)  stool();
        }
        if (Magnets > 0)
            translate([0, cm(foot_cy()), 0]) magnets(Width, Foot_d, Magnets);
    }
}

// The solid back foot: a low block across the full width, deep enough for the disc. Its
// height is floored to Height_min so a pocket still fits when Height_scale squashes the set.
module foot() {
    translate([0, cm(foot_cy()), 0])
        footprint(Width, Foot_d, printed_h(Foot_h));
}

// The backdrop paper: a thin upright board at the back, full width less its roll ends,
// draft-tapered so it prints upright (as projector_screen.scad's board does).
module backdrop() {
    translate([0, cm(Depth / 2 - Paper_d / 2), 0])
        cushion(Width - 2 * Paper_margin, Paper_d, -0.01, Height, Paper_taper, Corner_radius);
}

// The cove: a concave quarter-sweep filling the corner between the paper (vertical) and the
// floor, so the backdrop has no horizon line. Built as a corner block with an elliptical
// column carved out of its front-top — the remaining solid's face is the concave sweep, and
// because its cross-section only ever shrinks on the way up it prints with nothing to
// support. Its z-radius rises with Height_scale, its y-radius does not, so it stays tied to
// whatever the paper does.
module cove() {
    yw = cm(paper_front());
    Ry = cm(Sweep_r);
    Rz = rise(Sweep_r);
    cy = yw - Ry;                       // printed y of the cove front (on the floor)
    w  = cm(Width - 2 * Paper_margin);
    difference() {
        translate([0, (cy + yw) / 2, Rz / 2]) cube([w, Ry, Rz], center = true);
        translate([0, cy, Rz])
            scale([1, Ry, Rz]) rotate([0, 90, 0])
                cylinder(h = w + 2, r = 1, center = true);
    }
}

// The apron: a low floor slab from the cove front forward to the front edge (overlapping
// back under the cove so the two weld), the paper run the subject stands on and what the
// lights and stool stand on.
module apron() {
    y0 = -Depth / 2;
    y1 = cove_front() + 6;              // overlap under the cove base for a solid weld
    translate([0, cm((y0 + y1) / 2), 0])
        footprint(Width - 2 * Paper_margin, y1 - y0, rise(Apron_h));
}

// The two softboxes, one at each front corner, each turned Box_toe degrees in plan to face
// the set (a yaw the printer ignores; nothing leans, so nothing overhangs).
module softboxes() {
    for (s = [-1, 1])
        translate([s * cm(Width / 2 - Box_margin - Box_foot_w / 2),
                   cm(-Depth / 2 + Box_front), 0])
            rotate([0, 0, -s * Box_toe])
                softbox();
}

// One softbox: a rectangular box on a low foot, the diffuser recessed into its front (-Y)
// face. The box is a draft-tapered cushion() so it prints upright like the backdrop.
module softbox() {
    foot_top = rise(Apron_h) + rise(Box_foot_h);
    union() {
        footprint(Box_foot_w, Box_foot_d, foot_top);              // the stand foot
        difference() {
            cushion(Box_w, Box_d, foot_top - 0.01, Box_h, Cushion_taper, Corner_radius);
            front_recess(0, foot_top + rise(Box_h) / 2,
                         cm(Box_w) * (1 - 2 * Diffuser_inset),
                         rise(Box_h) * (1 - 2 * Diffuser_inset),
                         Box_d, Diffuser_cut + Cushion_taper);
        }
    }
}

// The posing stool: a plain round drum (a seat on a thin pedestal would overhang at the
// rim — see the header), standing on the apron in the middle of the set.
module stool() {
    translate([0, cm(-Depth / 2 + Stool_front), 0])
        cylinder(h = rise(Apron_h) + rise(Stool_h), d = cm(Stool_d));
}
