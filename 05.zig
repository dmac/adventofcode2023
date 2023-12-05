const std = @import("std");
const util = @import("util.zig");

const Entry = struct {
    key: i64,
    val: i64,
    len: i64,
};

const Maps = struct {
    seed_to_soil: std.ArrayList(Entry),
    soil_to_fertilizer: std.ArrayList(Entry),
    fertilizer_to_water: std.ArrayList(Entry),
    water_to_light: std.ArrayList(Entry),
    light_to_temp: std.ArrayList(Entry),
    temp_to_humidity: std.ArrayList(Entry),
    humidity_to_location: std.ArrayList(Entry),
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var seeds = std.ArrayList(i64).init(allocator);
    var maps = Maps{
        .seed_to_soil = std.ArrayList(Entry).init(allocator),
        .soil_to_fertilizer = std.ArrayList(Entry).init(allocator),
        .fertilizer_to_water = std.ArrayList(Entry).init(allocator),
        .water_to_light = std.ArrayList(Entry).init(allocator),
        .light_to_temp = std.ArrayList(Entry).init(allocator),
        .temp_to_humidity = std.ArrayList(Entry).init(allocator),
        .humidity_to_location = std.ArrayList(Entry).init(allocator),
    };

    const lines = try util.file_lines(allocator, "05.txt");
    const seed_strs = try util.fields(allocator, (try util.split(allocator, lines[0], ":"))[1]);
    for (seed_strs) |s| {
        const seed = try util.atoi(s);
        try seeds.append(seed);
    }

    var list: *std.ArrayList(Entry) = undefined;
    for (lines[1..]) |line| {
        if (line.len == 0) {
            continue;
        }
        if (std.mem.startsWith(u8, line, "seed")) {
            list = &maps.seed_to_soil;
            continue;
        } else if (std.mem.startsWith(u8, line, "soil")) {
            list = &maps.soil_to_fertilizer;
            continue;
        } else if (std.mem.startsWith(u8, line, "fertilizer")) {
            list = &maps.fertilizer_to_water;
            continue;
        } else if (std.mem.startsWith(u8, line, "water")) {
            list = &maps.water_to_light;
            continue;
        } else if (std.mem.startsWith(u8, line, "light")) {
            list = &maps.light_to_temp;
            continue;
        } else if (std.mem.startsWith(u8, line, "temperature")) {
            list = &maps.temp_to_humidity;
            continue;
        } else if (std.mem.startsWith(u8, line, "humidity")) {
            list = &maps.humidity_to_location;
            continue;
        }
        const fields = try util.fields(allocator, line);
        const entry = Entry{
            .key = try util.atoi(fields[1]),
            .val = try util.atoi(fields[0]),
            .len = try util.atoi(fields[2]),
        };
        try list.append(entry);
    }

    var min: i64 = std.math.maxInt(i64);
    for (seeds.items) |seed| {
        const loc = seed_to_location(maps, seed);
        if (loc < min) {
            min = loc;
        }
    }
    std.debug.print("{d}\n", .{min});

    var loc: i64 = 0;
    outer: while (true) : (loc += 1) {
        const seed = location_to_seed(maps, loc);
        var i: usize = 0;
        while (i < seeds.items.len) : (i += 2) {
            const start = seeds.items[i];
            const len = seeds.items[i + 1];
            if (seed >= start and seed < start + len) {
                break :outer;
            }
        }
    }
    std.debug.print("{d}\n", .{loc});
}

fn seed_to_location(maps: Maps, seed: i64) i64 {
    const soil = look_up(seed, maps.seed_to_soil);
    const fertilizer = look_up(soil, maps.soil_to_fertilizer);
    const water = look_up(fertilizer, maps.fertilizer_to_water);
    const light = look_up(water, maps.water_to_light);
    const temp = look_up(light, maps.light_to_temp);
    const humidity = look_up(temp, maps.temp_to_humidity);
    const location = look_up(humidity, maps.humidity_to_location);
    return location;
}

fn look_up(key: i64, map: std.ArrayList(Entry)) i64 {
    for (map.items) |entry| {
        if (key >= entry.key and key < entry.key + entry.len) {
            return entry.val + (key - entry.key);
        }
    }
    return key;
}

fn location_to_seed(maps: Maps, location: i64) i64 {
    const humidity = reverse_look_up(location, maps.humidity_to_location);
    const temp = reverse_look_up(humidity, maps.temp_to_humidity);
    const light = reverse_look_up(temp, maps.light_to_temp);
    const water = reverse_look_up(light, maps.water_to_light);
    const fertilizer = reverse_look_up(water, maps.fertilizer_to_water);
    const soil = reverse_look_up(fertilizer, maps.soil_to_fertilizer);
    const seed = reverse_look_up(soil, maps.seed_to_soil);
    return seed;
}

fn reverse_look_up(val: i64, map: std.ArrayList(Entry)) i64 {
    for (map.items) |entry| {
        if (val >= entry.val and val < entry.val + entry.len) {
            return entry.key + (val - entry.val);
        }
    }
    return val;
}
