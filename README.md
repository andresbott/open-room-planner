# open-room-planner  [![CC BY-NC 4.0][cc-by-nc-shield]][cc-by-nc]
3d print / laser cut room planner

## Scale

Everything is drawn at **1:50** — the same scale as the paper plans in
`base.svg` (A4, 210 mm ≈ 10.5 m of real room):

| real | on the plan |
|---|---|
| 1 m | 20 mm |
| 1 cm | 0.2 mm |
| a 160x200 bed | 32 x 40 mm |

Parts are modelled in **real-world centimetres** and shrunk on the way out, so a
`.scad` reads like a furniture spec sheet (`Width = 160; Length = 200;`) instead
of a pile of pre-divided numbers. `scad/lib/common.scad` does the conversion:

```openscad
function cm(v) = v * 10 / Scale;  // real cm  -> printed mm
function mm(v) = v / Scale;       // real mm  -> printed mm
```

To render at another scale, override it in one place — the Makefile passes it
down to every part:

```sh
make bedroom SCALE=25     # or: openscad -D Scale=25 ...
```

### What is *not* scaled

A few values are printed millimetres on purpose — they are print/handling
details rather than real-world dimensions, so they stay the same at any scale:

- **piece height** (`Height` per part, `BED_H ?= 6` in the Makefile) — kept low
  so the tokens stack and slide around on the plan
- **corner rounding** (`Corner_radius = 0.6`)
- **engraved labels, symbols and grooves** (`Label_size = 3`, `Label_depth = 0.4`,
  `Symbol_size = 4`, `Symbol_stroke = 0.4`) — a piece too narrow for a readable
  size gets a pictogram instead: the PAX frames carry a clothes hanger
- **magnet pockets** (`Magnet_d`, `Magnet_h`, …) — hardware, see below

So changing `SCALE` resizes footprints but leaves thickness untouched: at
`SCALE=25` the 160x200 bed is 64 x 80 x 6 mm, at `SCALE=100` it is 16 x 20 x 6 mm.

## Magnets

Parts can hold onto a steel plan surface with neodymium discs dropped into
pockets in their bottom face. `magnets(w_cm, d_cm, n)` puts `n` of them in a row
along the longer axis; the count is clamped to what fits, so the same call is
safe on a nightstand and on a double bed (a piece too small for even one is left
solid, with a warning).

```openscad
difference() { footprint(160, 200, 6); magnets(160, 200, 2); }
```

Sizing, per magnet, flush against a painted steel whiteboard:

| disc | pull | notes |
|---|---|---|
| 2 x 1 mm | ~20 g | fine on a **flat** board, too weak on a wall |
| 5 x 1 mm | ~130 g | best value — 1 mm deep in a 6 mm piece |
| 3 x 2 mm | ~200 g | fits the small tokens |

On a **vertical** board what holds a piece up is friction, not pull: roughly
`0.3 x pull`, so ~20 g of pull carries ~6 g — about what a 160x200 bed weighs.
Aim well above that.

Defaults live in `scad/lib/common.scad` and are overridable per build:

```sh
make bedroom MAGNET_D=3 MAGNET_H=2   # 3x2 discs
make bedroom BED_MAGNETS=0           # no pockets
make bedroom PAX_MAGNETS=0           # ditto, PAX wardrobes
```

A pocket needs the piece to be about 7.6 mm across for a 5 mm disc, so at 1:50
the 35 cm-deep IKEA PAX wardrobe frames (7 mm) render solid with a warning —
build those with `MAGNET_D=3 MAGNET_H=2`.

Printing and assembly:

- the pocket opens at the **bottom**, so the magnet touches the steel directly
  (0.4 mm of plastic in the gap costs a small disc half its pull) and nothing has
  to bridge — no mid-print pause, drop the magnet in afterwards
- `Magnet_fit = 0.2` is added to the diameter for a press fit; a drop of CA glue
  keeps it there, and the depth equals the magnet height so it sits flush
- insert every magnet the same way up: neighbouring pieces then repel gently
  instead of snapping together and skewing the layout

This work is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License][cc-by-nc].

[![CC BY-NC 4.0][cc-by-nc-image]][cc-by-nc]

[cc-by-nc]: https://creativecommons.org/licenses/by-nc/4.0/
[cc-by-nc-image]: https://licensebuttons.net/l/by-nc/4.0/88x31.png
[cc-by-nc-shield]: https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg
