const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Point = util.Point(usize);

pub fn main() !void {
    const lines = try util.file_lines(allocator, "18.txt");
    const grid = try make_grid(lines);
    grid.grid[grid.origin.row][grid.origin.col] = true;

    var p = grid.origin;
    for (lines) |line| {
        const parts = try util.fields(allocator, line);
        const n: usize = @intCast(try util.atoi(parts[1]));
        if (parts[0][0] == 'U') {
            for (0..n) |_| {
                p.row -= 1;
                grid.grid[p.row][p.col] = true;
            }
        } else if (parts[0][0] == 'D') {
            for (0..n) |_| {
                p.row += 1;
                grid.grid[p.row][p.col] = true;
            }
        } else if (parts[0][0] == 'L') {
            for (0..n) |_| {
                p.col -= 1;
                grid.grid[p.row][p.col] = true;
            }
        } else if (parts[0][0] == 'R') {
            for (0..n) |_| {
                p.col += 1;
                grid.grid[p.row][p.col] = true;
            }
        } else {
            unreachable;
        }
    }

    p = Point{ .row = 1, .col = 1 };
    outer: while (true) : (p.row += 1) {
        p.col = 1;
        while (true) : (p.col += 1) {
            if (grid.grid[p.row][p.col] and grid.grid[p.row][p.col - 1]) {
                continue :outer;
            }
            if (!grid.grid[p.row][p.col] and grid.grid[p.row][p.col - 1]) {
                break :outer;
            }
        }
    }
    var queue = std.ArrayList(Point).init(allocator);
    try queue.append(p);
    while (queue.items.len > 0) {
        const q = queue.pop();
        if (q.row > 0 and !grid.grid[q.row - 1][q.col]) {
            try queue.append(Point{ .row = q.row - 1, .col = q.col });
        }
        if (q.row < grid.grid.len - 1 and !grid.grid[q.row + 1][q.col]) {
            try queue.append(Point{ .row = q.row + 1, .col = q.col });
        }
        if (q.col > 0 and !grid.grid[q.row][q.col - 1]) {
            try queue.append(Point{ .row = q.row, .col = q.col - 1 });
        }
        if (q.col < grid.grid[0].len and !grid.grid[q.row][q.col + 1]) {
            try queue.append(Point{ .row = q.row, .col = q.col + 1 });
        }
        grid.grid[q.row][q.col] = true;
    }

    var part1: usize = 0;
    for (grid.grid) |row| {
        for (row) |b| {
            if (b) {
                part1 += 1;
            }
        }
    }
    std.debug.print("{d}\n", .{part1});
    // print_grid(grid);
}

const Grid = struct {
    origin: Point,
    grid: [][]bool,
};

fn make_grid(lines: [][]u8) !Grid {
    var p = util.Point(i64){ .row = 0, .col = 0 };
    var min_row: i64 = 0;
    var max_row: i64 = 0;
    var min_col: i64 = 0;
    var max_col: i64 = 0;
    for (lines) |line| {
        const parts = try util.fields(allocator, line);
        const n = try util.atoi(parts[1]);
        switch (parts[0][0]) {
            'U' => p.row -= n,
            'D' => p.row += n,
            'L' => p.col -= n,
            'R' => p.col += n,
            else => unreachable,
        }
        min_row = @min(min_row, p.row);
        max_row = @max(max_row, p.row);
        min_col = @min(min_col, p.col);
        max_col = @max(max_col, p.col);
    }
    const num_rows = max_row - min_row + 1;
    const num_cols = max_col - min_col + 1;

    const origin = Point{
        .row = @intCast(-min_row),
        .col = @intCast(-min_col),
    };
    const grid = try allocator.alloc([]bool, @intCast(num_rows));
    for (grid) |*row| {
        row.* = try allocator.alloc(bool, @intCast(num_cols));
    }
    return .{
        .origin = origin,
        .grid = grid,
    };
}

fn print_grid(grid: Grid) void {
    for (grid.grid) |row| {
        for (row) |b| {
            if (b) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}
