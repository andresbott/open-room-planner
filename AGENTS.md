# AGENTS.md — how to add and change parts in open-room-planner

This is a catalogue of 3D-printable furniture tokens for a 1:40 room planner. Every
part is one `scad/<room>/<part>.scad`, written in **real-world centimetres** and shrunk
on the way out by `scad/lib/common.scad`. Read `README.md` first for the scale, height,
wall and magnet system — this file is about **how a new part should look and be built**,
which the README does not spell out.

The rule that matters most: **a token is not a labelled brick.** It is a small model of
a piece of furniture, seen from a low angle across a table. If a new part comes out as a
rounded box with a hairline drawn on its top face, it is not finished.

---

## 1. The style rules

### 1.1 Relief beats ink

Prefer, in this order:

1. **Real form** — the silhouette does the work: a pedestal under a seat, a plinth and a
   worktop lip on a cabinet, a slab on two panel ends, a waist between a foot and a top.
2. **A real hollow or recess** — deep enough to catch the light and to feel under a
   fingertip: a sink bowl, a bath basin, a hob burner, a recessed door front, an open
   shelf bay.
3. **An engraved line or symbol** — last resort, and only for things that genuinely
   *are* ink: an engraved size (`label()`), a pictogram (`hanger()`, `drawers()`,
   `place_setting()`, `rays()`), a drain ring on a surface too big to mistake it, a seat
   pad line.

At 1:40 a `Label_depth` (0.4 mm) groove says nothing under a fingertip and disappears in
a photograph. Do not spend a part's whole design on engraving.

### 1.2 Put the detail where a low angle can see it

The top face is the face a photograph of the plan sees *least* of, and on a tall piece it
is 15 × 15 mm of nothing. Doors, drawers, oven doors, portholes, control fascias and
handles go on the **front (−Y) face**, where they are in the room.

**Never fake an elevation on the top face** — no "+Y stands for up" seams. That was the
old kitchen and fridge, and it read as a puzzle rather than as furniture.

### 1.3 It prints the right way up, without supports

Non-negotiable, because the whole set is meant to come off an FDM bed unattended:

- Nothing overhangs by more than **45°**. A step *outwards* on the way up is a 45° flare
  (`flare()`); a hollow's walls **slope out** as they rise (`hollow()`); a raised pad
  tapers (`cushion()`).
- Nothing has to bridge. A recess in a vertical face is fine (it is a short ceiling);
  a hole through mid-air is not.
- **No spikes or thin protrusions.** A tap, a handle, a knob is ~1 mm at 1:40 — it snaps
  off and catches on whatever the piece is stored with. Model it as a **cut**: a grip
  slot (`Grip_h`), a knob dip, or leave it off and draw what it stands on (a sink's deck).
  The one thing that may stand off a face is a **vertical prism** — a half-round bar up a
  door, as `bathroom/cabinet.scad` does: every layer lands squarely on the one below, so it
  prints support-free and there is nothing fine enough to break. A horizontal bar, a tap or
  a bud is not that; if it is not a prism running the print direction, cut it instead.
- Nothing finer than one nozzle: `Symbol_stroke` (0.4 mm) is the pen, `Symbol_min`
  (1.6 mm) the smallest symbol worth cutting. Keep `Symbol_margin` to an edge.
- The magnet pocket opens at the **bottom** face and needs `magnet_pocket_h()` of depth
  with material above it — see §1.6.

If a part has to print upside down or on its back to obey this, that is allowed, but say
so in capitals in the header comment (`office/desk.scad`, `livingroom/bookshelf.scad`).

### 1.4 A part must be recognisable, and different from its neighbours

Two pieces that share a footprint have to differ by something a person can see. In the
kitchen: the run has drawer fronts, the sink a bowl and a door pair, the dishwasher one
full-height panel under a fascia, the cooker burners and knobs, the fridge two uneven
doors, the larder three even courses. When you add a part, look at what it will sit next
to and give it the thing that tells them apart — then write that reason in the header.

### 1.5 Real dimensions, always

```openscad
cm(v)         // real cm      -> printed mm  (footprints, depths, insets)
mm(v)         // real mm      -> printed mm
rise(v)       // real cm      -> printed mm, for what stands ON a piece (a cushion, a TV)
printed_h(v)  // real cm      -> printed mm, for a whole piece's height (floors at Height_min)
plan_cm(v) / rise_cm(v)       // the way back, for reporting and for handing on
```

- A part reads like a spec sheet: `Width = 160; Depth = 90; Height = 85;` — never
  pre-divided numbers.
- Every part sets `Print_h = printed_h(Height);` right after its dimensions.
- Only **print detail** stays in printed mm: engraving depth, corner rounding, magnet
  pockets, a 45° flare's height (45° is a fact about the printer, so it uses `cm()` of
  the step and is the one height `Height_scale` leaves alone).
- Derive, do not hand-tune: size a bowl / a symbol / a fronts grid from the piece it is
  on, so one file covers every variant (`washbasin.scad`, `cabinet.scad`).

### 1.6 Clamp, then say so

A part must render at any `Scale`, `Height_scale` or size without breaking. Clamp
everything to what fits, and `echo()` when something was given up, in the units the part
is written in:

```openscad
echo(str("WARNING: an ", Bowl_depth, " cm bowl does not fit in a ", Height,
         " cm unit over ", magnet_pocket_h(), " mm of magnet pocket — sunk ",
         rise_cm(bowl_dz()), " cm instead (give it more: SINK_H)"));
```

Silent truncation is a bug. `NOTE:` for "this still works, but differently"; `WARNING:`
for "you asked for something you did not get".

Every part takes at least one magnet. Hand `magnets()` **the footprint that actually
touches the board** — for a unit on a plinth that is `unit_plinth_d()`, for a pedestal it
is the foot — so the disc is chosen and the pockets placed on the real bottom face.

### 1.7 Conventions

| | |
|---|---|
| origin | the piece is centred on it, standing on `z = 0` |
| front | **−Y**. Back / wall side is +Y, and stays flush so pieces butt |
| `Width` / `Depth` / `Height` | real cm; `Diameter` for a round piece. The Makefile passes these by name — do not rename them |
| `Magnets` | pocket count, `0` = none |
| `Show_*` | one toggle per feature, default `true`, so a plain variant is a `-D` away |
| units in comments | always say `cm` or `mm`; a bare number is a bug waiting to happen |

---

## 2. The shared library

Check `scad/lib/common.scad` before writing geometry — most of what a new part needs is
already there, and using it is what keeps the set looking like one set.

**Bodies** `footprint()` · `footprint_2d()` · `footprint_round(_2d)()` ·
`footprint_oval(_2d)()` · `footprint_front_2d()` · `footprint_inset_2d()` · `flare()`

**Fitted units** (a kitchen run, an island, a larder, any cabinet with fronts)
`base_unit()` · `island_unit()` · `unit_fronts()` · `unit_fascia()` and the
`unit_over/back/room/slab/foot/face_z0/face_z1/face_d/plinth_d()` functions (plus
`island_plinth_w/d()` for the four-sided version). Pass the same `top_cm` throughout;
`0` means "no worktop of its own, fronts run the full height".

**Legged pieces** (a chair, a bench, a buffet, a chest, a bedside table — anything
free-standing) `legged_block()` · `legged_2d()` and the
`legged_set/leg/face_z1/face_d/field_w/floor_w/floor_d()` functions. Corner posts at the
full footprint, the rail between them set back, a slab over the lot: a frame rather than a
brick, and still a broad bottom face for a pocket. Fronts go on the rail face — hand
`unit_fronts()` the field between the posts and `face_cm = legged_face_d(…)`.

**Open bays** `front_bays()` — a grid of open recesses with the shelves left standing at the
face as ribs: an open shelf unit, a glazed case, a wardrobe frame's hanging space. Equal bays
only; a piece whose bays differ cuts them one at a time (`bedroom/ikea_pax.scad`).

**Handles** are the quickest way to say what kind of furniture a piece is: a fitted kitchen
is handleless and reads by the grip rail `unit_fronts()` cuts by default; a chest of drawers,
a bedside table or a vanity has knobs (`knob_cm`/`knob_n`, or `front_knobs()` directly); a
bathroom column has a real bar (`grip = false` and add your own — see §1.3 for what may stand
off a face and what may not).

**A slab on open legs** (a table — the one body with real air under it) `slab_on_legs()` ·
`slab_legs_2d()` · `slab_leg_pockets()` and `slab_leg()` / `slab_leg_gap()` / `slab_leg_x()` /
`magnet_span_cm()`. The outline is the child, so a round top and a rectangular one come out of
the same call. It only works because those parts **print face down** — upright the slab would
bridge between the legs — so say so in capitals in the header, as they all do.

Reach for it only when openness is the point of the piece, and check a leg can still bury a
magnet first: `slab_leg()` clamps to `magnet_span_cm()` (25 cm of real furniture at 1:40), and
on anything shallower than about 50 cm that eats the whole depth — which is why the dining
bench and the hall console are frames instead. `slab_leg_gap()` is there to report it.

**Hollows** `hollow(top_z, depth) <2D child>` — a sink bowl, a bath basin, a hob burner.
Walls slope out to a flat floor (`Hollow_floor`), which is also what gives a drain
somewhere to sit.

**Faces** `front_recess()` (a recess in the front, −Y) · `back_recess()` (the same in the
back, +Y — recess both faces of a thin upright and the web between still prints solid) ·
`appliance_front()` (porthole machines) · `porthole()`

**Soft things** `cushion()` — a tapered raised pad: a pillow, a seat, a sofa back, an
upright TV or mirror board.

**Ink** `label()` · `label_front()` · `label_size*()` · `groove()` · `stroke_line()` ·
`stroke_arc()` · `hanger()` · `drawers()` · `place_setting()` · `rays()`

**Magnets** `magnets()` · `magnet_pads()` · `magnet_pocket()` · `magnet_min_span()` ·
`magnet_pocket_h()` · `magnet_count()` · `magnet_row()`

If two parts start needing the same shape, **put it in the library** with a doc comment
in the house voice — that is how `hollow()` and `base_unit()` got there.

---

## 3. Adding a part

1. **Write `scad/<room>/<part>.scad`.** Copy the shape of a sibling: header comment,
   `include <../lib/common.scad>`, dimensions, `Print_h`, feature knobs, `Magnets`, the
   call, then the modules and `function`s it needs.
2. **Declare it in the Makefile**, in that room's block:
   ```make
   $(eval $(call part,<room>,<part>,Height=$(<PART>_H);Magnets=1,<out-name>))
   ```
   → `files/<room>/<room>_<out-name>.{stl,png}`. Add a `<PART>_H ?= <cm>` with the other
   room heights, and use a `foreach`/`eval` matrix for size variants (see `BED_SIZES`).
3. **Render and *look at it*:** `make <room>` (or `make <room> REBUILD=1`).
   The PNG in `files/<room>/` is the review — open it. If it reads as a box, go back to
   §1.1.
4. **Update `TODO.md`** — mark the item `[x]` with a one-line note ending in the path,
   and add `- [ ] More sizes: …` sub-tasks for what is not built yet. Do not claim a
   variant the Makefile does not render.

### Verification before claiming it works

```sh
make <room> REBUILD=1 2>&1 | grep -iE 'ECHO|ERROR|Simple:'   # manifold + no surprise clamps
```

Every render must report `Simple: yes`. Then check the extremes, because a token has to
survive the global knobs:

```sh
for o in "-D Scale=100" "-D Height_scale=0.4" "-D Height_scale=2"; do
  openscad -o /tmp/t.stl $o scad/<room>/<part>.scad 2>&1 | grep -iE 'ECHO|ERROR|Simple: *no'
done
```

Only the library's own expected notes (a small scale dropping to the 2 mm disc) are
acceptable there. If you changed `scad/lib/common.scad`, render **every** part — the lib
is shared by all of them:

```sh
for f in $(find scad -name '*.scad' -not -path 'scad/lib/*'); do
  openscad -o /tmp/chk.stl "$f" 2>&1 | grep -iE 'ERROR|Simple: *no' && echo "^^ $f"
done
```

To inspect a part from another angle (note: `--render` must come **before** `--camera`,
or OpenSCAD 2021 prints its usage and exits):

```sh
openscad -o /tmp/p.png --imgsize=800,800 --render --camera=0,0,0,0,0,0,60 scad/<room>/<part>.scad
```

---

## 4. Writing the header comment

Every part opens with prose, not a bullet list, and it earns its length by explaining
**why the piece is shaped the way it is** — including what was deliberately left out and
what it must not be mistaken for. Follow the existing files' voice: plain sentences, em
dashes, real numbers, no marketing. Add an ASCII section drawing when the form is not
obvious from the words (`office/chair.scad`, `office/desk.scad`, the fitted-units section
of the library).

Cover, in roughly this order:

- what the piece is, and what shape it is built from;
- why the detail is where it is (and why it is not engraved on the top, if that is the
  interesting bit);
- what it deliberately does not have, and why (a tap, a handle, a footring);
- what `Width` / `Depth` / `Height` mean in real cm, with the common real sizes;
- anything about printing: which way up, what has to stay above a magnet pocket.

Same for library additions, plus how to call them.

## 5. Housekeeping

- Rendered `files/**/*.stl` and `*.png` are **tracked**: re-render the rooms you touched
  and commit the outputs with the source. `make all` if you changed the library.
- Do not edit anything under `files/` by hand.
- **OpenSCAD's STL output is not byte-reproducible** — two renders of the same source
  differ in facet order, so `md5sum` and `git diff` will report changes that are not
  changes. To prove a refactor left geometry alone, compare *sorted* geometry:
  `grep -oE '(vertex|facet normal) .*' f.stl | sort | md5sum` (and the facet count).
- `TODO.md` is managed by the `todo` app — keep to its format (see the comment block at
  the top of the file) and only ever edit inside it.
- `README.md` is the user-facing explanation of the system (scale, heights, walls,
  magnets). Update it when you change something it documents.
