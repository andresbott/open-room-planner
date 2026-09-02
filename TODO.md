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

## Dining

- [x] Dining table
  med; rect 120x80..200x100 and square 70/80/90 on four corner legs with real air under
  the top (printed FACE DOWN, a pocket per foot in diagonal order); round 90-120 on a
  pedestal with a splayed foot - scad/diningroom/table.scad
  - [ ] 70x70 warns its legs leave too little span — decide whether to force Legs=false
    for the smallest square top

## Bathroom

- [x] Shower tray / enclosure
  low; 80x80..120x120 and 80x120 / 90x140 cm, a real sunken pan with a sunk drain and a
  cover ring; -D Show_enclosure=true adds a walk-in kerb - scad/bathroom/shower.scad
  - [ ] Expose the kerb as a Makefile knob if the walk-in variant is worth rendering

## Kids room

- [x] Cube storage (KALLAX-style)
  med; 77x39 cm, real open cube bays cut into the front face (prints on its back)
  (was a grid engraved on top) - scad/kidsroom/cube_storage.scad
  - [ ] More sizes in the Makefile: 2x4 147x39 (the part takes Cols/Rows)

## Hobby / gym

- [x] Photo studio
  high; a 2 m seamless backdrop that coves down to the floor, a softbox angled in from each front
  corner and a posing stool — a studio set, not the projector screen it is built like; prints
  upright (concave cove + vertical draft-tapered panels, no overhangs) - scad/hobby/photo_studio.scad
  - [ ] More backdrop widths (the part takes any Width; PHOTO_STUDIO_WIDTHS in the Makefile)

# Structure

## Walls

- [x] Wall corners
  med; an L of two wall arms meeting at a right angle, one per thickness (11.5/17.5/24) with
  ~30 cm stub legs — drop one at each room corner and imply the run between, rather than a
  segment along every wall. Square-ended so it still butts a straight wall; one L covers all
  four corners by turning it (no hand); no engraved number, the shape does the work -
  scad/walls/corner.scad
  - [ ] More corner leg lengths / a size matrix in the Makefile (the part takes any Leg)

## Pool

- [x] Pool tiles
  low; 200 cm module at 35 cm, Kind = corner / edge / water / steps / round / ladder — four
  corners make the smallest pool; add edges and water for a bigger one, a steps or ladder tile
  where you get in, a round corner for a curved end. An empty sunken basin (no water surface); a third magnet at the centre
  - scad/pool/pool.scad
  - [ ] More module sizes in the Makefile (150 for a plunge pool; the part takes any Module)

# Tools

## Measuring

# Fixes
