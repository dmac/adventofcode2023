const std = @import("std");
const util = @import("util.zig");

const Game = struct {
    id: i64,
    trials: []Trial,
};

const Trial = struct {
    red: i64 = 0,
    green: i64 = 0,
    blue: i64 = 0,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const lines = try util.file_lines(allocator, "02.txt");
    var games = std.ArrayList(Game).init(allocator);
    for (lines) |line| {
        const i = std.mem.indexOf(u8, line, ":").?;
        const id: i64 = try util.atoi(line[5..i]);
        var trials = std.ArrayList(Trial).init(allocator);
        for (try util.split(allocator, line[i + 1 ..], ";")) |trial_s| {
            var trial = Trial{};
            for (try util.split(allocator, trial_s, ",")) |color_s| {
                const fields = try util.fields(allocator, color_s);
                const n = try util.atoi(fields[0]);
                switch (fields[1][0]) {
                    'r' => trial.red = n,
                    'g' => trial.green = n,
                    'b' => trial.blue = n,
                    else => unreachable,
                }
            }
            try trials.append(trial);
        }
        const game: Game = .{
            .id = id,
            .trials = trials.items,
        };
        try games.append(game);
    }

    var possible_sum: i64 = 0;
    var power_sum: i64 = 0;
    for (games.items) |game| {
        var possible = true;
        var max_red: i64 = 0;
        var max_green: i64 = 0;
        var max_blue: i64 = 0;
        for (game.trials) |trial| {
            if (trial.red > 12 or trial.green > 13 or trial.blue > 14) {
                possible = false;
            }
            max_red = @max(max_red, trial.red);
            max_green = @max(max_green, trial.green);
            max_blue = @max(max_blue, trial.blue);
        }
        if (possible) {
            possible_sum += game.id;
        }
        power_sum += max_red * max_green * max_blue;
    }
    std.debug.print("{d}\n", .{possible_sum});
    std.debug.print("{d}\n", .{power_sum});
}
