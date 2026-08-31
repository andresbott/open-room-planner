# Makefile — render open-room-planner parts (STLs + preview PNGs) from the
# per-part .scad files under scad/, grouped by room. Each room -> files/<room>/.
#
# Parts are written in real-world centimetres and shrunk to the plan scale by
# scad/lib/common.scad (1:40 — 2.5 cm = 1 m).
#
# Add a part: drop scad/<room>/<part>.scad next to its siblings, then declare one
#   $(call part,<room>,<part>,<PARAMS>,<out-name>)
# per variant in that room's block (explicitly, or via a foreach/eval matrix like
# the bed sizes). The generic %.stl / %.png rules do the actual rendering.
#
# Add a room: give it a <ROOM>_DIR, declare its parts, add a phony aggregator and
# a clean-<room> target, and list it under `all` / `clean`.

OPENSCAD   ?= openscad
SCAD_DIR   := scad
LIB_DIR    := $(SCAD_DIR)/lib
FILES_DIR  := files
# every part depends on the shared lib
LIB_SCADS  := $(wildcard $(LIB_DIR)/*.scad)

# Plan scale: 1:SCALE. 40 -> 2.5 cm on the plan = 1 m (an A5 sheet ~ a 50 m2 room).
SCALE      ?= 40
# OpenSCAD $fn for the final render (the CLI is never $preview, so this is the real one)
RESOLUTION ?= 64

# Heights are real-world centimetres, like every footprint, and are shrunk by the
# same SCALE (see the heights section in scad/lib/common.scad). Each part below
# declares the real height of the furniture it stands for — <ROOM>_<PART>_H, in cm.
# These two knobs act on all of them at once:
#   HEIGHT_SCALE  squash every piece (0.75 = three quarters as tall) while keeping
#                 them in the right order — a shorter, cheaper set to print
#   HEIGHT_MIN    the least a piece may print, whatever its real height: a magnet
#                 pocket (2.2 mm for the standard 4x2 disc) plus 1.2 mm of material
#                 over it. Only a shower tray reaches it — raise it along with
#                 MAGNET_H if you fit a deeper magnet.
HEIGHT_SCALE ?= 1
HEIGHT_MIN   ?= 3.4

# Magnet pockets in the bottom face, in printed mm — hardware, so they are not
# scaled. Two discs cover the catalogue: the standard 4x2, and a 2x1 for pieces too
# narrow for it (a chair leg, a partition wall) — each part gets the bigger one that
# fits, and says so when it drops to the small one. They are different heights, so a
# pocket is cut as deep as the disc that goes in it: 2.2 mm under a piece of furniture,
# 1.2 under a wall (see HEIGHT_MIN above — the shallowest piece has to bury the deeper
# one). How many go in a part is a per-part parameter.
MAGNET_D       ?= 4
MAGNET_D_SMALL ?= 2
MAGNET_H       ?= 2
MAGNET_H_SMALL ?= 1
# Printer allowance on a pocket: an FDM hole prints undersize, so it is cut this
# much wider and deeper than the disc. Raise it if the magnets will not drop in,
# lower it if they fall out.
MAGNET_FIT     ?= 0.3
MAGNET_FIT_H   ?= 0.2

# Shared by every part; each part adds its own dimensions on top.
COMMON = Scale=$(SCALE);Resolution=$(RESOLUTION);Height_scale=$(HEIGHT_SCALE);Height_min=$(HEIGHT_MIN);Magnet_d=$(MAGNET_D);Magnet_d_small=$(MAGNET_D_SMALL);Magnet_h=$(MAGNET_H);Magnet_h_small=$(MAGNET_H_SMALL);Magnet_fit=$(MAGNET_FIT);Magnet_fit_h=$(MAGNET_FIT_H)

# Preview-image settings. The %.png rule renders straight to PNG (no post-processing).
# IMG_COLOR is a colorscheme *name*. The custom "OceanPlan" scheme is shipped in this
# repo under $(SCAD_CONFIG_DIR); it is made visible to OpenSCAD at render time via
# XDG_CONFIG_HOME, since OpenSCAD 2021.01 resolves schemes by name, not by file path.
IMG_SIZE   ?= 1600,1600
IMG_COLOR  ?= OceanPlan
SCAD_CONFIG_DIR ?= $(CURDIR)/openscad-config
IMG_OPTS   ?= --imgsize=$(IMG_SIZE) --colorscheme=$(IMG_COLOR) --viewall --autocenter --render

# Renders are skipped when the outputs are newer than the .scad sources and this
# Makefile. Set REBUILD=1 to force everything to re-render.
REBUILD    ?=
ifdef REBUILD
FORCE_DEP  := FORCE
endif

default: help

# part,<room>,<part-scad>,<PARAMS>,<out-name> -> declares files/<room>/<room>_<out-name>.{stl,png}
# and the sources + parameters they share.
define part
STLS_$(1) += $(FILES_DIR)/$(1)/$(1)_$(4).stl
SRCOF_$(FILES_DIR)/$(1)/$(1)_$(4).stl := $(SCAD_DIR)/$(1)/$(2).scad
$(FILES_DIR)/$(1)/$(1)_$(4).stl $(FILES_DIR)/$(1)/$(1)_$(4).png: $(SCAD_DIR)/$(1)/$(2).scad $(LIB_SCADS) Makefile $(FORCE_DEP)
$(FILES_DIR)/$(1)/$(1)_$(4).stl $(FILES_DIR)/$(1)/$(1)_$(4).png: SRC = $(SCAD_DIR)/$(1)/$(2).scad
$(FILES_DIR)/$(1)/$(1)_$(4).stl $(FILES_DIR)/$(1)/$(1)_$(4).png: PARAMS = $(3);$(COMMON)
endef

#==========================================================================================
##@ Rendering
#==========================================================================================
.PHONY: all
all: bedroom livingroom kitchen diningroom bathroom office hallway kidsroom laundry outdoor hobby walls pool tools ## render every room + structure (STLs + previews)

# ---- Bedroom -----------------------------------------------------------------
BEDROOM_DIR  := $(FILES_DIR)/bedroom

# -- Beds: one piece per mattress size, in cm (IKEA naming). Height is the top of
#    the mattress — one of the lowest pieces of the set.
BED_SIZES := 80x200 90x200 120x200 140x200 160x200 180x200
BED_H     ?= 50
# magnet pockets per bed, in a row along the length (0 = none)
BED_MAGNETS ?= 2
# expand <width>x<length> -> Width/Length params
$(foreach s,$(BED_SIZES),$(eval $(call part,bedroom,bed,Width=$(word 1,$(subst x, ,$(s)));Length=$(word 2,$(subst x, ,$(s)));Height=$(BED_H);Magnets=$(BED_MAGNETS),bed_$(s))))

# -- IKEA PAX wardrobe frames, in cm — every width x every depth, at the tall
#    236 cm frame height (PAX_H=201 renders the short frame instead).
PAX_WIDTHS := 50 75 100
PAX_DEPTHS := 35 58
PAX_H      ?= 236
# magnet pockets per frame (0 = none). At 1:40 the 35 cm-deep frames are 8.75 mm
# across — still wide enough for a 4 mm disc, so every frame depth takes one. The
# widths in PAX_WIDE_WIDTHS get a row of PAX_WIDE_MAGNETS instead: a 100 cm frame is
# 25 mm long and one pocket in the middle lets it pivot on the plan.
PAX_MAGNETS      ?= 1
PAX_WIDE_WIDTHS  := 100
# ... and PAX_MAGNETS=0 still means no pockets on any frame, wide ones included.
PAX_WIDE_MAGNETS ?= $(if $(filter 0,$(PAX_MAGNETS)),0,2)
$(foreach w,$(PAX_WIDTHS),$(foreach d,$(PAX_DEPTHS),$(eval $(call part,bedroom,ikea_pax,Width=$(w);Depth=$(d);Height=$(PAX_H);Magnets=$(if $(filter $(w),$(PAX_WIDE_WIDTHS)),$(PAX_WIDE_MAGNETS),$(PAX_MAGNETS)),ikea_pax_$(w)x$(d)))))

# -- IKEA HEMNES chests of drawers: <width>x<depth> footprints, in cm, at the
#    96 cm carcass height of the 3- and 8-drawer chests (the 6-drawer one is 131).
HEMNES_SIZES := 108x50
HEMNES_H     ?= 96
# magnet pockets per chest, in a row along the width (0 = none)
HEMNES_MAGNETS ?= 2
$(foreach s,$(HEMNES_SIZES),$(eval $(call part,bedroom,ikea_hemnes,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(HEMNES_H);Magnets=$(HEMNES_MAGNETS),ikea_hemnes_$(s))))
# The narrow 2-drawer chest (54x50, one column of two, a lower 66 cm carcass) and the wide
# 8-drawer one (160x50, two columns of four at the 96 cm carcass) — the same part, Cols and
# Drawers driving how many fronts it carries (see ikea_hemnes.scad).
$(eval $(call part,bedroom,ikea_hemnes,Width=54;Depth=50;Height=66;Cols=1;Drawers=2;Magnets=1,ikea_hemnes_54x50))
$(eval $(call part,bedroom,ikea_hemnes,Width=160;Depth=50;Height=$(HEMNES_H);Cols=2;Drawers=4;Magnets=2,ikea_hemnes_160x50))

# -- Bed-end benches: one piece per common width, in cm — 100/120 for a single or
#    small double, 140/160 to span a queen/king footboard. Depth stays 40 (a
#    bench's seat depth). Height is seat height — the flat top face, no cushion.
#    Printed as a U — a seat slab on an end panel at each end, open underneath — so
#    print it UPSIDE DOWN, seat face on the bed: nothing to bridge, nothing to support.
BENCH_WIDTHS := 100 120 140 160
BENCH_DEPTH  ?= 40
BENCH_H      ?= 45
# magnet pockets per bench: one in the foot of each end panel, the only material a U
# has at floor level (0 = none, 2 = the pair)
BENCH_MAGNETS ?= 2
$(foreach w,$(BENCH_WIDTHS),$(eval $(call part,bedroom,bench,Width=$(w);Depth=$(BENCH_DEPTH);Height=$(BENCH_H);Magnets=$(BENCH_MAGNETS),bench_$(w)x$(BENCH_DEPTH))))
# The branded IKEA EKENÄSET bench: the same bench part at its real 112 x 48 cm
# footprint, at the same seat height and magnet count as the plain widths.
$(eval $(call part,bedroom,bench,Width=112;Depth=48;Height=$(BENCH_H);Magnets=$(BENCH_MAGNETS),ikea_ekenaset_112x48))

# -- Nightstands / bedside tables: one piece per common width, in cm; depth stays
#    40 (a bedside table's usual depth). Height is the top, about level with the
#    mattress next to it. Near-square — at 1:40 a 40 cm side is 10 mm, comfortably
#    wide enough for the single 4 mm magnet.
NIGHTSTAND_WIDTHS  := 40 45 50 60
NIGHTSTAND_DEPTH   ?= 40
NIGHTSTAND_H       ?= 55
NIGHTSTAND_MAGNETS ?= 1
$(foreach w,$(NIGHTSTAND_WIDTHS),$(eval $(call part,bedroom,nightstand,Width=$(w);Depth=$(NIGHTSTAND_DEPTH);Height=$(NIGHTSTAND_H);Magnets=$(NIGHTSTAND_MAGNETS),nightstand_$(w)x$(NIGHTSTAND_DEPTH))))

# -- Dressing tables: one piece per common vanity width, in cm — 80/100/120. A
#    standing mirror on the back of a flat top: a vanity's drawers are on its front,
#    which a token seen from above cannot show, and the mirror is enough to tell the
#    piece apart (see the .scad). Depth stays 40 (a slim vanity). Height is the top
#    at desk height; the mirror stands its own 65 cm above that.
DRESSING_TABLE_WIDTHS  := 80 100 120
DRESSING_TABLE_DEPTH   ?= 40
DRESSING_TABLE_H       ?= 75
# magnet pockets per table, in a row along the width (0 = none)
DRESSING_TABLE_MAGNETS ?= 2
$(foreach w,$(DRESSING_TABLE_WIDTHS),$(eval $(call part,bedroom,dressing_table,Width=$(w);Depth=$(DRESSING_TABLE_DEPTH);Height=$(DRESSING_TABLE_H);Magnets=$(DRESSING_TABLE_MAGNETS),dressing_table_$(w)x$(DRESSING_TABLE_DEPTH))))

# -- Extra bedroom pieces, one default variant each (sizes live in the .scad). A
#    standalone/sliding wardrobe is full height, like a tall PAX frame.
WARDROBE_H ?= 236
$(eval $(call part,bedroom,wardrobe,Height=$(WARDROBE_H);Magnets=2,wardrobe))

BEDROOM_STLS := $(STLS_bedroom)
BEDROOM_PNGS := $(BEDROOM_STLS:.stl=.png)

.PHONY: bedroom
bedroom: $(BEDROOM_STLS) $(BEDROOM_PNGS) ## render bedroom parts + previews -> files/bedroom/

# ---- Living room -------------------------------------------------------------
LIVINGROOM_DIR := $(FILES_DIR)/livingroom

# -- Standing lamp: one piece — the classic floor lamp, a 45 cm drum (empire) shade
#    on a pole. Height is the real height of a floor lamp — the tallest thing in the
#    room after the wardrobes. The shade is the widest part of a lamp — the space it
#    actually takes — so that is the size in the file name. lamp.scad still carries
#    the cone, globe and tripod shapes at any shade/foot size; they are just not
#    built (override Type/Shade to render one).
LAMP_H       ?= 160
# magnet pockets per lamp (0 = none). At 1:40 a 30 cm lamp foot is 7.5 mm across —
# comfortably wide enough for a 4 mm disc, so the lamp takes one pocket.
LAMP_MAGNETS ?= 1
# the drum shade diameter and the foot it stands on, in cm
LAMP_SHADE   ?= 45
LAMP_BASE    ?= 30
# The least the pole may print, in mm — a real 5 cm pole is only 1.25 mm at 1:40, so
# this is what actually gets printed. Six perimeters at a 0.4 nozzle: a pole this
# thick prints upright without wobbling and survives handling. Raise it for a
# sturdier pole, lower it for a finer one.
LAMP_STEM_MIN ?= 2.4
$(eval $(call part,livingroom,lamp,Type="drum";Shade=$(LAMP_SHADE);Base=$(LAMP_BASE);Height=$(LAMP_H);Stem_min=$(LAMP_STEM_MIN);Magnets=$(LAMP_MAGNETS),lamp_drum_$(LAMP_SHADE)))

# -- Sofas: straight multi-seat tokens by width in cm (depth 90) — a 150 loveseat,
#    a 200 three-seat and a 240 large — plus an L-shaped chaise sectional in both
#    hands (chaise on the left or the right, seen from the front). Height is the top
#    of the back over the seat it rises from (Seat); the chaise is a real L
#    footprint, not a wider rectangle (see scad/livingroom/sofa.scad).
SOFA_WIDTHS   := 150 200 240
SOFA_DEPTH    ?= 90
SOFA_H        ?= 85
SOFA_SEAT     ?= 45
SOFA_MAGNETS  ?= 2
# the L-shaped chaise sectional: overall back-run width x how far the chaise reaches,
# and the width of the chaise leg — one size, in both hands
CHAISE_WIDTH  ?= 260
CHAISE_DEPTH  ?= 160
CHAISE_LEG    ?= 95
CHAISE_HANDS  := left right
$(foreach w,$(SOFA_WIDTHS),$(eval $(call part,livingroom,sofa,Width=$(w);Depth=$(SOFA_DEPTH);Height=$(SOFA_H);Seat=$(SOFA_SEAT);Magnets=$(SOFA_MAGNETS),sofa_$(w)x$(SOFA_DEPTH))))
$(foreach h,$(CHAISE_HANDS),$(eval $(call part,livingroom,sofa,Chaise="$(h)";Width=$(CHAISE_WIDTH);Depth=$(SOFA_DEPTH);Chaise_depth=$(CHAISE_DEPTH);Chaise_width=$(CHAISE_LEG);Height=$(SOFA_H);Seat=$(SOFA_SEAT);Magnets=$(SOFA_MAGNETS),sofa_chaise_$(CHAISE_WIDTH)x$(CHAISE_DEPTH)_$(h))))

# -- Extra living-room pieces, one default variant each, at their real heights in cm.
#    The armchair carries two: the top of the back (Height) over the seat it rises
#    from (Seat) — see armchair.scad.
ARMCHAIR_H      ?= 80
ARMCHAIR_SEAT   ?= 42
TV_UNIT_H       ?= 45
LR_SIDEBOARD_H  ?= 80
LR_CONSOLE_H    ?= 80
$(eval $(call part,livingroom,armchair,Height=$(ARMCHAIR_H);Seat=$(ARMCHAIR_SEAT);Magnets=1,armchair))
$(eval $(call part,livingroom,tv_unit,Height=$(TV_UNIT_H);Magnets=2,tv_unit))
$(eval $(call part,livingroom,sideboard,Height=$(LR_SIDEBOARD_H);Magnets=2,sideboard))
$(eval $(call part,livingroom,console,Height=$(LR_CONSOLE_H);Magnets=2,console))

# -- Bookshelves: open shelving (BILLY-style), one piece per common width x
#    height in cm; depth stays 28 (the BILLY carcass). The shelves are a real
#    recessed front, not a symbol engraved on top — printed on its BACK the
#    dividers stand as clean vertical walls (see scad/livingroom/bookshelf.scad).
BOOKSHELF_WIDTHS  := 40 60 80
BOOKSHELF_HEIGHTS := 106 202
BOOKSHELF_DEPTH   ?= 28
# magnet pockets per shelf unit, in the bottom face (0 = none)
BOOKSHELF_MAGNETS ?= 1
$(foreach w,$(BOOKSHELF_WIDTHS),$(foreach h,$(BOOKSHELF_HEIGHTS),$(eval $(call part,livingroom,bookshelf,Width=$(w);Depth=$(BOOKSHELF_DEPTH);Height=$(h);Magnets=$(BOOKSHELF_MAGNETS),bookshelf_$(w)x$(h)))))

LIVINGROOM_STLS := $(STLS_livingroom)
LIVINGROOM_PNGS := $(LIVINGROOM_STLS:.stl=.png)

.PHONY: livingroom
livingroom: $(LIVINGROOM_STLS) $(LIVINGROOM_PNGS) ## render living-room parts + previews -> files/livingroom/

# ---- Kitchen -----------------------------------------------------------------
KITCHEN_DIR := $(FILES_DIR)/kitchen
# Real heights in cm. Every counter unit — worktop, island, sink, corner, peninsula, the
# slot-in cooker AND the integrated dishwasher — finishes at the 90 cm counter line, so a
# row of them stands level (the dishwasher carries its own worktop slab too, see
# dishwasher.scad); a bar stool puts the seat at 65; the larder unit, the oven housing and
# the fridge run nearly floor to ceiling.
WORKTOP_H       ?= 90
ISLAND_H        ?= 90
SINK_H          ?= 90
COOKER_H        ?= 90
DISHWASHER_H    ?= 90
BAR_STOOL_H     ?= 65
K_CABINET_H     ?= 200
FRIDGE_H        ?= 185
CORNER_UNIT_H   ?= 90
BREAKFAST_BAR_H ?= 90
OVEN_COLUMN_H   ?= 200
$(eval $(call part,kitchen,worktop,Height=$(WORKTOP_H);Magnets=2,worktop))
# a short run the width of the dishwasher (60 cm), to sit beside it or fill a gap; near
# square, so one central pocket like the other 60 cm units rather than the long run's two
$(eval $(call part,kitchen,worktop,Width=60;Height=$(WORKTOP_H);Magnets=1,worktop_60))
# the in-between run lengths — 80 and 100 cm — the part sizes its cabinets off Width
$(eval $(call part,kitchen,worktop,Width=80;Height=$(WORKTOP_H);Magnets=2,worktop_80))
$(eval $(call part,kitchen,worktop,Width=100;Height=$(WORKTOP_H);Magnets=2,worktop_100))
$(eval $(call part,kitchen,island,Height=$(ISLAND_H);Magnets=2,island))
$(eval $(call part,kitchen,sink,Height=$(SINK_H);Magnets=2,sink))
$(eval $(call part,kitchen,cooker,Height=$(COOKER_H);Magnets=1,cooker))
# a wider range: 90 cm with six burners (3x2) and a double oven
$(eval $(call part,kitchen,cooker,Width=90;Height=$(COOKER_H);Burner_cols=3;Oven_cols=2;Magnets=2,cooker_90))
$(eval $(call part,kitchen,dishwasher,Height=$(DISHWASHER_H);Magnets=1,dishwasher))
$(eval $(call part,kitchen,bar_stool,Height=$(BAR_STOOL_H);Magnets=1,bar_stool))
$(eval $(call part,kitchen,cabinet,Height=$(K_CABINET_H);Magnets=1,cabinet))
$(eval $(call part,kitchen,fridge,Height=$(FRIDGE_H);Magnets=1,fridge))
# The corner unit takes one pocket under each arm — corner to opposite corner, which is
# what stops an L pivoting (see Magnets in corner_unit.scad, where 1 and 3 mean other
# layouts rather than fewer pockets in a row).
$(eval $(call part,kitchen,corner_unit,Height=$(CORNER_UNIT_H);Magnets=2,corner_unit))
# a bigger square corner (120x120, a 60x60 notch) and an unequal one (120x90) — the part
# takes any Width/Depth/Arm (see corner_unit.scad)
$(eval $(call part,kitchen,corner_unit,Width=120;Depth=120;Height=$(CORNER_UNIT_H);Magnets=2,corner_unit_120x120))
$(eval $(call part,kitchen,corner_unit,Width=120;Depth=90;Height=$(CORNER_UNIT_H);Magnets=2,corner_unit_120x90))
$(eval $(call part,kitchen,breakfast_bar,Height=$(BREAKFAST_BAR_H);Magnets=2,breakfast_bar))
# more peninsula lengths — the part sizes its cabinets off Width (150 short, 210/240 long)
$(eval $(call part,kitchen,breakfast_bar,Width=150;Height=$(BREAKFAST_BAR_H);Magnets=2,breakfast_bar_150))
$(eval $(call part,kitchen,breakfast_bar,Width=210;Height=$(BREAKFAST_BAR_H);Magnets=2,breakfast_bar_210))
$(eval $(call part,kitchen,breakfast_bar,Width=240;Height=$(BREAKFAST_BAR_H);Magnets=2,breakfast_bar_240))
$(eval $(call part,kitchen,oven_column,Height=$(OVEN_COLUMN_H);Magnets=1,oven_column))
# a single-oven column (no microwave) and a single oven over a warming drawer — the same
# housing, Micro_h=0 dropping the microwave and Warming_h adding the drawer (see oven_column.scad)
$(eval $(call part,kitchen,oven_column,Micro_h=0;Height=$(OVEN_COLUMN_H);Magnets=1,oven_column_single))
$(eval $(call part,kitchen,oven_column,Micro_h=0;Warming_h=14;Height=$(OVEN_COLUMN_H);Magnets=1,oven_column_warming))

KITCHEN_STLS := $(STLS_kitchen)
KITCHEN_PNGS := $(KITCHEN_STLS:.stl=.png)

.PHONY: kitchen
kitchen: $(KITCHEN_STLS) $(KITCHEN_PNGS) ## render kitchen parts + previews -> files/kitchen/

# ---- Dining room -------------------------------------------------------------
# The dining table lives here, alongside the seating and storage — every piece at
# its real height in cm: table tops at 75, seats at 45, a buffet at 85 and a glazed
# display cabinet at full 200 cm.
DININGROOM_DIR := $(FILES_DIR)/diningroom

# -- Tables: one piece per standard top, in cm, at dining-table height (TABLE_H=45
#    renders the same tops as coffee tables). Rectangular tops are <width>x<depth>;
#    a square top is the same thing with equal sides, listed apart only to read as a
#    group.
TABLE_RECT_SIZES   := 120x80 140x80 160x90 180x90 200x100
TABLE_SQUARE_SIZES := 70x70 80x80 90x90
#    Round tops, by diameter in cm.
TABLE_ROUND_DIAMS  := 90 100 110 120
TABLE_H            ?= 75
# magnet pockets per table (0 = none). A rectangular or square top stands on four corner
# legs, so a pocket is one FOOT, taken in diagonal order — two of them, corner to opposite
# corner, are what stop the piece pivoting, and four is one in every foot. A round top is
# a single pedestal with one pocket in the middle of its foot, which cannot pivot at all.
TABLE_MAGNETS        ?= 2
TABLE_CENTRE_MAGNETS ?= 1
$(foreach s,$(TABLE_RECT_SIZES),$(eval $(call part,diningroom,table,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(TABLE_H);Magnets=$(TABLE_MAGNETS),table_$(s))))
$(foreach s,$(TABLE_SQUARE_SIZES),$(eval $(call part,diningroom,table,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(TABLE_H);Magnets=$(TABLE_MAGNETS),table_$(s))))
$(foreach d,$(TABLE_ROUND_DIAMS),$(eval $(call part,diningroom,table,Round=true;Diameter=$(d);Height=$(TABLE_H);Magnets=$(TABLE_CENTRE_MAGNETS),table_round_$(d))))

# The chair carries two heights: the top of its back (Height) over the seat it rises
# from (Seat) — see chair.scad.
CHAIR_H           ?= 90
CHAIR_SEAT        ?= 45
DR_SIDEBOARD_H    ?= 85
DR_BENCH_H        ?= 45
DISPLAY_CABINET_H ?= 200
$(eval $(call part,diningroom,chair,Height=$(CHAIR_H);Seat=$(CHAIR_SEAT);Magnets=1,chair))
$(eval $(call part,diningroom,sideboard,Height=$(DR_SIDEBOARD_H);Magnets=2,sideboard))
$(eval $(call part,diningroom,bench,Height=$(DR_BENCH_H);Magnets=2,bench))
$(eval $(call part,diningroom,display_cabinet,Height=$(DISPLAY_CABINET_H);Magnets=2,display_cabinet))

DININGROOM_STLS := $(STLS_diningroom)
DININGROOM_PNGS := $(DININGROOM_STLS:.stl=.png)

.PHONY: diningroom
diningroom: $(DININGROOM_STLS) $(DININGROOM_PNGS) ## render dining-room parts + previews -> files/diningroom/

# ---- Bathroom ----------------------------------------------------------------
# Real heights in cm: a shower tray is floor level, a bath rim 58, a toilet cistern
# 78, a vanity counter 85 and a storage column 180.
BATHROOM_DIR := $(FILES_DIR)/bathroom

# -- Bathtubs: <length>x<width> footprints in cm, in the two common shapes — a
#    built-in rectangular tub and a freestanding oval one (sizes per
#    twbathtub.com). The basin is a sunken hollow, so the tub reads as a bath and
#    not as a tray; see scad/bathroom/bathtub.scad. Height is the real rim height —
#    and at 1:40 that still leaves room for the tub's full 40 cm of hollow.
BATHTUB_RECT_SIZES := 120x70 140x70 150x70 160x75 170x75 180x80
BATHTUB_OVAL_SIZES := 95x60 120x60 125x65 150x70 170x75 180x80
BATHTUB_H          ?= 58
# magnet pockets per tub, in a row along the length (0 = none)
BATHTUB_MAGNETS ?= 2
$(foreach s,$(BATHTUB_RECT_SIZES),$(eval $(call part,bathroom,bathtub,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(BATHTUB_H);Magnets=$(BATHTUB_MAGNETS),bathtub_$(s))))
$(foreach s,$(BATHTUB_OVAL_SIZES),$(eval $(call part,bathroom,bathtub,Oval=true;Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(BATHTUB_H);Magnets=$(BATHTUB_MAGNETS),bathtub_oval_$(s))))

# -- Shower trays: <width>x<depth> footprints in cm — square trays plus a couple
#    of rectangular ones, from a compact 80x80 through the common 90x90 / 80x120
#    up to a 90x140 walk-in (size range per usacabinetstore.com standard-shower-
#    sizes). The pan is a real sunken floor with a sunk drain, not an engraved outline
#    (see scad/bathroom/shower.scad), and SHOWER_H is what makes room for it: it is the
#    real height of the tray plus the waste build-up under it, and 20 cm — a tray on the
#    frame its trap sits in — is 5 mm at 1:40, which is what it takes to bury a 2.2 mm
#    magnet pocket and still sink the full 4 cm pan above it. Still the lowest piece in
#    the catalogue by a long way. Build shorter and the recess is clamped to what is
#    left, with a warning in the render log (below ~17.5 cm), so a flat tray is a
#    SHOWER_H away if that is what you want.
SHOWER_SIZES := 80x80 90x90 100x100 120x120 80x120 90x140
SHOWER_H     ?= 20
# one central magnet pocket per tray is enough for a near-square piece (0 = none)
SHOWER_MAGNETS ?= 1
$(foreach s,$(SHOWER_SIZES),$(eval $(call part,bathroom,shower,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(SHOWER_H);Magnets=$(SHOWER_MAGNETS),shower_$(s))))

# The toilet carries two heights: over the cistern (Height) and the bowl/seat in
# front of it (Seat) — the token steps down at the join (see toilet.scad).
TOILET_H     ?= 78
TOILET_SEAT  ?= 40
B_CABINET_H  ?= 180
$(eval $(call part,bathroom,toilet,Height=$(TOILET_H);Seat=$(TOILET_SEAT);Magnets=1,toilet))
$(eval $(call part,bathroom,cabinet,Height=$(B_CABINET_H);Magnets=1,cabinet))

# -- Washbasins / vanity units: single-bowl by <width>x<depth> in cm (standard
#    European vanity sizes — 40 cloakroom, 50/60 compact, 80 roomy), plus wider
#    double-bowl units (Basins=2). Height is the real counter height; the bowl
#    auto-sizes to each counter and its dished recess is real, not engraved (see
#    washbasin.scad).
WASHBASIN_SIZES   := 40x35 50x40 60x45 80x50
WASHBASIN_DOUBLE  := 120x50 150x50
WASHBASIN_H       ?= 85
# magnet pockets per single unit, in a row along the width (0 = none). At 1:40
# the 40x35 cloakroom is 8.75 mm deep — wide enough for a 4 mm disc — and the wider
# doubles take the two they ask for.
WASHBASIN_MAGNETS ?= 1
$(foreach s,$(WASHBASIN_SIZES),$(eval $(call part,bathroom,washbasin,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Basins=1;Height=$(WASHBASIN_H);Magnets=$(WASHBASIN_MAGNETS),washbasin_$(s))))
$(foreach s,$(WASHBASIN_DOUBLE),$(eval $(call part,bathroom,washbasin,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Basins=2;Height=$(WASHBASIN_H);Magnets=2,washbasin_double_$(s))))

BATHROOM_STLS := $(STLS_bathroom)
BATHROOM_PNGS := $(BATHROOM_STLS:.stl=.png)

.PHONY: bathroom
bathroom: $(BATHROOM_STLS) $(BATHROOM_PNGS) ## render bathroom parts + previews -> files/bathroom/

# ---- Home office -------------------------------------------------------------
# Real heights in cm: a desk top at 74 with its pedestal at 72 underneath, a swivel
# chair's back at 95 over a 47 cm seat.
OFFICE_DIR := $(FILES_DIR)/office
DESK_H            ?= 74
OFFICE_CHAIR_H    ?= 95
OFFICE_CHAIR_SEAT ?= 47
FILING_CABINET_H  ?= 72
# A task chair stands on its five-star base, which is wider than the seat, so the
# base is what it occupies on the plan (65 cm base, 50 cm seat).
OFFICE_CHAIR_BASE ?= 65
OFFICE_CHAIR_SEAT_D ?= 50
# -- Desks: one piece per standard top, in cm. The token is a slab on a panel
#    support at each end — a U, printed upside down — with the size engraved on top.
#    Two magnet pockets, one in each support foot, an end of the desk apart.
DESK_SIZES   := 120x60 140x70 150x80 160x80
DESK_MAGNETS ?= 2
$(foreach s,$(DESK_SIZES),$(eval $(call part,office,desk,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(DESK_H);Magnets=$(DESK_MAGNETS),desk_$(s))))
$(eval $(call part,office,chair,Base=$(OFFICE_CHAIR_BASE);Diameter=$(OFFICE_CHAIR_SEAT_D);Height=$(OFFICE_CHAIR_H);Seat=$(OFFICE_CHAIR_SEAT);Magnets=1,chair))
$(eval $(call part,office,filing_cabinet,Height=$(FILING_CABINET_H);Magnets=1,filing_cabinet))

# -- IKEA IVAR pine shelving: <width>x<depth>x<height> in cm, built from the real side
#    units and shelves — the 48 wide unit takes one 42 cm shelf, 89 one 83, 174 two and
#    259 three, at either side-unit depth (30/50) and either height (124/179/226). Like
#    the bookshelf these are real open bays and shelves cut back into the front face, not
#    a symbol engraved on top — printed on its back the posts and shelves stand as clean
#    vertical walls (see scad/office/ikea_ivar.scad). Bays and shelves are derived from
#    the size, so a size not listed here still comes out right. Each unit carries its
#    WIDTH engraved on the top face, the way a wall segment carries its length.
#    IVAR_BACK is the back panel, in real cm. The real IVAR has none, but the token keeps
#    one so it prints: laid on its back the panel is a continuous first layer instead of a
#    grid of single-perimeter walls, and it braces posts and shelves that are all at the
#    print floor at 1:40. IVAR_BACK=0 renders the true open frame.
IVAR_SIZES ?= 48x30x124 48x30x179 89x30x179 89x50x179 174x30x179 174x50x179 \
              174x30x226 259x30x179 259x50x179
IVAR_BACK  ?= 2
# magnet pockets per unit, in a row along the width (0 = none). The 48 cm unit is only
# 12 mm long at 1:40 and takes one; the widths in IVAR_WIDE_WIDTHS get a row of
# IVAR_WIDE_MAGNETS instead, so a 259 cm run cannot pivot on the plan.
IVAR_MAGNETS      ?= 1
IVAR_WIDE_WIDTHS  := 89 174 259
# ... and IVAR_MAGNETS=0 still means no pockets on any unit, wide ones included.
IVAR_WIDE_MAGNETS ?= $(if $(filter 0,$(IVAR_MAGNETS)),0,2)
$(foreach s,$(IVAR_SIZES),$(eval $(call part,office,ikea_ivar,Width=$(word 1,$(subst x, ,$(s)));Depth=$(word 2,$(subst x, ,$(s)));Height=$(word 3,$(subst x, ,$(s)));Back_th=$(IVAR_BACK);Magnets=$(if $(filter $(word 1,$(subst x, ,$(s))),$(IVAR_WIDE_WIDTHS)),$(IVAR_WIDE_MAGNETS),$(IVAR_MAGNETS)),ikea_ivar_$(s))))

OFFICE_STLS := $(STLS_office)
OFFICE_PNGS := $(OFFICE_STLS:.stl=.png)

.PHONY: office
office: $(OFFICE_STLS) $(OFFICE_PNGS) ## render home-office parts + previews -> files/office/

# ---- Hallway / entrance ------------------------------------------------------
# Real heights in cm: a shoe cabinet three flaps high, a console at 80, a bench at
# seat height and a hall tree up at coat-hook height.
HALLWAY_DIR := $(FILES_DIR)/hallway
SHOE_CABINET_H ?= 100
HL_CONSOLE_H   ?= 80
HL_BENCH_H     ?= 45
COAT_RACK_H    ?= 180
$(eval $(call part,hallway,shoe_cabinet,Height=$(SHOE_CABINET_H);Magnets=2,shoe_cabinet))
$(eval $(call part,hallway,console,Height=$(HL_CONSOLE_H);Magnets=2,console))
$(eval $(call part,hallway,bench,Height=$(HL_BENCH_H);Magnets=2,bench))
$(eval $(call part,hallway,coat_rack,Height=$(COAT_RACK_H);Magnets=1,coat_rack))

HALLWAY_STLS := $(STLS_hallway)
HALLWAY_PNGS := $(HALLWAY_STLS:.stl=.png)

.PHONY: hallway
hallway: $(HALLWAY_STLS) $(HALLWAY_PNGS) ## render hallway parts + previews -> files/hallway/

# ---- Kids room ---------------------------------------------------------------
# Real heights in cm: a cot rail at 90, a changing surface at the same, cube storage
# two 39 cm cubes high, and the bunk bed up at 165 over its top guard rail — as tall
# as a wardrobe on a single bed's footprint.
KIDSROOM_DIR := $(FILES_DIR)/kidsroom
COT_H            ?= 90
CHANGING_TABLE_H ?= 90
CUBE_STORAGE_H   ?= 77
BUNK_BED_H       ?= 165
$(eval $(call part,kidsroom,cot,Height=$(COT_H);Magnets=2,cot))
$(eval $(call part,kidsroom,changing_table,Height=$(CHANGING_TABLE_H);Magnets=2,changing_table))
$(eval $(call part,kidsroom,cube_storage,Height=$(CUBE_STORAGE_H);Magnets=2,cube_storage))
$(eval $(call part,kidsroom,bunk_bed,Height=$(BUNK_BED_H);Magnets=2,bunk_bed))

KIDSROOM_STLS := $(STLS_kidsroom)
KIDSROOM_PNGS := $(KIDSROOM_STLS:.stl=.png)

.PHONY: kidsroom
kidsroom: $(KIDSROOM_STLS) $(KIDSROOM_PNGS) ## render kids-room parts + previews -> files/kidsroom/

# ---- Laundry / utility -------------------------------------------------------
# Real heights in cm: washer and dryer are both 85 cm cases (under-worktop height),
# the stacked tower is two of them (170), the sink rim is at 90, and open racking
# runs up to 180.
LAUNDRY_DIR := $(FILES_DIR)/laundry
WASHING_MACHINE_H     ?= 85
TUMBLE_DRYER_H        ?= 85
WASHER_DRYER_STACK_H  ?= 170
UTILITY_SINK_H        ?= 90
STORAGE_SHELVING_H    ?= 180
$(eval $(call part,laundry,washing_machine,Height=$(WASHING_MACHINE_H);Magnets=1,washing_machine))
$(eval $(call part,laundry,tumble_dryer,Height=$(TUMBLE_DRYER_H);Magnets=1,tumble_dryer))
$(eval $(call part,laundry,washer_dryer_stack,Height=$(WASHER_DRYER_STACK_H);Magnets=2,washer_dryer_stack))
$(eval $(call part,laundry,utility_sink,Height=$(UTILITY_SINK_H);Magnets=1,utility_sink))
$(eval $(call part,laundry,storage_shelving,Height=$(STORAGE_SHELVING_H);Magnets=2,storage_shelving))

LAUNDRY_STLS := $(STLS_laundry)
LAUNDRY_PNGS := $(LAUNDRY_STLS:.stl=.png)

.PHONY: laundry
laundry: $(LAUNDRY_STLS) $(LAUNDRY_PNGS) ## render laundry parts + previews -> files/laundry/

# ---- Balcony / outdoor -------------------------------------------------------
# Real heights in cm: a garden table at 74, the seating with its back over its seat
# (see chair.scad / sofa.scad), a 40 cm pot — build it at 80+ for a tree — a gas barbecue on
# a cart at counter height (90), and a low wood-burning fire pit (45).
OUTDOOR_DIR := $(FILES_DIR)/outdoor
OD_TABLE_H     ?= 74
OD_CHAIR_H     ?= 85
OD_CHAIR_SEAT  ?= 42
OD_SOFA_H      ?= 80
OD_SOFA_SEAT   ?= 42
PLANTER_H      ?= 40
GRILL_H        ?= 90
FIRE_PIT_H     ?= 45
# magnet pockets per table: one per foot, in diagonal order (see outdoor/table.scad) — two,
# corner to opposite corner, are what stop a legged top tilting or pivoting
OD_TABLE_MAGNETS ?= 2
$(eval $(call part,outdoor,table,Height=$(OD_TABLE_H);Magnets=$(OD_TABLE_MAGNETS),table))
# the round garden table (Diameter=90) — four legs round the rim, the part takes Round=true
$(eval $(call part,outdoor,table,Round=true;Diameter=90;Height=$(OD_TABLE_H);Magnets=$(OD_TABLE_MAGNETS),table_round_90))
$(eval $(call part,outdoor,chair,Height=$(OD_CHAIR_H);Seat=$(OD_CHAIR_SEAT);Magnets=1,chair))
# the sun lounger (a long 60x190 recliner) — the same part takes Lounger=true; two pockets
# along its length, like a bed, keep the long piece from pivoting
$(eval $(call part,outdoor,chair,Lounger=true;Height=$(OD_CHAIR_H);Seat=$(OD_CHAIR_SEAT);Magnets=2,lounger))
$(eval $(call part,outdoor,sofa,Height=$(OD_SOFA_H);Seat=$(OD_SOFA_SEAT);Magnets=2,sofa))
$(eval $(call part,outdoor,planter,Height=$(PLANTER_H);Magnets=1,planter))
# A gas barbecue on a cart — a firebox with a bar grate and a lid hump, a side burner, and the
# controls + cupboard on the front. Two pockets, in the plinth like the kitchen run.
$(eval $(call part,outdoor,grill,Height=$(GRILL_H);Magnets=2,grill))
# a wider 6-burner cart (160 cm) — the part sizes its firebox and prep shelf off Width
$(eval $(call part,outdoor,grill,Width=160;Height=$(GRILL_H);Magnets=2,grill_160))
# A wood-burning fire pit — a tapered bowl with a log stack in it; round, plus a square variant.
$(eval $(call part,outdoor,fire_pit,Height=$(FIRE_PIT_H);Magnets=1,fire_pit))
$(eval $(call part,outdoor,fire_pit,Round=false;Height=$(FIRE_PIT_H);Magnets=1,fire_pit_square))

OUTDOOR_STLS := $(STLS_outdoor)
OUTDOOR_PNGS := $(OUTDOOR_STLS:.stl=.png)

.PHONY: outdoor
outdoor: $(OUTDOOR_STLS) $(OUTDOOR_PNGS) ## render outdoor parts + previews -> files/outdoor/

# ---- Hobby / gym -------------------------------------------------------------
# Real heights in cm: a treadmill deck at 18 (its console stands ~115 cm above it), a multi-gym
# frame up at 210, and a weight bench at seat height. The gym pieces read by their masses and
# frames — the treadmill's belt and console, the multi-gym's plate stack, the bench's stacked
# plates — not by cables or bars, which do not print at 1:40 (see the .scad headers).
HOBBY_DIR := $(FILES_DIR)/hobby
TREADMILL_H     ?= 18
MULTI_GYM_H     ?= 210
WEIGHT_BENCH_H  ?= 45
DUMBBELL_RACK_H ?= 75
$(eval $(call part,hobby,treadmill,Height=$(TREADMILL_H);Magnets=2,treadmill))
$(eval $(call part,hobby,multi_gym,Height=$(MULTI_GYM_H);Magnets=2,multi_gym))
$(eval $(call part,hobby,weight_bench,Height=$(WEIGHT_BENCH_H);Magnets=2,weight_bench))
# a tiered dumbbell rack — the free-weights corner's other half
$(eval $(call part,hobby,dumbbell_rack,Height=$(DUMBBELL_RACK_H);Magnets=2,dumbbell_rack))
# -- Projector screen: a big upright screen on a low foot, one per screen width in cm. HEIGHT is
#    the foot height only; the screen board stands its own 16:9 height above it (see the .scad).
PROJECTOR_SCREEN_WIDTHS  := 200 280
PROJECTOR_SCREEN_H       ?= 16
PROJECTOR_SCREEN_MAGNETS ?= 2
$(foreach w,$(PROJECTOR_SCREEN_WIDTHS),$(eval $(call part,hobby,projector_screen,Width=$(w);Height=$(PROJECTOR_SCREEN_H);Magnets=$(PROJECTOR_SCREEN_MAGNETS),projector_screen_$(w))))

HOBBY_STLS := $(STLS_hobby)
HOBBY_PNGS := $(HOBBY_STLS:.stl=.png)

.PHONY: hobby
hobby: $(HOBBY_STLS) $(HOBBY_PNGS) ## render hobby / gym parts + previews -> files/hobby/

# ---- Walls / structure -------------------------------------------------------
# Straight interior wall segments: <thickness>x<length> footprints in cm. One
# non-load-bearing partition thickness (11.5 half-brick) and two load-bearing
# interior ones (17.5, 24) — they read apart by how thick they are, and each segment
# carries its LENGTH engraved on one face (not on top: the face is the big surface on a
# piece this shape, so every segment can carry it, the 2.875 mm 11.5 cm partition and
# the 25 cm stub included — see wall.scad).
# Square-ended, so segments butt flush and corners meet. A wall is the one part whose
# height is PRINTED mm rather than a scaled real height (see wall.scad): 25 mm, a real
# 100 cm at 1:40 — proud of the worktops and chests (22.5 mm) so a run reads as a room,
# while a wardrobe (59 mm) still rises clear of it and you can see over the ribbon.
WALLS_DIR := $(FILES_DIR)/walls
WALL_THICKNESSES := 11.5 17.5 24
WALL_LENGTHS     := 25 50 100 150 200 300
WALL_H           ?= 25
# Magnet pockets per wall (0 = none). A wall is a thin ribbon — 2.875..6 mm across
# printed at 1:40 — so the load-bearing walls drop to the small 2x1 disc (see
# MAGNET_D_SMALL), and the 11.5 cm partition, too thin for even that, gets a low round
# pad under each pocket instead of going without (a touch proud of both faces near the
# floor; the render log says which pieces are padded). The 25 cm segments only fit one
# of the two pockets.
WALL_MAGNETS ?= 2
$(foreach t,$(WALL_THICKNESSES),$(foreach l,$(WALL_LENGTHS),$(eval $(call part,walls,wall,Thickness=$(t);Length=$(l);Height=$(WALL_H);Magnets=$(WALL_MAGNETS),wall_$(t)x$(l)))))

# -- Openings: windows, doorways and sliding glazed doors, as short segments that butt
#    between the plain
#    ones — [ wall 100 ][ window 100 ][ wall 50 ] — so an opening can go anywhere in
#    a run and the catalogue stays one part per size per thickness. Each is the
#    opening plus a pier (OPENING_REVEAL) at each end, at the same thickness and
#    printed height as a plain wall. The ribbon drops across the opening: to a sill
#    under a window (with the glass line engraved along it) and lower still to a
#    threshold under a door, so the two read apart by touch as well as from above.
#    Both are printed mm, and both are a share of WALL_H — about a third of the ribbon
#    for a sill and a fifth for a threshold — so raising the wall raises them with it.
#    A door then carries that threshold on into the room as the quarter circle the
#    leaf sweeps (DOOR_SWING), so the piece occupies the floor the door needs and
#    nothing can be planned into it — and that plate carries the opening width
#    engraved on it, as a plain wall carries its length.
#    A SLIDING glazed door is the third kind: a door's threshold (you walk over it), but
#    the leaf runs along the wall instead of swinging, so the piece takes NO floor —
#    plan a sofa right up against it. It carries a line per leaf on two tracks across the
#    wall instead of a swing (see sliding_door.scad), which is what tells the three
#    openings apart from above. Sizes are the German
#    standards — windows on the
#    1/8 m series they are sold in, doors the DIN 18101 masonry opening (Rohbaumass)
#    for the 61/73.5/86/98.5/111 cm leaves, sliders on the 1/8 m series too.
#    DOOR_HANDS is which end the hinge is on;
#    turning a segment round in the plan gives the other two hands (see door.scad) — a
#    slider needs no hand at all, turning it round is the only variant it has.
OPENING_REVEAL   ?= 20
WINDOW_WIDTHS    := 60 80 100 120 140 160 180
WINDOW_SILL_H    ?= 20
DOOR_WIDTHS      := 62.5 75 87.5 100 112.5
DOOR_HANDS       := left right
DOOR_THRESHOLD_H ?= 2.7
# false = a plain opening, with the swing arc engraved in the threshold instead
DOOR_SWING       ?= true
# Sliding glazed doors: the patio widths, on the same threshold as a hinged door (they
# are both walked over) and with SLIDING_PANELS leaves sharing the opening — 2 is the
# usual slider, 3 a wide one. SLIDING_OVERLAP is how far the leaves overlap where they
# meet, in cm.
SLIDING_WIDTHS   := 150 175 200 250 300
SLIDING_PANELS   ?= 2
SLIDING_OVERLAP  ?= 5
# Magnet pockets per pier (0 = none). The pier is the only part of an opening segment
# thick enough to sink a pocket into, so it is what sets OPENING_REVEAL above: a pocket
# needs 4.3 mm of floor at 1:40, i.e. a pier of at least 17.2 cm, and 20 is the first
# round number past it. Across the thickness the 11.5 cm partition still needs the pad
# the thin walls get; the load-bearing ones take the 2x1 disc as they are.
OPENING_MAGNETS  ?= 1
$(foreach t,$(WALL_THICKNESSES),$(foreach w,$(WINDOW_WIDTHS),$(eval $(call part,walls,window,Thickness=$(t);Width=$(w);Reveal=$(OPENING_REVEAL);Height=$(WALL_H);Sill_h=$(WINDOW_SILL_H);Magnets=$(OPENING_MAGNETS),window_$(t)x$(w)))))
$(foreach t,$(WALL_THICKNESSES),$(foreach w,$(DOOR_WIDTHS),$(foreach h,$(DOOR_HANDS),$(eval $(call part,walls,door,Thickness=$(t);Width=$(w);Reveal=$(OPENING_REVEAL);Height=$(WALL_H);Threshold_h=$(DOOR_THRESHOLD_H);Hand="$(h)";Swing_plate=$(DOOR_SWING);Magnets=$(OPENING_MAGNETS),door_$(t)x$(w)_$(h))))))
$(foreach t,$(WALL_THICKNESSES),$(foreach w,$(SLIDING_WIDTHS),$(eval $(call part,walls,sliding_door,Thickness=$(t);Width=$(w);Reveal=$(OPENING_REVEAL);Height=$(WALL_H);Threshold_h=$(DOOR_THRESHOLD_H);Panels=$(SLIDING_PANELS);Panel_overlap=$(SLIDING_OVERLAP);Magnets=$(OPENING_MAGNETS),sliding_door_$(t)x$(w)))))

WALLS_STLS := $(STLS_walls)
WALLS_PNGS := $(WALLS_STLS:.stl=.png)

.PHONY: walls
walls: $(WALLS_STLS) $(WALLS_PNGS) ## render wall segments, windows + doors -> files/walls/

# ---- Pool --------------------------------------------------------------------
# A swimming pool built from composable tiles that butt flush on a fixed module, the way the
# walls build a room shell (see pool/pool.scad). Six Kinds — corner, edge, water, steps, round
# and ladder — lay out to any pool: a coping ring round a continuous sheet of water. The smallest
# pool is four corners; add edges along the sides and water tiles in the middle for a bigger one,
# a steps or ladder tile where you get in, and a round corner for a curved end. Turn a corner/edge
# in the plan to face its coping out. A tile is a low near-floor piece (like a shower tray) —
# POOL_H is set by burying a magnet under the water, not by how tall a pool is; the water surface
# is rippled and the near-square tile takes a third magnet at its centre (POOL_CENTRE_MAGNET).
# POOL_MODULE is the tile side (200 = a 2 m square).
POOL_DIR := $(FILES_DIR)/pool
POOL_MODULE  ?= 200
POOL_H       ?= 35
POOL_COPING  ?= 30
POOL_KINDS   := corner edge water steps round ladder
POOL_MAGNETS ?= 2
POOL_CENTRE_MAGNET ?= true
$(foreach k,$(POOL_KINDS),$(eval $(call part,pool,pool,Kind="$(k)";Module=$(POOL_MODULE);Height=$(POOL_H);Coping=$(POOL_COPING);Magnets=$(POOL_MAGNETS);Centre_magnet=$(POOL_CENTRE_MAGNET),$(k))))

POOL_STLS := $(STLS_pool)
POOL_PNGS := $(POOL_STLS:.stl=.png)

.PHONY: pool
pool: $(POOL_STLS) $(POOL_PNGS) ## render pool tiles + previews -> files/pool/

# ---- Tools -------------------------------------------------------------------
# A measuring ruler for the plan: a low flat bar with a tick every 50 cm and a numbered one every
# 100, drawn through cm() so it is correct at whatever Scale the set is built at (see
# tools/ruler.scad). RULER_LENGTHS are the real distances it spans, in cm. A thin bar, so like a
# wall it takes the small 2x1 disc (with the pad path); RULER_MAGNETS=0 for a handheld one.
TOOLS_DIR := $(FILES_DIR)/tools
RULER_LENGTHS := 300 500
RULER_MAGNETS ?= 2
$(foreach l,$(RULER_LENGTHS),$(eval $(call part,tools,ruler,Length=$(l);Magnets=$(RULER_MAGNETS),ruler_$(l))))

TOOLS_STLS := $(STLS_tools)
TOOLS_PNGS := $(TOOLS_STLS:.stl=.png)

.PHONY: tools
tools: $(TOOLS_STLS) $(TOOLS_PNGS) ## render tools (ruler) + previews -> files/tools/

#------------------------------------------------------------------------------------------
# Generic recipes. Each concrete target supplies its own SRC + PARAMS (see room blocks).
#   %.stl -> geometry;  %.png -> OpenSCAD image, trimmed + margined via ImageMagick.
#------------------------------------------------------------------------------------------
%.stl: | check-openscad
	@mkdir -p "$(@D)"
	@echo ">> rendering $@"
	@$(OPENSCAD) -o "$@" -D '$(PARAMS)' "$(SRC)"

%.png: | check-openscad
	@mkdir -p "$(@D)"
	@echo ">> rendering preview $@"
	@XDG_CONFIG_HOME="$(SCAD_CONFIG_DIR)" $(OPENSCAD) -o "$@" $(IMG_OPTS) -D '$(PARAMS)' "$(SRC)"

#==========================================================================================
##@ Utilities
#==========================================================================================
ALL_STLS := $(BEDROOM_STLS) $(LIVINGROOM_STLS) $(KITCHEN_STLS) $(DININGROOM_STLS) \
            $(BATHROOM_STLS) $(OFFICE_STLS) $(HALLWAY_STLS) $(KIDSROOM_STLS) \
            $(LAUNDRY_STLS) $(OUTDOOR_STLS) $(HOBBY_STLS) $(WALLS_STLS) \
            $(POOL_STLS) $(TOOLS_STLS)

.PHONY: list
list: ## list every declared part and the .scad it renders from
	@printf '%-42s %s\n' "OUTPUT" "SOURCE"
	@$(foreach f,$(ALL_STLS),printf '%-42s %s\n' "$(f)" "$(SRCOF_$(f))";)

#==========================================================================================
##@ Cleaning
#==========================================================================================
.PHONY: clean-bedroom
clean-bedroom: ## remove rendered bedroom files (files/bedroom/)
	@rm -rf "$(BEDROOM_DIR)"
	@echo "✅ removed $(BEDROOM_DIR)"

.PHONY: clean-livingroom
clean-livingroom: ## remove rendered living-room files (files/livingroom/)
	@rm -rf "$(LIVINGROOM_DIR)"
	@echo "✅ removed $(LIVINGROOM_DIR)"

.PHONY: clean-kitchen
clean-kitchen: ## remove rendered kitchen files (files/kitchen/)
	@rm -rf "$(KITCHEN_DIR)"
	@echo "✅ removed $(KITCHEN_DIR)"

.PHONY: clean-diningroom
clean-diningroom: ## remove rendered dining-room files (files/diningroom/)
	@rm -rf "$(DININGROOM_DIR)"
	@echo "✅ removed $(DININGROOM_DIR)"

.PHONY: clean-bathroom
clean-bathroom: ## remove rendered bathroom files (files/bathroom/)
	@rm -rf "$(BATHROOM_DIR)"
	@echo "✅ removed $(BATHROOM_DIR)"

.PHONY: clean-office
clean-office: ## remove rendered home-office files (files/office/)
	@rm -rf "$(OFFICE_DIR)"
	@echo "✅ removed $(OFFICE_DIR)"

.PHONY: clean-hallway
clean-hallway: ## remove rendered hallway files (files/hallway/)
	@rm -rf "$(HALLWAY_DIR)"
	@echo "✅ removed $(HALLWAY_DIR)"

.PHONY: clean-kidsroom
clean-kidsroom: ## remove rendered kids-room files (files/kidsroom/)
	@rm -rf "$(KIDSROOM_DIR)"
	@echo "✅ removed $(KIDSROOM_DIR)"

.PHONY: clean-laundry
clean-laundry: ## remove rendered laundry files (files/laundry/)
	@rm -rf "$(LAUNDRY_DIR)"
	@echo "✅ removed $(LAUNDRY_DIR)"

.PHONY: clean-outdoor
clean-outdoor: ## remove rendered outdoor files (files/outdoor/)
	@rm -rf "$(OUTDOOR_DIR)"
	@echo "✅ removed $(OUTDOOR_DIR)"

.PHONY: clean-walls
clean-walls: ## remove rendered wall files (files/walls/)
	@rm -rf "$(WALLS_DIR)"
	@echo "✅ removed $(WALLS_DIR)"

.PHONY: clean-hobby
clean-hobby: ## remove rendered hobby files (files/hobby/)
	@rm -rf "$(HOBBY_DIR)"
	@echo "✅ removed $(HOBBY_DIR)"

.PHONY: clean-pool
clean-pool: ## remove rendered pool files (files/pool/)
	@rm -rf "$(POOL_DIR)"
	@echo "✅ removed $(POOL_DIR)"

.PHONY: clean-tools
clean-tools: ## remove rendered tools files (files/tools/)
	@rm -rf "$(TOOLS_DIR)"
	@echo "✅ removed $(TOOLS_DIR)"

.PHONY: clean
clean: clean-bedroom clean-livingroom clean-kitchen clean-diningroom clean-bathroom \
       clean-office clean-hallway clean-kidsroom clean-laundry clean-outdoor clean-hobby \
       clean-walls clean-pool clean-tools ## remove all rendered files

# FORCE (always out of date) is only pulled in when REBUILD=1.
.PHONY: FORCE
FORCE:

.PHONY: check-openscad
check-openscad:
	@command -v $(OPENSCAD) >/dev/null 2>&1 || { echo "❌ '$(OPENSCAD)' not found — install OpenSCAD or set OPENSCAD=<path>"; exit 1; }

#==========================================================================================
#  Help
#==========================================================================================
.PHONY: help
help: # Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
