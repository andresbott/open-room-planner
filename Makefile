# Makefile — render open-room-planner parts (STLs + preview PNGs) from the
# per-part .scad files under scad/, grouped by room. Each room -> files/<room>/.
#
# Parts are written in real-world centimetres and shrunk to the plan scale by
# scad/lib/common.scad (1:50 — 2 cm = 1 m, same as base.svg).
#
# Add a part: drop scad/<room>/<part>.scad next to its siblings, then declare one
#   $(call part,<room>,<part>,<PARAMS>,<out-name>)
# per variant in that room's block (explicitly, or via a foreach/eval matrix like
# the bed sizes). The generic %.stl / %.png rules do the actual rendering.
#
# Add a room: give it a <ROOM>_DIR, declare its parts, add a phony aggregator and
# a clean-<room> target, and list it under `all` / `clean`.

OPENSCAD   ?= openscad
CONVERT    ?= convert
SCAD_DIR   := scad
LIB_DIR    := $(SCAD_DIR)/lib
FILES_DIR  := files
# every part depends on the shared lib
LIB_SCADS  := $(wildcard $(LIB_DIR)/*.scad)

# Plan scale: 1:SCALE. 50 keeps the parts interchangeable with base.svg.
SCALE      ?= 50
# OpenSCAD $fn for the final render (the CLI is never $preview, so this is the real one)
RESOLUTION ?= 64

# Magnet pockets in the bottom face, in printed mm — hardware, so they are not
# scaled. Set these to the discs you actually have (5x1 and 3x2 both fit a 6 mm
# piece); how many go in a part is a per-part parameter.
MAGNET_D   ?= 5
MAGNET_H   ?= 1

# Shared by every part; each part adds its own dimensions on top.
COMMON = Scale=$(SCALE);Resolution=$(RESOLUTION);Magnet_d=$(MAGNET_D);Magnet_h=$(MAGNET_H)

# Preview-image settings (%.png rule: OpenSCAD render -> ImageMagick trim + margin).
IMG_SIZE   ?= 1600,1600
IMG_COLOR  ?= Cornfield
IMG_BG     ?= rgb(255,255,229)
IMG_MARGIN ?= 7%
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
all: bedroom ## render every room (STLs + previews)

# ---- Bedroom -----------------------------------------------------------------
BEDROOM_DIR  := $(FILES_DIR)/bedroom

# -- Beds: one piece per mattress size, in cm (IKEA naming). BED_H is the printed
#    height in mm, not a scaled real height — 6 mm matches the existing 1:50 set.
BED_SIZES := 80x200 90x200 140x200 160x200
BED_H     ?= 6
# magnet pockets per bed, in a row along the length (0 = none)
BED_MAGNETS ?= 2
# expand <width>x<length> -> Width/Length params
$(foreach s,$(BED_SIZES),$(eval $(call part,bedroom,bed,Width=$(word 1,$(subst x, ,$(s)));Length=$(word 2,$(subst x, ,$(s)));Height=$(BED_H);Magnets=$(BED_MAGNETS),bed_$(s))))

# -- Wardrobes: IKEA PAX frames, in cm — every width x every depth.
WARDROBE_WIDTHS := 50 75 100
WARDROBE_DEPTHS := 35 58
WARDROBE_H      ?= 6
# magnet pockets per wardrobe (0 = none). The 35 cm-deep frames are only 7 mm
# across at 1:50, too narrow for a 5 mm disc: they render solid with a warning
# unless you build them with smaller hardware (MAGNET_D=3 MAGNET_H=2).
WARDROBE_MAGNETS ?= 1
$(foreach w,$(WARDROBE_WIDTHS),$(foreach d,$(WARDROBE_DEPTHS),$(eval $(call part,bedroom,wardrobe,Width=$(w);Depth=$(d);Height=$(WARDROBE_H);Magnets=$(WARDROBE_MAGNETS),wardrobe_$(w)x$(d)))))

BEDROOM_STLS := $(STLS_bedroom)
BEDROOM_PNGS := $(BEDROOM_STLS:.stl=.png)

.PHONY: bedroom
bedroom: $(BEDROOM_STLS) $(BEDROOM_PNGS) ## render bedroom parts + previews -> files/bedroom/

#------------------------------------------------------------------------------------------
# Generic recipes. Each concrete target supplies its own SRC + PARAMS (see room blocks).
#   %.stl -> geometry;  %.png -> OpenSCAD image, trimmed + margined via ImageMagick.
#------------------------------------------------------------------------------------------
%.stl: | check-openscad
	@mkdir -p "$(@D)"
	@echo ">> rendering $@"
	@$(OPENSCAD) -o "$@" -D '$(PARAMS)' "$(SRC)"

%.png: | check-openscad check-convert
	@mkdir -p "$(@D)"
	@echo ">> rendering preview $@"
	@$(OPENSCAD) -o "$(@:.png=.raw.png)" $(IMG_OPTS) -D '$(PARAMS)' "$(SRC)"
	@$(CONVERT) "$(@:.png=.raw.png)" -fuzz 3% -trim +repage -bordercolor '$(IMG_BG)' -border $(IMG_MARGIN) "$@"
	@rm -f "$(@:.png=.raw.png)"

#==========================================================================================
##@ Utilities
#==========================================================================================
ALL_STLS := $(BEDROOM_STLS)

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

.PHONY: clean
clean: clean-bedroom ## remove all rendered files

# FORCE (always out of date) is only pulled in when REBUILD=1.
.PHONY: FORCE
FORCE:

.PHONY: check-openscad
check-openscad:
	@command -v $(OPENSCAD) >/dev/null 2>&1 || { echo "❌ '$(OPENSCAD)' not found — install OpenSCAD or set OPENSCAD=<path>"; exit 1; }

.PHONY: check-convert
check-convert:
	@command -v $(CONVERT) >/dev/null 2>&1 || { echo "❌ '$(CONVERT)' (ImageMagick) not found — needed for preview images, or set CONVERT=<path>"; exit 1; }

#==========================================================================================
#  Help
#==========================================================================================
.PHONY: help
help: # Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
