"""Render the flat's geometry as an isometric line drawing (or a flat plan).

usage: render.py GEOMETRY.json OUT.svg [--mode iso|plan]
                 [--wall-height CM] [--front-height CM]
                 [--tiles TILES.json --layout landscape|portrait|scene]
                 [--people PEOPLE.json]
                 [--focus FOCUS.json | --thumb ROOM] [--aspect W/H]
                 [--style CSS]

GEOMETRY.json is geometry.nix serialised: room polygons, wall openings,
furniture boxes and device boxes (raised by a `base` height) in centimetres
in the reference frame, plus a display rotation. TILES.json maps room ids
to the icon of each of their tiles (an isometric model: lamp, tv, speaker);
the strips are laid out around the drawing and joined to their room by a
leader line. The `scene` layout draws the flat alone, with no strips.
--style embeds a stylesheet, for previews outside Home Assistant, which
supplies its own.

--focus crops a scene to some rooms for a room view's header, at --aspect.
The rest of the flat is faded, and markers stand where the room's lights,
switches and media players are. FOCUS.json is {"rooms": [ids], "markers":
[{"kind": "light"|"switch"|"media", "name", "entity", "at": [x, y, z]}]},
`at` in the reference frame like the geometry. --thumb crops a scene to one
room, faded around it the same way, for a thumbnail.

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
`<room>.strip`, `<room>.title`, `<room>.temp`, `<room>.humidity`,
`<room>.tile<k>`, `<room>.tile<k>.text`, `<room>.motion` for rooms with a
motion sensor, `<room>.countdown` for rooms with a lights-off timer,
`door.<name>` for each named door opening, `device.<name>` and
`device.<name>.glow` for each device, each person's entity id for their
badge, `<room>.rain` for outdoor rooms, `marker.<entity>`,
`marker.<entity>.state` and `marker.<entity>.hit` for each marker, and
`fp-scene` around the whole drawing for scene-wide state (daylight).
"""

import argparse
import json
import math
import random
from itertools import pairwise
from pathlib import Path
from xml.sax.saxutils import escape

from shapely.geometry import LineString, Point, Polygon
from shapely.geometry import box as rect
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
RIPPLE_RADIUS = 80  # cm on the floor; the outermost motion ring
DEVICE_GLOW_RADIUS = 110  # cm on the floor around an active device
ROUND_SIDES = 20  # polygon sides for a `round` box
AIRFLOW_RISE = 60  # cm of airflow drawn above a running fan's top
COUNTDOWN_RADIUS = 35  # cm on the floor; the lights-off countdown ring
AWAY_SPACING = 70  # cm between away badges outside the front door
RAIN_DROPS = 70  # drops over an outdoor room
RAIN_HEIGHT = 160  # cm the rain falls from
WINDOW_GLOW_BLUR = 8  # spread of daylight round a window, in drawing units
MARKER_RADIUS = 30  # drawing units; a marker's disc
MARKER_GLOW = 2.6  # a lit light's glow, in marker radii
MARKER_FONT = 0.9  # a marker's name, in marker radii; its state is smaller
MARKER_STATE_FONT = 0.85  # a marker's state, as a fraction of its name
WIDEST_MARKER_STATE = "Unavailable"
FOCUS_PAD = 0.04  # margin round focused rooms, as a fraction of their size
FADE_CLEARANCE = 14  # drawing units the fade keeps clear of focused walls

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
        "climate_line": 0,  # readings follow the room name
    },
    "portrait": {
        "gap": 0.1,
        "title": 0.45,
        "spacing": 0.35,
        "reach": 0.45,
        "columns": 2,
        "text": 0.25,
        # A line of its own: after the name, readings would run into the
        # next strip in the phone's narrow rows.
        "climate_line": 0.3,
    },
}
TITLE_FONT = 0.62  # room name size, as a fraction of the title band
CLIMATE_SAMPLE = "22.4° · 61%"  # widest readings text, for layout
ICON_LINE = 0.016  # icon stroke, as a fraction of the tile edge


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

    def boxes(key):
        out = []
        for f in geo.get(key, []):
            x0, y0, x1, y1 = f["rect"]
            if f.get("round"):
                # The ellipse inscribed in the rect, as a polygon.
                cx, cy, rx, ry = (
                    (x0 + x1) / 2,
                    (y0 + y1) / 2,
                    (x1 - x0) / 2,
                    (y1 - y0) / 2,
                )
                corners = [
                    (cx + rx * math.cos(t), cy + ry * math.sin(t))
                    for t in (2 * math.pi * i / ROUND_SIDES for i in range(ROUND_SIDES))
                ]
            else:
                corners = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
            out.append(dict(f, polygon=[rotate(c, degrees) for c in corners]))
        return out

    furniture, devices = boxes("furniture"), boxes("devices")

    pts = [p for r in rooms for p in r["polygon"]]
    dx, dy = -min(x for x, _ in pts), -min(y for _, y in pts)

    def shift(p):
        return (p[0] + dx, p[1] + dy)

    for item in rooms + furniture + devices:
        item["polygon"] = [shift(p) for p in item["polygon"]]
    for o in openings:
        o["from"], o["to"] = shift(o["from"]), shift(o["to"])
    heights = {f["name"]: f["height"] for f in furniture}
    seats = {
        name: [
            (*shift(rotate(tuple(p), degrees)), heights[seat["furniture"]])
            for p in seat["spots"]
        ]
        for name, seat in geo.get("seats", {}).items()
    }

    def place(point):
        """A reference-frame point in the drawing's frame, like the geometry."""
        return shift(rotate(tuple(point), degrees))

    return rooms, openings, furniture, devices, seats, place


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

    def __init__(self, svg, segment=None, top=None, solid=None):
        self.svg = svg
        self.segment = segment  # vertical face: its plan segment
        self.top = top  # horizontal top: its plan outline segments
        # For a top: (footprint, base z, top z) of the solid it closes.
        self.solid = solid

    def segments(self):
        return [self.segment] if self.segment else self.top


def stacked(a, b):
    """+1 if a's solid rests on b's, -1 if b's rests on a's, else 0.

    Depth alone puts a box on a shelf behind the shelf when the shelf
    reaches further forward; whatever sits on top is painted last.
    """
    if not (a.solid and b.solid):
        return 0
    (pa, base_a, top_a), (pb, base_b, top_b) = a.solid, b.solid
    if pa.intersection(pb).area <= EPS:
        return 0
    if base_a >= top_b - EPS:
        return 1
    if base_b >= top_a - EPS:
        return -1
    return 0


def in_front(a, b):
    """+1 if a must be painted after b, -1 if before, 0 if unrelated."""
    on_top = stacked(a, b)
    if on_top:
        return on_top
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


def extrude(geom, height, cls, project, windows=(), base=0.0):
    """Visible side faces and the top of a solid from `base` up to `height`."""
    faces, tops = [], []
    for poly in polygons(geom):
        for a, b in ring_segments(poly):
            if not facing_viewer(a, b):
                continue
            quad = [
                project(*a, base),
                project(*b, base),
                project(*b, height),
                project(*a, height),
            ]
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
                    # The blurred copy beneath is daylight bleeding round the
                    # frame; floorplan.css shows it only while the sun is up.
                    svg += (
                        f'<polygon class="fp-window-glow" filter="url(#fp-blur)" points="{fmt(pane)}"/>'
                        f'<polygon class="fp-window" points="{fmt(pane)}"/>'
                    )
            faces.append(Item(svg, segment=(a, b)))
        outline = list(ring_segments(poly))
        tops.append(
            Item(
                f'<path class="{cls}" fill-rule="evenodd" d="{path(poly, project, height)}"/>',
                top=outline,
                solid=(poly, base, height),
            )
        )
    return faces, tops


def polygon_centroid(points):
    c = Polygon(points).representative_point()
    return c.x, c.y


def door_pin(door, rooms, project, size):
    """Map pin over a door's threshold, on the outside of the wall.

    Inside, the door is hidden behind the walls nearest the viewer; outside
    the flat nothing is drawn in front of it.
    """
    (ax, ay), (bx, by) = door["from"], door["to"]
    width = math.hypot(bx - ax, by - ay)
    nx, ny = -(by - ay) / width, (bx - ax) / width
    indoor = unary_union([Polygon(r["polygon"]) for r in rooms if not r.get("outdoor")])
    mx, my = (ax + bx) / 2, (ay + by) / 2
    if indoor.contains(Point(mx + nx * EXTERIOR_WALL, my + ny * EXTERIOR_WALL)):
        nx, ny = -nx, -ny
    x, y = project(mx + nx * EXTERIOR_WALL, my + ny * EXTERIOR_WALL)
    r, rise = size * 0.3, size * 1.2
    # The door model fills a pin head about 0.38 of a tile across.
    icon_tile = r / 0.38
    model = "".join(iso_icon("door", x, y - rise, icon_tile))
    return [
        f'<g id="door.{door["name"]}" class="fp-door">',
        f'<ellipse class="fp-pin-shadow" cx="{x:.1f}" cy="{y:.1f}" rx="{r * 0.9:.1f}" ry="{r * 0.5:.1f}"/>',
        '<g class="fp-pin">',
        f'<line class="fp-pin-stem" x1="{x:.1f}" y1="{y:.1f}" x2="{x:.1f}" y2="{y - rise + r:.1f}"/>',
        f'<circle class="fp-pin-head" cx="{x:.1f}" cy="{y - rise:.1f}" r="{r:.1f}"/>',
        f'<g class="fp-icon-model" stroke-width="{icon_tile * ICON_LINE:.2f}">{model}</g>',
        "</g>",
        "</g>",
    ]


def countdown(room_id, centre):
    """Dial around a room's anchor that drains while its lights-off timer runs.

    A faint full track sits under the arc. The arc is a path starting at the
    top of the ellipse and running clockwise, like a clock face; pathLength
    makes its dash pattern 100 long whatever its real perimeter, so
    floorplan.css can drain it from 0 to 100.
    """
    x, y = centre
    r = COUNTDOWN_RADIUS
    rx, ry = r * math.sqrt(2) * COS30, r * math.sqrt(2) * SIN30
    top, bottom = f"{x:.1f},{y - ry:.1f}", f"{x:.1f},{y + ry:.1f}"
    arc = f"M {top} A {rx:.1f} {ry:.1f} 0 1 1 {bottom} A {rx:.1f} {ry:.1f} 0 1 1 {top}"
    return (
        f'<g id="{room_id}.countdown" class="fp-countdown">'
        f'<ellipse class="fp-countdown-track" cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}"/>'
        f'<path class="fp-countdown-arc" pathLength="100" d="{arc}"/>'
        "</g>"
    )


def person_badges(person, places, r):
    """A person's badge at each place it can show (sofa, bed, door).

    floorplan.css shows one at a time from the group's data-on (home) and
    data-bedtime attributes.
    """
    out = [f'<g id="{person["entity"]}" class="fp-person">']
    for place, (x, y) in places.items():
        out += [
            f'<g class="fp-at-{place}">',
            f'<ellipse class="fp-badge-shadow" cx="{x:.1f}" cy="{y:.1f}" rx="{r * 0.8:.1f}" ry="{r * 0.4:.1f}"/>',
            f'<circle class="fp-badge" cx="{x:.1f}" cy="{y - r:.1f}" r="{r:.1f}"/>',
            (
                f'<text class="fp-badge-text" x="{x:.1f}" y="{y - r * 0.62:.1f}"'
                f' style="font-size:{r * 1.05:.1f}px">{escape(person["initial"])}</text>'
            ),
            "</g>",
        ]
    out.append("</g>")
    return out


def door_spots(door, rooms, project, count, spacing):
    """Screen points along the outside of a door, for away badges."""
    (ax, ay), (bx, by) = door["from"], door["to"]
    width = math.hypot(bx - ax, by - ay)
    ux, uy = (bx - ax) / width, (by - ay) / width
    nx, ny = -uy, ux
    indoor = unary_union([Polygon(r["polygon"]) for r in rooms if not r.get("outdoor")])
    mx, my = (ax + bx) / 2, (ay + by) / 2
    if indoor.contains(Point(mx + nx * EXTERIOR_WALL, my + ny * EXTERIOR_WALL)):
        nx, ny = -nx, -ny
    out = EXTERIOR_WALL + spacing
    return [
        project(
            mx + nx * out + ux * spacing * (i - (count - 1) / 2),
            my + ny * out + uy * spacing * (i - (count - 1) / 2),
        )
        for i in range(count)
    ]


def ripple(room_id, centre, radius):
    """Rings on the floor around a room's anchor; floorplan.css animates them
    outwards while the room's motion sensor is on.

    A floor circle of radius r projects to an axis-aligned ellipse with
    semi-axes r·√2·cos30 and r·√2·sin30.
    """
    x, y = centre
    rx, ry = radius * math.sqrt(2) * COS30, radius * math.sqrt(2) * SIN30
    # Centred on the group's origin so scaling a ring needs no
    # transform-origin, which SVG renderers support unevenly.
    rings = "".join(
        f'<ellipse class="fp-ripple" rx="{rx:.1f}" ry="{ry:.1f}"/>' for _ in range(3)
    )
    return (
        f'<g id="{room_id}.motion" class="fp-motion"'
        f' transform="translate({x:.1f} {y:.1f})">{rings}</g>'
    )


def envelope(rooms, project, height):
    """Screen area of rooms with their walls, swept from floor to wall top."""
    shapes = []
    for r in rooms:
        ring = list(
            Polygon(r["polygon"])
            .buffer(EXTERIOR_WALL, join_style=MITRE)
            .exterior.coords
        )
        shapes += [Polygon([project(x, y, z) for x, y in ring]) for z in (0.0, height)]
        shapes += [
            Polygon(
                [project(*a), project(*b), project(*b, height), project(*a, height)]
            ).buffer(0)
            for a, b in pairwise(ring)
        ]
    return unary_union(shapes)


def crop(area, aspect):
    """viewBox (x, y, w, h) at `aspect`, centred on `area` with a margin."""
    x0, y0, x1, y1 = area.bounds
    w = (x1 - x0) * (1 + 2 * FOCUS_PAD)
    h = (y1 - y0) * (1 + 2 * FOCUS_PAD)
    if w / h < aspect:
        w = h * aspect
    else:
        h = w / aspect
    return (x0 + x1) / 2 - w / 2, (y0 + y1) / 2 - h / 2, w, h


def fade(area, box):
    """Veil over everything in `box` outside `area`; floorplan.css sets its
    opacity. Taps pass through to the floors under it."""
    x, y, w, h = box
    holes = [
        fmt(p.exterior.coords)
        for p in polygons(area.buffer(FADE_CLEARANCE, join_style=MITRE))
    ]
    d = f"M{x:.1f},{y:.1f} h{w:.1f} v{h:.1f} h{-w:.1f}Z" + "".join(
        f" M{ring}Z" for ring in holes
    )
    return f'<path class="fp-focus-fade" fill-rule="evenodd" d="{d}"/>'


def marker_point(spec, place, project):
    return project(*place(spec["at"][:2]), spec["at"][2])


def marker_extent(spec, place, project):
    """Screen box a marker covers: its glow, and the name and state centred
    under it, at 0.6 em a character like Strip's estimates."""
    x, y = marker_point(spec, place, project)
    r = MARKER_RADIUS
    font = r * MARKER_FONT
    half = max(
        MARKER_GLOW * r,
        len(spec["name"]) * 0.3 * font,
        len(WIDEST_MARKER_STATE) * 0.3 * font * MARKER_STATE_FONT,
    )
    return rect(
        x - half,
        y - MARKER_GLOW * r,
        x + half,
        max(y + MARKER_GLOW * r, y + r + font * 2.5),
    )


def marker(spec, place, project):
    """A light, switch or media player where it stands, named, with its state.

    Lights are discs with a lamp shade that glow while on; switches are
    rounded squares with a toggle, media players discs with a play mark.
    """
    x, y = marker_point(spec, place, project)
    r = MARKER_RADIUS
    eid = f"marker.{spec['entity']}"
    kind = spec["kind"]
    if kind not in ("light", "switch", "media"):
        raise SystemExit(f"marker {spec['entity']}: unknown kind {kind!r}")
    out = [f'<g id="{eid}" class="fp-marker fp-marker-{kind}">']
    if kind == "light":
        out.append(
            f'<circle class="fp-marker-glow" cx="{x:.1f}" cy="{y:.1f}" r="{r * MARKER_GLOW:.1f}"/>'
        )
    if kind == "switch":
        out.append(
            f'<rect class="fp-marker-body" x="{x - r:.1f}" y="{y - r:.1f}"'
            f' width="{2 * r}" height="{2 * r}" rx="{r * 0.45:.1f}"/>'
        )
    else:
        out.append(
            f'<circle class="fp-marker-body" cx="{x:.1f}" cy="{y:.1f}" r="{r}"/>'
        )
    if kind == "light":
        shade = [
            (x - 0.48 * r, y + 0.28 * r),
            (x - 0.2 * r, y - 0.3 * r),
            (x + 0.2 * r, y - 0.3 * r),
            (x + 0.48 * r, y + 0.28 * r),
        ]
        out += [
            f'<polygon class="fp-marker-glyph" points="{fmt(shade)}"/>',
            (
                f'<line class="fp-marker-glyph" x1="{x:.1f}" y1="{y - 0.3 * r:.1f}"'
                f' x2="{x:.1f}" y2="{y - 0.62 * r:.1f}"/>'
            ),
        ]
    elif kind == "switch":
        out += [
            (
                f'<rect class="fp-marker-glyph" x="{x - 0.5 * r:.1f}" y="{y - 0.26 * r:.1f}"'
                f' width="{r:.1f}" height="{0.52 * r:.1f}" rx="{0.26 * r:.1f}"/>'
            ),
            # One knob per position; floorplan.css shows the one that applies.
            f'<circle class="fp-marker-knob fp-knob-off" cx="{x - 0.24 * r:.1f}" cy="{y:.1f}" r="{0.14 * r:.1f}"/>',
            f'<circle class="fp-marker-knob fp-knob-on" cx="{x + 0.24 * r:.1f}" cy="{y:.1f}" r="{0.14 * r:.1f}"/>',
        ]
    else:
        play = [
            (x - 0.28 * r, y - 0.42 * r),
            (x + 0.46 * r, y),
            (x - 0.28 * r, y + 0.42 * r),
        ]
        out.append(f'<polygon class="fp-marker-mark" points="{fmt(play)}"/>')
    font = r * MARKER_FONT
    out += [
        (
            f'<text class="fp-marker-name" x="{x:.1f}" y="{y + r + font * 1.1:.1f}"'
            f' style="font-size:{font:.1f}px">{escape(spec["name"])}</text>'
        ),
        (
            f'<text id="{eid}.state" class="fp-marker-state" x="{x:.1f}" y="{y + r + font * 2.2:.1f}"'
            f' style="font-size:{font * MARKER_STATE_FONT:.1f}px">–</text>'
        ),
        # The rule binds to this disc alone; see Strip.svg.
        f'<circle id="{eid}.hit" class="fp-hit" cx="{x:.1f}" cy="{y:.1f}" r="{r * 1.5:.1f}"/>',
        "</g>",
    ]
    return out


def device_glow(device, project):
    """Pool of light on the floor around a device, shown while it is active."""
    c = Polygon(device["polygon"]).centroid
    (x, y), r = project(c.x, c.y), DEVICE_GLOW_RADIUS
    rx, ry = r * math.sqrt(2) * COS30, r * math.sqrt(2) * SIN30
    cls = "fp-device-glow" + (" fp-pulse" if device.get("effect") == "pulse" else "")
    return (
        f'<ellipse id="device.{device["name"]}.glow" class="{cls}"'
        f' cx="{x:.1f}" cy="{y:.1f}" rx="{rx:.1f}" ry="{ry:.1f}"/>'
    )


def rain(room, project):
    """Falling rain over an outdoor room, shown while the forecast says so.

    Each drop is a line from RAIN_HEIGHT to the floor whose dashes floorplan.css
    moves down it; delays vary so drops do not fall in step. A fixed seed per
    room keeps the build reproducible.
    """
    rng = random.Random(room["id"])
    floor = Polygon(room["polygon"])
    x0, y0, x1, y1 = floor.bounds
    drops = []
    while len(drops) < RAIN_DROPS:
        x, y = rng.uniform(x0, x1), rng.uniform(y0, y1)
        if not floor.contains(Point(x, y)):
            continue
        (sx, sy), (ex, ey) = project(x, y, RAIN_HEIGHT), project(x, y)
        drops.append(
            f'<line x1="{sx:.1f}" y1="{sy:.1f}" x2="{ex:.1f}" y2="{ey:.1f}"'
            f' style="animation-delay:{-rng.uniform(0, 1):.2f}s"/>'
        )
    wet = fmt([project(x, y) for x, y in room["polygon"]])
    return (
        f'<g id="{room["id"]}.rain" class="fp-rain">'
        f'<polygon class="fp-rain-wet" points="{wet}"/>{"".join(drops)}</g>'
    )


def device_effect(device, project):
    """Marks on a device's top that floorplan.css animates while it runs.

    `spin` is a dashed ring on the top (a washing machine's drum); `airflow`
    is dashed lines rising from it (a fan or extractor). Dash offsets move,
    so nothing needs a transform origin. `pulse` lives on the floor glow.
    """
    poly = Polygon(device["polygon"])
    c = poly.centroid
    x0, y0, x1, y1 = poly.bounds
    r = min(x1 - x0, y1 - y0) / 2
    top = device["base"] + device["height"]
    x, y = project(c.x, c.y, top)
    effect = device.get("effect")
    if effect == "spin":
        ring = r * 0.65
        return (
            f'<ellipse class="fp-effect fp-spin" cx="{x:.1f}" cy="{y:.1f}"'
            f' rx="{ring * math.sqrt(2) * COS30:.1f}" ry="{ring * math.sqrt(2) * SIN30:.1f}"/>'
        )
    if effect == "airflow":
        spread = r * math.sqrt(2) * COS30 * 0.5
        return "".join(
            f'<line class="fp-effect fp-airflow" x1="{x + dx:.1f}" y1="{y:.1f}"'
            f' x2="{x + dx:.1f}" y2="{y - AIRFLOW_RISE:.1f}"/>'
            for dx in (-spread, 0, spread)
        )
    return ""


def render_iso(
    rooms,
    openings,
    furniture,
    devices,
    project,
    wall_height,
    front_height,
    linked,
):
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
    # On the floor, so the walls the device hangs on cover its far half.
    out += [device_glow(d, project) for d in devices]
    # Rain at floor level, so the walls in front of an outdoor room cover it
    # as they would the room itself.
    out += [rain(r, project) for r in rooms if r.get("outdoor")]
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
    # A device is small enough to paint as one unit, ordered by its
    # footprint like a furniture top; grouped, a rule can light it as one.
    for d in devices:
        poly = Polygon(d["polygon"])
        top = d["base"] + d["height"]
        faces, tops = extrude(poly, top, "fp-device", project, base=d["base"])
        if d.get("round"):
            # A cylinder's side is one surface: fill its facets without
            # their seams and outline the whole side once.
            side = unary_union(
                [
                    Polygon(
                        [
                            project(*a, d["base"]),
                            project(*b, d["base"]),
                            project(*b, top),
                            project(*a, top),
                        ]
                    ).buffer(0.01)
                    for a, b in ring_segments(poly)
                    if facing_viewer(a, b)
                ]
            )
            side_svg = f'<polygon class="fp-device fp-device-side" points="{fmt(side.exterior.coords)}"/>'
            svg = side_svg + "".join(i.svg for i in tops)
        else:
            svg = "".join(i.svg for i in faces + tops)
        svg += device_effect(d, project)
        furn_tops.append(
            Item(
                f'<g id="device.{d["name"]}" class="fp-device-group">{svg}</g>',
                top=list(ring_segments(poly)),
                solid=(poly, d["base"], d["base"] + d["height"]),
            )
        )

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


def iso_icon(kind, cx, cy, tile):
    """A tiny model in the drawing's own projection, centred on (cx, cy).

    Models are laid out for a 120 unit tile and scaled to `tile`. Classes
    let floorplan.css colour them by state: `fp-icon` for solid parts,
    `fp-icon-detail` for parts filled only while active (a lit screen, a
    playing speaker cone), `fp-icon-ray` for light shown only while on and
    `fp-icon-frame` for outlines that are never filled.
    """
    k = tile / 120

    def at(scale, dx, dy):
        def project(p):
            x, y, z = p
            return (
                cx + dx * k + (x - y) * COS30 * scale * k,
                cy + dy * k + ((x + y) * SIN30 - z) * scale * k,
            )

        return project

    def face(points, cls="fp-icon"):
        return f'<polygon class="{cls}" points="{fmt(points)}"/>'

    def box(P, x0, y0, z0, x1, y1, z1):
        # The faces turned to the viewer (+x, +y), then the top.
        return [
            face([P((x1, y0, z0)), P((x1, y1, z0)), P((x1, y1, z1)), P((x1, y0, z1))]),
            face([P((x0, y1, z0)), P((x1, y1, z0)), P((x1, y1, z1)), P((x0, y1, z1))]),
            face([P((x0, y0, z1)), P((x1, y0, z1)), P((x1, y1, z1)), P((x0, y1, z1))]),
        ]

    def ring(P, z, r, n=32):
        return [
            P((r * math.cos(t), r * math.sin(t), z))
            for t in (2 * math.pi * i / n for i in range(n))
        ]

    def disc(P, y, z, r, cls, n=24):
        # A circle upright in the x-z plane, on the +y face of a box.
        return face(
            [
                P((r * math.cos(t), y, z + r * math.sin(t)))
                for t in (2 * math.pi * i / n for i in range(n))
            ],
            cls,
        )

    if kind == "lamp":
        P = at(5.4, 0, 1)
        top, rim = ring(P, 4.4, 1.0), ring(P, 1.4, 3.6)
        # Shade silhouette: the top ring's back edge, the sides, and the
        # rim's front half; the rim's back half is behind the shade.
        top_mid = sum(p[1] for p in top) / len(top)
        rim_mid = sum(p[1] for p in rim) / len(rim)
        back = sorted((p for p in top if p[1] <= top_mid), key=lambda p: p[0])
        front = sorted((p for p in rim if p[1] >= rim_mid), key=lambda p: -p[0])
        (x0, y0), (x1, y1) = P((0, 0, 8.5)), P((0, 0, 4.4))
        bx, by = P((0, 0, 1.4))
        return [
            f'<line class="fp-icon" x1="{x0:.1f}" y1="{y0:.1f}" x2="{x1:.1f}" y2="{y1:.1f}"/>',
            face([*back, max(rim), *front, min(rim)]),
            face(top),
            *(
                f'<line class="fp-icon-ray" x1="{bx + a * 7 * k:.1f}" y1="{by + 3 * k:.1f}"'
                f' x2="{bx + a * 13 * k:.1f}" y2="{by + 11 * k:.1f}"/>'
                for a in (-1, 0, 1)
            ),
        ]
    if kind == "tv":
        P = at(5.2, -2, 7)
        # Depths and the bezel are wide enough that parallel edges stay
        # clearly apart at tile size instead of reading as one thick line.
        screen = [
            P((-3.1, 0.6, 2.5)),
            P((3.1, 0.6, 2.5)),
            P((3.1, 0.6, 5.5)),
            P((-3.1, 0.6, 5.5)),
        ]
        return [
            *box(P, -1.8, -1.1, 0, 1.8, 1.1, 0.7),  # foot
            *box(P, -0.35, -0.3, 0.7, 0.35, 0.3, 1.6),  # neck
            *box(P, -4, -0.6, 1.6, 4, 0.6, 6.4),  # panel
            face(screen, "fp-icon-detail"),
        ]
    if kind == "speaker":
        P = at(5.4, 0, 8)
        return [
            *box(P, -2.4, -2.4, 0, 2.4, 2.4, 5.2),
            disc(P, 2.4, 2.6, 1.5, "fp-icon-detail"),
            disc(P, 2.4, 2.6, 0.5, "fp-icon"),
        ]
    if kind == "door":
        P = at(5.0, 4, 12)
        hinge, leaf, height = -2.2, 4.4, 7
        swing = math.radians(70)
        lx, ly = hinge + leaf * math.cos(swing), leaf * math.sin(swing)
        frame = [
            P((-2.2, 0, 0)),
            P((-2.2, 0, height)),
            P((2.2, 0, height)),
            P((2.2, 0, 0)),
        ]
        return [
            f'<polyline class="fp-icon-frame" points="{fmt(frame)}"/>',
            face(
                [
                    P((hinge, 0, 0)),
                    P((lx, ly, 0)),
                    P((lx, ly, height)),
                    P((hinge, 0, height)),
                ]
            ),
        ]
    raise SystemExit(f"unknown icon: {kind}")


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

    def __init__(self, room, icons, climate, anchor, layout):
        self.id, self.name, self.icons, self.anchor = (
            room["id"],
            room["name"],
            icons,
            anchor,
        )
        self.layout = layout
        self.climate = climate
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
        # Readings go on their own line under the name when the layout has
        # one, otherwise after the name.
        line = self.layout["climate_line"] if self.climate else 0
        self.climate_h = line * tile
        self.tiles_w = self.columns * tile + (self.columns - 1) * self.gap
        # No font metrics at build time: 0.6 em per character is a generous
        # average for the UI font's bold weight.
        name_w = len(self.name) * 0.6 * self.title * TITLE_FONT
        readings_w = len(CLIMATE_SAMPLE) * 0.6 * self.climate_font
        if self.climate and not line:
            name_w += readings_w
        self.w = max(self.tiles_w, name_w, readings_w if line else 0)
        self.h = (
            self.title + self.climate_h + self.rows * tile + (self.rows - 1) * self.gap
        )

    @property
    def climate_font(self):
        line = self.layout["climate_line"]
        return line * self.tile * 0.78 if line else self.title * TITLE_FONT * 0.72

    def readings(self):
        """Temperature and humidity tspans, filled in by ha-floorplan rules."""
        return (
            f'<tspan id="{self.id}.temp" class="fp-reading">–</tspan>'
            # No-break spaces: SVG text collapses plain ones at tspan edges.
            '<tspan class="fp-reading-sep"> · </tspan>'
            f'<tspan id="{self.id}.humidity" class="fp-reading">–</tspan>'
        )

    def svg(self):
        name_size = self.title * TITLE_FONT
        inline = self.climate and not self.climate_h
        out = [
            f'<g id="{self.id}.strip" class="fp-strip">',
            f'<g id="{self.id}.title" class="fp-strip-title">',
            f'<rect class="fp-hit" x="{self.x:.1f}" y="{self.y:.1f}" width="{self.w:.1f}" height="{self.title + self.climate_h:.1f}"/>',
            (
                f'<text x="{self.x:.1f}" y="{self.y + name_size:.1f}"'
                f' style="font-size:{name_size:.1f}px">{escape(self.name)}'
                + (
                    f'<tspan class="fp-readings" dx="{self.climate_font * 0.5:.1f}"'
                    f' style="font-size:{self.climate_font:.1f}px">{self.readings()}</tspan>'
                    if inline
                    else ""
                )
                + "</text>"
            ),
        ]
        if self.climate_h:
            out.append(
                f'<text class="fp-readings" x="{self.x:.1f}" y="{self.y + self.title + self.climate_h * 0.62:.1f}"'
                f' style="font-size:{self.climate_font:.1f}px">{self.readings()}</text>'
            )
        out.append("</g>")
        top = self.y + self.title + self.climate_h
        for k, icon in enumerate(self.icons):
            tx = self.x + (k % self.columns) * (self.tile + self.gap)
            ty = top + (k // self.columns) * (self.tile + self.gap)
            model = "".join(
                iso_icon(icon, tx + self.tile / 2, ty + self.tile * 0.42, self.tile)
            )
            out += [
                f'<g id="{self.id}.tile{k}" class="fp-tile">',
                f'<rect class="fp-tile-bg" x="{tx:.1f}" y="{ty:.1f}" width="{self.tile}" height="{self.tile}" rx="{self.tile * 0.16:.1f}"/>',
                f'<g class="fp-icon-model" stroke-width="{self.tile * ICON_LINE:.2f}">{model}</g>',
                (
                    f'<text id="{self.id}.tile{k}.text" class="fp-tile-text" x="{tx + self.tile / 2:.1f}" y="{ty + self.tile * 0.84:.1f}"'
                    f' style="font-size:{self.tile * self.layout["text"]:.1f}px">–</text>'
                ),
                # ha-floorplan listens on a rule's element and every element
                # inside it, and runs a hold once per element under the
                # finger. The tile's rule binds to this rect alone, on top.
                f'<rect id="{self.id}.tile{k}.hit" class="fp-hit" x="{tx:.1f}" y="{ty:.1f}" width="{self.tile}" height="{self.tile}"/>',
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
            row = top + s.title + s.climate_h + s.tile / 2
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
    ap.add_argument("--people")
    ap.add_argument(
        "--layout", choices=[*sorted(LAYOUTS), "scene"], default="landscape"
    )
    crops = ap.add_mutually_exclusive_group()
    crops.add_argument("--focus")
    crops.add_argument("--thumb", metavar="ROOM")
    ap.add_argument("--aspect", type=float, default=1.0)
    ap.add_argument("--style")
    args = ap.parse_args()
    if (args.focus or args.thumb) and (args.mode != "iso" or args.layout != "scene"):
        raise SystemExit("--focus and --thumb crop a scene: use --layout scene")
    if args.aspect <= 0:
        raise SystemExit("--aspect must be positive")

    rooms, openings, furniture, devices, seats, place = load(args.geometry)
    view = None
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
        anchors = {
            r["id"]: anchor(r, furniture, project) for r in rooms if r["id"] in tiles
        }
        xs, ys = [p[0] for p in span], [p[1] for p in span]
        drawing = (min(xs), min(ys), max(xs), max(ys))
        layout = LAYOUTS.get(args.layout)
        strips = (
            [
                Strip(
                    r,
                    [t["icon"] for t in tiles[r["id"]]["tiles"]],
                    "climate" in tiles[r["id"]],
                    anchors[r["id"]],
                    layout,
                )
                for r in rooms
                if r["id"] in tiles
            ]
            if layout
            else []
        )
        if strips:
            LAYOUT_FUNCTIONS[args.layout](strips, drawing, layout)
        named_doors = [o for o in openings if o["type"] == "door" and o.get("name")]

        body = render_iso(
            rooms,
            openings,
            furniture,
            devices,
            project,
            args.wall_height,
            args.front_height,
            set(tiles),
        )
        for room_id, centre in anchors.items():
            if "motion" in tiles[room_id]:
                body.append(ripple(room_id, centre, RIPPLE_RADIUS))
            if "timer" in tiles[room_id]:
                body.append(countdown(room_id, centre))
        for s in strips:
            body += s.leader_svg()
        # Pins and badges are sized like tiles so they read at the same scale;
        # a scene sizes them as its landscape drawing would.
        pin_size = (
            strips[0].tile
            if strips
            else LAYOUTS["landscape"]["tile"] * (drawing[2] - drawing[0])
        )
        for door in named_doors:
            body += door_pin(door, rooms, project, pin_size)
        people = json.loads(Path(args.people).read_text()) if args.people else []
        front = next((d for d in named_doors if d["name"] == "front"), None)
        if people and front:
            away = door_spots(front, rooms, project, len(people), AWAY_SPACING)
            for i, person in enumerate(people):
                places = {name: project(*spots[i]) for name, spots in seats.items()}
                places["door"] = away[i]
                body += person_badges(person, places, pin_size * 0.2)
        for s in strips:
            body += s.svg()
            span += [(s.x, s.y), (s.x + s.w, s.y + s.h)]

        if args.focus or args.thumb:
            spec = (
                json.loads(Path(args.focus).read_text())
                if args.focus
                else {"rooms": [args.thumb], "markers": []}
            )
            if not spec["rooms"]:
                raise SystemExit("focus on no rooms: list at least one")
            missing = set(spec["rooms"]) - {r["id"] for r in rooms}
            if missing:
                raise SystemExit(
                    f"focus on unknown rooms: {', '.join(sorted(missing))}"
                )
            area = envelope(
                [r for r in rooms if r["id"] in spec["rooms"]],
                project,
                args.wall_height,
            )
            # Framed to show every marker and its labels whole, even one
            # standing above the walls; faded round the rooms alone.
            framed = unary_union(
                [area] + [marker_extent(m, place, project) for m in spec["markers"]]
            )
            view = crop(framed, args.aspect)
            body.append(fade(area, view))
            for m in spec["markers"]:
                body += marker(m, place, project)
    if view:
        x0, y0, w, h = view
    else:
        xs, ys = [p[0] for p in span], [p[1] for p in span]
        margin = 40
        x0, y0 = min(xs) - margin, min(ys) - margin
        w, h = max(xs) - min(xs) + 2 * margin, max(ys) - min(ys) + 2 * margin
    style = [f"<style>{Path(args.style).read_text()}</style>"] if args.style else []
    svg = [
        f'<svg xmlns="http://www.w3.org/2000/svg" class="fp-root" viewBox="{x0:.1f} {y0:.1f} {w:.1f} {h:.1f}">',
        *style,
        # Stop colours come from floorplan.css, so the glow follows the theme.
        "<defs>"
        + "".join(
            f'<radialGradient id="{gid}">'
            f'<stop offset="0" class="{cls}" stop-opacity="0.6"/>'
            f'<stop offset="1" class="{cls}" stop-opacity="0"/>'
            "</radialGradient>"
            for gid, cls in (
                ("fp-glow", "fp-glow-stop"),
                ("fp-glow-heat", "fp-glow-stop fp-heat-stop"),
                ("fp-glow-cool", "fp-glow-stop fp-cool-stop"),
            )
        )
        + '<filter id="fp-blur" x="-1" y="-1" width="3" height="3">'
        + f'<feGaussianBlur stdDeviation="{WINDOW_GLOW_BLUR}"/></filter>'
        + "</defs>",
        f'<rect class="fp-bg" x="{x0:.1f}" y="{y0:.1f}" width="{w:.1f}" height="{h:.1f}"/>',
        # One element over the whole drawing carries scene-wide state, such
        # as whether it is daylight.
        '<g id="fp-scene">',
        *body,
        "</g>",
        "</svg>",
    ]
    with open(args.out, "w") as f:
        f.write("\n".join(svg) + "\n")


if __name__ == "__main__":
    main()
