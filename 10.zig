const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Tile = struct {
    row: usize,
    col: usize,
    start: bool = false,
    north: bool = false,
    south: bool = false,
    west: bool = false,
    east: bool = false,
    inside: bool = false,
};

pub fn main() !void {
    const lines = try util.file_lines(allocator, "10.txt");
    const grid = try parse_loop(lines);

    const steps = walk_grid(grid);
    var half_steps = @divTrunc(steps, 2);
    if (@mod(steps, 2) == 1) {
        half_steps += 1;
    }
    std.debug.print("{d}\n", .{half_steps});

    const insides = try fill_inside(grid);
    std.debug.print("{d}\n", .{insides});
}

const Direction = enum {
    none,
    north,
    south,
    west,
    east,
};

fn fill_inside(grid: [][]Tile) !i64 {
    var stack = std.ArrayList(*Tile).init(allocator);
    for (grid) |row| {
        for (row) |*tile| {
            if (tile.inside) {
                try stack.append(tile);
            }
        }
    }
    while (stack.items.len > 0) {
        const tile = stack.items[stack.items.len - 1];
        stack.shrinkRetainingCapacity(stack.items.len - 1);
        if (north_of(grid, tile.row, tile.col)) |t| {
            if (!in_loop(t) and !t.inside) {
                t.inside = true;
                try stack.append(t);
            }
        }
        if (south_of(grid, tile.row, tile.col)) |t| {
            if (!in_loop(t) and !t.inside) {
                t.inside = true;
                try stack.append(t);
            }
        }
        if (west_of(grid, tile.row, tile.col)) |t| {
            if (!in_loop(t) and !t.inside) {
                t.inside = true;
                try stack.append(t);
            }
        }
        if (east_of(grid, tile.row, tile.col)) |t| {
            if (!in_loop(t) and !t.inside) {
                t.inside = true;
                try stack.append(t);
            }
        }
    }
    var insides: i64 = 0;
    for (grid) |row| {
        for (row) |*tile| {
            if (tile.inside) {
                insides += 1;
            }
        }
    }
    return insides;
}

fn walk_grid(grid: [][]Tile) i64 {
    var tile: Tile = undefined;
    var from: Direction = .none;
    var steps: i64 = 0;
    outer: for (grid) |row| {
        for (row) |t| {
            if (t.start) {
                tile = t;
                break :outer;
            }
        }
    }
    var started = false;
    while (!tile.start or !started) {
        started = true;
        if (tile.north and from != .north) {
            tile = grid[tile.row - 1][tile.col];
            from = .south;
        } else if (tile.south and from != .south) {
            tile = grid[tile.row + 1][tile.col];
            from = .north;
        } else if (tile.west and from != .west) {
            tile = grid[tile.row][tile.col - 1];
            from = .east;
        } else if (tile.east and from != .east) {
            tile = grid[tile.row][tile.col + 1];
            from = .west;
        }
        steps += 1;

        // Whether we choose "left" or "right" as the inside is input-dependent.
        const left: bool = false;
        if (tile.north and tile.south) {
            if (from == .north) {
                if (left) {
                    if (east_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                } else {
                    if (west_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                }
            } else if (from == .south) {
                if (left) {
                    if (west_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                } else {
                    if (east_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                }
            }
        }
        if (tile.north and tile.west) {
            if ((from == .north and left) or (from == .west and !left)) {
                if (east_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
                if (south_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
            }
        }
        if (tile.north and tile.east) {
            if ((from == .east and left) or (from == .north and !left)) {
                if (south_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
                if (west_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
            }
        }
        if (tile.south and tile.west) {
            if ((from == .west and left) or (from == .south and !left)) {
                if (north_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
                if (east_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
            }
        }
        if (tile.south and tile.east) {
            if ((from == .south and left) or (from == .east and !left)) {
                if (west_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
                if (north_of(grid, tile.row, tile.col)) |t| {
                    t.inside = true;
                }
            }
        }
        if (tile.west and tile.east) {
            if (from == .west) {
                if (left) {
                    if (north_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                } else {
                    if (south_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                }
            } else if (from == .east) {
                if (left) {
                    if (south_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                } else {
                    if (north_of(grid, tile.row, tile.col)) |t| {
                        t.inside = true;
                    }
                }
            }
        }
    }
    return steps;
}

fn mark_inside(grid: [][]Tile, row: usize, col: usize, dir: Direction) void {
    _ = dir;
    _ = col;
    _ = row;
    _ = grid;
}

fn north_of(grid: [][]Tile, row: usize, col: usize) ?*Tile {
    if (row == 0) {
        return null;
    }
    const t = &grid[row - 1][col];
    if (in_loop(t)) {
        return null;
    }
    return t;
}

fn south_of(grid: [][]Tile, row: usize, col: usize) ?*Tile {
    if (row >= grid.len - 1) {
        return null;
    }
    const t = &grid[row + 1][col];
    if (in_loop(t)) {
        return null;
    }
    return t;
}

fn west_of(grid: [][]Tile, row: usize, col: usize) ?*Tile {
    if (col == 0) {
        return null;
    }
    const t = &grid[row][col - 1];
    if (in_loop(t)) {
        return null;
    }
    return t;
}

fn east_of(grid: [][]Tile, row: usize, col: usize) ?*Tile {
    if (col >= grid[row].len - 1) {
        return null;
    }
    const t = &grid[row][col + 1];
    if (in_loop(t)) {
        return null;
    }
    return t;
}

fn print_grid(grid: [][]Tile) void {
    for (grid) |row| {
        for (row) |tile| {
            if (tile.start) {
                std.debug.print("S", .{});
            } else if (tile.north and tile.south) {
                std.debug.print("┃", .{});
            } else if (tile.west and tile.east) {
                std.debug.print("━", .{});
            } else if (tile.north and tile.east) {
                std.debug.print("┗", .{});
            } else if (tile.north and tile.west) {
                std.debug.print("┛", .{});
            } else if (tile.south and tile.west) {
                std.debug.print("┓", .{});
            } else if (tile.south and tile.east) {
                std.debug.print("┏", .{});
            } else if (tile.inside) {
                std.debug.print("I", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn parse_loop(lines: []const []const u8) ![][]Tile {
    var grid = try allocator.alloc([]Tile, lines.len);
    for (lines, 0..) |line, row| {
        grid[row] = try allocator.alloc(Tile, line.len);
        for (grid[row], 0..) |*tile, col| {
            tile.* = Tile{
                .row = row,
                .col = col,
            };
        }
    }
    var sr: usize = 0;
    var sc: usize = 0;
    outer: for (lines, 0..) |line, row| {
        for (line, 0..) |c, col| {
            if (c == 'S') {
                sr = row;
                sc = col;
                break :outer;
            }
        }
    }
    var stile = &grid[sr][sc];
    {
        stile.start = true;
        var c: u8 = undefined;
        if (sr > 0) {
            c = lines[sr - 1][sc];
            if (c == '|' or c == '7' or c == 'F') {
                stile.north = true;
            }
        }
        if (sr < lines.len - 1) {
            c = lines[sr + 1][sc];
            if (c == '|' or c == 'J' or c == 'L') {
                stile.south = true;
            }
        }
        if (sc > 0) {
            c = lines[sr][sc - 1];
            if (c == '-' or c == 'L' or c == 'F') {
                stile.west = true;
            }
        }
        if (sc < lines[sr].len - 1) {
            c = lines[sr][sc + 1];
            if (c == '-' or c == 'J' or c == '7') {
                stile.east = true;
            }
        }
    }
    var stack = std.ArrayList(*Tile).init(allocator);
    try stack.append(stile);
    while (stack.items.len > 0) {
        var tile = stack.items[stack.items.len - 1];
        stack.shrinkRetainingCapacity(stack.items.len - 1);
        const c = lines[tile.row][tile.col];
        switch (c) {
            '|' => {
                tile.north = true;
                tile.south = true;
            },
            '-' => {
                tile.west = true;
                tile.east = true;
            },
            'L' => {
                tile.north = true;
                tile.east = true;
            },
            'J' => {
                tile.north = true;
                tile.west = true;
            },
            '7' => {
                tile.south = true;
                tile.west = true;
            },
            'F' => {
                tile.south = true;
                tile.east = true;
            },
            else => {},
        }
        if (tile.north) {
            const next = &grid[tile.row - 1][tile.col];
            if (!in_loop(next)) {
                try stack.append(next);
            }
        }
        if (tile.south) {
            const next = &grid[tile.row + 1][tile.col];
            if (!in_loop(next)) {
                try stack.append(next);
            }
        }
        if (tile.west) {
            const next = &grid[tile.row][tile.col - 1];
            if (!in_loop(next)) {
                try stack.append(next);
            }
        }
        if (tile.east) {
            const next = &grid[tile.row][tile.col + 1];
            if (!in_loop(next)) {
                try stack.append(next);
            }
        }
    }
    return grid;
}

fn in_loop(tile: *Tile) bool {
    return tile.north or tile.south or tile.west or tile.east;
}
