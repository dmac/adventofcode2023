const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    const lines = try util.file_lines(allocator, "11.txt");
    std.debug.print("{d}\n", .{try run(lines, 2)});
    std.debug.print("{d}\n", .{try run(lines, 1000000)});
}

fn run(lines: [][]u8, by: usize) !i64 {
    const exrows = try expand_rows(lines, by);
    const excols = try expand_cols(lines, by);
    const galaxies = try find_galaxies(lines);
    var sum: i64 = 0;
    var i: usize = 0;
    while (i < galaxies.len - 1) : (i += 1) {
        var j: usize = i + 1;
        while (j < galaxies.len) : (j += 1) {
            const path = shortest_path(galaxies[i], galaxies[j], exrows, excols);
            sum += @as(i64, @intCast(path));
        }
    }
    return sum;
}

fn expand_rows(grid: [][]u8, by: usize) ![]usize {
    const exrows = try allocator.alloc(usize, grid.len);
    for (exrows) |*n| {
        n.* = 1;
    }
    for (grid, 0..) |line, row| {
        var empty = true;
        for (line) |ch| {
            if (ch == '#') {
                empty = false;
                break;
            }
        }
        if (empty) {
            exrows[row] += by - 1;
        }
    }
    return exrows;
}

fn expand_cols(grid: [][]u8, by: usize) ![]usize {
    const excols = try allocator.alloc(usize, grid[0].len);
    for (excols) |*n| {
        n.* = 1;
    }
    var col: usize = 0;
    while (col < grid[0].len) : (col += 1) {
        var empty = true;
        var row: usize = 0;
        while (row < grid.len) : (row += 1) {
            if (grid[row][col] == '#') {
                empty = false;
                break;
            }
        }
        if (empty) {
            excols[col] += by - 1;
        }
    }
    return excols;
}

fn find_galaxies(grid: [][]u8) ![]util.Point(usize) {
    var galaxies = std.ArrayList(util.Point(usize)).init(allocator);
    for (grid, 0..) |line, row| {
        for (line, 0..) |ch, col| {
            if (ch == '#') {
                const p = util.Point(usize){
                    .row = row,
                    .col = col,
                };
                try galaxies.append(p);
            }
        }
    }
    return galaxies.toOwnedSlice();
}

fn shortest_path(a: util.Point(usize), b: util.Point(usize), exrows: []usize, excols: []usize) usize {
    var path: usize = 0;
    {
        var i = @min(a.row, b.row);
        const end = @max(a.row, b.row);
        while (i < end) : (i += 1) {
            path += exrows[i];
        }
    }
    {
        var i = @min(a.col, b.col);
        const end = @max(a.col, b.col);
        while (i < end) : (i += 1) {
            path += excols[i];
        }
    }
    return path;
}
