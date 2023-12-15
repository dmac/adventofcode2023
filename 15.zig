const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const HashMap = struct {
    buckets: [256]?*Node = std.mem.zeroes([256]?*Node),
};

const Node = struct {
    label: []const u8,
    value: usize,
    next: ?*Node,
};

pub fn main() !void {
    const b = std.mem.trim(u8, try util.file_bytes(allocator, "15.txt"), &std.ascii.whitespace);
    var it = std.mem.tokenizeScalar(u8, b, ',');
    var part1: usize = 0;
    var map = HashMap{};
    while (it.next()) |s| {
        const h = hash(s);
        part1 += h;

        if (s[s.len - 1] == '-') {
            delete(&map, s[0 .. s.len - 1]);
        } else {
            const parts = try util.split(allocator, @constCast(s), "=");
            std.debug.assert(parts.len == 2);
            try insert(&map, parts[0], @intCast(try util.atoi(parts[1])));
        }
        // print_map(&map);
    }
    std.debug.print("{d}\n", .{part1});

    var part2: usize = 0;
    for (map.buckets, 0..) |np, i| {
        var j: usize = 0;
        var npp: ?*Node = np;
        while (npp) |p| {
            part2 += (1 + i) * (1 + j) * p.value;
            npp = p.next;
            j += 1;
        }
    }
    std.debug.print("{d}\n", .{part2});
}

fn hash(s: []const u8) usize {
    var h: usize = 0;
    for (s) |c| {
        h += c;
        h *= 17;
        h = @mod(h, 256);
    }
    return h;
}

fn print_map(map: *HashMap) void {
    for (map.buckets, 0..) |np, i| {
        if (np) |p| {
            std.debug.print("{d}:", .{i});
            var npp: ?*Node = p;
            while (npp) |pp| {
                std.debug.print(" {s} {d},", .{ pp.label, pp.value });
                npp = pp.next;
            }
            std.debug.print("\n", .{});
        }
    }
}

fn delete(map: *HashMap, label: []const u8) void {
    const bucket = hash(label);
    // std.debug.print("delete {s} (bucket={d})\n", .{ label, bucket });
    var prev: *?*Node = &map.buckets[bucket];
    var np: ?*Node = map.buckets[bucket];
    while (np) |p| : (np = p.next) {
        if (std.mem.eql(u8, p.label, label)) {
            prev.* = p.next;
            return;
        }
        prev = &prev.*.?.next;
    }
}

fn insert(map: *HashMap, label: []const u8, value: usize) !void {
    const bucket = hash(label);
    // std.debug.print("insert {s}={d} (bucket={d})\n", .{ label, value, bucket });
    var np: ?*Node = map.buckets[bucket];
    var last: ?*Node = null;
    while (np) |p| {
        if (std.mem.eql(u8, p.label, label)) {
            p.value = value;
            return;
        }
        np = p.next;
        last = p;
    }
    const node = try allocator.create(Node);
    node.*.label = label;
    node.*.value = value;
    node.*.next = null;
    if (last) |n| {
        n.next = node;
    } else {
        map.buckets[bucket] = node;
    }
}
