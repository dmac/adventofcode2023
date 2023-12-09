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
    const lines = try util.file_lines(allocator, "09.txt");
    var seqs = std.ArrayList([]const i64).init(allocator);
    for (lines) |line| {
        var seq = std.ArrayList(i64).init(allocator);
        for (try util.fields(allocator, line)) |s| {
            const n = try util.atoi(s);
            try seq.append(n);
        }
        try seqs.append(try seq.toOwnedSlice());
    }

    var sum: i64 = 0;
    for (seqs.items) |seq| {
        const next = try extrapolate(seq, true);
        sum += next;
    }
    std.debug.print("{d}\n", .{sum});

    sum = 0;
    for (seqs.items) |seq| {
        const next = try extrapolate(seq, false);
        sum += next;
    }
    std.debug.print("{d}\n", .{sum});
}

fn extrapolate(seq: []const i64, comptime part1: bool) !i64 {
    var orig = try allocator.alloc(i64, seq.len + 1);
    for (orig) |*n| {
        n.* = 0;
    }
    if (part1) {
        std.mem.copyForwards(i64, orig, seq);
    } else {
        std.mem.copyForwards(i64, orig[1..], seq);
    }
    var seqs = std.ArrayList([]i64).init(allocator);
    try seqs.append(orig);
    while (true) {
        const curr = seqs.items[seqs.items.len - 1];
        var all_zero = true;
        for (curr) |n| {
            if (n != 0) {
                all_zero = false;
                break;
            }
        }
        if (all_zero) {
            break;
        }
        var next = try allocator.alloc(i64, curr.len - 1);
        for (next) |*n| {
            n.* = 0;
        }
        var i: usize = if (part1) 0 else 1;
        const end: usize = curr.len - (if (part1) 2 else 1);
        while (i < end) : (i += 1) {
            next[i] = curr[i + 1] - curr[i];
        }
        try seqs.append(next);
    }
    var i: usize = seqs.items.len - 1;
    while (i > 0) : (i -= 1) {
        const curr = seqs.items[i];
        var next = seqs.items[i - 1];
        if (part1) {
            next[next.len - 1] = next[next.len - 2] + curr[curr.len - 1];
        } else {
            next[0] = next[1] - curr[0];
        }
    }
    if (part1) {
        return seqs.items[0][seqs.items[0].len - 1];
    } else {
        return seqs.items[0][0];
    }
}
