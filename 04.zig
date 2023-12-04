const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const lines = try util.file_lines(allocator, "04.txt");
    var copies = std.ArrayList(i64).init(allocator);
    var wins = std.ArrayList(i64).init(allocator);
    for (lines) |line| {
        const i = std.mem.indexOf(u8, line, ":").?;
        const card = try util.split(allocator, line[i + 1 ..], "|");
        const winners = try parse_ints(allocator, card[0]);
        const numbers = try parse_ints(allocator, card[1]);
        var set = std.AutoHashMap(i64, struct {}).init(allocator);
        for (winners) |n| {
            try set.put(n, .{});
        }
        var count: i64 = 0;
        for (numbers) |n| {
            if (set.contains(n)) {
                count += 1;
            }
        }
        try copies.append(1);
        try wins.append(count);
    }

    var sum: i64 = 0;
    for (wins.items) |count| {
        if (count > 0) {
            const score = std.math.pow(i64, 2, count - 1);
            sum += score;
        }
    }
    std.debug.print("{d}\n", .{sum});

    for (copies.items, 0..) |n, i| {
        var j: usize = 0;
        while (j < wins.items[i]) : (j += 1) {
            copies.items[i + 1 + j] += n;
        }
    }
    sum = 0;
    for (copies.items) |n| {
        sum += n;
    }
    std.debug.print("{d}\n", .{sum});
}

fn parse_ints(allocator: std.mem.Allocator, s: []const u8) ![]i64 {
    var ints = std.ArrayList(i64).init(allocator);
    for (try util.fields(allocator, s)) |ns| {
        const n = try util.atoi(ns);
        try ints.append(n);
    }
    return ints.toOwnedSlice();
}
