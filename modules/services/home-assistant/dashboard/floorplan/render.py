"""Render the flat's geometry as an isometric line drawing (or a flat plan).

usage: render.py GEOMETRY.json OUT.svg [--mode iso|plan]
                 [--wall-height CM] [--front-height CM]
                 [--tiles TILES.json --icons MDI.ttf --layout landscape|portrait]
                 [--style CSS]

GEOMETRY.json is geometry.nix serialised: room polygons, wall openings and
furniture boxes in centimetres in the reference frame, plus a display
rotation. TILES.json maps room ids to the MDI icon of each of their tiles;
the strips are laid out around the drawing and joined to their room by a
leader line. --style embeds a stylesheet, for previews outside Home
Assistant, which supplies its own.

Walls are derived, not drawn per room: the gaps between neighbouring rooms
are closed (internal walls), an exterior wall is grown around the result,
the rooms are subtracted and doors cut out. That one solid is extruded, so
walls join at corners with no gaps. Exterior walls facing the viewer are
split off and extruded only to --front-height, a cutaway that keeps the
floors behind them visible.

Hidden lines are handled by painting far to near with background-filled
faces. Only faces turned towards the viewer are drawn. Vertical faces can
only overlap on screen where their screen-x spans (x - y) overlap, and there
the nearer one has the larger x + y, so they are ordered pairwise rather
than by one depth value. Tops of anything lower than the full wall height
(furniture, low front walls, railings) are ordered against vertical faces
the same way. Full-height wall tops go last: everything else is lower, so
nothing can sit in front of them on screen.

Element ids are stable so ha-floorplan rules can target them:
`<room>.floor`, `<room>.leader`, `<room>.anchor`,
`<room>.strip`, `<room>.title`, `<room>.tile<k>` and `<room>.tile<k>.text`.
"""

import argparse
import json
import math
from itertools import pairwise
from pathlib import Path
from xml.sax.saxutils import escape

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont
from shapely.geometry import LineString, Polygon
from shapely.geometry.polygon import orient
from shapely.ops import nearest_points, unary_union

EPS = 1.0  # cm; plan measurements are rounded to the centimetre
# More than half the internal wall thickness (~10 cm), so closing fills
# every gap between neighbouring rooms but no wider recess in the outline.
INTERNAL_GAP = 15
EXTERIOR_WALL = 30
DOOR_REACH = 50  # door cuts reach this far either side of the opening line
RAILING = 5
ANCHOR_CLEARANCE = 15  # keeps a leader's end dot off furniture and wall edges

COS30 = math.cos(math.radians(30))
SIN30 = 0.5
MITRE = 2  # shapely join_style
FLAT = 2  # shapely cap_style

# Strip proportions, in tile edges. Landscape tiles are a fraction of the
# drawing's width, which keeps tile text near 12 px on a 1000 px card;
# portrait tiles are as large as the drawing's width allows.
LAYOUTS = {
    "landscape": {
        "tile": 0.09,
        "gap": 0.1,
        "title": 0.36,
        "spacing": 0.3,
        "reach": 0.45,
        "columns": None,  # one row
        "text": 0.22,
    },
    "portrait": {
        "gap": 0.1,
        "title": 0.45,
        "spacing": 0.35,
        "reach": 0.45,
        "columns": 2,
        "text": 0.25,
    },
}
TITLE_FONT = 0.62  # room name size, as a fraction of the title band
# MDI glyphs are drawn on a 512 unit em whose 24 px icon box spans
# y = -64..448 (font units, y up).
MDI_EM = 512
MDI_TOP = 448


def rotate(point, degrees):
    """Rotate anticlockwise as seen on screen (y grows downwards)."""
    x, y = point
    for _ in range((degrees // 90) % 4):
        x, y = y, -x
    return x, y


def load(path):
    geo = json.loads(Path(path).read_text())
    degrees = geo.get("rotate", 0)
    rooms = [
        dict(r, polygon=[rotate(tuple(p), degrees) for p in r["polygon"]])
        for r in geo["rooms"]
    ]
    openings = [
        dict(
            o,
            **{
                "from": rotate(tuple(o["from"]), degrees),
                "to": rotate(tuple(o["to"]), degrees),
            },
        )
        for o in geo["openings"]
    ]
    furniture = []
    for f in geo.get("furniture", []):
        x0, y0, x1, y1 = f["rect"]
        corners = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
        furniture.append(dict(f, polygon=[rotate(c, degrees) for c in corners]))

    pts = [p for r in rooms for p in r["polygon"]]
    dx, dy = -min(x for x, _ in pts), -min(y for _, y in pts)

    def shift(p):
        return (p[0] + dx, p[1] + dy)

    for item in rooms + furniture:
        item["polygon"] = [shift(p) for p in item["polygon"]]
    for o in openings:
        o["from"], o["to"] = shift(o["from"]), shift(o["to"])
    return rooms, openings, furniture


def polygons(geom):
    if geom.is_empty:
        return []
    if isinstance(geom, Polygon):
        return [geom] if geom.area > EPS else []
    return [g for part in getattr(geom, "geoms", []) for g in polygons(part)]


def walls(rooms, openings):
    """Wall solid split into (full-height part, exterior front part)."""
    floor = unary_union([Polygon(r["polygon"]) for r in rooms if not r.get("outdoor")])
    closed = floor.buffer(INTERNAL_GAP, join_style=MITRE).buffer(
        -INTERNAL_GAP, join_style=MITRE
    )
    footprint = closed.buffer(EXTERIOR_WALL, join_style=MITRE)
    solid = footprint.difference(floor)
    # Doors cut through any wall; open-plan edges only remove what closing
    # the gaps between rooms might have filled in.
    reach = {"door": DOOR_REACH, "open": INTERNAL_GAP}
    cuts = [
        LineString([o["from"], o["to"]]).buffer(reach[o["type"]], cap_style=FLAT)
        for o in openings
        if o["type"] in reach
    ]
    if cuts:
        solid = solid.difference(unary_union(cuts))

    # Exterior edges whose outward normal faces the viewer (+x +y); with the
    # ring anticlockwise the outward normal of a-b is (dy, -dx) and the
    # inside is to the left, which single-sided buffering covers.
    outline = max(polygons(footprint), key=lambda p: p.area)
    ring = list(orient(outline, 1.0).exterior.coords)
    bands = [
        LineString([a, b]).buffer(EXTERIOR_WALL + EPS, single_sided=True)
        for a, b in pairwise(ring)
        if (b[1] - a[1]) - (b[0] - a[0]) > 0
    ]
    front = solid.intersection(unary_union(bands)) if bands else Polygon()
    return solid.difference(front), front


def railings(rooms):
    return unary_union(
        [
            Polygon(r["polygon"]).difference(
                Polygon(r["polygon"]).buffer(-RAILING, join_style=MITRE)
            )
            for r in rooms
            if r.get("outdoor")
        ]
    )


def screen_span(seg):
    """Screen-x interval (x - y) and depth (x + y) along a plan segment."""
    (px, py), (qx, qy) = seg
    return (px - py, qx - qy), (px + py, qx + qy)


def depth_at(seg, u):
    (u0, u1), (d0, d1) = screen_span(seg)
    if abs(u1 - u0) < 1e-9:
        return max(d0, d1)
    return d0 + (d1 - d0) * (u - u0) / (u1 - u0)


def u_range(segs):
    us = [u for s in segs for u in screen_span(s)[0]]
    return min(us), max(us)


def depths_at(segs, u):
    """Depths of the plan segments that cross screen line u."""
    out = []
    for s in segs:
        lo, hi = sorted(screen_span(s)[0])
        if lo - EPS <= u <= hi + EPS:
            out.append(depth_at(s, u))
    return out


class Item:
    """A paintable face: a vertical wall face or a horizontal top."""

    def __init__(self, svg, segment=None, top=None):
        self.svg = svg
        self.segment = segment  # vertical face: its plan segment
        self.top = top  # horizontal top: its plan outline segments

    def segments(self):
        return [self.segment] if self.segment else self.top


def in_front(a, b):
    """+1 if a must be painted after b, -1 if before, 0 if unrelated."""
    sa, sb = a.segments(), b.segments()
    lo_a, hi_a = u_range(sa)
    lo_b, hi_b = u_range(sb)
    lo, hi = max(lo_a, lo_b), min(hi_a, hi_b)
    if hi - lo <= EPS:
        return 0
    u = (lo + hi) / 2
    da, db = depths_at(sa, u), depths_at(sb, u)
    if not da or not db:
        return 0
    if a.segment and b.segment:
        diff = da[0] - db[0]
    elif a.segment:  # a vertical against b's top: compare with its near edge
        diff = da[0] - max(db)
    elif b.segment:
        diff = max(da) - db[0]
    else:
        diff = max(da) - max(db)
    if abs(diff) <= EPS:
        return 0
    return 1 if diff > 0 else -1


def paint_order(items):
    n = len(items)
    before = [set() for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            rel = in_front(items[i], items[j])
            if rel > 0:
                before[i].add(j)
            elif rel < 0:
                before[j].add(i)

    def nearness(k):
        return max(sum(screen_span(s)[1]) for s in items[k].segments())

    order, placed = [], [False] * n
    while len(order) < n:
        ready = [
            k for k in range(n) if not placed[k] and all(placed[b] for b in before[k])
        ]
        if not ready:
            # Only reachable through a cycle; break it at the farthest item
            # rather than dropping faces.
            ready = [min((k for k in range(n) if not placed[k]), key=nearness)]
        for k in sorted(ready, key=nearness):
            placed[k] = True
            order.append(k)
    return [items[k] for k in order]


def fmt(points):
    return " ".join(f"{x:.1f},{y:.1f}" for x, y in points)


def project_with(scale):
    def project(x, y, z=0.0):
        return ((x - y) * COS30 * scale, ((x + y) * SIN30 - z) * scale)

    return project


def ring_segments(poly):
    poly = orient(poly, 1.0)
    for ring in [poly.exterior, *poly.interiors]:
        yield from pairwise(ring.coords)


def facing_viewer(a, b):
    # Outward normal (dy, -dx) for a ring oriented by shapely's orient().
    return (b[1] - a[1]) - (b[0] - a[0]) > 0


def path(poly, project, z):
    poly = orient(poly, 1.0)
    rings = [poly.exterior, *poly.interiors]
    return " ".join(
        "M "
        + " L ".join(
            f"{x:.1f},{y:.1f}" for x, y in (project(px, py, z) for px, py in r.coords)
        )
        + " Z"
        for r in rings
    )


def extrude(geom, height, cls, project, windows=()):
    """Visible side faces and the top of an extruded solid."""
    faces, tops = [], []
    for poly in polygons(geom):
        for a, b in ring_segments(poly):
            if not facing_viewer(a, b):
                continue
            quad = [project(*a), project(*b), project(*b, height), project(*a, height)]
            svg = f'<polygon class="{cls}" points="{fmt(quad)}"/>'
            seg = LineString([a, b])
            for w in windows:
                line = LineString([w["from"], w["to"]])
                if height > 100 and seg.buffer(EPS).contains(line):
                    (wx0, wy0), (wx1, wy1) = w["from"], w["to"]
                    pane = [
                        project(wx0, wy0, 90),
                        project(wx1, wy1, 90),
                        project(wx1, wy1, height - 6),
                        project(wx0, wy0, height - 6),
                    ]
                    svg += f'<polygon class="fp-window" points="{fmt(pane)}"/>'
            faces.append(Item(svg, segment=(a, b)))
        outline = list(ring_segments(poly))
        tops.append(
            Item(
                f'<path class="{cls}" fill-rule="evenodd" d="{path(poly, project, height)}"/>',
                top=outline,
            )
        )
    return faces, tops


def polygon_centroid(points):
    c = Polygon(points).representative_point()
    return c.x, c.y


def render_iso(rooms, openings, furniture, project, wall_height, front_height, linked):
    """Drawing of the flat, unlabelled: the strips carry the room names.

    Floors of `linked` rooms are marked as tap targets.
    """
    tall, front = walls(rooms, openings)
    windows = [o for o in openings if o["type"] == "window"]

    out = []
    for r in rooms:
        cls = "fp-floor"
        if r.get("outdoor"):
            cls += " fp-outdoor"
        if r["id"] in linked:
            cls += " fp-room"
        out.append(
            f'<polygon id="{r["id"]}.floor" class="{cls}" points="{fmt([project(x, y) for x, y in r["polygon"]])}"/>'
        )
        out.append(
            f'<polygon class="fp-floor-edge" points="{fmt([project(x, y) for x, y in r["polygon"]])}"/>'
        )

    tall_faces, tall_tops = extrude(tall, wall_height, "fp-wall", project, windows)
    front_faces, front_tops = extrude(front, front_height, "fp-wall", project)
    rail_faces, rail_tops = extrude(railings(rooms), front_height, "fp-wall", project)
    furn_faces, furn_tops = [], []
    for f in furniture:
        faces, tops = extrude(
            Polygon(f["polygon"]), f["height"], "fp-furniture", project
        )
        furn_faces += faces
        furn_tops += tops

    for item in paint_order(
        tall_faces
        + front_faces
        + rail_faces
        + furn_faces
        + furn_tops
        + front_tops
        + rail_tops
    ):
        out.append(item.svg)
    out += [t.svg for t in tall_tops]

    # Windows in walls cut down to the front height show as a line along
    # the wall top.
    for w in windows:
        mid = LineString([w["from"], w["to"]]).interpolate(0.5, normalized=True)
        if front.buffer(EPS).contains(mid):
            (x0, y0), (x1, y1) = w["from"], w["to"]
            (sx0, sy0), (sx1, sy1) = (
                project(x0, y0, front_height),
                project(x1, y1, front_height),
            )
            out.append(
                f'<line class="fp-window" x1="{sx0:.1f}" y1="{sy0:.1f}" x2="{sx1:.1f}" y2="{sy1:.1f}"/>'
            )
    return out


def mdi_paths(font_path, names):
    """SVG path data of MDI icons by name, in font units (y up)."""
    glyphs = TTFont(font_path).getGlyphSet()
    out = {}
    for name in names:
        if name not in glyphs:
            raise SystemExit(f"unknown MDI icon: {name}")
        pen = SVGPathPen(glyphs)
        glyphs[name].draw(pen)
        out[name] = pen.getCommands()
    return out


def anchor(room, furniture, project):
    """Screen point at the floor's centre, or the nearest floor clear of furniture.

    The centroid of an L-shaped room can fall outside it, and a dot on a
    piece of furniture reads as sitting on top of it.
    """
    floor = Polygon(room["polygon"])
    blocked = unary_union(
        [
            Polygon(f["polygon"]).buffer(ANCHOR_CLEARANCE, join_style=MITRE)
            for f in furniture
        ]
    )
    free = floor.buffer(-ANCHOR_CLEARANCE, join_style=MITRE).difference(blocked)
    if free.is_empty:
        free = floor
    centre = floor.centroid
    p = centre if free.contains(centre) else nearest_points(free, centre)[0]
    return project(p.x, p.y)


class Strip:
    """A room's tiles in a grid under its name, joined to the room by a leader."""

    def __init__(self, room, icons, anchor, layout):
        self.id, self.name, self.icons, self.anchor = (
            room["id"],
            room["name"],
            icons,
            anchor,
        )
        self.layout = layout
        self.columns = min(len(icons), layout["columns"] or len(icons))
        self.rows = -(-len(icons) // self.columns)
        self.x = self.y = 0.0
        self.leader = []
        self.size(1.0)

    def size(self, tile):
        """Set the dimensions for a tile edge of `tile` user units."""
        self.tile = tile
        self.gap = self.layout["gap"] * tile
        self.title = self.layout["title"] * tile
        self.tiles_w = self.columns * tile + (self.columns - 1) * self.gap
        # No font metrics at build time: 0.6 em per character is a generous
        # average for the UI font's bold weight.
        title_w = len(self.name) * 0.6 * self.title * TITLE_FONT
        self.w = max(self.tiles_w, title_w)
        self.h = self.title + self.rows * tile + (self.rows - 1) * self.gap

    def svg(self, icon_paths):
        out = [
            f'<g id="{self.id}.strip" class="fp-strip">',
            f'<g id="{self.id}.title" class="fp-strip-title">',
            f'<rect class="fp-hit" x="{self.x:.1f}" y="{self.y:.1f}" width="{self.w:.1f}" height="{self.title:.1f}"/>',
            (
                f'<text x="{self.x:.1f}" y="{self.y + self.title * TITLE_FONT:.1f}"'
                f' style="font-size:{self.title * TITLE_FONT:.1f}px">{escape(self.name)}</text>'
            ),
            "</g>",
        ]
        size = self.tile * 0.4
        s = size / MDI_EM
        for k, icon in enumerate(self.icons):
            tx = self.x + (k % self.columns) * (self.tile + self.gap)
            ty = self.y + self.title + (k // self.columns) * (self.tile + self.gap)
            ix, iy = tx + (self.tile - size) / 2, ty + self.tile * 0.14
            out += [
                f'<g id="{self.id}.tile{k}" class="fp-tile">',
                f'<rect class="fp-tile-bg" x="{tx:.1f}" y="{ty:.1f}" width="{self.tile}" height="{self.tile}" rx="{self.tile * 0.16:.1f}"/>',
                f'<path class="fp-tile-icon" transform="translate({ix:.1f} {iy + MDI_TOP * s:.1f}) scale({s:.4f} {-s:.4f})" d="{icon_paths[icon]}"/>',
                (
                    f'<text id="{self.id}.tile{k}.text" class="fp-tile-text" x="{tx + self.tile / 2:.1f}" y="{ty + self.tile * 0.84:.1f}"'
                    f' style="font-size:{self.tile * self.layout["text"]:.1f}px">–</text>'
                ),
                "</g>",
            ]
        out.append("</g>")
        return out

    def leader_svg(self):
        r = self.tile * 0.06
        ax, ay = self.anchor
        return [
            f'<polyline id="{self.id}.leader" class="fp-leader" points="{fmt(self.leader + [self.anchor])}"/>',
            f'<circle id="{self.id}.anchor" class="fp-anchor" cx="{ax:.1f}" cy="{ay:.1f}" r="{r:.1f}"/>',
        ]


def stack(desired, sizes, lo, hi, spacing):
    """Starts along one axis, in order, as near `desired` as overlap allows.

    A forward pass pushes items clear of their predecessor and of `lo`; a
    backward pass pulls them back inside `hi` where there is room.
    """
    starts = []
    for d, size in zip(desired, sizes):
        floor_ = lo if not starts else starts[-1] + sizes[len(starts) - 1] + spacing
        starts.append(max(d, floor_))
    for i in range(len(starts) - 1, -1, -1):
        limit = (
            hi - sizes[i]
            if i == len(starts) - 1
            else starts[i + 1] - spacing - sizes[i]
        )
        starts[i] = min(starts[i], limit)
    return starts


def layout_landscape(strips, box, layout):
    """Strips in a column either side of the drawing, sized from its width."""
    x0, y0, x1, y1 = box
    tile = layout["tile"] * (x1 - x0)
    for s in strips:
        s.size(tile)
    mid, reach = (x0 + x1) / 2, layout["reach"] * tile
    for side in (-1, 1):
        column = sorted(
            (s for s in strips if (s.anchor[0] < mid) == (side < 0)),
            key=lambda s: s.anchor[1],
        )
        desired = [s.anchor[1] - s.title - s.tile / 2 for s in column]
        tops = stack(desired, [s.h for s in column], y0, y1, layout["spacing"] * tile)
        width = max((s.w for s in column), default=0)
        for s, top in zip(column, tops):
            s.y = top
            row = top + s.title + s.tile / 2
            if side < 0:
                s.x = x0 - 2 * reach - width
                s.leader = [(s.x + s.tiles_w + reach * 0.15, row), (x0 - reach, row)]
            else:
                s.x = x1 + 2 * reach
                s.leader = [(x1 + 2 * reach - reach * 0.15, row), (x1 + reach, row)]


def layout_portrait(strips, box, layout):
    """Grid strips in one row above and one below the drawing.

    Rooms split by anchor height so the wider row is as narrow as possible,
    and tiles grow until that row spans the drawing: on a phone the whole
    image is only as wide as the screen. Each row is ordered by anchor x so
    leaders do not cross one another.
    """
    x0, y0, x1, y1 = box
    ordered = sorted(strips, key=lambda s: s.anchor[1])

    def row_width(row):
        """Width in tile edges, as every strip is sized for a tile of 1."""
        return sum(s.w for s in row) + layout["spacing"] * (len(row) - 1)

    split = min(
        range(len(ordered) + 1),
        key=lambda k: max(row_width(ordered[:k]), row_width(ordered[k:])),
    )
    tile = (x1 - x0) / max(row_width(ordered[:split]), row_width(ordered[split:]))
    for s in strips:
        s.size(tile)
    reach, spacing = layout["reach"] * tile, layout["spacing"] * tile
    for row, above in ((ordered[:split], True), (ordered[split:], False)):
        row.sort(key=lambda s: s.anchor[0])
        if not row:
            continue
        free = max(x1 - x0 - sum(s.w for s in row), spacing * (len(row) - 1))
        gap = free / (len(row) - 1) if len(row) > 1 else 0
        x = x0 if len(row) > 1 else (x0 + x1 - row[0].w) / 2
        for s in row:
            s.x = x
            x += s.w + gap
            cx = s.x + s.tiles_w / 2
            if above:
                s.y = y0 - 2 * reach - s.h
                s.leader = [(cx, s.y + s.h + reach * 0.15), (cx, y0 - reach)]
            else:
                s.y = y1 + 2 * reach
                s.leader = [(cx, s.y - reach * 0.15), (cx, y1 + reach)]


LAYOUT_FUNCTIONS = {"landscape": layout_landscape, "portrait": layout_portrait}


def render_plan(rooms, openings, furniture, scale):
    out = []
    tall, front = walls(rooms, openings)
    for geom, colour in ((tall, "#585b70"), (front, "#7f849c")):
        for poly in polygons(geom):
            d = " ".join(
                "M "
                + " L ".join(f"{x * scale:.1f},{y * scale:.1f}" for x, y in r.coords)
                + " Z"
                for r in [poly.exterior, *poly.interiors]
            )
            out.append(f'<path d="{d}" fill="{colour}" fill-rule="evenodd"/>')
    for r in rooms:
        out.append(
            f'<polygon id="{r["id"]}.floor" class="fp-floor-edge" points="{fmt([(x * scale, y * scale) for x, y in r["polygon"]])}"/>'
        )
        cx, cy = polygon_centroid(r["polygon"])
        out.append(
            f'<text id="{r["id"]}.name" class="fp-label" x="{cx * scale:.1f}" y="{cy * scale:.1f}">{escape(r["name"])}</text>'
        )
    for f in furniture:
        out.append(
            f'<polygon class="fp-furniture" points="{fmt([(x * scale, y * scale) for x, y in f["polygon"]])}"/>'
        )
    colours = {"door": "#f38ba8", "open": "#a6e3a1", "window": "#89b4fa"}
    for o in openings:
        (x0, y0), (x1, y1) = o["from"], o["to"]
        out.append(
            f'<line x1="{x0 * scale:.1f}" y1="{y0 * scale:.1f}" x2="{x1 * scale:.1f}" y2="{y1 * scale:.1f}" stroke="{colours[o["type"]]}" stroke-width="4"/>'
        )
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("geometry")
    ap.add_argument("out")
    ap.add_argument("--mode", choices=["iso", "plan"], default="iso")
    ap.add_argument("--wall-height", type=float, default=130.0)
    ap.add_argument("--front-height", type=float, default=25.0)
    ap.add_argument("--scale", type=float, default=1.0)
    ap.add_argument("--tiles")
    ap.add_argument("--icons")
    ap.add_argument("--layout", choices=sorted(LAYOUTS), default="landscape")
    ap.add_argument("--style")
    args = ap.parse_args()
    if args.tiles and not args.icons:
        ap.error("--tiles needs --icons")

    rooms, openings, furniture = load(args.geometry)
    pts = [p for r in rooms for p in r["polygon"]]
    if args.mode == "plan":
        body = render_plan(rooms, openings, furniture, args.scale)
        span = [(x * args.scale, y * args.scale) for x, y in pts]
        pad = (EXTERIOR_WALL + 10) * args.scale
        span += [(x - pad, y - pad) for x, y in span] + [
            (x + pad, y + pad) for x, y in span
        ]
    else:
        project = project_with(args.scale)
        # Walls stand outside the room outlines, so frame their outline too.
        tall, front = walls(rooms, openings)
        outline = pts + [
            p
            for poly in polygons(unary_union([tall, front, railings(rooms)]))
            for p in poly.exterior.coords
        ]
        span = [project(x, y, z) for x, y in outline for z in (0.0, args.wall_height)]

        tiles = json.loads(Path(args.tiles).read_text()) if args.tiles else {}
        unknown = set(tiles) - {r["id"] for r in rooms}
        if unknown:
            raise SystemExit(f"tiles for unknown rooms: {', '.join(sorted(unknown))}")
        empty = sorted(room for room, spec in tiles.items() if not spec["tiles"])
        if empty:
            raise SystemExit(f"rooms with an empty tile list: {', '.join(empty)}")
        layout = LAYOUTS[args.layout]
        strips = [
            Strip(
                r,
                [t["icon"] for t in tiles[r["id"]]["tiles"]],
                anchor(r, furniture, project),
                layout,
            )
            for r in rooms
            if r["id"] in tiles
        ]
        if strips:
            xs, ys = [p[0] for p in span], [p[1] for p in span]
            LAYOUT_FUNCTIONS[args.layout](
                strips, (min(xs), min(ys), max(xs), max(ys)), layout
            )
        icon_paths = (
            mdi_paths(args.icons, {i for s in strips for i in s.icons})
            if strips
            else {}
        )

        body = render_iso(
            rooms,
            openings,
            furniture,
            project,
            args.wall_height,
            args.front_height,
            set(tiles),
        )
        for s in strips:
            body += s.leader_svg()
        for s in strips:
            body += s.svg(icon_paths)
            span += [(s.x, s.y), (s.x + s.w, s.y + s.h)]
    xs, ys = [p[0] for p in span], [p[1] for p in span]
    margin = 40
    x0, y0 = min(xs) - margin, min(ys) - margin
    w, h = max(xs) - min(xs) + 2 * margin, max(ys) - min(ys) + 2 * margin
    style = [f"<style>{Path(args.style).read_text()}</style>"] if args.style else []
    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" class="fp-root" viewBox="{x0:.1f} {y0:.1f} {w:.1f} {h:.1f}">',
        *style,
        f'<rect class="fp-bg" x="{x0:.1f}" y="{y0:.1f}" width="{w:.1f}" height="{h:.1f}"/>',
        *body,
        "</svg>",
    ]
    with open(args.out, "w") as f:
        f.write("\n".join(svg) + "\n")


if __name__ == "__main__":
    main()
