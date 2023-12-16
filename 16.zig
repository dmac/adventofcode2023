const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Direction = enum(u8) {
    north = 1 << 0,
    south = 1 << 1,
    west = 1 << 2,
    east = 1 << 3,
};

const Beam = struct {
    p: util.Point(usize),
    d: Direction,
};

const EnergizedMap = std.AutoHashMap(util.Point(usize), u8);

pub fn main() !void {
    const grid = try util.file_lines(allocator, "16.txt");
    const part1 = try simulate(grid, Beam{ .p = .{ .row = 0, .col = 0 }, .d = .east });
    std.debug.print("{d}\n", .{part1});

    var part2: usize = 0;
    for (0..grid[0].len) |c| {
        const n = Beam{ .p = .{ .row = 0, .col = c }, .d = .south };
        part2 = @max(part2, try simulate(grid, n));
        const s = Beam{ .p = .{ .row = grid.len - 1, .col = c }, .d = .north };
        part2 = @max(part2, try simulate(grid, s));
    }
    for (0..grid.len) |r| {
        const w = Beam{ .p = .{ .row = r, .col = 0 }, .d = .east };
        part2 = @max(part2, try simulate(grid, w));
        const e = Beam{ .p = .{ .row = r, .col = grid[0].len - 1 }, .d = .west };
        part2 = @max(part2, try simulate(grid, e));
    }
    std.debug.print("{d}\n", .{part2});
}

fn simulate(grid: [][]u8, start: Beam) !usize {
    var energized = EnergizedMap.init(allocator);
    var beams = std.ArrayList(Beam).init(allocator);
    try beams.append(start);
    while (beams.items.len > 0) {
        var b = beams.items[beams.items.len - 1];
        beams.shrinkRetainingCapacity(beams.items.len - 1);

        if (energized.get(b.p)) |d| {
            const bd = @intFromEnum(b.d);
            if (d & bd > 0) {
                continue;
            }
            try energized.put(b.p, d | bd);
        } else {
            try energized.put(b.p, @intFromEnum(b.d));
        }

        const c = grid[b.p.row][b.p.col];
        if (c == '\\') {
            b.d = switch (b.d) {
                .north => .west,
                .south => .east,
                .west => .north,
                .east => .south,
            };
        } else if (c == '/') {
            b.d = switch (b.d) {
                .north => .east,
                .south => .west,
                .west => .south,
                .east => .north,
            };
        } else if (c == '-' and (b.d == .north or b.d == .south)) {
            try beams.append(.{ .p = b.p, .d = .west });
            try beams.append(.{ .p = b.p, .d = .east });
            continue;
        } else if (c == '|' and (b.d == .west or b.d == .east)) {
            try beams.append(.{ .p = b.p, .d = .north });
            try beams.append(.{ .p = b.p, .d = .south });
            continue;
        }

        if (b.d == .north) {
            if (b.p.row == 0) continue;
            b.p.row -= 1;
        } else if (b.d == .south) {
            if (b.p.row == grid.len - 1) continue;
            b.p.row += 1;
        } else if (b.d == .west) {
            if (b.p.col == 0) continue;
            b.p.col -= 1;
        } else if (b.d == .east) {
            if (b.p.col == grid[0].len - 1) continue;
            b.p.col += 1;
        }
        try beams.append(b);
    }
    return energized.count();
}

fn print_energized(grid: []const []const u8, energized: *EnergizedMap) void {
    for (0..grid.len) |r| {
        for (0..grid[0].len) |c| {
            const p = util.Point(usize){ .row = r, .col = c };
            if (energized.contains(p)) {
                std.debug.print("#", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
}
