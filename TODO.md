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
The storage is frame-and-panel on four corner legs with its fronts on the front (-Y) face and
KNOBS rather than the kitchen's grip rail (legged_block / unit_fronts in
scad/lib/common.scad) — that pairing is what tells bedroom furniture from a fitted run at
1:40. The two tall pieces are told apart by their fronts: a PAX is an open bay, a wardrobe is
two leaves on two tracks.
- [x] Bed
  low; 80/90/140/160 x200 cm, a headboard with its field sunk on both faces, pillows and a
  raised duvet with the size engraved on it - scad/bedroom/bed.scad
  - [ ] More sizes: 120x200 (small double), 180x200 (king)
- [x] IKEA PAX wardrobe frames
  high; 50/75/100 W x 35/58 D cm, a real open bay with the shelf and the clothes rail left
  standing across it as ribs, hanger on the top - scad/bedroom/ikea_pax.scad
- [x] IKEA HEMNES chest of drawers
  med; 108x50 cm, three full-width drawer fronts with two knobs each on the front face -
  scad/bedroom/ikea_hemnes.scad
  - [ ] More sizes: 2-drawer 54x50, 8-drawer 160x50 (the part takes Cols/Drawers)
- [x] Nightstand / bedside table
  low; 40/45/50/60 x40 cm, one or two drawer fronts with knobs on the front face, clean top -
  scad/bedroom/nightstand.scad
- [x] Dressing table / vanity
  med; 80/100/120 x40 cm, a standing oval mirror on a flat top over a shallow drawer band,
  with the knee hole sunk deeper than the drawers - scad/bedroom/dressing_table.scad
- [x] Bench / storage box (foot of bed)
  low; 100/120/140/160 x40 and the IKEA EKENÄSET 112x48, a real U — a seat slab on an end
  panel each side, open underneath, printed UPSIDE DOWN; BENCH lid variant for a blanket box
  - scad/bedroom/bench.scad
- [x] Standalone / sliding-door wardrobe
  high; 150x60 at 236 cm, two or three leaves on two tracks — the front ones left at the face
  lapping over the sunken ones, each with a finger pull - scad/bedroom/wardrobe.scad
- [x] Open shelving / bookcase
  high; covered by the shared living-room bookshelf (scad/livingroom/bookshelf.scad)

## Living room
- [x] Standing lamp
  high; the 45 cm drum shade only (cone/globe/tripod still in the part, not
  built) - scad/livingroom/lamp.scad
  - [ ] Table / desk lamp variants (same part at LAMP_H=50, smaller shades)
- [x] Sofa
  low; 150/200/240 x90 straight + L-shaped chaise sectional (left/right); a reclined split
  back (one cushion per seat), a soft seat cushion with a seam line per seat, arms and
  diamond throw pillows - scad/livingroom/sofa.scad
- [x] Armchair
  low; 80x80 cm; a chunky boxy tub chair — thick squared arms wrapping into a thick vertical
  back, a seat cushion, on four short corner legs (a legged frame, not spikes) -
  scad/livingroom/armchair.scad
- [x] TV unit / media console
  low; 160x40 at 45 cm, an upright 16:9 screen recessed into a board on the back of the top,
  over a row of fronts with knobs on the front face - scad/livingroom/tv_unit.scad
- [x] Bookshelf / shelving unit
  high; BILLY-style, 40/60/80 W x 106/202 H cm, real recessed open shelves (printed on its back) - scad/livingroom/bookshelf.scad
- [x] Sideboard / display cabinet
  med; 160x45 at 80 cm, a shallow drawer row over taller cupboard doors on the front face —
  the uneven split is what tells it from the dining buffet - scad/livingroom/sideboard.scad
- [x] Console / side table
  low-med; 110x35 at 80 cm (40x40 at 45 for a side table, with Magnets=1), one drawer under
  the top and the space under it sunk deeper still - scad/livingroom/console.scad

## Kitchen
Every unit is built from the shared fitted-unit body in scad/lib/common.scad — a worktop
slab overhanging a carcass of recessed door/drawer fronts on a set-back plinth
(base_unit / island_unit / unit_fronts / unit_fascia) — so a run, a sink, a cooker and a
dishwasher line up and are told apart by their fronts rather than by hairlines engraved
on the top face. The three tall 60x60 pieces are told apart the same way: the larder has
three even courses of door, the fridge two doors split about a third of the way up, and the
oven column two glazed appliance cases in its middle.
- [x] Base-cabinet / worktop run
  med; 120x60 cm, worktop lip + toe kick, one cabinet per 60 cm with two drawer fronts
  up each - scad/kitchen/worktop.scad
  - [ ] More lengths in the Makefile: 80, 100 (60 built as worktop_60; the part takes any Width)
- [x] Wall / tall cabinet
  high; 60x60 cm larder/broom unit at 200 cm, three courses of full-height door fronts
  on a plinth (override Depth to 35 for the wall unit) - scad/kitchen/cabinet.scad
- [x] Kitchen island
  med; 120x90 cm, stepped on all four sides — slab overhanging and plinth set back all
  round, 3x2 fronts on the front face - scad/kitchen/island.scad
- [x] Fridge / freezer
  high; freestanding 60x60 cm at 185, fridge door over a 60 cm freezer one on the front
  face (American-style: Width=90, Depth=70) - scad/kitchen/fridge.scad
- [x] Cooker (oven + hob)
  med; 60x60 cm 4-burner slot-in and a wider 90 cm range (cooker_90) — six burners on a
  3x2 grid and a double oven; real dished burners at the two sizes a hob has, oven door(s)
  under a fascia with a knob per burner - scad/kitchen/cooker.scad
- [x] Dishwasher
  med; 60x60 cm at 90 — one integrated door under a control fascia, now carrying the run's
  worktop slab so it stands level with the rest of the counter - scad/kitchen/dishwasher.scad
- [x] Sink unit
  med; 80x60 cm on the run's body, a real sunken bowl with a plughole and a door pair
  below it (Bowls=2 for a double) - scad/kitchen/sink.scad
- [x] Bar stool
  med; round 35 cm at 65, a seat on a pedestal — foot, cone, column and a flare out to
  the seat - scad/kitchen/bar_stool.scad
- [x] Corner base unit
  med; L-shaped 90x90 cm with 60 cm arms, two base_unit bodies at right angles so the slab
  overhangs and the plinth sets back on both faces that look into the room while the two
  open ends stay flush, one door per arm - scad/kitchen/corner_unit.scad
  - [ ] More sizes in the Makefile: 120x120, and an unequal 120x90 (the part takes any
    Width/Depth/Arm)
- [x] Breakfast bar / peninsula
  med; 180x90 cm on the island body with a bar level standing 15 cm above the counter along
  the back edge — a two-level top, and what the bar stool sits at. No knee overhang: a 30 cm
  cantilever at 1:40 cannot be printed - scad/kitchen/breakfast_bar.scad
  - [ ] More lengths in the Makefile: 150, 210, 240 (the part sizes its cabinets off Width)
- [x] Built-in oven column
  high; 60x60 cm at 200, an oven and a combi microwave stacked in the middle of the column —
  each a case standing flush in a deep shadow gap, with a control fascia and a sunken glass
  door — over and under a plain door - scad/kitchen/oven_column.scad
  - [ ] Single-appliance variant (Micro_h=0) and a warming-drawer one

## Dining
The seating and the storage are frames, not blocks: a corner post at each edge with the
rail between them set back and a top slab standing proud (legged_block in
scad/lib/common.scad), which is the one form that keeps a broad bottom face for a 4 mm
magnet. Only the table gets real air under its top, and it pays for it by printing face
down.
- [x] Dining table
  med; rect 120x80..200x100 and square 70/80/90 on four corner legs with real air under
  the top (printed FACE DOWN, a pocket per foot in diagonal order); round 90-120 on a
  pedestal with a splayed foot - scad/diningroom/table.scad
  - [ ] Coffee-table variants (same part at TABLE_H=45, setting off) in the Makefile
  - [ ] 70x70 warns its legs leave too little span — decide whether to force Legs=false
        for the smallest square top
- [x] Dining chair
  med; 45x45 cm, a dished seat on four corner legs under a back panel whose field is sunk
  on both faces, so it reads as a frame from either side - scad/diningroom/chair.scad
- [x] Dining bench
  low; 140x35 cm, the chair's frame and one dished place per 45 cm of width (three on the
  standard bench), so it says how many people it takes - scad/diningroom/bench.scad
- [x] Sideboard / buffet
  med; 180x45 cm, three bays of drawers over doors recessed into the panel between the
  legs, on the front face and not engraved on the top - scad/diningroom/sideboard.scad
- [x] Display / china cabinet
  high; 100x40 cm, a solid door pair to 80 cm and a glazed case of four shelved bays above
  it, panes sunk behind a mullion, cornice on top - scad/diningroom/display_cabinet.scad

## Bathroom
Every fixture in here is read by a real hollow rather than by an outline: a bath basin, a
shower pan, a washbasin bowl and now a toilet pan are all the same cut one size apart
(hollow() in scad/lib/common.scad), each clamped to what its height leaves over a magnet
pocket and each warning in the render log when it had to give any of it back.
- [x] Bathtub
  med; rect 120x70..180x80, oval 95x60..180x80 cm, basin sunk as a real hollow - scad/bathroom/bathtub.scad
- [x] Shower tray / enclosure
  low; 80x80..120x120 and 80x120 / 90x140 cm, a real sunken pan with a sunk drain and a
  cover ring; -D Show_enclosure=true adds a walk-in kerb - scad/bathroom/shower.scad
  - [ ] Expose the kerb as a Makefile knob if the walk-in variant is worth rendering
- [x] Toilet
  low; 40x70 cm, a rounded bowl stepping down from the cistern with the PAN sunk for real
  inside the seat and the flush plate recessed into the tank top - scad/bathroom/toilet.scad
- [x] Washbasin / vanity
  med; 40x35..80x50 single and 120/150x50 double, a real dished bowl per basin with a
  countersunk plughole, cabinet fronts on the front face - scad/bathroom/washbasin.scad
- [x] Bathroom cabinet
  med/high; 40x35 at 180 cm, recessed door leaves on a set-back plinth with real half-round
  bar handles — the one piece in the set with something standing off a face -
  scad/bathroom/cabinet.scad

## Home office
- [x] Desk
  med; 120x60..160x80 cm, a slab on a panel support at each end — a U, printed upside down - scad/office/desk.scad
- [x] Office chair
  med; 65 cm five-star base under a 50 cm seat, wrap-around back and arms - scad/office/chair.scad
- [x] Bookshelf / shelving
  high; covered by the shared living-room bookshelf (scad/livingroom/bookshelf.scad) - office part removed
- [x] IKEA IVAR shelving
  high; 48/89/174/259 W x 30/50 D x 124/179/226 H cm, built from the real side units and
  shelves; real recessed open bays and shelves like the bookshelf (printed on its back),
  several bays side by side, each unit with its width engraved on the top face. Keeps a
  back panel the real unit has not, so it prints — IVAR_BACK=0 for the true open frame.
  Bays and shelves are derived from the size - scad/office/ikea_ivar.scad
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
The three machines are read by their porthole doors on the front face (appliance_front in
scad/lib/common.scad) and told apart by what is beside the door: a detergent drawer on the
washer, none on the dryer, both plus a seam on the stacked tower.
- [x] Washing machine
  med; 60x60 cm at 85, porthole door under a fascia with a detergent drawer - shared, also
  goes in the kitchen/bathroom - scad/laundry/washing_machine.scad
- [x] Tumble dryer
  med; 60x60 cm at 85, the washer's twin without the drawer - scad/laundry/tumble_dryer.scad
  - [x] Stacked washer-dryer tower: the same footprint at 170 cm, two doors and a seam -
        scad/laundry/washer_dryer_stack.scad
- [x] Utility sink
  med; 60x50 cm, a real 30 cm-deep tub sunk in a base unit's worktop with a plughole and a
  door pair — deeper and edge-to-edge where the kitchen's is a bowl in a counter -
  scad/laundry/utility_sink.scad
- [x] Storage shelving
  high; 80x40 at 180 cm, real open bays with the shelves left standing across them as ribs
  (front_bays) - scad/laundry/storage_shelving.scad

## Balcony / outdoor
- [x] Outdoor table
  med; 80x80 (Round=true, Diameter=90 for the round one) at 74 cm, a slatted top on four real
  legs with the air of a table under it — printed FACE DOWN, a pocket per foot; square tops on
  corner legs, round ones on four legs round the rim - scad/outdoor/table.scad
  - [ ] Round variant in the Makefile (the part already takes Round=true)
- [x] Outdoor chair / lounger
  low; chair 55x55 at 85 cm with a back and arm cushions; Lounger=true swaps it for a 60x190
  sun lounger whose head end climbs as a real wedge - scad/outdoor/chair.scad
  - [ ] Lounger variant in the Makefile (the part already takes Lounger=true)
- [x] Outdoor sofa / bench
  low; 140x70 at 80 cm, the indoor sofa's wraparound back and arms - scad/outdoor/sofa.scad
- [x] Planter / plant pot
  low-high; round 40 cm (square with Round=false), a tapered pot with a real hollow in it and
  the soil as its floor; build at Height=80+ for a tree - scad/outdoor/planter.scad

# Structure

## Walls
- [x] Interior wall segments
  a 25 mm printed ribbon (a real 100 cm at 1:40), not a scaled ceiling (the one exception — see the README); non-bearing 11.5, load-bearing 17.5/24 cm thick; lengths 25/50/100/150/200/300, each engraved on the segment's face - scad/walls/wall.scad
- [x] Window segments
  wall height, drops to a 20 mm sill (a real 80 cm parapet) across the opening with the glass line on it; openings 60-180 cm (1/8 m series), 20 cm pier either side (long enough to take a magnet) - scad/walls/window.scad
- [x] Sliding glazed door segments
  wall height, drops to the same 2.7 mm threshold as a door (both are walked over), with a line per leaf on two tracks across the wall instead of a swing — so it takes no floor and a sofa can go against it; openings 150/175/200/250/300 cm (1/8 m series), no hand - scad/walls/sliding_door.scad
- [x] Door segments
  wall height, drops to a 2.7 mm threshold that carries on into the room as the quarter circle the leaf sweeps, so the piece occupies the swing, with the opening width engraved on that plate; openings 62.5/75/87.5/100/112.5 cm (DIN 18101 Rohbaumass), left/right hand - scad/walls/door.scad
