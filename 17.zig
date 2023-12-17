const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Point = util.Point(usize);

const Path = struct {
    ps: []Point,
    cost: usize,

    const Self = @This();

    fn compare(_: void, a: Self, b: Self) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

pub fn main() !void {
    const grid = try util.file_lines(allocator, "17.txt");
    var queue = std.PriorityQueue(Path, void, Path.compare).init(allocator, {});
    {
        var ps = try allocator.alloc(Point, 1);
        ps[0] = Point{ .row = 0, .col = 0 };
        try queue.add(.{ .ps = ps, .cost = 0 });
    }

    var i: usize = 0;
    while (queue.count() > 0) : (i += 1) {
        const path = queue.remove();
        const p: Point = path.ps[path.ps.len - 1];

        std.debug.print("{any}\n", .{path});

        if (i >= 10) break;

        if (p.row == grid.len - 1 and p.col == grid[0].len - 1) {
            std.debug.print("{d}", .{path.cost});
            break;
        }

        var nexts = std.ArrayList(Point).init(allocator);
        if (p.row > 0) {
            const north = Point{ .row = p.row - 1, .col = p.col };
            if (!in_slice(path.ps, north)) {
                try nexts.append(north);
            }
        }
        if (p.row < grid.len - 1) {
            const south = Point{ .row = p.row + 1, .col = p.col };
            if (!in_slice(path.ps, south)) {
                try nexts.append(south);
            }
        }
        if (p.col > 0) {
            const west = Point{ .row = p.row, .col = p.col - 1 };
            if (!in_slice(path.ps, west)) {
                try nexts.append(west);
            }
        }
        if (p.col < grid[0].len - 1) {
            const east = Point{ .row = p.row, .col = p.col + 1 };
            if (!in_slice(path.ps, east)) {
                try nexts.append(east);
            }
        }
        for (nexts.items) |next| {
            var ps = try allocator.alloc(Point, path.ps.len + 1);
            std.mem.copyForwards(Point, ps, path.ps);
            ps[ps.len - 1] = next;
            const nextpath = Path{
                .ps = ps,
                .cost = path.cost + grid[next.row][next.col] - '0',
            };
            try queue.add(nextpath);
            // std.debug.print("{any}\n", .{nextpath});
        }
    }
}

fn in_slice(s: []Point, e: Point) bool {
    for (s) |v| {
        if (std.meta.eql(v, e)) return true;
    }
    return false;
}
