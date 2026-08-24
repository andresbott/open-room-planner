// bedroom / bed — a mattress-footprint token with the size engraved on top and
// raised pillows marking the head end.
//
// Width/Length are the real-world mattress size in cm (IKEA naming, e.g.
// 160x200), Height the real height of the made bed — the top of the mattress, the
// surface you sit on. All three are shrunk by the plan scale (see printed_h() in
// lib/common.scad), so a bed is one of the lowest pieces of the set.

include <../lib/common.scad>

Width  = 160;  // cm
Length = 200;  // cm
Height = 50;   // cm — top of the mattress

// the printed height, mm: Height at the plan scale
Print_h = printed_h(Height);

Show_label = true;
// Pillows at the head end (+Y), in real-world cm — an IKEA 80x50 one, narrowed to
// whatever the mattress leaves, standing Pillow_h proud of the mattress.
Pillow_w   = 80;
Pillow_d   = 50;
Pillow_gap = 4;    // mattress left around and between the pillows
Pillow_h   = 10;
// Mattresses this wide (cm) get two pillows instead of one.
Pillow_pair_from = 120;
// Magnet pockets in the bottom face, in a row along the length (0 = none).
// Two keep the piece from pivoting on the board; see Magnet_* in lib/common.scad.
Magnets = 2;

bed();

module bed() {
    n  = Width >= Pillow_pair_from ? 2 : 1;
    pw = min(Pillow_w, (Width - (n + 1) * Pillow_gap) / n);
    py = Length / 2 - Pillow_gap - Pillow_d / 2;
    union() {
        difference() {
            footprint(Width, Length, Print_h);
            if (Show_label)
                translate([0, -cm(Length) / 6, 0])
                    label(str(Width, "x", Length), Print_h);
            if (Magnets > 0)
                magnets(Width, Length, Magnets);
        }
        // pillows mark the head end
        for (i = [0 : n - 1])
            translate([cm((i - (n - 1) / 2) * (pw + Pillow_gap)), cm(py), 0])
                cushion(pw, Pillow_d, Print_h, Pillow_h);
    }
}
