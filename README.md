# open-room-planner  [![CC BY-NC 4.0][cc-by-nc-shield]][cc-by-nc]
3d print / laser cut room planner

## Scale

Everything is drawn at **1:40** — 25 mm on the plan = 1 m of real room, so an A5
sheet holds about a 50 m² flat and an A4 about 100 m²:

| real | on the plan |
|---|---|
| 1 m | 25 mm |
| 1 cm | 0.25 mm |
| a 160x200 bed | 40 x 50 mm |

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
make bedroom SCALE=50     # or: openscad -D Scale=50 ...
```

## Heights

Heights are to scale too: a part declares the real height of the furniture it
stands for, in centimetres, and it is shrunk by the same 1:40 as its footprint.
So the set is a scale model, not a set of tiers — the pieces stand to each other
exactly as the furniture does:

| piece | real | printed |
|---|---|---|
| shower tray | 10 cm | 2.5 mm |
| bed (top of the mattress) | 50 cm | 12.5 mm |
| dining table | 75 cm | 18.75 mm |
| kitchen worktop | 90 cm | 22.5 mm |
| fridge-freezer | 185 cm | 46.25 mm |
| PAX wardrobe frame | 236 cm | 59 mm |

Anything that stands **on** a piece is real too — a sofa is a 45 cm seat with the
back rising to 85 and the arms to 65, a bed is a mattress with 10 cm pillows on
it, a bath is a 58 cm rim around a 40 cm hollow, a toilet is a 40 cm bowl in
front of a 78 cm cistern. Only drawing detail stays in printed millimetres:
engraved symbols, grooves and magnet pockets are ink and hardware, not furniture.

`scad/lib/common.scad` does the conversion, next to `cm()`:

```openscad
function rise(v)      = cm(v) * Height_scale;         // a cushion, a mirror board
function printed_h(v) = max(Height_min, rise(v));     // a whole piece
```

Two knobs act on every part at once, and each part's own height is a Makefile
variable in cm:

```sh
make all HEIGHT_SCALE=0.75      # every piece three quarters as tall, same order
make all HEIGHT_MIN=3           # nothing prints thinner than 3 mm
make bedroom PAX_H=201          # the short PAX frame instead of the tall one
make diningroom TABLE_H=45      # the dining tops as coffee tables
```

`Height_min` is the floor a piece may not print below, whatever its real height
says: a magnet pocket (1.2 mm) plus material over it. At 1:40 the shower tray
(2.5 mm) sits right on top of it. Where a hollow no longer fits the height above a
pocket — a bath basin, a shower pan — the part sinks what it can and says so in the
render log; at this scale a 10 cm tray gives up almost all of its recess, so build
the trays taller (`SHOWER_H`) if you want a pan you can feel.

## Walls and openings

A room's shell is built from square-ended segments that butt flush, so a run is
assembled from the catalogue rather than printed in one piece:

```
[ wall 100 ][ window 100 ][ wall 50 ][ door 87.5 left ][ wall 25 ]
```

| part | real sizes (cm) | files |
|---|---|---|
| `wall` | thickness 11.5 / 17.5 / 24, length 25–300 | 18 |
| `window` | opening 60–180 in 20 cm steps | 21 |
| `door` | opening 62.5 / 75 / 87.5 / 100 / 112.5, two hands | 30 |

Thicknesses are the German standards — 11.5 cm half-brick partition, 17.5 and
24 cm load-bearing. Door openings are DIN 18101 masonry sizes (*Rohbaumaß*), for the
61 / 73.5 / 86 / 98.5 / 111 cm leaves sold to fit them; window widths are the 1/8 m
series.

**Every segment carries its size engraved on it**, so a run can be picked out of the
box by reading the numbers rather than by measuring:

| part | number | where |
|---|---|---|
| `wall` | its length | one face (`-Y`), centred and half way up |
| `door` | the opening width | the floor the leaf sweeps |

A wall's number is on the face and not on top because that is the big surface on a
piece this shape: even the thinnest partition is 12.5 mm tall and 6.25 mm long on its
face, so all 18 segments carry it — engraved on top, only the load-bearing ones were
wide enough (11.5 cm is a 2.875 mm ribbon at 1:40). Thickness is not engraved: it
reads off the ribbon itself, and off which segments butt flush against it.

Walls are the one exception to scaled heights, on purpose: **12.5 mm printed**, not
a scaled 250 cm ceiling (which would be a 62.5 mm ribbon you could not see the room
past, with openings needing bridged lintels instead of the sill/threshold drop
below). That is the bed line at 1:40 — high enough to read as a wall around the low
pieces, low enough that a worktop (22.5 mm) or a wardrobe (59 mm) still stands clear
of it and you can see over it into the room. An opening segment is the opening
plus a 20 cm pier at
each end (`OPENING_REVEAL` — the pier is the only part of the segment a magnet
pocket can go in, and 20 cm is the first round number long enough for one at
1:40), and across the opening the ribbon **drops** — so you can see and feel a
hole in the wall, not just read a line from above:

| | left under the opening | drawn on it |
|---|---|---|
| window | 4.5 mm sill (about a third of the ribbon) | the glass line |
| door | 2.7 mm threshold (about a fifth) | the closed leaf |

Both drops are printed mm and are set as a share of the wall height, so raising the
ribbon (`WALL_H`) means raising them with it.

A door then **occupies its swing**: the threshold carries on into the room as the
quarter circle the leaf sweeps, so the outline of the piece is the arc a plan
would draw, and the floor the door needs is taken — you cannot put a wardrobe
where it has to open. The radius is the leaf, not the opening (`Frame`, 15 mm in
DIN 18101), so the plate stops just short of the far jamb and the segment still
butts flush between plain ones. That plate is also the one big flat surface a door
has, so it is where the opening width is engraved — out on the bisector of the
quadrant, clear of the leaf line and both jambs. With `DOOR_SWING=false` there is no
plate, and the number goes on the threshold behind the leaf line instead — which
only a 17.5 or 24 cm wall is thick enough for.

`Hand` is which end the hinge is on; turning a door segment round in the plan
swaps hinge end *and* the room it opens into, so `left` and `right` cover all
four hands.

```sh
make walls                            # all 69 parts
make walls WALL_H=22.5                # a taller ribbon, up to the worktop line
                                      # (printed mm, not cm — raise the two drops
                                      #  below with it)
make walls OPENING_REVEAL=25          # wider piers either side of an opening — raise
                                      # it at a smaller scale, where 20 cm of pier is
                                      # no longer enough to sink a magnet pocket into
                                      # (the render log says when it is not)
make walls WINDOW_SILL_H=7            # a shallower drop under a window
make walls DOOR_SWING=false           # plain openings, swing arc engraved instead
```

## Magnets

Parts can hold onto a steel plan surface with neodymium discs dropped into
pockets in their bottom face. `magnets(w_cm, d_cm, n)` puts `n` of them in a row
along the longer axis; the count is clamped to what fits, so the same call is
safe on a nightstand and on a double bed (a piece too short for all of them gets
fewer, with a warning).

```openscad
difference() { footprint(160, 200, 6); magnets(160, 200, 2); }
```

**Two discs, both 1 mm high** — so every pocket is the same depth and there are
only two kinds of magnet to buy:

| disc | pull | goes in |
|---|---|---|
| 4 x 1 mm | ~90 g | everything wide enough for it — the standard |
| 2 x 1 mm | ~20 g | pieces too narrow for a 4 mm pocket |

`magnets()` chooses per piece: the 4 mm disc where the footprint is at least
6.3 mm across (25.2 cm of real furniture at 1:40), the 2 mm one below that. A
piece that drops to the small disc says so in the render log — that is how you
know which magnet to drop into which part:

```
NOTE: 200x17.5 cm at 1:40 is too narrow for a 4 mm disc — cut for 2 2x1 mm
```

Every piece of furniture in the catalogue clears 25.2 cm on its short side, so it
takes the 4 mm disc. The walls do not: at 1:40 the 17.5 and 24 cm segments drop to
the 2 mm disc, and the 11.5 cm partition — a 2.875 mm ribbon, narrower than even
that pocket plus a wall around it (4.3 mm) — gets **the material instead of going
without**: `magnet_pads()` puts a low round pad under each pocket, a touch proud of
both faces and only 2 mm off the floor, so the segment still reads at its real
thickness from above and a partition is not mistaken for a bearing wall. It is
said in the render log too:

```
NOTE: 200x11.5 cm at 1:40 is too thin to hold a pocket — cut for 2 2x1 mm on a 4.3 mm pad
```

A part asks for a pad by adding it to its solid and cutting the pockets with
`pad = true`; a piece already wide enough gets nothing, so the pair is safe
anywhere:

```openscad
difference() {
    union() { footprint(200, 11.5, 7, r = 0); magnet_pads(200, 11.5, 2); }
    magnets(200, 11.5, 2, pad = true);
}
```

So every part in the catalogue takes at least one magnet — the shortest 25 cm
segments one instead of two, and a window or door one per pier.

On a **vertical** board what holds a piece up is friction, not pull: roughly
`0.3 x pull`, so a 4 mm disc's ~90 g carries ~27 g and a 2 mm one ~6 g. Since the
pieces went to scaled heights they are solid blocks rather than plates — a 160x200
bed is 40 x 50 x 12.5 mm — and a big one printed solid weighs more than that on its
own. Lay the board flat, or print sparse infill and give the wide pieces more than
one pocket.

Defaults live in `scad/lib/common.scad` and are overridable per build:

```sh
make all MAGNET_D=5 MAGNET_D_SMALL=3   # bigger discs, if that is what you have
make all MAGNET_FIT=0.4                # pockets too tight? widen them
make bedroom BED_MAGNETS=0             # no pockets
make bedroom PAX_MAGNETS=0             # ditto, PAX wardrobes (wide frames included)
make bedroom PAX_WIDE_MAGNETS=1        # one pocket on the 100 cm frames too
make bedroom HEMNES_MAGNETS=1          # one pocket per HEMNES chest instead of two
make diningroom TABLE_MAGNETS=0        # ditto, dining-room tables
make walls WALL_MAGNETS=0              # ditto, wall segments
```

Printing and assembly:

- the pocket opens at the **bottom**, so the magnet touches the steel directly
  (0.4 mm of plastic in the gap costs a small disc half its pull) and nothing has
  to bridge — no mid-print pause, drop the magnet in afterwards
- a pocket is cut `Magnet_fit = 0.3` mm wider and `Magnet_fit_h = 0.2` mm deeper
  than the disc, because an FDM hole prints undersize: the magnet drops in by
  hand, a spot of CA glue holds it, and it can never stand proud of the bottom
  face and make the piece rock
- insert every magnet the same way up: neighbouring pieces then repel gently
  instead of snapping together and skewing the layout
- a pad is flush with the bottom face, so a padded piece still sits flat; the
  0.7 mm it bulges either side is at floor level, so butt a corner (the end of one
  segment against the face of another) clear of one

This work is licensed under a
[Creative Commons Attribution-NonCommercial 4.0 International License][cc-by-nc].

[![CC BY-NC 4.0][cc-by-nc-image]][cc-by-nc]

[cc-by-nc]: https://creativecommons.org/licenses/by-nc/4.0/
[cc-by-nc-image]: https://licensebuttons.net/l/by-nc/4.0/88x31.png
[cc-by-nc-shield]: https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg
