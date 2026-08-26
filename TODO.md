<!-- todo:guide — managed by todo; this block is rewritten on save. Docs: https://github.com/andresbott/todo
This file is a todo list managed by "todo", a terminal TODO app:
https://github.com/andresbott/todo

todo watches this file and reloads it automatically when it changes on disk, so
you — human or agent — can edit it directly in any editor. Keep to this format
so todo can parse what you write:

  # Heading           Headings ("#" to "######") are categories; they nest by
                      heading level.
  - [ ] Open task     A "- [ ]" line is an open task; "- [x]" marks it done.
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
  low; 80/90/140/160 x200 cm - scad/bedroom/bed.scad
  - [ ] More sizes: 120x200 (small double), 180x200 (king)
- [x] IKEA PAX wardrobe frames
  high; 50/75/100 W x 35/58 D cm - scad/bedroom/ikea_pax.scad
- [x] IKEA HEMNES chest of drawers
  med; 108x50 cm - scad/bedroom/ikea_hemnes.scad
  - [ ] More sizes: 2-drawer 54x50, 8-drawer 160x50
- [x] Nightstand / bedside table
  low; 40/45/50/60 x40 cm, drawer fronts + knobs - scad/bedroom/nightstand.scad
- [x] Dressing table / vanity
  med; 80/100/120 x40 cm, standing oval mirror on a flat top - scad/bedroom/dressing_table.scad
- [ ] Bench / storage box (foot of bed)
  low; ~100-160 x40 cm
- [ ] Standalone / sliding-door wardrobe
  high; complements PAX - one solid carcass, doors as grooves
- [ ] Open shelving / bookcase
  high; BILLY-style, ~80x28 cm, shelves as grooves

## Living room
- [x] Standing lamp
  high; the 45 cm drum shade only (cone/globe/tripod still in the part, not
  built) - scad/livingroom/lamp.scad
  - [ ] Table / desk lamp variants (same part at LAMP_H=50, smaller shades)
- [x] Sofa
  low; 150/200/240 x90 straight + L-shaped chaise sectional (left/right) - scad/livingroom/sofa.scad
- [ ] Armchair
  low; ~80x80 cm
- [ ] TV unit / media console
  med (or low); ~120-200 x40 cm, drawer/door grooves
- [x] Bookshelf / shelving unit
  high; BILLY-style, 40/60/80 W x 106/202 H cm, real recessed open shelves (printed on its back) - scad/livingroom/bookshelf.scad
- [ ] Sideboard / display cabinet
  med; ~160x45 cm
- [ ] Console / side table
  low-med; ~40x40 side or ~110x35 console

## Kitchen
- [ ] Base-cabinet / worktop run
  med; modular lengths (60/80/100/120 cm), 60 cm deep
- [ ] Wall / tall cabinet
  high; larder / broom units, 60 cm deep
- [ ] Kitchen island
  med; ~120x90 cm
- [ ] Fridge / freezer
  high; freestanding ~60x60 cm, or American-style ~90x70 cm
- [ ] Cooker (oven + hob)
  med; 60x60 cm, hob rings engraved on top
- [ ] Dishwasher
  med; 60x60 cm
- [ ] Sink unit
  med; part of the worktop run, basin engraved
- [ ] Bar stool
  med; small round ~35 cm token

## Dining
- [x] Dining table
  med; rect 120x80..200x100, square 70/80/90, round 90-120 - scad/diningroom/table.scad
  - [ ] Coffee-table variants (same part at TABLE_H=45, setting off) in the Makefile
- [ ] Dining chair
  med; ~45x45 cm small token, backrest hint
- [ ] Dining bench
  low; ~140x35 cm
- [ ] Sideboard / buffet
  med; ~180x45 cm
- [ ] Display / china cabinet
  high; ~100x40 cm

## Bathroom
- [x] Bathtub
  med; rect 120x70..180x80, oval 95x60..180x80 cm, basin sunk as a real hollow - scad/bathroom/bathtub.scad
- [ ] Shower tray / enclosure
  low; 90x90 / 80x120 cm
- [ ] Toilet
  low; ~40x70 cm
- [ ] Washbasin / vanity
  med; ~60x45 cm single, ~120 cm double
- [ ] Bathroom cabinet
  med/high; tall storage ~40x35 cm

## Home office
- [ ] Desk
  med; 120x60 / 160x80 cm
- [ ] Office chair
  med; ~50x50 cm round token
- [x] Bookshelf / shelving
  high; covered by the shared living-room bookshelf (scad/livingroom/bookshelf.scad) - office part removed
- [ ] Drawer / filing cabinet
  med; ~40x55 cm pedestal, drawers engraved

## Hallway / entrance
- [ ] Shoe cabinet
  med; shallow ~100x30 cm
- [ ] Console / hall table
  med; ~100x35 cm
- [ ] Coat rack / hall tree
  high; slim footprint ~40x40 cm
- [ ] Bench
  low; ~100x35 cm

## Kids room
- [ ] Bunk bed
  high; 90x200 footprint on a single bed's floor space, ~165 cm tall so it reads as a bunk
- [ ] Cot / crib
  low; 60x120 cm
- [ ] Changing table
  med; ~80x50 cm
- [ ] Cube storage (KALLAX-style)
  med; 2x2 / 2x4 grid engraved, ~77/147 x39 cm

## Laundry / utility
- [ ] Washing machine
  med; 60x60 cm - shared, also goes in the kitchen/bathroom
- [ ] Tumble dryer
  med; 60x60 cm, stacks on the washer
- [ ] Utility sink
  med; ~60x50 cm
- [ ] Storage shelving
  high; open racking

## Balcony / outdoor
- [ ] Outdoor table
  med; slatted top or reuse table.scad; ~80x80 / round 90
- [ ] Outdoor chair / lounger
  low; chair ~55x55, sun lounger ~60x190
- [ ] Outdoor sofa / bench
  low; ~140x70 cm
- [ ] Planter / plant pot
  low-high; round 30-50 cm, tall for a tree

# Structure

## Walls
- [x] Interior wall segments
  a 12.5 mm printed ribbon, not a scaled ceiling (the one exception — see the README); non-bearing 11.5, load-bearing 17.5/24 cm thick; lengths 25/50/100/150/200/300, each engraved on the segment's face - scad/walls/wall.scad
- [x] Window segments
  wall height, drops to a 4.5 mm sill across the opening with the glass line on it; openings 60-180 cm (1/8 m series), 20 cm pier either side (long enough to take a magnet) - scad/walls/window.scad
- [x] Door segments
  wall height, drops to a 2.7 mm threshold that carries on into the room as the quarter circle the leaf sweeps, so the piece occupies the swing, with the opening width engraved on that plate; openings 62.5/75/87.5/100/112.5 cm (DIN 18101 Rohbaumass), left/right hand - scad/walls/door.scad
