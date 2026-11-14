"""Small geometry helpers shared by the habitat generator and validator.

Coordinates are Roblox studs: +X east, -Z north, +Y up. `h` values are heights above the floor top
(FLOOR_TOP). Rotations are 3x3 matrices stored as three COLUMN vectors (right, up, back), the same
convention as Roblox CFrame components, so Rojo's `orientation` rows are M[i][j] = column_j[i].
"""
import math

FLOOR_TOP = 0.5  # top of the habitat floor slab (same as the old arena)


def normalize(v):
    n = math.sqrt(sum(c * c for c in v))
    return tuple(c / n for c in v)


def cross(a, b):
    return (a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0])


def yaw_columns(yaw_degrees):
    """Rotation about +Y (CFrame.Angles(0, yaw, 0)) as columns."""
    c, s = math.cos(math.radians(yaw_degrees)), math.sin(math.radians(yaw_degrees))
    return ((c, 0.0, -s), (0.0, 1.0, 0.0), (s, 0.0, c))


def yaw_for_x_axis(dx, dz):
    """Yaw (degrees) that turns a part's local +X axis toward the horizontal direction (dx, dz)."""
    return math.degrees(math.atan2(-dz, dx))


def yaw_for_look(dx, dz):
    """Yaw (degrees) that makes a part's LookVector (-Z local) point along (dx, dz)."""
    return math.degrees(math.atan2(-dx, -dz))


def vertical_cylinder_columns():
    """Roblox cylinders run along local X; rotate 90 degrees about Z so the axis is vertical."""
    return ((0.0, 1.0, 0.0), (-1.0, 0.0, 0.0), (0.0, 0.0, 1.0))


def columns_to_rows(cols):
    return [[cols[j][i] for j in range(3)] for i in range(3)]


def ramp_frame(p1, p2):
    """Frame for a ramp whose top surface runs from p1 to p2 (each (x, y, z) in world studs).

    Local axes: X = width (horizontal), Y = thickness (the normal, pointing up), Z = along the ramp.
    Returns (columns, unit_along, unit_normal, length).
    """
    along = normalize((p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]))
    right = normalize(cross((0.0, 1.0, 0.0), along))
    normal = cross(along, right)
    length = math.dist(p1, p2)
    return (right, normal, along), along, normal, length
