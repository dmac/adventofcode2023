const std = @import("std");
const util = @import("util.zig");

// map (row, col) to list of adjacent part numbers.
const GearMap = std.AutoArrayHashMap([2]usize, std.ArrayList(i64));

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const lines = try util.file_lines(allocator, "03.txt");
    var gear_map = GearMap.init(allocator);
    var part_sum: i64 = 0;
    var row: usize = 0;
    while (row < lines.len) : (row += 1) {
        const line = lines[row];
        var col: usize = 0;
        while (col < line.len) : (col += 1) {
            if (std.ascii.isDigit(line[col])) {
                const ds = digit_str(line, col);
                if (try is_part(lines, ds, row, col, &gear_map)) {
                    part_sum += try util.atoi(ds);
                }
                col += ds.len - 1;
            }
        }
    }
    std.debug.print("{d}\n", .{part_sum});

    var ratio_sum: i64 = 0;
    var gear_it = gear_map.iterator();
    while (gear_it.next()) |entry| {
        const parts = entry.value_ptr.items;
        if (parts.len != 2) {
            continue;
        }
        ratio_sum += parts[0] * parts[1];
    }
    std.debug.print("{d}\n", .{ratio_sum});
}

fn digit_str(line: []const u8, start: usize) []const u8 {
    var end: usize = start;
    while (end < line.len) : (end += 1) {
        if (!std.ascii.isDigit(line[end])) {
            break;
        }
    }
    return line[start..end];
}

fn is_part(lines: [][]const u8, ds: []const u8, row: usize, col: usize, gear_map: *GearMap) !bool {
    var part = false;
    // check above
    if (row > 0) {
        const r = row - 1;
        var c = if (col > 0) col - 1 else col;
        while (c <= col + ds.len and c < lines[row].len) : (c += 1) {
            if (is_symbol(lines[r][c])) {
                if (lines[r][c] == '*') {
                    try update_gear_map(gear_map, ds, r, c);
                }
                part = true;
            }
        }
    }
    // check below
    if (row < lines.len - 1) {
        const r = row + 1;
        var c = if (col > 0) col - 1 else col;
        while (c <= col + ds.len and c < lines[row].len) : (c += 1) {
            if (is_symbol(lines[r][c])) {
                if (lines[r][c] == '*') {
                    try update_gear_map(gear_map, ds, r, c);
                }
                part = true;
            }
        }
    }
    // check sides
    if (col > 0) {
        const c = col - 1;
        if (is_symbol(lines[row][c])) {
            if (lines[row][c] == '*') {
                try update_gear_map(gear_map, ds, row, c);
            }
            part = true;
        }
    }
    if (col + ds.len < lines[row].len) {
        const c = col + ds.len;
        if (is_symbol(lines[row][c])) {
            if (lines[row][c] == '*') {
                try update_gear_map(gear_map, ds, row, c);
            }
            part = true;
        }
    }
    return part;
}

fn is_symbol(c: u8) bool {
    return c != '.' and !std.ascii.isDigit(c);
}

fn update_gear_map(gear_map: *GearMap, ds: []const u8, row: usize, col: usize) !void {
    const k = .{ row, col };
    const entry = try gear_map.getOrPut(k);
    if (!entry.found_existing) {
        entry.value_ptr.* = std.ArrayList(i64).init(gear_map.allocator);
    }
    var parts = entry.value_ptr;
    const n = try util.atoi(ds);
    try parts.append(n);
}
