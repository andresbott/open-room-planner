<!-- todo:guide — managed by todo; this block is rewritten on save. Docs: https://github.com/andresbott/todo
This file is a todo list managed by "todo", a terminal TODO app:
https://github.com/andresbott/todo

todo watches this file and reloads it automatically when it changes on disk, so
you — human or agent — can edit it directly in any editor. Keep to this format
so todo can parse what you write:

  # Heading           Headings ("#" to "######") are categories; they nest by
                      heading level.
  - [ ] Open task     A "- [ ]" line is an open task; "- [x]" marks it done.
  - [/] In progress   "- [/]" flags a task in progress, "- [>]" defers it.
  - [x] Done task     Tasks must live under a category heading.
    - [ ] Subtask     Indent by two spaces to nest a subtask under a task.
    Description text  An indented, non-checkbox line is the task's description.

Notes for editors:
- Text above the first heading (this block included) is preserved on save.
- todo rewrites the file into the canonical form above on every change, so any
  other free-form markdown placed between items is not kept.
-->

Furniture catalogue, grouped by room. One task = one part (a scad/<room>/<part>.scad);
sizes are the real-world cm variants to render. Heights are real too — a part declares the
real height of its furniture in cm and it is shrunk by the plan scale, see the README — so
the low/med/high word in each note is only a rough band for what to look up: low = seat
height or under (~45 cm), med = counter height (~75-100), high = over head height (~180+).
[x] = already modelled and rendered; [ ] = still to build.

# Rooms

## Bedroom

- [x] Bed
  low; 80/90/140/160 x200 cm, a headboard with its field sunk on both faces, pillows and a
  raised duvet with the size engraved on it - scad/bedroom/bed.scad
  - [x] More sizes: 120x200 (small double), 180x200 (king) — in the Makefile BED_SIZES
- [x] IKEA HEMNES chest of drawers
  med; 108x50 cm, three full-width drawer fronts with two knobs each on the front face -
  scad/bedroom/ikea_hemnes.scad
  - [x] More sizes: 2-drawer 54x50, 8-drawer 160x50 (Cols/Drawers variants in the Makefile)

## Living room

- [x] Standing lamp
  high; the 45 cm drum shade only (cone/globe/tripod still in the part, not
  built) - scad/livingroom/lamp.scad
  - [x] Table / desk lamp variants (same part at LAMP_H=50, smaller shades)

## Kitchen

- [x] Base-cabinet / worktop run
  med; 120x60 cm, worktop lip + toe kick, one cabinet per 60 cm with two drawer fronts
  up each - scad/kitchen/worktop.scad
  - [x] More lengths in the Makefile: 80, 100 (worktop_80 / worktop_100; 60 was worktop_60)
- [x] Corner base unit
  med; L-shaped 90x90 cm with 60 cm arms, two base_unit bodies at right angles so the slab
  overhangs and the plinth sets back on both faces that look into the room while the two
  open ends stay flush, one door per arm - scad/kitchen/corner_unit.scad
  - [x] More sizes in the Makefile: 120x120, and an unequal 120x90 (corner_unit_120x120 /
    corner_unit_120x90)
- [x] Breakfast bar / peninsula
  med; 180x90 cm on the island body with a bar level standing 15 cm above the counter along
  the back edge — a two-level top, and what the bar stool sits at. No knee overhang: a 30 cm
  cantilever at 1:40 cannot be printed - scad/kitchen/breakfast_bar.scad
  - [x] More lengths in the Makefile: 150, 210, 240 (the part sizes its cabinets off Width)
- [x] Built-in oven column
  high; 60x60 cm at 200, an oven and a combi microwave stacked in the middle of the column —
  each a case standing flush in a deep shadow gap, with a control fascia and a sunken glass
  door — over and under a plain door - scad/kitchen/oven_column.scad
  - [x] Single-appliance (oven_column_single, Micro_h=0) and warming-drawer (oven_column_warming) variants

## Dining

- [x] Dining table
  med; rect 120x80..200x100 and square 70/80/90 on four corner legs with real air under
  the top (printed FACE DOWN, a pocket per foot in diagonal order); round 90-120 on a
  pedestal with a splayed foot - scad/diningroom/table.scad
  - [x] Coffee tables built as a distinct cube-like part (chunky top + open shelf on a solid base), not a low dining table - scad/livingroom/coffee_table.scad
  - [ ] 70x70 warns its legs leave too little span — decide whether to force Legs=false
    for the smallest square top

## Bathroom

- [x] Shower tray / enclosure
  low; 80x80..120x120 and 80x120 / 90x140 cm, a real sunken pan with a sunk drain and a
  cover ring; -D Show_enclosure=true adds a walk-in kerb - scad/bathroom/shower.scad
  - [ ] Expose the kerb as a Makefile knob if the walk-in variant is worth rendering
- [x] Bathtub
  low; rectangular and oval, a sunken basin and a small faucet — a tall spout and two handle
  knobs (vertical prisms) on the tap deck - scad/bathroom/bathtub.scad

## Home office

- [x] Drawer / filing cabinet
  med; 40x55 cm pedestal on a toe kick, three recessed drawer fronts with finger pulls on the
  front face (was a brick with a symbol engraved on top) - scad/office/filing_cabinet.scad

## Hallway / entrance

- [x] Shoe cabinet
  med; 100x30 cm, three tilt-out flap fronts recessed into the front face over a toe kick
  (was a box with seams on top) - scad/hallway/shoe_cabinet.scad
- [x] Console / hall table
  med; 100x35 cm, a thin proud top slab on four corner legs, open under it -
  scad/hallway/console.scad
- [x] Coat rack / hall tree
  high; 40x40 cm, a slim post on a splayed foot, a knob cap and peg relief up the front
  (was a box with dots on top) - scad/hallway/coat_rack.scad
- [x] Bench
  low; 100x35 cm, a cushioned seat on a leg frame over an open shoe shelf
  (was a slab with grooves on top) - scad/hallway/bench.scad

## Kids room

- [x] Bunk bed
  high; 90x200 at 165 cm, two mattressed decks with front/guard rails and a recessed ladder,
  sleeping gaps cut back to a panel (prints on its back) - scad/kidsroom/bunk_bed.scad
- [x] Cot / crib
  low; 60x120 cm, real barred sides cut through both long faces and a sunken mattress well
  (was a box with bars on top) - scad/kidsroom/cot.scad
- [x] Changing table
  med; 80x50 cm, front drawer fronts with knobs under a guarded, dished changing top
  (was a box with drawers on top) - scad/kidsroom/changing_table.scad
- [x] Cube storage (KALLAX-style)
  med; 77x39 cm, real open cube bays cut into the front face (prints on its back)
  (was a grid engraved on top) - scad/kidsroom/cube_storage.scad
  - [ ] More sizes in the Makefile: 2x4 147x39 (the part takes Cols/Rows)

## Laundry / utility

## Balcony / outdoor

- [x] Outdoor table
  med; 80x80 (Round=true, Diameter=90 for the round one) at 74 cm, a slatted top on four real
  legs with the air of a table under it — printed FACE DOWN, a pocket per foot; square tops on
  corner legs, round ones on four legs round the rim - scad/outdoor/table.scad
  - [x] Round variant in the Makefile (table_round_90, Round=true)
- [x] Outdoor chair / lounger
  low; chair 55x55 at 85 cm with a back and arm cushions; Lounger=true swaps it for a 60x190
  sun lounger whose head end climbs as a real wedge - scad/outdoor/chair.scad
  - [x] Lounger variant in the Makefile (lounger, Lounger=true)
- [x] Grill / barbecue
  med; 120x60 at 90 cm, a gas BBQ cart — a sunken firebox with a bar grate and a lid hump, a
  side burner on the prep shelf, knob dips and cupboard doors on the front face -
  scad/outdoor/grill.scad
  - [x] Wider variant in the Makefile (grill_160; sizes its firebox and prep off Width)

## Hobby / gym

- [x] Weight bench
  low; 95x130 at 45 cm, a narrow padded bench on a leg frame beside a stack of weight plates
  (the barbell left off — it does not print at 1:40) - scad/hobby/weight_bench.scad
  - [x] A dumbbell rack (the incline-bench variant was dropped on review) - scad/hobby/dumbbell_rack.scad
- [x] Projector screen
  high; 200 and 280 cm wide, a big 16:9 screen recessed into a thin upright panel on a low foot —
  like the TV unit but a bigger screen and a lower base - scad/hobby/projector_screen.scad

# Structure

## Walls

## Pool

- [x] Pool tiles
  low; 200 cm module at 35 cm, Kind = corner / edge / water / steps / round / ladder — four
  corners make the smallest pool; add edges and water for a bigger one, a steps or ladder tile
  where you get in, a round corner for a curved end. An empty sunken basin (no water surface); a third magnet at the centre
  - scad/pool/pool.scad
  - [ ] More module sizes in the Makefile (150 for a plunge pool; the part takes any Module)
  - [x] A rounded / kidney corner variant (Kind=round), and a ladder-entry tile (Kind=ladder)
- [x] remove the water from the pool
  the water surface (raised ripples, then a carved-sphere dapple) was dropped entirely — the tiles
  are now an empty sunken basin: coping round a bare pool floor - scad/pool/pool.scad
- [x] make wather waves look less croded
  the rippled water is spaced wider now (Ripple_pitch 17->28 cm) so it reads calmer
- [x] make pool lather look like a lather, dont use poles
  dropped the grab-rail posts; the ladder is now a narrow multi-tread flight (rungs), Kind=ladder

# Tools

## Measuring

- [x] Ruler
  a low flat bar with a tick every 50 cm and a numbered one every 100, drawn through cm() so it
  is correct at any Scale; spans 300/500 cm - scad/tools/ruler.scad
  - [x] More lengths in the Makefile (the part takes any Length)
  - [x] the last numner of the ruler is always cut off

# Fixes

- [x] the table tops on all tables are too thin, make them tiker for better structure after printing
  Top_h 4->8 cm (2 mm printed) on the dining table, garden table, hall console and desk
