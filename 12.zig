const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Line = struct {
    s: []const u8,
    ns: []usize,
    vns: []usize,
};

pub fn main() !void {
    var perm = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const lines = try util.file_lines(perm.allocator(), "12.txt");
    var part1: i64 = 0;
    var part2: i64 = 0;
    for (lines) |line| {
        const l1 = try parse(line);
        part1 += try solve(l1, 0);
        const l2 = try unfold(l1);
        // std.debug.print("{s} {d}\n", .{ l2.s, l2.ns });
        part2 += try solve(l2, 0);
        _ = arena.reset(.free_all);
    }
    std.debug.print("{d}\n", .{part1});
    std.debug.print("{d}\n", .{part2});
}

fn unfold(line: Line) !Line {
    const s = try allocator.alloc(u8, line.s.len * 5 + 4);
    var li: usize = 0;
    for (s, 0..) |_, si| {
        if (li == line.s.len) {
            s[si] = '?';
            li = 0;
        } else {
            s[si] = line.s[li];
            li += 1;
        }
    }
    var ns = std.ArrayList(usize).init(allocator);
    for (0..5) |_| {
        try ns.appendSlice(line.ns);
    }
    const vns = try ns.toOwnedSlice();
    const l = Line{
        .s = s,
        .ns = vns,
        .vns = vns,
    };
    return l;
}

fn solve(line: Line, from: usize) !i64 {
    // std.debug.print("{s} {d} {d}\n", .{ line.s, line.ns, from });
    // for (0..from) |_| {
    //     std.debug.print(" ", .{});
    // }
    // std.debug.print("^\n", .{});

    if (line.ns.len == 0) {
        if (try verify(line)) {
            return 1;
        }
        return 0;
    }

    var rem_groups: usize = 0;
    var rem_groups_it = std.mem.tokenizeAny(u8, line.s[from..], ".");
    while (rem_groups_it.next()) |s| {
        // std.debug.print("{s} ", .{s});
        if (std.mem.containsAtLeast(u8, s, 1, "#")) {
            rem_groups += 1;
        }
    }
    // std.debug.print("\n\n", .{});
    if (rem_groups > line.ns.len) {
        return 0;
    }

    const n = line.ns[0];
    var sum: i64 = 0;
    var rest: usize = line.ns.len - 1;
    for (line.ns) |m| {
        rest += m;
    }
    if (from + rest > line.s.len) {
        return 0;
    }
    var i: usize = from;
    while (i + n <= line.s.len) : (i += 1) {
        if (i > 0 and line.s[i - 1] == '#') {
            if (line.s[i] == '#') {
                return sum;
            }
            continue;
        }
        if (i + n < line.s.len and line.s[i + n] == '#') {
            if (line.s[i] == '#') {
                return sum;
            }
            continue;
        }
        var place = true;
        var j: usize = i;
        while (j < i + n) : (j += 1) {
            if (line.s[j] != '#' and line.s[j] != '?') {
                place = false;
                break;
            }
        }
        if (!place) {
            // if (std.mem.containsAtLeast(u8, line.s[i .. i + n], 1, "#")) {
            //     return sum;
            // }
            if (line.s[i] == '#') {
                return sum;
            }
            continue;
        }
        if (rem_groups == line.ns.len and !std.mem.containsAtLeast(u8, line.s[i .. i + n], 1, "#")) {
            return sum;
        }
        var s = try allocator.alloc(u8, line.s.len);
        std.mem.copyForwards(u8, s, line.s);
        j = i;
        while (j < i + n) : (j += 1) {
            s[j] = '#';
        }
        if (i > 0 and line.s[i - 1] == '?') {
            s[i - 1] = '.';
        }
        if (i + n < s.len and s[i + n] == '?') {
            s[i + n] = '.';
        }
        const l = Line{
            .s = s,
            .ns = line.ns[1..],
            .vns = line.vns,
        };
        sum += try solve(l, i + n);
    }
    return sum;
}

fn verify(line: Line) !bool {
    // std.debug.print("{s} {d}\n", .{ line.s, line.ns });
    const groups = try util.tokenize(allocator, line.s, ".?");
    if (groups.len != line.vns.len) {
        return false;
    }
    for (groups, line.vns) |group, n| {
        if (group.len != n) {
            return false;
        }
    }
    return true;
}

fn parse(line: []const u8) !Line {
    var ns = std.ArrayList(usize).init(allocator);
    const parts = try util.fields(allocator, line);
    const counts = try util.split(allocator, parts[1], ",");
    for (counts) |n| {
        try ns.append(@intCast(try util.atoi(n)));
    }
    const vns = try ns.toOwnedSlice();
    const l = Line{
        .s = parts[0],
        .ns = vns,
        .vns = vns,
    };
    return l;
}
