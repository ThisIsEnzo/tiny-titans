#!/usr/bin/env python3
"""Validates the committed habitat (src/Workspace/Habitat/*.model.json) for TT-P3-01.

Reads the shipped JSON, rasterises every collidable part into 1-stud cells and builds a walking graph
for a simplified baseline traversal profile: it can step or jump UP at most 3 studs, can drop down any
distance, needs 6 studs of headroom, and uses a fixed body footprint. It checks offline geometry
criteria such as reachability, return paths, route widths and landmarks.

It is NOT a simulation of the standard Roblox avatar and does not prove playability or fun. Real
collision, camera, avatar proportions, jump behaviour and traversal feel need Roblox Studio.
Usage: python3 tools/habitat/validate_habitat.py [--map]
"""
import json
import math
import os
import sys
from collections import deque

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
HAB = os.path.join(ROOT, "src", "Workspace", "Habitat")
HALF = 70
STEP = 3.0          # max step / jump up (the old arena used 3-stud steps)
HEAD = 6.0          # headroom needed to stand under something
BODY = 5.5          # body height that must be free
R_WIDE, R_NARROW = 3.0, 1.5
MAX_PARTS = 260
MAX_OPEN_RADIUS = 13.0  # studs: only the Nest (rim radius 14) is meant to be this open

failures = []


def check(name, ok, detail=""):
    print(("ok:   " if ok else "FAIL: ") + name + (f"  [{detail}]" if detail and not ok else ""))
    if not ok:
        failures.append(name)


class P:
    pass


def load_parts():
    parts = []
    for fn in sorted(os.listdir(HAB)):
        if not fn.endswith(".model.json"):
            continue
        data = json.load(open(os.path.join(HAB, fn)))
        assert data["className"] == "Folder", fn
        for ch in data["children"]:
            p = P()
            pr = ch["properties"]
            p.area, p.name, p.cls = fn[:-len(".model.json")], ch["name"], ch["className"]
            p.size = tuple(pr["Size"])
            cf = pr["CFrame"]["CFrame"]
            p.pos = tuple(cf["position"])
            m = cf["orientation"]  # rows
            p.cols = tuple(tuple(m[i][j] for i in range(3)) for j in range(3))
            p.shape = pr.get("Shape", "Block")
            p.collide = pr["CanCollide"]
            p.tags = pr.get("Tags", [])
            p.props = pr
            parts.append(p)
    return parts


def obb_interval(p, x, z):
    """Vertical extent of an oriented box above/below the point (x, z), or None."""
    lo, hi = -1e9, 1e9
    for axis in range(3):
        col = p.cols[axis]
        half = p.size[axis] / 2
        base = col[0] * (x - p.pos[0]) + col[2] * (z - p.pos[2]) - col[1] * p.pos[1]
        slope = col[1]  # local coordinate = base + slope * y
        if abs(slope) < 1e-9:
            if abs(base) > half:
                return None
        else:
            a, b = (-half - base) / slope, (half - base) / slope
            lo, hi = max(lo, min(a, b)), min(hi, max(a, b))
            if lo > hi:
                return None
    return (lo, hi) if lo < hi else None


def part_interval(p, x, z):
    if p.shape == "Ball":
        r = p.size[0] / 2
        d2 = (x - p.pos[0]) ** 2 + (z - p.pos[2]) ** 2
        if d2 >= r * r:
            return None
        dy = math.sqrt(r * r - d2)
        return (p.pos[1] - dy, p.pos[1] + dy)
    if p.shape == "Cylinder":
        axis = p.cols[0]
        r, half = p.size[1] / 2, p.size[0] / 2
        if abs(axis[1]) > 0.99:  # vertical
            if (x - p.pos[0]) ** 2 + (z - p.pos[2]) ** 2 >= r * r:
                return None
            return (p.pos[1] - half, p.pos[1] + half)
        assert abs(axis[1]) < 0.01, f"{p.name}: tilted cylinders are not supported"
        ax, az = axis[0], axis[2]
        dx, dz = x - p.pos[0], z - p.pos[2]
        along, perp = dx * ax + dz * az, abs(-dx * az + dz * ax)
        if abs(along) > half or perp >= r:
            return None
        dy = math.sqrt(r * r - perp * perp)
        return (p.pos[1] - dy, p.pos[1] + dy)
    return obb_interval(p, x, z)


def merge(intervals):
    intervals.sort()
    out = []
    for lo, hi in intervals:
        if out and lo <= out[-1][1] + 0.01:
            out[-1] = (out[-1][0], max(out[-1][1], hi))
        else:
            out.append((lo, hi))
    return out


def rasterise(parts):
    n = 2 * HALF
    cells = [[[] for _ in range(n)] for _ in range(n)]  # [i = x][j = z]
    for p in parts:
        if not p.collide:
            continue
        reach = max(p.size) * 1.8 + 2
        i0, i1 = max(0, int(p.pos[0] + HALF - reach)), min(n - 1, int(p.pos[0] + HALF + reach))
        j0, j1 = max(0, int(p.pos[2] + HALF - reach)), min(n - 1, int(p.pos[2] + HALF + reach))
        for i in range(i0, i1 + 1):
            for j in range(j0, j1 + 1):
                iv = part_interval(p, i - HALF + 0.5, j - HALF + 0.5)
                if iv is not None:
                    cells[i][j].append(iv)
    return [[merge(c) for c in row] for row in cells]


def standing_nodes(cells):
    nodes = {}
    n = 2 * HALF
    for i in range(n):
        for j in range(n):
            ivs = cells[i][j]
            for k, (lo, hi) in enumerate(ivs):
                above = ivs[k + 1][0] if k + 1 < len(ivs) else 1e9
                if above - hi >= HEAD:
                    nodes[(i, j, k)] = hi
    return nodes


def footprint(r):
    c = int(math.ceil(r))
    return [(di, dj) for di in range(-c, c + 1) for dj in range(-c, c + 1) if di * di + dj * dj <= r * r + 0.01]


def valid_for(cells, node, top, fp):
    i, j, _ = node
    n = 2 * HALF
    for di, dj in fp:
        a, b = i + di, j + dj
        if not (0 <= a < n and 0 <= b < n):
            return False
        for lo, hi in cells[a][b]:
            if hi > top + STEP + 0.01 and lo < top + BODY:
                return False
    return True


def build_graph(cells, nodes, radius):
    fp = footprint(radius)
    ok = {nd for nd, t in nodes.items() if valid_for(cells, nd, t, fp)}
    per_cell = {}
    for nd in ok:
        per_cell.setdefault((nd[0], nd[1]), []).append(nd)
    adj = {nd: [] for nd in ok}
    for nd in ok:
        i, j, _ = nd
        t = nodes[nd]
        for di in (-1, 0, 1):
            for dj in (-1, 0, 1):
                if di == 0 and dj == 0:
                    continue
                best = None
                for cand in per_cell.get((i + di, j + dj), []):
                    ct = nodes[cand]
                    if ct <= t + STEP + 0.01 and (best is None or ct > nodes[best]):
                        best = cand
                if best is not None:
                    adj[nd].append(best)
    return ok, adj


def bfs(starts, adj):
    seen = set(starts)
    queue = deque(starts)
    while queue:
        cur = queue.popleft()
        for nxt in adj.get(cur, ()):
            if nxt not in seen:
                seen.add(nxt)
                queue.append(nxt)
    return seen


def reverse(adj):
    rev = {nd: [] for nd in adj}
    for a, outs in adj.items():
        for b in outs:
            rev[b].append(a)
    return rev


def nearest(nodes_ok, nodes, x, z, h=None, tol=2.5, htol=1.5):
    """Standing node near world (x, z) (optionally near height h above floor top 0.5)."""
    ci, cj = int(math.floor(x + HALF)), int(math.floor(z + HALF))
    best, bd = None, 1e9
    r = int(math.ceil(tol))
    for di in range(-r, r + 1):
        for dj in range(-r, r + 1):
            for nd in nodes_ok_by_cell.get((ci + di, cj + dj), []):
                d = math.hypot(di, dj)
                if d > tol:
                    continue
                t = nodes[nd] - 0.5
                if h is not None and abs(t - h) > htol:
                    continue
                score = d + (abs(t - h) if h is not None else 0)
                if score < bd:
                    best, bd = nd, score
    return best


nodes_ok_by_cell = {}


def main():
    show_map = "--map" in sys.argv
    probes = [tuple(map(float, a.split(","))) for a in sys.argv if a.count(",") in (1, 2) and a[0] in "-0123456789"]
    parts = load_parts()
    byname = {p.name: p for p in parts}
    print(f"loaded {len(parts)} parts from {len(set(p.area for p in parts))} files")

    # --- static data checks -------------------------------------------------------------------
    check("unique part names across all files", len(byname) == len(parts))
    check(f"part count within mobile budget (<= {MAX_PARTS})", len(parts) <= MAX_PARTS, str(len(parts)))
    inside = all(abs(p.pos[0]) <= HALF + 4 and abs(p.pos[2]) <= HALF + 4 and all(s > 0 for s in p.size) for p in parts)
    check("all parts have positive sizes and lie inside the habitat bounds", inside)
    static = all(p.props["Anchored"] and p.props["Locked"] and p.props["CanTouch"] is False for p in parts)
    check("everything anchored, locked, no touch events", static)
    def det(c):
        (a, b, d), (e, f, g), (h, i, j) = c
        return a * (f * j - g * i) - b * (e * j - g * h) + d * (e * i - f * h)

    def orthonormal(c):
        dots = [sum(c[x][k] * c[y][k] for k in range(3)) for x in range(3) for y in range(x, 3)]
        return all(abs(d - (1.0 if x == y else 0.0)) < 1e-4 for d, (x, y) in zip(dots, [(x, y) for x in range(3) for y in range(x, 3)]))

    check("every orientation is a proper rotation (orthonormal, determinant +1)",
          all(orthonormal(p.cols) and abs(det(p.cols) - 1) < 1e-4 for p in parts))
    steep = []
    for p in parts:
        if p.shape == "Block" and p.collide and abs(p.cols[1][1]) < 0.9999:
            slope = math.degrees(math.acos(max(-1.0, min(1.0, p.cols[1][1]))))
            if slope > 32.0:
                steep.append(f"{p.name} {slope:.0f}")
    check("tilted ramps are no steeper than 32 degrees", not steep, ", ".join(steep))
    spawns = [p for p in parts if p.cls == "SpawnLocation"]
    check("at least 3 spawn pads (multiplayer)", len(spawns) >= 3, str(len(spawns)))
    check("spawn pads are neutral, enabled and without a forcefield timer", all(
        s.props["Neutral"] and s.props["Enabled"] and s.props["Duration"] == 0 for s in spawns))
    landmarks = [p for p in parts if "Landmark" in p.tags]
    check("at least 3 landmarks", len(landmarks) >= 3, str(len(landmarks)))
    check("boundary walls tagged", sum("HabitatBoundary" in p.tags for p in parts) == 4)
    check("Tank-space and glider-span tags reserved, no mandatory gate",
          any("TankNook" in p.tags for p in parts) and any("FutureGliderSpan" in p.tags for p in parts))

    # --- walking graph ------------------------------------------------------------------------
    cells = rasterise(parts)
    nodes = standing_nodes(cells)
    ok_n, adj_n = build_graph(cells, nodes, R_NARROW)
    ok_w, adj_w = build_graph(cells, nodes, R_WIDE)
    global nodes_ok_by_cell
    nodes_ok_by_cell = {}
    for nd in ok_n:
        nodes_ok_by_cell.setdefault((nd[0], nd[1]), []).append(nd)
    ok_wide_set = ok_w

    def node_at(x, z, h=None, wide=False, tol=2.5):
        nd = nearest(ok_n, nodes, x, z, h, tol)
        if nd is not None and wide and nd not in ok_wide_set:
            return None
        return nd

    spawn_nodes = []
    for s in spawns:
        nd = node_at(s.pos[0], s.pos[2], h=0.4, tol=1.0)
        check(f"{s.name} is a safe standing spot (wide body)", nd is not None and nd in ok_wide_set)
        if nd is not None:
            spawn_nodes.append(nd)
    reach_n = bfs(spawn_nodes, adj_n)
    reach_w = bfs([n for n in spawn_nodes if n in ok_wide_set], adj_w)
    rev_n = reverse(adj_n)
    rev_w = reverse(adj_w)
    home_n = bfs(spawn_nodes, rev_n)  # nodes that can walk back to a spawn
    home_w = bfs([n for n in spawn_nodes if n in ok_wide_set], rev_w)

    trapped = [nd for nd in reach_n if nd not in home_n]
    check("no reachable standing spot is a trap (all can return to the Nest)", not trapped, f"{len(trapped)} cells")

    # primary route (wide body = 6-stud corridor): waypoints in walking order
    route = [
        ("Nest east opening", -33, 45, None), ("Meadow trail", -22, 41, None), ("Meadow hub south of the Great Stump", 8, 44, None),
        ("Meadow trail toward Rock Garden", -22, 33, None), ("Rock Garden gate", -48, 4, None),
        ("Rock Garden passage (south)", -50, -10, None), ("Rock Garden passage (middle)", -42, -20, None),
        ("Rock Garden passage (north)", -35, -28, None), ("Rock Garden north exit", -27, -44, None),
        ("North lane (west)", -12, -46, None), ("North lane (middle)", 8, -48, None), ("North lane (east)", 26, -46, None),
        ("Giant Roots ground (north)", 28, -40, None), ("Giant Roots ground (middle)", 28, -28, None),
        ("Giant Roots arch gap", 35, -4, None), ("Giant Roots south of the arch", 35, 6, None),
        ("Meadow east", 28, 36, None), ("Nest north opening", -43.7, 32.7, None), ("Nest south-east opening", -36.7, 54.2, None),
    ]
    for label, x, z, h in route:
        nd = node_at(x, z, 0.0 if h is None else h, wide=True)  # the primary route is at ground level
        check(f"primary route (6-stud wide): {label}", nd is not None and nd in reach_w and nd in home_w)

    # alternatives
    alts = [
        ("Nest north lane to Rock Garden", -47, 18, None), ("Nest lowland lane (south edge)", -6, 60, None),
        ("Lowland lane, east end", 42, 56, None),
    ]
    for label, x, z, h in alts:
        nd = node_at(x, z, h, wide=True)
        check(f"alternative path (wide): {label}", nd is not None and nd in reach_w and nd in home_w)
    elevated = [
        ("Great Stump top (lookout)", 8, 26, 9.0), ("Rock terrace lookout", -54, -16, 6.0), ("Arch top", 31, -4, 10.0),
        ("Leaf platform 1", 33, -24, 10.0), ("Leaf platform 2 (on foot via ramp)", 60, -18, 10.0),
        ("Fallen leaf perch", 3, 50, 3.7),
    ]
    for label, x, z, h in elevated:
        nd = node_at(x, z, h, tol=3.0)
        check(f"optional elevated spot reachable on foot and back: {label}", nd is not None and nd in reach_n and nd in home_n)
    secret = [("Secret crack mouth", -44, -42, None), ("Secret crack middle", -44, -46, None), ("Dewdrop Glade", -44, -58, None)]
    for label, x, z, h in secret:
        nd = node_at(x, z, h, tol=2.5)
        check(f"secret route: {label} (narrow body)", nd is not None and nd in reach_n and nd in home_n)
    # the glider span must not be a walkable link, and the shortcut must save a long walk
    lp1 = node_at(33, -24, 10.0, tol=3.0)
    lp2 = node_at(60, -18, 10.0, tol=3.0)
    gap = abs(byname["LeafPlatform2"].pos[0] - 7 - byname["LeafPlatform1"].pos[0] - 8)
    check("leaf platforms 1 and 2 are separated by a 10-stud gap (glider span, not a walkway)", abs(gap - 10) < 0.1, str(gap))
    dist = {}
    if lp1 is not None and lp2 is not None:
        q = deque([lp1])
        dist[lp1] = 0
        while q:
            cur = q.popleft()
            for nx in adj_n[cur]:
                if nx not in dist:
                    dist[nx] = dist[cur] + 1
                    q.append(nx)
        walk = dist.get(lp2)
        check("walking from leaf platform 1 to 2 needs a detour of 35+ steps (a 10-stud glide would save it)", walk is not None and walk >= 35, str(walk))

    # tank nook: front door blocked by the static boulder, side door open
    nook_in = node_at(-31, 14, None, tol=1.5)
    check("Tank nook interior remains reachable through its side door", nook_in is not None and nook_in in reach_n)

    # multiplayer: open spaces around the pads and trail mouths
    wide_near_nest = sum(1 for nd in ok_wide_set if abs(nd[0] - HALF + 48) < 16 and abs(nd[1] - HALF - 46) < 16)
    check("Nest has plenty of wide standing room for several players", wide_near_nest > 300, str(wide_near_nest))

    # scale: tall objects exist
    tall = sorted((p.size[0] if p.shape == "Cylinder" else p.size[1], p.name) for p in landmarks)
    check("landmarks are oversized (at least three are 15+ studs tall)", sum(1 for h, _ in tall if h >= 15) >= 3, str(tall))

    # no huge empty spaces: largest circle with nothing taller than 1 stud inside (needs numpy and scipy)
    try:
        import numpy as np
        from scipy import ndimage
        n = 2 * HALF
        free = np.ones((n + 2, n + 2), dtype=bool)  # padded: the outside counts as solid
        free[0, :] = free[-1, :] = free[:, 0] = free[:, -1] = False
        for i in range(n):
            for j in range(n):
                if any(hi - 0.5 > 1.0 for lo, hi in cells[i][j]):
                    free[i + 1, j + 1] = False
        radius = float(ndimage.distance_transform_edt(free).max())
        check(f"no huge empty space: largest open circle radius is {radius:.1f} studs (limit {MAX_OPEN_RADIUS})", radius <= MAX_OPEN_RADIUS)
    except ImportError:
        print("skip: open-space check needs numpy and scipy (pip install numpy scipy)")

    stats = f"standing spots: narrow {len(ok_n)}, wide {len(ok_w)}; reachable narrow {len(reach_n)}, wide {len(reach_w)}"
    print(stats)
    for probe in probes:  # "x,z" or "x,z,h": widest body that can stand near that spot and is reachable
        px, pz = probe[0], probe[1]
        ph = probe[2] if len(probe) > 2 else None
        best = 0.0
        for r in (1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0):
            okr, _ = build_graph(cells, nodes, r)
            near = [nd for nd in okr if abs(nd[0] - HALF + 0.5 - px) <= 1.5 and abs(nd[1] - HALF + 0.5 - pz) <= 1.5 and nd in reach_n and (ph is None or abs(nodes[nd] - 0.5 - ph) <= 1.5)]
            if near:
                best = r
        print(f"probe ({px}, {pz}): widest reachable standing radius {best}")
    for arg in sys.argv:
        if arg.startswith("--crop="):  # --crop=x0,x1,z0,z1 : 1 stud per char, ground-layer reach marks
            x0, x1, z0, z1 = map(int, arg[7:].split(","))
            print(f"\ncrop x {x0}..{x1}, z {z0}..{z1}: digit = top height class (0:<=1.5 1:<=4.5 2:<=7.5 3:<=10.5 4:more), '.' ground reachable wide, ',' narrow, ' ' no")
            for zz in range(z0, z1):
                row = f"{zz:4d} "
                for xx in range(x0, x1):
                    ivs = cells[xx + HALF][zz + HALF]
                    top = max([hi - 0.5 for lo, hi in ivs], default=0)
                    ground = (xx + HALF, zz + HALF)
                    if top > 1.5:
                        row += str(min(4, int((top + 1.5) // 3)))
                    else:
                        gw = any(nd[0] == ground[0] and nd[1] == ground[1] and nodes[nd] - 0.5 < 1.0 for nd in reach_w)
                        gn = any(nd[0] == ground[0] and nd[1] == ground[1] and nodes[nd] - 0.5 < 1.0 for nd in reach_n)
                        row += "." if gw else ("," if gn else " ")
                print(row)
    if show_map:
        print_map(cells, parts, nodes, reach_n, reach_w, spawns)
    print("\nRESULT:", "FAILED " + str(len(failures)) if failures else "all checks passed")
    return 1 if failures else 0


def print_map(cells, parts, nodes, reach_n, reach_w, spawns):
    n = 2 * HALF
    reach_cells_n = {(nd[0], nd[1]) for nd in reach_n}
    reach_cells_w = {(nd[0], nd[1]) for nd in reach_w}
    marks = {}
    for s in spawns:
        marks.setdefault((int(s.pos[0] + HALF) // 2, int(s.pos[2] + HALF) // 2), "S")
    print("\nmap (2 studs per char; +X east, -Z north at top). Digits = top height class, '.' reachable wide, ',' narrow only")
    for jj in range(0, n // 2):
        row = ""
        for ii in range(0, n // 2):
            if (ii, jj) in marks:
                row += marks[(ii, jj)]
                continue
            top = 0.0
            for di in (0, 1):
                for dj in (0, 1):
                    for lo, hi in cells[2 * ii + di][2 * jj + dj]:
                        top = max(top, hi - 0.5)
            if top > 0.8:
                row += "#" if top >= 12 else str(min(9, int((top + 1.4) // 3)))
            else:
                a, b = (2 * ii, 2 * jj), (2 * ii + 1, 2 * jj + 1)
                if a in reach_cells_w or b in reach_cells_w:
                    row += "."
                elif a in reach_cells_n or b in reach_cells_n:
                    row += ","
                else:
                    row += " "
        print(row)


if __name__ == "__main__":
    sys.exit(main())
