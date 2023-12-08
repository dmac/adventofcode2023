const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Node = struct {
    name: []const u8,
    left: usize = 0,
    right: usize = 0,
};

pub fn main() !void {
    const lines = try util.file_lines(allocator, "08.txt");
    const dirs = lines[0];
    var nodes = std.ArrayList(Node).init(allocator);
    var indexes = std.StringHashMap(usize).init(allocator);
    for (lines[2..]) |line| {
        const parts = try util.tokenize(allocator, line, " =(,)");
        const node = Node{ .name = parts[0] };
        try nodes.append(node);
        try indexes.put(parts[0], nodes.items.len - 1);
    }
    for (lines[2..], 0..) |line, i| {
        const parts = try util.tokenize(allocator, line, " =(,)");
        nodes.items[i].left = indexes.get(parts[1]) orelse std.math.maxInt(usize);
        nodes.items[i].right = indexes.get(parts[2]) orelse std.math.maxInt(usize);
    }

    {
        var curr = nodes.items[indexes.get("AAA").?];
        var di: usize = 0;
        var steps: i64 = 0;
        while (true) {
            steps += 1;
            const next = switch (dirs[di]) {
                'L' => curr.left,
                'R' => curr.right,
                else => unreachable,
            };
            curr = nodes.items[next];
            if (std.mem.eql(u8, curr.name, "ZZZ")) {
                break;
            }
            di += 1;
            if (di == dirs.len) {
                di = 0;
            }
        }
        std.debug.print("{d}\n", .{steps});
    }

    {
        var anodes = std.ArrayList(Node).init(allocator);
        for (nodes.items) |node| {
            if (node.name[2] == 'A') {
                try anodes.append(node);
            }
        }
        var cycles = try allocator.alloc(i64, anodes.items.len);
        var i: usize = 0;
        outer: while (i < anodes.items.len) : (i += 1) {
            var di: usize = 0;
            var steps: i64 = 0;
            while (true) {
                if (anodes.items[i].name[2] == 'Z') {
                    cycles[i] = steps;
                    continue :outer;
                }
                steps += 1;
                const next = switch (dirs[di]) {
                    'L' => anodes.items[i].left,
                    'R' => anodes.items[i].right,
                    else => unreachable,
                };
                anodes.items[i] = nodes.items[next];
                di += 1;
                if (di == dirs.len) {
                    di = 0;
                }
            }
        }

        var lcm: i64 = cycles[0];
        i = 1;
        while (i < cycles.len) : (i += 1) {
            lcm = util.lcm(lcm, cycles[i]);
        }
        std.debug.print("{d}\n", .{lcm});
    }
}
