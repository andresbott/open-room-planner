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
| shower tray (with its waste under it) | 20 cm | 5 mm |
| bed (top of the mattress) | 50 cm | 12.5 mm |
| dining table | 75 cm | 18.75 mm |
| kitchen worktop | 90 cm | 22.5 mm |
| fridge-freezer | 185 cm | 46.25 mm |
| PAX wardrobe frame | 236 cm | 59 mm |

Anything that stands **on** a piece is real too — a sofa is a 45 cm seat with the
back rising to 85 and the arms to 65, a bed is a mattress with 10 cm pillows on
it, a bath is a 58 cm rim around a 40 cm hollow, a toilet is a 40 cm bowl in
front of a 78 cm cistern, a kitchen unit is a 90 cm worktop overhanging a carcass
of door fronts on a 10 cm plinth. Only drawing detail stays in printed millimetres:
engraved symbols, grooves and magnet pockets are ink and hardware, not furniture.

The same goes for what is cut **into** a piece. A detail deep enough to catch the
light beats a line engraved on the top face, because the top face is the one a
photograph of the plan sees least of: a sink is a bowl you can put a fingertip in
and a hob is four dished burners, not two circles and a rectangle drawn in 0.4 mm
of ink; a fridge's doors, a cooker's oven and a run of drawer fronts are on the
**front** face, where they are in the room and where a low angle can read them.
`hollow()`, `base_unit()`, `unit_fronts()` and `appliance_front()` in
`scad/lib/common.scad` do this, and every one of them stays printable the right way
up: a hollow's walls slope out, a step outwards on the way up is a 45° flare, and a
recess in a vertical face is a cut and never a spike.

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
says: a magnet pocket (2.2 mm for the standard 4 x 2 disc) plus 1.2 mm of material
over it, so **3.4 mm**. Nothing in the catalogue reaches it — the shortest piece is a
shower tray at 5 mm — so it is a backstop for a piece you add that is lower, and for
building at a smaller scale.

Where a hollow no longer fits the height above a pocket — a bath basin, a shower
pan — the part sinks what it can and says so in the render log. This is what sets the
tray height: a shower tray is 20 cm because the pan has to go **above** a magnet, and
build one shorter than about 17.5 cm and it starts giving the recess back:

```
WARNING: a 4 cm pan does not fit in a 10 cm tray over 2.2 mm of magnet pocket — sunk 0 cm instead (give it more: SHOWER_H)
```

## Walls and openings

A room's shell is built from square-ended segments that butt flush, so a run is
assembled from the catalogue rather than printed in one piece:

```
[ wall 100 ][ window 100 ][ wall 50 ][ door 87.5 left ][ wall 25 ]
```

| part | real sizes (cm) | files |
|---|---|---|
| `wall` | thickness 11.5 / 17.5 / 24, length 25–300 | 18 |
| `corner` | thickness 11.5 / 17.5 / 24, an L with ~30 cm stub legs | 3 |
| `window` | opening 60–180 in 20 cm steps | 21 |
| `door` | opening 62.5 / 75 / 87.5 / 100 / 112.5, two hands | 30 |
| `sliding_door` | opening 150 / 175 / 200 / 250 / 300 | 15 |

Thicknesses are the German standards — 11.5 cm half-brick partition, 17.5 and
24 cm load-bearing. Door openings are DIN 18101 masonry sizes (*Rohbaumaß*), for the
61 / 73.5 / 86 / 98.5 / 111 cm leaves sold to fit them; window and slider widths are
the 1/8 m series.

**A segment carries its size engraved on it wherever there is room**, so a run can be
picked out of the box by reading the numbers rather than by measuring:

| part | number | where |
|---|---|---|
| `wall` | its length | one face (`-Y`), centred and half way up |
| `window` | the opening width | the same face, on the parapet under the opening |
| `door` | the opening width | the floor the leaf sweeps |
| `sliding_door` | — | no flat surface left to put one on |

The number is on the **face** and not on top because that is the big surface on a piece
this shape, whatever its thickness: even the thinnest partition is 25 mm tall and
6.25 mm long on its face, and a window's parapet is 20 mm tall and full length. Engraved
on top, only the load-bearing walls were ever wide enough (11.5 cm is a 2.875 mm ribbon
at 1:40), and on a window the sill top has the glass line down it with under a
millimetre of band either side. Thickness is not engraved: it reads off the ribbon
itself, and off which segments butt flush against it.

Walls are the one exception to scaled heights, on purpose: **25 mm printed**, not
a scaled 250 cm ceiling (which would be a 62.5 mm ribbon you could not see the room
past, with openings needing bridged lintels instead of the sill/threshold drop
below). 25 mm is a real **100 cm** at 1:40 — the wall cut off at parapet height, which
is enough to stand *proud of* the worktops and chests (22.5 mm) so that a run reads as a
room rather than as a line on the board, while a wardrobe (59 mm) still rises clear of
it and you can see over the ribbon into the room. Every opening runs from its sill or
threshold straight up to that cut, so nothing has to bridge. An opening segment is the
opening
plus a 20 cm pier at
each end (`OPENING_REVEAL` — the pier is the only part of the segment a magnet
pocket can go in, and 20 cm is the first round number long enough for one at
1:40), and across the opening the ribbon **drops** — so you can see and feel a
hole in the wall, not just read a line from above:

| | left under the opening | drawn on it | floor it takes |
|---|---|---|---|
| window | **20 mm** sill — a real 80 cm parapet | the glass line | — |
| door | 2.7 mm threshold — a step | the closed leaf | **the swing** |
| sliding door | 2.7 mm threshold | a line per leaf, on two tracks | — |

A sill you look **over**, a threshold you walk **over** — which is why the two are
nowhere near each other and why the two doors match. The window sill is set at a real
sill height (`WINDOW_SILL_H`, 80 cm of the wall's 100), so it reads as the parapet under
a window rather than as a token step; the threshold stays a low step whatever the wall
does, because that is what a threshold is.

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

A **sliding glazed door** is the third opening, and it is defined by what it does *not*
take: the leaf runs along the wall instead of swinging, so the piece claims no floor
beyond the wall itself — plan a sofa right up against it. It gets a door's threshold
(you walk over it, not a sill you look over) and, instead of a swing, **one engraved
line per leaf on two tracks** across the wall thickness, overlapping where they meet —
which is how a plan draws a slider, and what tells the three openings apart from above:

```
window        ————————————        one centred glass line
door          ———————— + the quarter circle it sweeps
sliding_door  ————
                  ————           a leaf per track, overlapping
```

`Panels` is how many leaves share the opening (2 is the usual slider, 3 a wide one) and
`Panel_overlap` how far they overlap at the meeting stile. There is no hand: turning the
segment round swaps which leaf is on the inner track, which is the only variant a slider
has. It carries no engraved number — the tracks have the threshold, and between them
there is less than a legible cap height on a wall this thin, so like a window it is told
apart by shape.

A **corner** lets you peg a room out without walling every side of it: it is an **L** of
two wall arms meeting at a right angle, so you drop one at each corner and leave the run
between **implied** rather than laying a segment along the whole wall.

```
[corner]              [corner]        drop a corner at each corner; the walls between
                                      are implied, not placed — turn the L in the plan
[corner]              [corner]        for each of the four corners (there is no hand)
```

Same thickness, height and square ends as `wall`, so a corner still butts flush against a
straight segment where you *do* want a length of wall. Its arms are short stubs (`CORNER_LEG`,
~30 cm past the corner block — the same length at every thickness, so all three read as a
clean L), and it carries **no engraved number**: unlike a segment it has no length to
carry, because the wall that matters is the one implied in the gap. One L covers all four
corners just by turning it, exactly as the pool is pegged out of corner tiles.

```sh
make walls                            # all 87 parts
make walls CORNER_LEG=50              # longer corner returns (a bigger stub each way)
make walls WALL_H=37.5                # a taller ribbon — 150 cm, up to a window head
                                      # (printed mm, not cm; raise WINDOW_SILL_H with
                                      #  it to keep the sill 80% of the way up)
make walls OPENING_REVEAL=25          # wider piers either side of an opening — raise
                                      # it at a smaller scale, where 20 cm of pier is
                                      # no longer enough to sink a magnet pocket into
                                      # (the render log says when it is not)
make walls WINDOW_SILL_H=14           # a lower sill, so more of the wall is glass
make walls DOOR_SWING=false           # plain openings, swing arc engraved instead
make walls SLIDING_PANELS=3           # three-leaf sliders instead of two
```

## Pool

A swimming pool is built the way a room shell is — from square tiles that **butt flush on a
fixed module**, assembled into one pool rather than printed in a piece. Six kinds make any pool:

| kind | coping (the paved rim) | the rest of the tile |
|---|---|---|
| `corner` | two outside edges, an L | water on the inner quarter |
| `edge` | one outside edge | water — a side of the pool |
| `water` | — | water to every edge — an interior tile |
| `steps` | one outside edge | water that **steps down** from it — the shallow end |
| `round` | two outside edges, curved | a **rounded corner** — the outer and water edges sweep a quarter circle |
| `ladder` | one outside edge | a narrow **ladder** flight of entry steps into the water |

The smallest pool is **four corners** — already a full coping ring round four quarters of water.
A longer one drops `edge` tiles along the sides and `water` tiles in the middle, with a `steps`
tile where you get in:

```
[corner][ edge ][corner]
[ edge ][water ][ edge ]     turn a corner or edge in the plan to face its coping outward, the
[corner][steps ][corner]     way you turn a wall — the default corner faces −X/−Y (a SW corner),
                             a quarter turn gives the other three.
```

Where two tiles meet, the water runs right to the edge, so it reads as **one continuous sheet**
while each tile still prints as its own watertight tray. The surface is **rippled** — low rounded
swells rather than a glassy plane — and the near-square tile takes a **third magnet at its centre**
(on top of the two in a row) so a 2 m sheet cannot lift or pivot between its neighbours. Like a
shower tray a pool tile is nearly floor level, and its height is set not by how deep a pool is but
by what it takes to sink a pan of water **above a magnet pocket** — so it is a low tile that clamps
the water and says so in the render log if it had to (raise `POOL_H`).

```sh
make pool                     # the six tiles at the 200 cm (2 m) module
make pool POOL_MODULE=150     # a smaller module — a plunge pool
make pool POOL_H=45           # a deeper pool (more water sunk over the magnet)
```

## Ruler

A ruler for the plan itself: a low flat bar with a **tick every 50 cm and a numbered one every
100**, so you can lay it across the board and read how much real room a run takes without doing
the 1:40 arithmetic. Its marks are drawn through the same `cm()` the parts use, so the ruler is
**correct at whatever scale the set is built at** — render everything at 1:50 and its hundreds
move to 20 mm apart to match.

```sh
make tools                    # a 3 m and a 5 m ruler
make tools RULER_LENGTHS=200  # a shorter one
make tools RULER_MAGNETS=0    # no pockets — a handheld ruler you slide about
```

## Printable mat

A paper floor to stand the tokens on, printed on an ordinary A4 printer — the flat
counterpart to the ruler above. It carries a **slight grid** (a faint line every 50 cm, a
stronger one every metre) and a **ruler border** (a tick every 50 cm, a numbered one every
metre, 0 in the bottom-left corner), both at the **same 1:40** the tokens are shrunk to, so a
piece covers exactly the cells its real footprint would — a 160x200 bed is 4 x 5 cells. It is
an SVG generated by `print/grid_mat.py`, not an OpenSCAD export, because a print wants a faint
grid and a black ruler at once and a single 2D fill cannot do both.

The one rule for printing: **print at 100 % (actual size), not "fit to page"** — otherwise the
scale is lost. Every sheet carries a **50 mm calibration bar** in the top margin: print it,
measure that bar, and if it is 50 mm the grid is a true 1:40.

```sh
make mat                      # A4 + A3, portrait + landscape — SVG + PDF, into files/mat/
```

| sheet | field | for |
|---|---|---|
| `grid_mat_a4_1-40_portrait`  | 7.5 x 11 m | the default |
| `grid_mat_a4_1-40_landscape` | 11 x 7.5 m | a wide room |
| `grid_mat_a3_1-40_portrait`  | 11 x 16 m  | a bigger sheet, if your printer takes A3 |
| `grid_mat_a3_1-40_landscape` | 16 x 11 m  | ... and wide |

`make mat` builds A4 and A3 by default (`MAT_PAPERS ?= a4 a3`; the generator also knows `a5`
and `letter`, and takes an explicit `WxH` in mm).

Like the ruler, the mat tracks the set's own `SCALE`, because a mat only matches the tokens at
the scale they were built at. `make mat` follows whatever scale you build the parts at, so a
1:50 set gets a 1:50 mat from the same command:

```sh
make all SCALE=50 && make mat SCALE=50    # a 1:50 set and the mat that fits it
```

The **SVGs are tracked**; the **PDFs are not** — the SVG->PDF converters embed a timestamp, so
the PDFs are not byte-reproducible. `make mat` writes both (a PDF where `rsvg-convert` or
`inkscape` is on the PATH — the format a print dialog scales most reliably); regenerate them any
time.

## Magnets

Parts can hold onto a steel plan surface with neodymium discs dropped into
pockets in their bottom face. `magnets(w_cm, d_cm, n)` puts `n` of them in a row
along the longer axis; the count is clamped to what fits, so the same call is
safe on a nightstand and on a double bed (a piece too short for all of them gets
fewer, with a warning).

```openscad
difference() { footprint(160, 200, 6); magnets(160, 200, 2); }
```

**Two discs**, so there are only two kinds of magnet to buy:

| disc | pull | pocket cut for it | goes in |
|---|---|---|---|
| 4 x 2 mm | ~180 g | ⌀4.3 x 2.2 mm | everything wide enough for it — the standard |
| 2 x 1 mm | ~20 g | ⌀2.3 x 1.2 mm | pieces too narrow for a 4 mm pocket |

`magnets()` chooses per piece: the 4 mm disc where the footprint is at least
6.3 mm across (25.2 cm of real furniture at 1:40), the 2 mm one below that — and
because the two are **different heights**, the pocket is cut as deep as the disc
that goes in it (`magnet_h_for`), never to one fixed depth. A piece that drops to
the small disc says so in the render log — that is how you know which magnet to
drop into which part:

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
`0.3 x pull`, so a 4 x 2 disc's ~180 g carries ~54 g and a 2 x 1 one ~6 g. Since the
pieces went to scaled heights they are solid blocks rather than plates — a 160x200
bed is 40 x 50 x 12.5 mm — and a big one printed solid weighs more than that on its
own. Lay the board flat, or print sparse infill and give the wide pieces more than
one pocket.

Defaults live in `scad/lib/common.scad` and are overridable per build:

```sh
make all MAGNET_D=5 MAGNET_D_SMALL=3   # bigger discs, if that is what you have
make all MAGNET_H=1 HEIGHT_MIN=2.4     # back to a 1 mm-thick standard disc (drop
                                       # HEIGHT_MIN by the same 1 mm it saves)
make all MAGNET_H=3 HEIGHT_MIN=4.4     # ... or a deeper one, ditto the other way
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
- the two discs are different depths (2.2 mm and 1.2 mm), but you cannot put the
  wrong one in the wrong hole: the 2 mm disc rattles around a 4.3 mm pocket, and the
  4 mm one does not go into a 2.3 mm one at all
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
