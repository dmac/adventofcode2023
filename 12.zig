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
    const lines = try util.file_lines(allocator, "12.txt");
    var sum: i64 = 0;
    for (lines) |line| {
        const l = try parse(line);
        // std.debug.print("{s} {d}\n", .{ l.s, l.ns });
        sum += try solve(l, 0);
    }
    std.debug.print("{d}\n", .{sum});
}

fn solve(line: Line, from: usize) !i64 {
    // std.debug.print("{s} {d} {d}\n", .{ line.s, line.ns, from });
    if (line.ns.len == 0) {
        if (try verify(line)) {
            return 1;
        }
        return 0;
    }
    const n = line.ns[0];
    var sum: i64 = 0;
    var i: usize = from;
    while (i <= line.s.len - n) : (i += 1) {
        var place = true;
        var j: usize = i;
        while (j < i + n) : (j += 1) {
            if (line.s[j] != '#' and line.s[j] != '?') {
                place = false;
                break;
            }
        }
        if (!place) {
            continue;
        }
        var s = try allocator.alloc(u8, line.s.len);
        std.mem.copyForwards(u8, s, line.s);
        j = i;
        while (j < i + n) : (j += 1) {
            s[j] = '#';
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
