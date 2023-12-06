const std = @import("std");
const util = @import("util.zig");

const Race = struct {
    time: i64,
    dist: i64,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const lines = try util.file_lines(allocator, "06.txt");
    const times = (try util.fields(allocator, lines[0]))[1..];
    const dists = (try util.fields(allocator, lines[1]))[1..];

    var races = std.ArrayList(Race).init(allocator);
    var i: usize = 0;
    while (i < times.len) : (i += 1) {
        const race = Race{
            .time = try util.atoi(times[i]),
            .dist = try util.atoi(dists[i]),
        };
        try races.append(race);
    }

    var product: i64 = 1;
    for (races.items) |race| {
        const ways_to_win = count_ways_to_win(race);
        product *= ways_to_win;
    }
    std.debug.print("{d}\n", .{product});

    const bigrace = Race{
        .time = try util.atoi(try std.mem.join(allocator, "", times)),
        .dist = try util.atoi(try std.mem.join(allocator, "", dists)),
    };
    std.debug.print("{d}\n", .{count_ways_to_win(bigrace)});
}

fn count_ways_to_win(race: Race) i64 {
    var count: i64 = 0;
    var t: i64 = 1;
    while (t <= race.time) : (t += 1) {
        const dist = t * (race.time - t);
        if (dist > race.dist) {
            count += 1;
        }
    }
    return count;
}
