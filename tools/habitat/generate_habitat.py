#!/usr/bin/env python3
"""Generates src/Workspace/Habitat/*.model.json (TT-P3-01 First Habitat greybox).

The layout lives in this file (one builder function per area); the generated Rojo model files are
committed and are what the place is built from. Re-run after changing the layout:

    python3 tools/habitat/generate_habitat.py
    python3 tools/habitat/validate_habitat.py

Everything is static, anchored, Locked, script-free geometry. No external assets.
Heights `h` are measured above the floor top (Y = 0.5); mandatory routes never step up more than 3.
"""
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from habitat_geometry import (  # noqa: E402
    FLOOR_TOP, columns_to_rows, ramp_frame, vertical_cylinder_columns, yaw_columns,
    yaw_for_look, yaw_for_x_axis,
)

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "src", "Workspace", "Habitat")
HALF = 70  # play area is X, Z in [-70, 70]


def rgb(r, g, b):
    return [round(r / 255, 4), round(g / 255, 4), round(b / 255, 4)]


# Palette (greybox but natural): one family per area so zones read at a glance.
C = {
    "grass": rgb(96, 142, 70), "grass_dark": rgb(66, 108, 54), "grass_light": rgb(128, 170, 84),
    "dirt": rgb(140, 108, 72), "straw": rgb(206, 178, 108), "twig": rgb(112, 82, 52),
    "bark": rgb(104, 72, 48), "bark_dark": rgb(78, 54, 38), "wood": rgb(150, 110, 70),
    "rock": rgb(124, 122, 118), "rock_dark": rgb(96, 96, 98), "rock_warm": rgb(140, 124, 108),
    "slate": rgb(88, 98, 108), "leaf": rgb(86, 160, 72), "leaf_light": rgb(132, 188, 84),
    "cap": rgb(196, 56, 52), "stem": rgb(236, 228, 210), "white": rgb(250, 250, 246),
    "water": rgb(110, 168, 210), "glow": rgb(96, 240, 200), "glow_soft": rgb(150, 255, 222),
    "acorn": rgb(150, 100, 56), "acorn_cap": rgb(110, 76, 48), "food": rgb(76, 255, 102),
}


class Part:
    def __init__(self, name, cls="Part", shape="Block", size=(1, 1, 1), pos=(0, 0, 0), cols=None,
                 material="SmoothPlastic", color=None, collide=True, transparency=0.0, tags=(),
                 extra=None, area=""):
        self.name, self.cls, self.shape = name, cls, shape
        self.size, self.pos = tuple(size), tuple(pos)
        self.cols = cols or yaw_columns(0)
        self.material, self.color = material, color or C["rock"]
        self.collide, self.transparency, self.tags = collide, transparency, list(tags)
        self.extra, self.area = extra or {}, area

    def to_json(self):
        props = {
            "Anchored": True,
            "CanCollide": self.collide,
            "CanTouch": False,
            "CanQuery": self.collide,
            "Locked": True,
            "Material": self.material,
            "Color": self.color,
            "Size": [round(v, 4) for v in self.size],
            "CFrame": {"CFrame": {
                "position": [round(v, 4) for v in self.pos],
                "orientation": [[round(v, 6) for v in row] for row in columns_to_rows(self.cols)],
            }},
            "TopSurface": "Smooth",
            "BottomSurface": "Smooth",
        }
        if self.shape != "Block":
            props["Shape"] = self.shape
        if self.transparency:
            props["Transparency"] = self.transparency
        if not self.collide:
            props["CastShadow"] = False
        props.update(self.extra)
        if self.tags:
            props["Tags"] = self.tags
        return {"name": self.name, "className": self.cls, "properties": props}


class Area:
    """One generated folder (one .model.json). Keeps part names unique."""

    def __init__(self, name):
        self.name, self.parts, self._names = name, [], set()

    def _add(self, part):
        assert part.name not in self._names, f"duplicate part name {part.name} in {self.name}"
        self._names.add(part.name)
        part.area = self.name
        self.parts.append(part)
        return part

    # --- primitives -------------------------------------------------------------------------
    def block(self, name, x, z, sx, sz, h, y0=0.0, yaw=0.0, **kw):
        """Box footprint sx (local X) by sz (local Z), height h, bottom y0 above the floor."""
        return self._add(Part(name, size=(sx, h, sz), pos=(x, FLOOR_TOP + y0 + h / 2, z),
                              cols=yaw_columns(yaw), **kw))

    def pillar(self, name, x, z, diameter, h, y0=0.0, **kw):
        return self._add(Part(name, shape="Cylinder", size=(h, diameter, diameter),
                              pos=(x, FLOOR_TOP + y0 + h / 2, z), cols=vertical_cylinder_columns(), **kw))

    def ball(self, name, x, z, diameter, hc, **kw):
        """Ball with its centre hc above the floor top."""
        return self._add(Part(name, shape="Ball", size=(diameter, diameter, diameter),
                              pos=(x, FLOOR_TOP + hc, z), **kw))

    def ramp(self, name, a, b, width, thick=1.0, **kw):
        """Ramp whose TOP surface runs from a=(x, z, h) to b=(x, z, h)."""
        p1 = (a[0], FLOOR_TOP + a[2], a[1])
        p2 = (b[0], FLOOR_TOP + b[2], b[1])
        cols, _along, normal, length = ramp_frame(p1, p2)
        mid = tuple((p1[i] + p2[i]) / 2 - normal[i] * thick / 2 for i in range(3))
        return self._add(Part(name, size=(width, thick, length), pos=mid, cols=cols, **kw))

    def strip(self, name, a, b, width, color, material="Ground", y=0.05):
        """Flat, non-colliding ground overlay (trail, puddle edge, ground tint) from a to b."""
        dx, dz = b[0] - a[0], b[1] - a[1]
        length = math.hypot(dx, dz)
        return self._add(Part(name, size=(length, 0.1, width), pos=((a[0] + b[0]) / 2, FLOOR_TOP + y, (a[1] + b[1]) / 2),
                              cols=yaw_columns(yaw_for_x_axis(dx, dz)), material=material, color=color,
                              collide=False))

    def disc(self, name, x, z, diameter, color, material="Sand", y=0.05, **kw):
        return self._add(Part(name, shape="Cylinder", size=(0.1, diameter, diameter), pos=(x, FLOOR_TOP + y, z),
                              cols=vertical_cylinder_columns(), material=material, color=color, collide=False, **kw))

    def food(self, name, x, z, h=0.0):
        """Existing FoodSpawn marker (FoodService spawns the pickup 2 studs above it)."""
        return self._add(Part(name, size=(3, 0.3, 3), pos=(x, FLOOR_TOP + h + 0.15, z), material="Neon",
                              color=[0.3, 1.0, 0.4], collide=False, tags=["FoodSpawn"]))

    def to_json(self):
        return {"className": "Folder", "children": [p.to_json() for p in self.parts]}


def polar(cx, cz, radius, degrees):
    """Point on a circle; angle 0 = east, 90 = north (-Z)."""
    a = math.radians(degrees)
    return (cx + radius * math.cos(a), cz - radius * math.sin(a))


# ============================================================================================
# Terrain: floor, boundary, ground tints
# ============================================================================================
def build_terrain():
    a = Area("Terrain")
    a.block("HabitatFloor", 0, 0, 140, 140, 1.0, y0=-1.0, material="Grass", color=C["grass"])
    # Boundary: tall opaque natural walls (hedge, cliff). Inner faces at +/-70, 50 studs tall.
    for name, x, z, sx, sz, color, mat in [
        ("CliffNorth", 0, -72, 148, 4, C["slate"], "Slate"),
        ("HedgeSouth", 0, 72, 148, 4, C["grass_dark"], "LeafyGrass"),
        ("CliffWest", -72, 0, 4, 140, C["rock_dark"], "Slate"),
        ("HedgeEast", 72, 0, 4, 140, C["grass_dark"], "LeafyGrass"),
    ]:
        a.block(name, x, z, sx, sz, 50, y0=0.0, material=mat, color=color, tags=["HabitatBoundary"])
    # Zone tints (visual only) so each area reads at a glance without a minimap.
    a.disc("TintMeadow", 4, 34, 74, C["grass_light"], material="Grass", y=0.03)
    a.disc("TintRockGarden", -46, -22, 56, C["rock_warm"], material="Pebble", y=0.04)
    a.disc("TintRoots", 46, -22, 52, C["bark_dark"], material="Ground", y=0.04)
    a.disc("TintHollow", -44, -60, 22, C["slate"], material="Slate", y=0.04)
    return a


# ============================================================================================
# A. Nest: safe starting area (south-west corner)
# ============================================================================================
NEST = (-48, 46)
NEST_RADIUS = 14


def build_nest():
    a = Area("Nest")
    cx, cz = NEST
    a.disc("StrawBed", cx, cz, 30, C["straw"], material="Fabric", y=0.06)
    # Twig rim: 10 segments, three left out as openings (east: main trail, north: Rock Garden
    # lane, south-east: lowland lane). Rim is 3.2 tall and only decorative: no gate, no hazard.
    openings = {0, 2, 9}
    for k in range(10):
        if k in openings:
            continue
        deg = 36 * k
        px, pz = polar(cx, cz, NEST_RADIUS, deg)
        tx, tz = math.sin(math.radians(deg)), math.cos(math.radians(deg))  # tangent
        a.block(f"NestRim{k + 1}", px, pz, 8.9, 2.2, 3.2, yaw=yaw_for_x_axis(tx, tz), material="Wood", color=C["twig"])
    # Loose twigs outside the rim (low, walkable over): scale cues.
    for i, (x, z, yaw) in enumerate([(-66, 54, 24), (-58, 64, -18), (-34, 64, 10), (-72 + 6, 36, 80)]):
        a.block(f"NestTwig{i + 1}", x, z, 13, 1.6, 1.6, yaw=yaw, material="Wood", color=C["twig"])
    # Spawn pads: three, so several players do not stack; they face the main (east) trail.
    look = yaw_for_look(54, -20)
    for i, (x, z) in enumerate([(cx - 4, cz - 4), (cx + 4, cz - 2), (cx, cz + 5)]):
        a._add(Part(f"NestSpawn{i + 1}", cls="SpawnLocation", size=(7, 0.4, 7), pos=(x, FLOOR_TOP + 0.2, z),
                    cols=yaw_columns(look), material="Fabric", color=C["straw"],
                    extra={"Neutral": True, "Enabled": True, "AllowTeamChangeOnTouch": False, "Duration": 0}))
    # Landmark: the Lone Dandelion, tall and pale so it is visible from the whole habitat (the way home).
    a.pillar("DandelionStem", -63, 36, 1.6, 22, material="Grass", color=C["leaf_light"], tags=["Landmark"])
    a.ball("DandelionPuff", -63, 36, 10, 24.5, material="Fabric", color=C["white"], transparency=0.12, collide=False)
    # First food, just outside the east opening and visible from the pads.
    a.food("NestFood", -30, 43)
    return a


def log(area, name, x, z, length, diameter, yaw=0.0, **kw):
    """Fallen log lying on the floor (cylinder along local X)."""
    return area._add(Part(name, shape="Cylinder", size=(length, diameter, diameter),
                          pos=(x, FLOOR_TOP + diameter / 2, z), cols=yaw_columns(yaw), **kw))


def trail(area, prefix, points, width=7):
    for i in range(len(points) - 1):
        area.strip(f"{prefix}{i + 1}", points[i], points[i + 1], width, C["dirt"], material="Ground", y=0.07)


# ============================================================================================
# B. Meadow: main exploration area (centre)
# ============================================================================================
def build_meadow():
    a = Area("Meadow")
    # Worn trails guide the eye: east trail (main) to the Great Stump and on toward the Roots; west
    # trail to the Rock Garden; a lowland lane along the south edge from the Nest.
    trail(a, "TrailEast", [(-34, 46), (-22, 41), (-8, 41), (8, 45), (24, 38), (32, 24), (34, 8)])
    trail(a, "TrailWest", [(-8, 41), (-22, 33), (-30, 20), (-30, 6)])
    trail(a, "TrailLane", [(-37, 54), (-24, 58), (-6, 60), (12, 60), (30, 63), (42, 56), (44, 44)], width=6)

    # Landmark 1: the Great Stump with a log ramp up its west side (optional lookout).
    a.pillar("GreatStump", 8, 26, 22, 9, material="Wood", color=C["wood"], tags=["Landmark"])
    a.ramp("StumpLogRamp", (-26, 26, 0.0), (-3, 26, 9.0), 7, 1.2, material="Wood", color=C["bark"])
    for i, (x, z, yaw) in enumerate([(19, 33, 30), (-3, 37, -25), (21, 17, -60)]):
        a.block(f"StumpRootHump{i + 1}", x, z, 9, 4, 2.4, yaw=yaw, material="Wood", color=C["bark"])

    # Fallen leaf: a gentle ramp resting on a pebble; an optional low perch with a pickup.
    a.ramp("FallenLeaf", (-12, 50, 0.4), (4, 50, 3.8), 9, 0.6, material="LeafyGrass", color=C["leaf"])
    a.block("LeafPebble", 3, 50, 7, 5, 2.2, material="Rock", color=C["rock_warm"])

    # Puddle (decor, shallow and harmless) with a ring of pebbles: a scale cue.
    a.block("Puddle", -12, 12, 18, 11, 0.12, y0=0.0, yaw=20, material="Glass", color=C["water"],
            transparency=0.35, collide=False)
    for i, (x, z, s, h) in enumerate([(-21, 9, 3.5, 1.8), (-19, 17, 3, 1.4), (-5, 6, 4, 2.2), (-3, 15, 2.6, 1.2)]):
        a.block(f"PuddlePebble{i + 1}", x, z, s, s, h, yaw=i * 37, material="Rock", color=C["rock"])

    # Giant acorn (half buried): an oversized object and a sheltered corner.
    a.ball("Acorn", 26, 52, 12, 4.5, material="Wood", color=C["acorn"])
    a.pillar("AcornCap", 26, 52, 11, 3, y0=7.5, material="Wood", color=C["acorn_cap"])

    # Stepping stones (low, climbable): reasons to leave the trail.
    for i, (x, z, sx, sz, h, yaw) in enumerate([(-18, 28, 5, 4, 2.4, 20), (20, 12, 6, 5, 3.0, -10),
                                                  (30, 30, 4, 4, 2.0, 35), (-3, 13, 5, 5, 3.0, 40),
                                                  (14, 54, 5, 4, 2.6, -15)]):
        a.block(f"StepStone{i + 1}", x, z, sx, sz, h, yaw=yaw, material="Rock", color=C["rock_warm"])

    # Landmark 2: the Red Toadstool, a walk-under silhouette at the north edge of the Meadow.
    a.pillar("ToadstoolStem", -4, -6, 5, 9, material="Fabric", color=C["stem"])
    a.pillar("ToadstoolCap", -4, -6, 17, 2.5, y0=9, material="Fabric", color=C["cap"], tags=["Landmark"])
    for i, (dx, dz) in enumerate([(-4, -2), (3, -4), (4, 3), (-2, 4), (0, 0)]):
        a.disc(f"ToadstoolSpot{i + 1}", -4 + dx, -6 + dz, 2.2, C["white"], material="SmoothPlastic", y=11.55)

    # Giant grass blades (non-colliding): scale cues at the edges.
    for i, (x, z, h) in enumerate([(-34, 63, 16), (-31, 65, 20), (-28, 62, 13), (32, 62, 17), (35, 65, 21), (38, 61, 14),
                                   (60, 54, 18), (63, 57, 15), (-20, -6, 17), (-17, -9, 13), (22, -6, 16), (25, -3, 19)]):
        a.block(f"GrassBlade{i + 1}", x, z, 0.9, 0.35, h, yaw=i * 29, material="Grass", color=C["grass_dark"], collide=False)

    # South-east: the Mushroom Grove (shaded walk-under caps with 6.5 studs of headroom) and a berry bramble.
    for i, (x, z, stem_h, cap_d) in enumerate([(44, 34, 6.5, 11), (56, 40, 7.5, 13), (64, 30, 6.5, 11), (50, 52, 7.0, 12), (62, 58, 6.5, 11)]):
        a.pillar(f"GroveStem{i + 1}", x, z, 3, stem_h, material="Fabric", color=C["stem"])
        a.pillar(f"GroveCap{i + 1}", x, z, cap_d, 1.6, y0=stem_h, material="Fabric", color=C["cap"] if i % 2 == 0 else C["acorn"])
    for i, (x, z) in enumerate([(56, 47), (60, 50), (63, 45), (59, 54)]):
        a.ball(f"Berry{i + 1}", x, z, 5.2, 2.6, material="SmoothPlastic", color=rgb(120, 52, 130) if i % 2 else rgb(176, 48, 70))

    # East: a clover hill of two 3-stud steps (a lookout toward the Roots), and a boulder between the south-west trails.
    a.block("CloverHill1", 38, 16, 14, 10, 3.0, yaw=10, material="Grass", color=C["grass_dark"])
    a.block("CloverHill2", 40, 15, 7, 6, 6.0, yaw=10, material="Grass", color=C["grass_dark"])
    a.block("MeadowBoulder1", -20, 51, 7, 6, 5.0, yaw=30, material="Rock", color=C["rock_warm"])

    # Pickups: scattered along the trails and optional detours, not on a grid.
    a.food("MeadowFood1", -14, 41)       # on the trail, first reward
    a.food("MeadowFood2", 3, 50, 3.7)    # on the fallen leaf
    a.food("MeadowFood3", 8, 26, 9.0)    # stump top (lookout)
    a.food("MeadowFood4", 34, 47)        # beside the acorn
    a.food("MeadowFood5", 28, 20)        # off the trail toward the Roots
    a.food("MeadowFood6", -10, 20)       # puddle edge, between the trails
    a.food("MeadowFood8", 40, 15, 6.0)   # clover hill top
    a.food("MeadowFood7", 52, 44)        # inside the Mushroom Grove, a detour from the east trail
    return a


def rock(area, name, x, z, sx, sz, h, yaw=0.0, color=None, y0=0.0, **kw):
    return area.block(name, x, z, sx, sz, h, y0=y0, yaw=yaw, material="Rock", color=color or C["rock"], **kw)


# ============================================================================================
# C. Rock Garden: obstacles, shelter and elevation (north-west)
# ============================================================================================
def build_rock_garden():
    a = Area("RockGarden")
    trail(a, "RGTrail", [(-46, 32), (-48, 18), (-48, 4), (-50, -10), (-42, -20), (-35, -28), (-27, -44)], width=6)
    # Gate rocks frame the southern entrance (a wide, readable doorway).
    rock(a, "GateRockW", -59, 0, 9, 11, 9, 10)
    rock(a, "GateRockE", -37, 1, 9, 10, 8, -12)
    # Main passage walls (S-curve), wide enough for several players side by side.
    rock(a, "WallW1", -62, -16, 12, 14, 12, 6)
    rock(a, "WallW2", -58, -30, 10, 10, 10, -8)
    rock(a, "WallW3", -64, -42, 12, 12, 13, 12)
    rock(a, "WallE1", -33, -12, 9, 14, 10, 8)
    rock(a, "WallE2", -26, -30, 9, 13, 11, -10)
    rock(a, "WallE3", -14, -57, 10, 8, 9, 4)  # closes the clearing's north-west corner, leaves the lane open
    # Terrace stairs to a lookout (3-stud steps), a vantage over the passage.
    rock(a, "TerraceStep1", -52, -14, 8, 8, 3.0, 0, color=C["rock_warm"])
    rock(a, "TerraceStep2", -54, -16, 5, 6, 6.0, 0, color=C["rock_warm"])
    # Shelter den: roofed alcove (interior 8x8, 7 studs of headroom) opening east.
    rock(a, "DenBack", -57, -26, 2, 10, 8, 0)
    rock(a, "DenSouth", -52, -21, 10, 2, 8, 0)
    rock(a, "DenNorth", -52, -31, 10, 2, 8, 0)
    rock(a, "DenRoof", -52, -26, 12, 12, 1.5, y0=7.0, color=C["rock_dark"])
    # Tank nook (future): an alcove whose front door is blocked by a loose boulder (static for now);
    # the baseline form uses the narrow side door, so nothing is gated.
    rock(a, "NookBack", -36, 14, 2, 9, 7, 0, tags=["TankNook"])
    rock(a, "NookNorth", -31, 9.5, 10, 2, 7, 0)
    rock(a, "NookSouth", -33.5, 18.5, 3, 2, 7, 0)  # shortened: leaves a 6-stud side door (x -32 to -26)
    rock(a, "NookBoulder", -24.5, 14, 5, 5, 5, 20, color=C["rock_dark"], tags=["TankNook", "FutureTankPush"])
    # The screening rock hiding the secret crack (see build_secret) stands at the north end of the passage.
    rock(a, "ScreenRock", -44, -31, 9, 5, 9, 0, color=C["rock_dark"])
    # Boulders and a leaning twig on the strip between the Nest and the gate: cover, and a route choice.
    rock(a, "WestRock1", -60, 22, 7, 6, 5, 25)
    rock(a, "WestRock2", -56, 11, 6, 6, 3.5, -10, color=C["rock_warm"])
    rock(a, "WestRock3", -64, 6, 6, 7, 6, 40)
    # Pickups
    a.food("RockFood1", -47, 6)           # near the gate: invites the player in
    a.food("RockFood2", -54, -16, 6.0)    # terrace lookout
    a.food("RockFood3", -53, -26)         # inside the den
    a.food("RockFood4", -30, 14)          # inside the Tank nook (side door)
    return a


# ============================================================================================
# D. Giant Roots: vertical traversal (east / north-east)
# ============================================================================================
def build_giant_roots():
    a = Area("GiantRoots")
    trail(a, "RootsTrail", [(28, -40), (28, -26), (31, -12), (35, -2), (34, 8)], width=7)
    # Landmark 3: the Old Tree trunk (huge; the silhouette to the north-east) and its flare roots.
    a.pillar("OldTreeTrunk", 54, -40, 26, 70, material="Wood", color=C["bark_dark"], tags=["Landmark"])
    for i, (x, z, sx, sz, h, yaw) in enumerate([(44, -31, 14, 6, 6, 20), (62, -24, 14, 6, 5, -35)]):
        a.block(f"FlareRoot{i + 1}", x, z, sx, sz, h, yaw=yaw, material="Wood", color=C["bark"])
    # Root arch: a walk-through gateway (8 studs wide, 7 studs of headroom) with an elevated top.
    a.block("ArchLegW", 28.5, -4, 5, 7, 7, material="Wood", color=C["bark"])
    a.block("ArchLegE", 41.5, -4, 5, 7, 7, material="Wood", color=C["bark"])
    a.block("ArchBeam", 35, -4, 18, 7, 3, y0=7, material="Wood", color=C["bark"], tags=["Landmark"])
    # Elevated route (optional): ramp up to the arch top, a root bridge to the first leaf platform, and a
    # ramp down on the north side. Ground-level alternatives always remain.
    a.ramp("RootRampArch", (62, 8, 0.0), (44, -4, 10.0), 7, 1.5, material="Wood", color=C["bark"])
    a.ramp("RootBridge", (35, -7.5, 10.0), (35, -17, 10.0), 6, 1.5, material="Wood", color=C["bark"])
    a.block("LeafPlatform1", 35, -24, 16, 11, 0.8, y0=9.2, material="LeafyGrass", color=C["leaf"])
    a.pillar("LeafStalk1", 35, -24, 3.5, 9.2, material="Wood", color=C["bark_dark"])
    a.ramp("LeafRampNorth", (35, -29.5, 10.0), (35, -50, 0.0), 6, 1.2, material="LeafyGrass", color=C["leaf_light"])
    # Glider span (future): a second platform 10 studs away across a gap. It is also reachable on foot by
    # RootRampEast, so the gap is only a shortcut and a place to try gliding later.
    a.block("LeafPlatform2", 60, -18, 14, 10, 0.8, y0=9.2, material="LeafyGrass", color=C["leaf"], tags=["FutureGliderSpan"])
    a.pillar("LeafStalk2", 60, -18, 3.5, 9.2, material="Wood", color=C["bark_dark"])
    a.ramp("RootRampEast", (66, 4, 0.0), (62, -13, 10.0), 6, 1.2, material="Wood", color=C["bark"])
    # Ground roots for a short slalom on the open route.
    for i, (x, z, sx, sz, h, yaw) in enumerate([(46, -8, 10, 4, 5, 40), (47, -24, 8, 4, 6, -30), (22, -30, 8, 4, 3, 10)]):
        a.block(f"GroundRoot{i + 1}", x, z, sx, sz, h, yaw=yaw, material="Wood", color=C["bark"])
    # Shelf-fungus steps up the trunk's north side: 3-stud steps to a 9-stud vantage (optional).
    for i, (x, z, h) in enumerate([(45.1, -52.7, 3.0), (54.0, -55.5, 6.0), (62.9, -52.7, 9.0)]):
        a.pillar(f"FungusStep{i + 1}", x, z, 12, h, material="Fabric", color=C["acorn"] if i % 2 == 0 else C["cap"])
    # Seed pods and bramble stones fill the north strip with cover and scale.
    for i, (x, z) in enumerate([(30, -60), (37, -64), (26, -66)]):
        a.ball(f"SeedPod{i + 1}", x, z, 8, 3.2, material="Fabric", color=rgb(150, 160, 84))
    for i, (x, z, sx, sz, h, yaw) in enumerate([(22, -56, 6, 5, 3.0, 20), (34, -56, 5, 5, 2.4, -30)]):
        a.block(f"BrambleStone{i + 1}", x, z, sx, sz, h, yaw=yaw, material="Rock", color=C["rock_warm"])
    a.food("RootFood6", 63, -53, 9.0)      # fungus-step vantage
    a.food("RootFood1", 36, 1)             # just before the arch
    a.food("RootFood2", 31, -4, 10.0)      # arch top
    a.food("RootFood3", 32, -24, 10.0)     # first leaf platform
    a.food("RootFood4", 60, -18, 10.0)     # second leaf platform (walkable via RootRampEast)
    a.food("RootFood5", 30, -42)           # ground, at the foot of the trunk
    return a


# ============================================================================================
# E. Secret: the crack and the Dewdrop Glade (north-west, hidden behind the Rock Garden)
# ============================================================================================
def build_secret():
    a = Area("Secret")
    # Crack: 5 studs wide, 12 long, between two rock masses; a screening rock hides its mouth.
    rock(a, "CrackMassW", -51.25, -44, 9.5, 12, 14, 0, color=C["rock_dark"])
    rock(a, "CrackMassE", -36.75, -44, 9.5, 12, 14, 0, color=C["rock_dark"])
    # Glade: an open pocket (22 studs wide) behind the crack; ring walls on the sides, the north boundary wall behind it.
    rock(a, "GladeWallW", -56.5, -59.5, 3, 19, 12, 0, color=C["rock_dark"])
    rock(a, "GladeWallE", -31.5, -59.5, 3, 19, 12, 0, color=C["rock_dark"])
    rock(a, "GladeShelf", -38, -66, 6, 5, 3, 15, color=C["rock_warm"])  # a low rock to sit on, out of the way
    # Clues outside: glowing mushrooms along the approach (see also the beam).
    for i, (x, z) in enumerate([(-50, -34), (-46, -36), (-43, -33)]):
        a.pillar(f"ClueStem{i + 1}", x, z, 0.8, 1.6, material="Fabric", color=C["stem"], collide=False)
        a.ball(f"ClueCap{i + 1}", x, z, 2.2, 1.9, material="Neon", color=C["glow"], collide=False)
    # Reward: the Dewdrop on its leaf, ringed by glowing mushrooms, and the beam that can be seen from afar.
    a.disc("DewLeaf", -44, -62, 10, C["leaf_light"], material="LeafyGrass", y=0.08)
    a.ball("Dewdrop", -44, -62, 5, 2.7, material="Glass", color=C["water"], transparency=0.25, tags=["Landmark"])
    for i in range(6):
        px, pz = polar(-44, -62, 7.5, 60 * i + 20)
        a.pillar(f"GladeStem{i + 1}", px, pz, 1.0, 2.5, material="Fabric", color=C["stem"], collide=False)
        a.ball(f"GladeCap{i + 1}", px, pz, 3.0, 2.9, material="Neon", color=C["glow"], collide=False)
    a.pillar("DewBeam", -44, -62, 3, 44, material="Neon", color=C["glow_soft"], transparency=0.72, collide=False)
    a.food("SecretFood1", -44, -46)
    a.food("SecretFood2", -44, -57)
    return a


def build_north_clearing(a):
    """North clearing and lane (added to the Meadow folder): connects the Rock Garden exit and the Roots."""
    trail(a, "TrailNorth", [(-27, -44), (-12, -46), (8, -48), (24, -46), (28, -40)], width=7)
    log(a, "HollowLog", 4, -34, 24, 8, yaw=6, material="Wood", color=C["bark"], tags=["Landmark"])
    for i, (x, z, sx, sz, h, yaw) in enumerate([(-14, -24, 6, 5, 3.0, 25), (14, -20, 5, 5, 2.6, -20), (-8, -38, 5, 4, 2.2, 60),
                                                  (18, -42, 6, 5, 3.0, 15)]):
        a.block(f"ClearingStone{i + 1}", x, z, sx, sz, h, yaw=yaw, material="Rock", color=C["rock_warm"])
    # Sleeping snail shell (landmark) and pebble cairns: cover and silhouettes in the middle of the clearing.
    a.ball("SnailShell", -12, -24, 12, 4.5, material="SmoothPlastic", color=rgb(196, 140, 84), tags=["Landmark"])
    a.ball("SnailShellCore", -12, -24, 7, 7.2, material="SmoothPlastic", color=rgb(150, 98, 60))
    for i, (x, z, h) in enumerate([(14, -8, 8), (-20, -12, 7), (-1, -22, 9)]):
        a.pillar(f"Cairn{i + 1}", x, z, 5, h, material="Rock", color=C["rock_warm"])
        a.ball(f"CairnTop{i + 1}", x, z, 3.2, h + 1.2, material="Rock", color=C["rock"])
    for i, (x, z, sx, sz, h, yaw) in enumerate([(4, -60, 8, 6, 6.0, 15), (-8, -63, 6, 6, 4.0, -25), (14, -64, 7, 5, 5.0, 40)]):
        a.block(f"NorthBoulder{i + 1}", x, z, sx, sz, h, yaw=yaw, material="Rock", color=C["rock_warm"])
    a.food("NorthFood3", 4, -66)   # tucked behind the boulders: a short detour off the lane
    a.food("NorthFood1", -6, -46)
    a.food("NorthFood2", 12, -38)


def build_all():
    meadow = build_meadow()
    build_north_clearing(meadow)
    return [build_terrain(), build_nest(), meadow, build_rock_garden(), build_giant_roots(), build_secret()]


def main():
    os.makedirs(OUT, exist_ok=True)
    for stale in os.listdir(OUT):
        if stale.endswith(".model.json"):
            os.remove(os.path.join(OUT, stale))
    total = 0
    for area in build_all():
        path = os.path.join(OUT, f"{area.name}.model.json")
        with open(path, "w", newline="\n") as handle:
            json.dump(area.to_json(), handle, indent=2)
            handle.write("\n")
        total += len(area.parts)
        print(f"{area.name}: {len(area.parts)} parts")
    print(f"total parts: {total}")


if __name__ == "__main__":
    main()
