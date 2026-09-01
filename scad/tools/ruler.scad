// tools / ruler — a measuring stick for the plan itself, not a piece of furniture: a low
// flat bar carrying a scale, so you can lay it across the board and read how much real room
// a run of pieces takes without doing the 1:40 arithmetic in your head. A tick every 50 cm,
// a longer tick and an engraved number every 100 cm, with a "0" at the left end — and over the
// first 100 cm, a finer tick every 10 cm, like the detailed end of a tape measure.
//
// The one thing that makes it work is that the marks are drawn through cm(), the same
// real-cm -> printed-mm conversion every part uses (see lib/common.scad): a 100 cm tick sits
// at cm(100) along the bar, so the ruler is correct at WHATEVER Scale the set is built at —
// render the whole catalogue at 1:50 and the ruler's hundreds move to 20 mm apart to match,
// with no change here. The numbers are the real distance in cm (50, 100, 150 …), because that
// is the "common size" you want to check a doorway or a worktop run against.
//
// The marks go on the TOP face, because a ruler is the one thing you read from straight above
// rather than from a low angle across the table — there is nothing on its edges to see. They
// are engraved and not raised on purpose: this is genuinely ink (a scale IS printed lines), the
// one place §1.1's "relief beats ink" gives way, the same call the wall makes for its length.
//
// Length is the real distance the ruler SPANS, in cm — how far across the plan it reaches
// (500 cm = 5 m, a good reach for a room). Width is its real cross-section in cm, like a wall's
// thickness — thin, so like a wall it drops to the small 2x1 magnet disc. Height is the one
// exception the wall also makes: a PRINTED height in mm, not a scaled real one, because a
// ruler's real thickness (a few cm) would be under a millimetre and too flimsy to pick up — so
// it is a flat bar you set by hand instead. A ruler is usually happier with Magnets=0 (you
// slide it about), but it takes them like any thin ribbon if you want it to stay put.

include <../lib/common.scad>

Length = 500;  // cm — the real distance the ruler spans (its reach across the plan)
Width  = 24;   // cm — real cross-section, thin like a load-bearing wall (drops to the 2x1 disc)
Height = 6;    // PRINTED mm — a flat handleable bar, not a scaled real thickness (see the wall)

// The scale on it, in real cm: a tick every Minor, a longer tick + a number every Major.
Show_scale = true;
Minor = 50;    // cm between the short ticks ...
Major = 100;   // ... and between the long, numbered ones
// Label the minor (50 cm) ticks too, not just the hundreds — off by default, so the bar reads
// as cleanly as a tape measure; -D Label_minor=true when you want every mark called out.
Label_minor = false;

// The first Fine_span cm also carries a finer graduation — a short tick every Fine cm — so the
// start of the ruler reads like the detailed end of a tape measure while the rest stays a clean
// run of 50s. The fine ticks are shorter than the 50 cm ticks and skip where a 50/100 tick already
// falls, so they read as a subdivision and not a clash.
Fine      = 10;   // cm between the fine ticks in the first section (0 = no fine graduation)
Fine_span = 100;  // cm from the 0 end that carries the fine ticks

// Tick geometry, as fractions of the bar so it holds at any Width. A tick rises from the front
// (-Y) edge; the numbers sit in the clear band along the back (+Y) edge above the short ticks.
Minor_frac = 0.30;  // how far a short tick reaches across the bar ...
Major_frac = 0.50;  // ... and a long one, leaving the back half clear for the numbers
Fine_frac  = 0.18;  // ... and a fine (10 cm) tick, shorter still so the hierarchy reads
Tick_depth = 0.4;   // printed mm a tick is cut into the top face (one nozzle, like a symbol)
Num_depth  = 0.4;   // ... and a number

// Magnet pockets in the bottom face (0 = none). A ruler is a thin bar — 6 mm across at 1:40
// for a 24 cm width — so like the load-bearing walls it takes the small 2x1 disc, and the pad
// path (magnet_pads / pad = true) carries it at any narrower width or scale without going
// without. Along the length the count is clamped to what fits. Default off — a ruler is a thing
// you move around — but the Makefile can pin it to the board like anything else.
Magnets = 0;

// the printed bar: Length and Width are real cm, Height is already printed mm (the exception)
Print_h = Height;

ruler();

module ruler() {
    difference() {
        union() {
            footprint(Length, Width, Print_h, r = 0);  // square ends, like a wall segment
            if (Magnets > 0) magnet_pads(Length, Width, Magnets);
        }
        if (Show_scale) scale_marks();
        if (Magnets > 0) magnets(Length, Width, Magnets, pad = true);
    }
}

// The scale: a mark at every Minor cm from 0 at the left end to the last one that lands on the
// bar, the hundreds drawn longer and numbered. Everything is placed with cm(), so a mark sits
// where its real distance falls on the plan at the current Scale.
module scale_marks() {
    w      = cm(Width);
    x0     = -cm(Length) / 2;                 // the "0" end, at the left
    n      = floor(Length / Minor);           // how many Minor steps fit along it
    for (i = [0 : n]) {
        d       = i * Minor;                  // real cm this mark stands for
        is_maj  = (d % Major == 0);
        tick(x0 + cm(d), (is_maj ? Major_frac : Minor_frac) * w);
        if (is_maj || Label_minor) number(x0 + cm(d), d, is_maj);
    }
    // the fine graduation over the first Fine_span cm: a short tick every Fine cm, skipping the
    // 50/100 marks already cut, so the start of the ruler reads finely divided
    if (Fine > 0)
        for (i = [0 : floor(min(Fine_span, Length) / Fine)]) {
            d = i * Fine;
            if (d % Minor != 0)
                tick(x0 + cm(d), Fine_frac * w);
        }
}

// One tick: a one-nozzle slot rising from the front (-Y) edge across <reach> of the bar's width,
// cut Tick_depth into the top face.
module tick(x, reach) {
    translate([x - Symbol_stroke / 2, -cm(Width) / 2, Print_h - Tick_depth])
        cube([Symbol_stroke, reach, Tick_depth + 0.01]);
}

// One engraved number by its tick, in the clear band along the back (+Y) edge. Sized to the
// gap between two ticks so a long number (a "500") cannot run into its neighbour, and dropped
// when that falls below the legibility floor rather than printed as a blob (cf. wall_label()).
// The number sits just to the right of its tick, but its centre is CLAMPED so the whole number
// stays on the bar — without that the last number (at the right end) runs off the end and the
// engraving, with no material past the end to cut into, comes out sliced in half.
module number(x, d, is_maj) {
    w    = cm(Width);
    txt  = str(d);
    room = cm(is_maj ? Major : Minor) - Symbol_margin;   // along the bar, between ticks
    band = (1 - Major_frac) * w - Symbol_margin;         // across it, the clear back strip
    size = label_size(room, band, txt);
    half = 0.35 * size * len(txt);                       // the number's half-width (0.7*size/digit)
    cx   = x + cm(Minor) / 8;                            // just right of the tick ...
    cxc  = max(-cm(Length) / 2 + Symbol_margin + half,   // ... but kept clear of either end,
               min(cm(Length) / 2 - Symbol_margin - half, cx));   // so it is never sliced off
    if (size >= Symbol_min)
        translate([cxc, w / 2 - band / 2 - Symbol_margin / 2, Print_h - Num_depth])
            linear_extrude(height = Num_depth + 0.01)
                text(txt, size = size, halign = "center", valign = "center",
                     font = "DejaVu Sans");
}
