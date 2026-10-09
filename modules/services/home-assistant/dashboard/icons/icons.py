"""Draw the dashboard's icon set in the floorplan's line style.

usage: icons.py OUT.js
       icons.py --sheet OUT.svg

Objects are isometric silhouettes with a few key edges, in the floorplan's
projection; symbols with no solid form (weather, alerts) are flat outlines
in the same weight. Home Assistant icons are filled paths only, with no
strokes, so every line is buffered into its outline here. A `shade` region
becomes the icon's secondary path, which Home Assistant draws at half
opacity.

OUT.js registers the set as `window.customIcons.fp`, so `fp:<name>` works
anywhere `<ha-icon>` does. --sheet renders every icon at 14, 24 and 48 px
on dark and light backgrounds, for review.
"""

import argparse
import json
import math

from shapely.affinity import scale, translate
from shapely.geometry import LineString, MultiPolygon, Point, Polygon
from shapely.geometry import box as rect
from shapely.geometry.polygon import orient
from shapely.ops import unary_union

C30 = math.cos(math.radians(30))
SIZE = 24
STROKE = 1.8
PAD = 2.2
ROUND_SIDES = 48


def iso(p):
    x, y, z = p
    return ((x - y) * C30, (x + y) * 0.5 - z)


def line(*points):
    return LineString([iso(p) for p in points])


def face(*points):
    return Polygon([iso(p) for p in points]).buffer(0)


def box_faces(x0, y0, z0, x1, y1, z1):
    """The three faces of a box turned towards the viewer."""
    return [
        face((x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)),
        face((x0, y1, z0), (x1, y1, z0), (x1, y1, z1), (x0, y1, z1)),
        face((x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)),
    ]


def corner(x0, y0, z0, x1, y1, z1):
    """The three edges meeting at a box's nearest top corner."""
    near = (x1, y1, z1)
    return [
        line(near, (x0, y1, z1)),
        line(near, (x1, y0, z1)),
        line(near, (x1, y1, z0)),
    ]


def ring(c, r, axis="z"):
    """A circle in 3D as projected points: horizontal, or upright in an x or y plane."""
    cx, cy, cz = c
    out = []
    for i in range(ROUND_SIDES):
        a, b = (
            r * math.cos(2 * math.pi * i / ROUND_SIDES),
            r * math.sin(2 * math.pi * i / ROUND_SIDES),
        )
        p = {
            "z": (cx + a, cy + b, cz),
            "y": (cx + a, cy, cz + b),
            "x": (cx, cy + a, cz + b),
        }[axis]
        out.append(iso(p))
    return Polygon(out)


def cylinder(c, r, z0, z1):
    """Silhouette and top rim of an upright cylinder."""
    x, y, _ = c
    top = ring((x, y, z1), r)
    return top.union(ring((x, y, z0), r)).convex_hull, top


def outline(*shapes):
    """The outer boundary of solids drawn together."""
    merged = unary_union(shapes)
    largest = max(getattr(merged, "geoms", [merged]), key=lambda g: g.area)
    return largest.exterior


class Icon:
    def __init__(self, lines, shade=None):
        self.lines = unary_union(lines) if isinstance(lines, list) else lines
        self.shade = shade

    def paths(self):
        """Primary and secondary SVG paths fitted to the 24 unit box."""
        parts = [self.lines] + ([self.shade] if self.shade is not None else [])
        x0, y0, x1, y1 = unary_union(parts).bounds
        s = (SIZE - 2 * PAD - STROKE) / max(x1 - x0, y1 - y0)

        def fit(g):
            g = translate(g, -(x0 + x1) / 2, -(y0 + y1) / 2)
            return translate(scale(g, s, s, origin=(0, 0)), SIZE / 2, SIZE / 2)

        primary = fit(self.lines).buffer(STROKE / 2, cap_style=1, join_style=1)
        secondary = Polygon()
        if self.shade is not None:
            secondary = fit(self.shade).buffer(-STROKE * 0.35).difference(primary)
        return to_path(primary), to_path(secondary)


def to_path(geom):
    if geom.is_empty:
        return ""
    geom = geom.simplify(0.03)
    polys = geom.geoms if isinstance(geom, MultiPolygon) else [geom]
    out = []
    for p in polys:
        if not isinstance(p, Polygon) or p.is_empty:
            continue
        p = orient(p, 1.0)
        for r in [p.exterior, *p.interiors]:
            pts = list(r.coords)[:-1]
            out.append("M" + "L".join(f"{x:.2f} {y:.2f}" for x, y in pts) + "Z")
    return "".join(out)


ICONS = {}


def icon(name):
    def register(fn):
        ICONS[name] = fn
        return fn

    return register


# Objects: isometric silhouettes ------------------------------------------------


@icon("sofa")
def sofa():
    back = (0, 0, 0, 2.2, 9, 3.4)
    seat = (2.2, 0, 0, 6.5, 9, 1.6)
    arm_far, arm_near = (2.2, 0, 0, 6.5, 1.2, 2.5), (2.2, 7.8, 0, 6.5, 9, 2.5)
    solids = [f for b in (back, seat, arm_far, arm_near) for f in box_faces(*b)]
    return Icon(
        [
            outline(*solids),
            line((2.2, 1.2, 1.6), (2.2, 7.8, 1.6)),
            line((2.2, 7.8, 2.5), (6.5, 7.8, 2.5), (6.5, 7.8, 1.6)),
            line((6.5, 1.2, 1.6), (6.5, 7.8, 1.6)),
        ]
    )


@icon("bed")
def bed():
    head = (0, 0, 0, 1.4, 7, 4.2)
    mattress = (1.4, 0, 0, 10, 7, 2.0)
    solids = box_faces(*head) + box_faces(*mattress)
    return Icon(
        [
            outline(*solids),
            line((1.4, 0, 2.0), (1.4, 7, 2.0)),
            line((3.6, 0, 2.0), (3.6, 7, 2.0)),
            line((10, 7, 2.0), (10, 0, 2.0)),
            line((10, 7, 2.0), (10, 7, 0)),
        ]
    )


@icon("tv")
def tv():
    slab = (-5, -0.5, 1.2, 5, 0.5, 7.2)
    screen = face((-4.1, 0.5, 2.0), (4.1, 0.5, 2.0), (4.1, 0.5, 6.4), (-4.1, 0.5, 6.4))
    return Icon(
        [
            outline(*box_faces(*slab)),
            line((-3, 0, 1.2), (-3, 0, 0)),
            line((3, 0, 1.2), (3, 0, 0)),
        ],
        screen,
    )


@icon("lamp")
def lamp():
    top, rim = ring((0, 0, 4.4), 1.0), ring((0, 0, 1.4), 3.6)
    shade = top.union(rim).convex_hull
    centre_y = rim.centroid.y
    rim_front = rim.exterior.intersection(rect(-99, centre_y, 99, 99))
    return Icon(
        [
            shade.exterior.difference(rim.buffer(-0.05)),
            rim_front,
            line((0, 0, 8.5), (0, 0, 4.4)),
        ]
    )


@icon("speaker")
def speaker():
    body = (0, 0, 0, 3.4, 3.4, 6)
    return Icon(
        [
            outline(*box_faces(*body)),
            *corner(*body),
            ring((1.7, 3.4, 2.2), 1.1, axis="y").exterior,
            ring((1.7, 3.4, 4.7), 0.45, axis="y").exterior,
        ]
    )


@icon("fan")
def fan():
    base, base_top = cylinder((0, 0, 0), 1.6, 0, 2.4)
    loop = Point(0, 0).buffer(1).exterior
    hoop = LineString([iso((2.2 * x, 0, 6.6 + 3.8 * y)) for x, y in loop.coords])
    return Icon([base.exterior, base_top.exterior.difference(hoop.buffer(0.6)), hoop])


@icon("thermostat")
def thermostat():
    puck, top = cylinder((0, 0, 0), 4, 0, 1.4)
    return Icon([puck.exterior, top.exterior, line((0, 0, 1.4), (2.4, -2.4, 1.4))])


@icon("thermometer")
def thermometer():
    stem, top = cylinder((0, 0, 0), 0.9, 2, 9)
    bulb = Point(iso((0, 0, 1.6))).buffer(1.9)
    return Icon(
        [outline(stem, bulb), top.exterior],
        Point(iso((0, 0, 1.6)))
        .buffer(1.0)
        .union(line((0, 0, 1.6), (0, 0, 6.5)).buffer(0.45)),
    )


@icon("battery")
def battery():
    body = (0, 0, 0, 8, 4, 3)
    nub = (8, 1.2, 0.8, 9, 2.8, 2.2)
    level = face((0.8, 4, 0.6), (4.5, 4, 0.6), (4.5, 4, 2.4), (0.8, 4, 2.4))
    return Icon([outline(*box_faces(*body), *box_faces(*nub)), *corner(*body)], level)


@icon("door")
def door():
    frame = (0, 0, 0, 0.6, 5, 8.5)
    return Icon(
        [
            outline(*box_faces(*frame)),
            *corner(*frame),
            face(
                (0.6, 0.7, 0), (0.6, 4.3, 0), (0.6, 4.3, 7.7), (0.6, 0.7, 7.7)
            ).exterior,
            Point(iso((0.6, 3.6, 3.9))).buffer(0.25).exterior,
        ]
    )


@icon("shower")
def shower():
    head = ring((4.5, 0, 7.4), 2.2)
    drops = [line((4.5 + d, -d, 5.4), (4.5 + d, -d, 3.4)) for d in (-1.4, 0, 1.4)]
    return Icon(
        [
            line((0, 0, 0), (0, 0, 9.4), (4.5, 0, 9.4), (4.5, 0, 7.4)),
            head.exterior,
            *drops,
        ]
    )


@icon("dining")
def dining():
    top = (0, 0, 4, 9, 6, 4.8)
    legs = [line((x, y, 4), (x, y, 0)) for x, y in ((8.4, 0.6), (8.4, 5.4), (0.6, 5.4))]
    return Icon([outline(*box_faces(*top)), *corner(*top), *legs])


@icon("teddy-bear")
def teddy_bear():
    head = Point(12, 12).buffer(6)
    ears = [Point(6.6, 6.6).buffer(2.4), Point(17.4, 6.6).buffer(2.4)]
    snout = Point(12, 14.6).buffer(2.3)
    eyes = [Point(9.6, 10.6), Point(14.4, 10.6), Point(12, 13.8)]
    return Icon(
        [
            outline(head, *ears),
            *(e.difference(head) for e in (ears[0].exterior, ears[1].exterior)),
            snout.exterior,
            *eyes,
        ]
    )


@icon("robot-vacuum")
def robot_vacuum():
    body, top = cylinder((0, 0, 0), 4.5, 0, 1.3)
    sensor = ring((-1.4, -1.4, 1.3), 1.0)
    return Icon([body.exterior, top.exterior, sensor.exterior])


@icon("car")
def car():
    body = (0, 0, 0.8, 10, 4.4, 3.0)
    cabin = (2.4, 0.3, 3.0, 7.2, 4.1, 5.0)
    wheels = [ring((x, 4.4, 0.9), 0.9, axis="y") for x in (2.2, 7.8)]
    return Icon(
        [
            outline(*box_faces(*body), *box_faces(*cabin), *wheels),
            *corner(*body),
            *corner(*cabin)[:2],
            *(w.exterior for w in wheels),
        ]
    )


@icon("server")
def server():
    lower, upper = (0, 0, 0, 6, 6, 2.4), (0, 0, 2.4, 6, 6, 4.8)
    leds = [Point(iso((x, 6, z))) for x in (4.6, 5.3) for z in (1.2, 3.6)]
    return Icon(
        [
            outline(*box_faces(*lower), *box_faces(*upper)),
            *corner(*upper),
            line((0, 6, 2.4), (6, 6, 2.4), (6, 0, 2.4)),
            line((6, 6, 2.4), (6, 6, 0)),
            *leds,
        ]
    )


@icon("fishbowl")
def fishbowl():
    bowl = Point(12, 13).buffer(8.5)
    opening = scale(Point(12, 5.2).buffer(4), 1, 0.38)
    body = bowl.union(opening.convex_hull).difference(rect(0, 0, 24, 5.2))
    fish = Polygon(
        [(7.5, 14), (11.5, 11.5), (14.5, 14), (11.5, 16.5), (7.5, 14)]
    ).union(Polygon([(14.5, 14), (17.5, 11.5), (17.5, 16.5)]))
    return Icon([body.exterior, opening.exterior, fish.boundary])


@icon("home")
def home():
    walls = (0, 0, 0, 6, 6, 4)
    roof = [
        face((0, 0, 4), (6, 0, 4), (6, 3, 7), (0, 3, 7)),
        face((0, 6, 4), (6, 6, 4), (6, 3, 7), (0, 3, 7)),
        face((6, 0, 4), (6, 6, 4), (6, 3, 7)),
    ]
    return Icon(
        [
            outline(*box_faces(*walls), *roof),
            line((6, 0, 4), (6, 3, 7), (6, 6, 4)),
            line((0, 6, 4), (6, 6, 4), (6, 0, 4)),
            line((6, 6, 4), (6, 6, 0)),
            line((6, 2.2, 0), (6, 2.2, 2.6), (6, 3.8, 2.6), (6, 3.8, 0)),
        ]
    )


@icon("floor-plan")
def floor_plan():
    floor = (0, 0, 0, 9, 9, 0.5)
    walls = [
        (0, 0, 0.5, 9, 0.6, 3.5),
        (0, 0.6, 0.5, 0.6, 9, 3.5),
        (4.5, 0.6, 0.5, 5.1, 4.5, 3.5),
    ]
    solids = box_faces(*floor) + [f for w in walls for f in box_faces(*w)]
    return Icon(
        [
            outline(*solids),
            line((0.6, 9, 0.5), (0.6, 9, 3.5)),
            line((9, 0.6, 0.5), (9, 0.6, 3.5)),
            line((0.6, 9, 0.5), (0.6, 0.6, 0.5), (9, 0.6, 0.5)),
            line((5.1, 0.6, 3.5), (5.1, 4.5, 3.5), (4.5, 4.5, 3.5)),
            line((5.1, 4.5, 3.5), (5.1, 4.5, 0.5)),
            line((9, 9, 0.5), (0, 9, 0.5)),
            line((9, 9, 0.5), (9, 0, 0.5)),
        ]
    )


@icon("timer")
def timer():
    dial = ring((0, 0, 0), 5)
    knob = line((0, 0, 0), (0, 0, 2.2))
    hand = line((0, 0, 0), (-3.4, -3.4, 0))
    return Icon(
        [dial.exterior, knob, hand, Point(iso((0, 0, 2.2))).buffer(0.5).exterior]
    )


@icon("calendar")
def calendar():
    page = (0, 0, 0, 0.6, 7, 7)
    rings = [line((0.3, y, 6.4), (0.3, y, 8)) for y in (2, 5)]
    header = line((0.6, 7, 5.2), (0.6, 0, 5.2))
    return Icon([outline(*box_faces(*page)), *corner(*page), header, *rings])


# Output -------------------------------------------------------------------------


def write_js(path):
    icons = {name: list(fn().paths()) for name, fn in ICONS.items()}
    with open(path, "w") as out:
        out.write(
            "const ICONS = " + json.dumps(icons, separators=(",", ":")) + ";\n"
            "window.customIcons = window.customIcons || {};\n"
            "window.customIcons.fp = {\n"
            "  getIcon: async (name) => {\n"
            '    const [path, secondaryPath] = ICONS[name] || ICONS.help || ["", ""];\n'
            '    return { path, secondaryPath, viewBox: "0 0 24 24" };\n'
            "  },\n"
            "  getIconList: async () => Object.keys(ICONS).map((name) => ({ name })),\n"
            "};\n"
        )


def write_sheet(path):
    sizes, cols = (14, 24, 48), 4
    cell_w, cell_h, head = 250, 74, 0
    themes = (("#1e1e2e", "#cdd6f4"), ("#eff1f5", "#4c4f69"))
    names = list(ICONS)
    rows = math.ceil(len(names) / cols)
    block = rows * cell_h
    parts = []
    for t, (bg, fg) in enumerate(themes):
        y0 = t * block
        parts.append(
            f'<rect x="0" y="{y0}" width="{cols * cell_w}" height="{block}" fill="{bg}"/>'
        )
        for i, name in enumerate(names):
            prim, sec = ICONS[name]().paths()
            x, y = (i % cols) * cell_w + 10, y0 + (i // cols) * cell_h + head
            parts.append(
                f'<text x="{x}" y="{y + 14}" fill="{fg}" font-family="Helvetica" font-size="12" opacity="0.7">{name}</text>'
            )
            for s in sizes:
                body = f'<path d="{prim}"/>' + (
                    f'<path d="{sec}" opacity="0.5"/>' if sec else ""
                )
                parts.append(
                    f'<g fill="{fg}" transform="translate({x} {y + 20 + (48 - s) / 2}) scale({s / SIZE})">{body}</g>'
                )
                x += s + 20
    with open(path, "w") as out:
        out.write(
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{cols * cell_w}" height="{2 * block}">{"".join(parts)}</svg>'
        )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("--sheet", action="store_true")
    args = ap.parse_args()
    (write_sheet if args.sheet else write_js)(args.out)


if __name__ == "__main__":
    main()
