#!/usr/bin/env python3
# print / grid_mat — a paper play-mat for the plan, printed on an ordinary office
# printer, that the 3D tokens stand ON. It is the flat counterpart to tools/ruler.scad:
# where the ruler is a bar you lay across the board, this is the board itself — a faint
# grid to line pieces up on and a ruler border to read how much real room a run takes,
# both at the SAME 1:SCALE the tokens are shrunk to (see scad/lib/common.scad).
#
# Why an SVG and not a .scad exported to SVG: a print wants two ink weights at once — a
# grid so light it stays underfoot and a ruler border black enough to read — and one
# OpenSCAD 2D export is a single fill. So the mat is generated here, in real millimetres
# on the page, with full control of stroke weight and colour.
#
# What is on it, and why it is where it is:
#   - a SLIGHT grid, faint light-grey, a line every 50 cm so a token lands square
#     without the grid fighting the furniture for the eye;
#   - a stronger line every 1 m, and a black frame — the metre lines give the field a
#     scale and the frame is the ruler's baseline;
#   - a RULER BORDER: a tick every 50 cm and a longer, numbered one every metre, 0 in
#     the bottom-left corner, exactly the ruler.scad convention — plus a finer 10 cm tick
#     along the first metre of each axis, the detailed end of a tape measure;
#   - a 50 mm calibration bar and a "print at 100 %" note in the top margin, because the
#     mat is only to scale if the printer does not shrink it to fit: measure that bar with
#     a real ruler and if it is 50 mm the grid is a true 1:SCALE.
#
# Everything is derived from the scale and the page, exactly as cm() derives the tokens:
# change the scale or the paper and the grid, the ruler numbers and the calibration bar
# all move to match, with nothing hand-placed.
#
#   python3 print/grid_mat.py                                   # A4 portrait, 1:40
#   python3 print/grid_mat.py --paper a3 --orient landscape     # A3 landscape, 1:40
#   python3 print/grid_mat.py --scale 50                        # A4 portrait, 1:50
#   python3 print/grid_mat.py --out /tmp/mat.svg                # to a path you name

import argparse
import os

# ---- fixed style: a slight grid, a black ruler (printed mm, not scaled) ------
MINOR_CM = 50            # cm — a grid line and a short ruler tick every ...
MAJOR_CM = 100           # cm — ... a stronger line, a long tick and a number every
FINE_CM  = 10            # cm — the tape-measure graduation over the first metre
FINE_SPAN_CM = 100       # cm from the origin that carries the fine ticks

C_MINOR = "#c8c8c8"; W_MINOR = 0.18          # faint 50 cm grid
C_MAJOR = "#9a9a9a"; W_MAJOR = 0.35          # stronger 1 m grid
C_FRAME = "#111111"; W_FRAME = 0.5           # the ruler baseline
C_INK   = "#000000"                          # ticks + numbers
C_NOTE  = "#333333"                          # captions

T_MINOR = 1.8; W_TICK_MIN = 0.30             # tick reach out of the frame, mm
T_MAJOR = 3.0; W_TICK_MAJ = 0.45
T_FINE  = 1.1; W_TICK_FINE = 0.22

F_NUM  = 2.6                                  # metre-number cap height, mm
F_NOTE = 2.1                                  # caption cap height, mm
FONT   = "DejaVu Sans, Helvetica, Arial, sans-serif"


def cm(v, scale):
    """Real cm -> mm on the page — mirrors cm() in scad/lib/common.scad."""
    return v * 10.0 / scale


def n(x):
    """Trim a coordinate to a tidy 0.001 mm so the SVG stays small and readable."""
    return f"{x:.3f}".rstrip("0").rstrip(".")


def g(x):
    """Format a metre value without a trailing .0 (7.5 stays 7.5, 8.0 -> 8)."""
    return f"{x:g}"


def seg(x1, y1, x2, y2):
    return f"M{n(x1)} {n(y1)}L{n(x2)} {n(y2)}"


class Page:
    """The geometry of one sheet: the grid frame and cells, derived from the page,
    the scale and the least margin that leaves room for ticks and numbers."""

    def __init__(self, scale, page_w, page_h, margin):
        self.scale, self.w, self.h, self.margin = scale, page_w, page_h, margin
        self.minor = cm(MINOR_CM, scale)          # 12.5 mm at 1:40
        self.major = cm(MAJOR_CM, scale)          # 25.0 mm at 1:40
        self.cpm = round(self.major / self.minor)  # 2 — a metre is two 50 cm cells
        self.nx = int((page_w - 2 * margin) // self.minor)   # 50 cm cells across ...
        self.ny = int((page_h - 2 * margin) // self.minor)   # ... and up
        gw, gh = self.nx * self.minor, self.ny * self.minor
        self.gx0 = (page_w - gw) / 2              # left frame
        self.gx1 = self.gx0 + gw                  # right frame
        self.gy_top = (page_h - gh) / 2           # top frame (smaller SVG y)
        self.gy_bot = self.gy_top + gh            # bottom frame — plan "0", y up


def render(pg):
    """One sheet: the faint grid, the metre grid, a ruler border with metre numbers
    (0 in the bottom-left corner), the tape-measure fine ticks at the origin, and the
    50 mm calibration bar."""
    o = []
    add = o.append

    add('<?xml version="1.0" encoding="UTF-8"?>')
    add(f'<svg xmlns="http://www.w3.org/2000/svg" width="{n(pg.w)}mm" height="{n(pg.h)}mm" '
        f'viewBox="0 0 {n(pg.w)} {n(pg.h)}" shape-rendering="geometricPrecision" '
        f'text-rendering="geometricPrecision">')
    add(f'  <title>open-room-planner grid mat — 1:{pg.scale}</title>')
    add(f'  <desc>Play-mat for 1:{pg.scale} furniture tokens. Grid {MINOR_CM} cm '
        f'({n(pg.minor)} mm), numbers in metres. Print at 100 % (actual size).</desc>')
    add(f'  <rect x="0" y="0" width="{n(pg.w)}" height="{n(pg.h)}" fill="#ffffff"/>')

    # --- the grid: minor (off-metre) and major (metre) lines across the field ---
    minor, major = [], []
    for i in range(1, pg.nx):
        x = pg.gx0 + i * pg.minor
        (major if i % pg.cpm == 0 else minor).append(seg(x, pg.gy_top, x, pg.gy_bot))
    for j in range(1, pg.ny):
        y = pg.gy_bot - j * pg.minor
        (major if j % pg.cpm == 0 else minor).append(seg(pg.gx0, y, pg.gx1, y))
    add(f'  <path d="{"".join(minor)}" fill="none" stroke="{C_MINOR}" stroke-width="{W_MINOR}"/>')
    add(f'  <path d="{"".join(major)}" fill="none" stroke="{C_MAJOR}" stroke-width="{W_MAJOR}"/>')

    # --- the frame (the ruler's baseline) ---
    add(f'  <rect x="{n(pg.gx0)}" y="{n(pg.gy_top)}" width="{n(pg.gx1 - pg.gx0)}" '
        f'height="{n(pg.gy_bot - pg.gy_top)}" fill="none" stroke="{C_FRAME}" '
        f'stroke-width="{W_FRAME}"/>')

    # --- ruler ticks on all four sides, at every 50 cm line ---
    tmin, tmaj = [], []
    for i in range(0, pg.nx + 1):
        x = pg.gx0 + i * pg.minor
        reach = T_MAJOR if i % pg.cpm == 0 else T_MINOR
        b = tmaj if i % pg.cpm == 0 else tmin
        b.append(seg(x, pg.gy_bot, x, pg.gy_bot + reach))     # bottom
        b.append(seg(x, pg.gy_top, x, pg.gy_top - reach))     # top
    for j in range(0, pg.ny + 1):
        y = pg.gy_bot - j * pg.minor
        reach = T_MAJOR if j % pg.cpm == 0 else T_MINOR
        b = tmaj if j % pg.cpm == 0 else tmin
        b.append(seg(pg.gx0, y, pg.gx0 - reach, y))           # left
        b.append(seg(pg.gx1, y, pg.gx1 + reach, y))           # right
    add(f'  <path d="{"".join(tmin)}" fill="none" stroke="{C_INK}" stroke-width="{W_TICK_MIN}"/>')
    add(f'  <path d="{"".join(tmaj)}" fill="none" stroke="{C_INK}" stroke-width="{W_TICK_MAJ}"/>')

    # --- tape-measure fine ticks over the first metre of each axis, at the origin ---
    if FINE_CM:
        fine = []
        c = FINE_CM
        while c <= min(FINE_SPAN_CM, pg.nx * MINOR_CM):
            if c % MINOR_CM:
                x = pg.gx0 + cm(c, pg.scale)
                fine.append(seg(x, pg.gy_bot, x, pg.gy_bot + T_FINE))
            c += FINE_CM
        c = FINE_CM
        while c <= min(FINE_SPAN_CM, pg.ny * MINOR_CM):
            if c % MINOR_CM:
                y = pg.gy_bot - cm(c, pg.scale)
                fine.append(seg(pg.gx0, y, pg.gx0 - T_FINE, y))
            c += FINE_CM
        add(f'  <path d="{"".join(fine)}" fill="none" stroke="{C_INK}" stroke-width="{W_TICK_FINE}"/>')

    # --- metre numbers: 0 in the corner, along the bottom and up the left ---
    nums = [f'  <g fill="{C_INK}" font-family="{FONT}" font-size="{F_NUM}">']
    for i in range(0, pg.nx + 1, pg.cpm):
        x = pg.gx0 + i * pg.minor
        nums.append(f'    <text x="{n(x)}" y="{n(pg.gy_bot + T_MAJOR + F_NUM)}" '
                    f'text-anchor="middle">{i // pg.cpm}</text>')
    for j in range(pg.cpm, pg.ny + 1, pg.cpm):               # skip 0 — shown by the x-axis
        y = pg.gy_bot - j * pg.minor
        nums.append(f'    <text x="{n(pg.gx0 - T_MAJOR - 1.4)}" y="{n(y + F_NUM * 0.36)}" '
                    f'text-anchor="end">{j // pg.cpm}</text>')
    nums.append('  </g>')
    o.extend(nums)

    # --- calibration bar + print note in the top margin ---
    bx, by = pg.w / 2, pg.gy_top - 4.0
    add(f'  <path d="{seg(bx - 25, by, bx + 25, by)}{seg(bx - 25, by - 1.4, bx - 25, by + 1.4)}'
        f'{seg(bx + 25, by - 1.4, bx + 25, by + 1.4)}" fill="none" stroke="{C_INK}" stroke-width="0.35"/>')
    add(f'  <text x="{n(bx)}" y="{n(by - 2.2)}" fill="{C_NOTE}" font-family="{FONT}" '
        f'font-size="{F_NOTE}" text-anchor="middle">'
        f'50 mm — print at 100 % (actual size), do not scale to fit</text>')

    # --- caption in the bottom margin ---
    add(f'  <text x="{n(pg.w / 2)}" y="{n(pg.gy_bot + T_MAJOR + F_NUM + F_NOTE + 1.4)}" '
        f'fill="{C_NOTE}" font-family="{FONT}" font-size="{F_NOTE}" text-anchor="middle">'
        f'open-room-planner &#183; scale 1:{pg.scale} &#183; grid {MINOR_CM} cm &#183; '
        f'numbers = metres &#183; {g(pg.nx / pg.cpm)} × {g(pg.ny / pg.cpm)} m field</text>')

    add('</svg>')
    return "\n".join(o) + "\n"


# Named paper sizes, portrait, in mm — pass one to --paper (or an explicit WxH).
PAPERS = {
    "a3": (297.0, 420.0),
    "a4": (210.0, 297.0),
    "a5": (148.0, 210.0),
    "letter": (215.9, 279.4),
}


def parse_paper(s):
    """--paper as a known name (a4, a3, a5, letter) or an explicit WxH in mm; returns
    (name, width, height), the name going into the output filename."""
    key = s.lower()
    if key in PAPERS:
        w, h = PAPERS[key]
        return key, w, h
    w, h = (float(v) for v in key.split("x"))
    return f"{g(w)}x{g(h)}", w, h


def main():
    ap = argparse.ArgumentParser(description="Generate a grid play-mat SVG for open-room-planner.")
    ap.add_argument("--scale", type=int, default=40, help="1:SCALE plan scale (default 40)")
    ap.add_argument("--paper", default="a4", help="a3 / a4 / a5 / letter, or WxH in mm (default a4)")
    ap.add_argument("--orient", choices=("portrait", "landscape"), default="portrait")
    ap.add_argument("--margin", type=float, default=9.0, help="least page-edge->frame margin, mm")
    ap.add_argument("--out", help="output SVG path (default files/mat/grid_mat_<slug>.svg)")
    a = ap.parse_args()

    name, pw, ph = parse_paper(a.paper)
    if a.orient == "landscape":
        pw, ph = ph, pw
    pg = Page(a.scale, pw, ph, a.margin)
    slug = f"{name}_1-{a.scale}_{a.orient}"
    here = os.path.dirname(os.path.abspath(__file__))
    path = a.out or os.path.normpath(
        os.path.join(here, os.pardir, "files", "mat", f"grid_mat_{slug}.svg"))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as fh:
        fh.write(render(pg))
    print(f"wrote {path}")
    print(f"  1:{a.scale}  {a.orient}  grid {MINOR_CM} cm = {n(pg.minor)} mm  "
          f"field {g(pg.nx/pg.cpm)}×{g(pg.ny/pg.cpm)} m "
          f"({pg.nx}×{pg.ny} cells)  margin {n(pg.gx0)}/{n(pg.gy_top)} mm")


if __name__ == "__main__":
    main()
