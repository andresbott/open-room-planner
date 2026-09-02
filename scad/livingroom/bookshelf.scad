// livingroom / bookshelf — an open shelving unit token (BILLY-style): a real
// recessed front of stacked open compartments, not a symbol engraved on top.
//
// A bookshelf is open at the front, so that is where the shelves have to read —
// and a token seen from above cannot show them. This one carves them for real:
// the compartments are cut back into the FRONT (-Y) face the way washbasin.scad
// cuts its bowl, leaving side walls, a base, a shelf between each pair and a back
// panel. Printed on its BACK — front face up — every divider stands as a vertical
// wall, so the thin panels come out clean with nothing to bridge; upright, each
// shelf underside would be an overhang. That is what makes real shelves worth it
// here, where every other carcass just engraves a symbol.
//
// Width/Depth are the real-world footprint in cm — commonly 40/60/80 wide, 28
// deep (the BILLY carcass). Height is the real carcass height — 202 cm tall, or
// 106 for the half-height one — shrunk by the plan scale like the footprint (see
// printed_h() in lib/common.scad), so it is one of the tallest pieces of the set.
//
// A real 2 cm shelf is only 0.5 mm at 1:40, under two perimeters, so the panels
// print at a floor of Panel_min (the way lamp.scad floors its pole at Stem_min),
// rising to true scale only when the plan is drawn larger.
//
// The shelves come STOCKED WITH BOOKS by default — this is a bookshelf, and an empty one
// reads as any open shelving (the KALLAX and the IVAR next door). Each compartment holds a
// row of books of varying width and height, so what a low angle reads is the ragged skyline
// of their tops: real form, not a symbol.
//
// The books ABUT — one solid mass per shelf, with the join between two of them cut in as a
// narrow seam in the front face. They are deliberately not separate spines with air between:
// at 1:40 a book is about a millimetre wide, so a row of freestanding ones is a comb of
// single-perimeter columns that print badly and snap off. Massed together they are one broad
// solid, and what tells the books apart is the same thing that tells a run of drawer fronts
// apart — the shadow line between them (Book_seam) plus the step where two neighbours differ
// in height. Relief and a cut, never a fragile spike (§1.1, §1.3).
//
// The mass runs the full depth to the back panel and fuses into it, so — printed on its back
// like the carcass — it is one clean vertical wall with nothing to bridge, and the seams are
// short recesses in a face that is pointing up. The stocking is deterministic (a fixed hash),
// so a re-render is the same shelf; every other shelf is left part-empty and mirrored, so the
// run does not stripe.

include <../lib/common.scad>

Width  = 80;   // cm
Depth  = 28;   // cm
Height = 202;  // cm — tall carcass (106 for the half-height one)

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_shelves = true;
// Open compartments stacked up the front; 0 = derive one per Shelf_target cm of
// carcass, so the tall frame gets about six and the half-height one about three.
Compartments = 0;
Shelf_target = 33;   // cm — target clear height of one compartment when deriving
// Panel thicknesses in real cm — the side walls and shelves, and the back panel
// left at the +Y face — each floored at Panel_min printed mm so they still print
// at 1:40 (see the header).
Shelf_th  = 2;    // cm — side walls, shelves
Back_th   = 2;    // cm — back panel left at the +Y face
Panel_min = 0.8;  // printed mm — two perimeters at a 0.4 mm nozzle
// Magnet pockets in the bottom face (0 = none). A 28 cm-deep piece is 7 mm across
// at 1:40 — wide enough for a 4 mm disc; the base is kept thick enough to seat it.
Magnets = 1;

// Books stocked in the compartments (see the header). All real cm except the fractions and
// the seam, which is printed mm — it is a drawing detail like Front_gap, so it does not scale.
Book_min_w  = 3;     // cm — a thin book ...
Book_max_w  = 5.5;   // ... and a thick one (a book is ~1 mm at 1:40, so a volume or two)
Book_min_hf = 0.6;   // shortest book, as a fraction of a compartment's clear height ...
Book_max_hf = 0.95;  // ... and the tallest, so the tops make a ragged skyline
Book_front  = 2;     // cm the books sit back from the carcass front — a shelf lip in front
Book_fill   = 0.86;  // average share of a shelf's width the books take (the rest left open)
Book_skip   = 0.07;  // chance a slot is left empty — a real gap where a book is missing
Book_max_n  = 50;    // most books one shelf can hold — a safe cap on the walk below
// The seam between two abutting books: the shadow line that reads them apart (see the
// header). One nozzle wide, so it prints as a real groove and not a smear.
Book_seam       = 0.4;  // printed mm wide ...
Book_seam_depth = 0.4;  // ... and mm deep into the front face of the mass

// ---- panel geometry (printed mm) --------------------------------------------
// A panel is a real thickness where the scale gives enough, else the print floor.
function panel_t() = max(cm(Shelf_th), Panel_min);
function back_t()  = max(cm(Back_th), Panel_min);
// The base carries the magnet pocket, so it keeps a wall of material over it.
function base_t()  = Magnets > 0 ? max(panel_t(), magnet_pocket_h() + Panel_min)
                                 : panel_t();
// Compartments: as asked for, or one per Shelf_target cm of the clear inner run
// (the carcass less the base and the top panel), measured back in real cm.
function n_comp() = Compartments > 0 ? Compartments
    : max(1, round(rise_cm(Print_h - base_t() - panel_t()) / Shelf_target));
// Clear height of one compartment: the run above the base, split n_comp() ways,
// less the shelf that divides each pair.
function comp_h() = (Print_h - base_t()) / n_comp() - panel_t();

bookshelf();

module bookshelf() {
    difference() {
        footprint(Width, Depth, Print_h);
        if (Show_shelves) shelves();
        if (Magnets > 0) magnets(Width, Depth, Magnets);
    }
    // the books go in AFTER the compartments are cut, filling the emptied bays
    if (Show_shelves) books();
}

// The open front: n_comp() compartments cut back into the -Y face, each the full
// clear width and the clear depth (a back panel is left at +Y), stacked from the
// base up with a shelf of panel_t() between each pair and the top panel left on.
module shelves() {
    t  = panel_t();
    n  = n_comp();
    ch = comp_h();
    if (ch < Panel_min)
        echo(str("WARNING: ", Width, "x", Height, " cm at 1:", Scale, " leaves ",
                 ch, " mm per compartment over ", n, " — too thin, shelves skipped"));
    else
        for (i = [0 : n - 1])
            compartment(base_t() + i * (ch + t) + ch / 2, ch);
}

// One open compartment: a full-width slot cut from the front (-Y) face back to the
// back panel, <ch> mm tall, centred at <cz> up from the bottom. Like washbasin.scad's
// front_cut(), the cut runs a hair past the front face so the mouth comes out clean.
module compartment(cz, ch) {
    w   = cm(Width) - 2 * panel_t();      // between the two side walls
    len = cm(Depth) - back_t() + 0.01;    // front face back to the back panel
    translate([0, -(back_t() + 0.01) / 2, cz])
        cube([w, len, ch], center = true);
}

// ---- books ------------------------------------------------------------------
// A deterministic 0..1 hash, so the "random" stocking is identical on every render — the
// tracked STL stays stable (the classic sin-fract trick; OpenSCAD sin() is in degrees).
function bhash(x) = let (s = sin(x * 127.1 + 311.7) * 43758.5453) s - floor(s);
// One spine's width (cm) and its height as a fraction of the compartment, per (shelf, slot).
function book_w_cm(ci, j) = Book_min_w + (Book_max_w - Book_min_w) * bhash(ci * 31.4 + j * 57.1 + 2.7);
function book_hf(ci, j)   = Book_min_hf + (Book_max_hf - Book_min_hf) * bhash(ci * 17.9 + j * 41.3 + 9.2);
function book_skip(ci, j) = bhash(ci * 23.1 + j * 8.7 + 5.5) < Book_skip;
// The left edge of slot j, printed mm from the row start — the running sum of the widths
// before it. No gap is added: the books abut, and the seam is cut in afterwards.
function book_x(ci, j)    = j <= 0 ? 0 : book_x(ci, j - 1) + cm(book_w_cm(ci, j - 1));
// How much of a shelf's width this row fills, jittered per shelf around Book_fill.
function book_fill(ci)    = max(0.45, min(1, Book_fill + (bhash(ci * 13.7 + 1.3) - 0.5) * 0.5));
// The clear width between the side walls, and how much of it this row fills.
function book_w()         = cm(Width) - 2 * panel_t();
function book_run(ci)     = book_fill(ci) * book_w();
// Whether slot j holds a book: it has to fit inside the row and not be a skipped gap. The
// mass and the seams both read it from here, so a seam can never land beside a missing book.
function book_used(ci, j) =
    book_x(ci, j) + cm(book_w_cm(ci, j)) <= book_run(ci) && !book_skip(ci, j);

// One row of upright spines per compartment, stacked the same way shelves() cuts the bays.
module books() {
    t  = panel_t();
    n  = n_comp();
    ch = comp_h();
    if (ch >= Panel_min)
        for (i = [0 : n - 1])
            book_row(base_t() + i * (ch + t) + ch / 2, ch, i);
}

// A shelf's books, mirrored on every other shelf so the open end alternates side.
module book_row(cz, ch, ci) {
    if (ci % 2 == 0) book_spines(cz, ch, ci);
    else mirror([1, 0, 0]) book_spines(cz, ch, ci);
}

// One shelf's books: the massed solid with the seams between them cut into its front face.
module book_spines(cz, ch, ci) {
    difference() {
        book_mass(cz, ch, ci);
        book_seams(cz, ch, ci);
    }
}

// The mass: books walked left to right up to book_fill() of the clear width, each abutting
// the last and full-depth to the back panel (fused into it, so it prints as one clean wall on
// its back). Some slots are left empty, which leaves a real gap where a book is missing.
module book_mass(cz, ch, ci) {
    bottom = cz - ch / 2;                          // the shelf top the books stand on
    w      = book_w();
    y0     = -cm(Depth) / 2 + cm(Book_front);      // front face, set back a shelf lip
    y1     =  cm(Depth) / 2 - back_t() + 0.01;     // fused into the back panel
    for (j = [0 : Book_max_n - 1])
        if (book_used(ci, j))
            translate([-w / 2 + book_x(ci, j), y0, bottom])
                cube([cm(book_w_cm(ci, j)), y1 - y0, book_hf(ci, j) * ch]);
}

// The seams: a narrow groove down the front face at every join between two books that are
// both there. It stops at the shorter of the two, so it never cuts air above a low book, and
// it only bites Book_seam_depth into the face — a shadow line, not a slot through the mass.
module book_seams(cz, ch, ci) {
    bottom = cz - ch / 2;
    w      = book_w();
    y0     = -cm(Depth) / 2 + cm(Book_front);
    for (j = [1 : Book_max_n - 1])
        if (book_used(ci, j) && book_used(ci, j - 1))
            translate([-w / 2 + book_x(ci, j) - Book_seam / 2, y0 - 0.1, bottom - 0.1])
                cube([Book_seam, Book_seam_depth + 0.1,
                      min(book_hf(ci, j), book_hf(ci, j - 1)) * ch + 0.1]);
}
