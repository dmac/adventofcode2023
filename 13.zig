const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    const b = try util.file_bytes(allocator, "13.txt");
    const bt = std.mem.trim(u8, b, &std.ascii.whitespace);
    const patterns = try util.split(allocator, @constCast(bt), "\n\n");
    var reflections = try allocator.alloc(usize, patterns.len);
    var part1: usize = 0;
    patternLoop: for (patterns, 0..) |pattern, pi| {
        const grid = try util.split(allocator, pattern, "\n");
        for (1..grid.len) |row| {
            if (check_row(grid, row)) {
                part1 += 100 * row;
                reflections[pi] = 100 * row;
                continue :patternLoop;
            }
        }
        for (1..grid[0].len) |col| {
            if (check_col(grid, col)) {
                part1 += col;
                reflections[pi] = col;
                continue :patternLoop;
            }
        }
        unreachable;
    }
    std.debug.print("{d}\n", .{part1});

    var part2: usize = 0;
    patternLoop: for (patterns, 0..) |pattern, pi| {
        const grid = try util.split(allocator, pattern, "\n");
        for (0..grid.len) |r| {
            for (0..grid[0].len) |c| {
                swap(grid, r, c);
                defer swap(grid, r, c);
                for (1..grid.len) |row| {
                    if (check_row(grid, row) and reflections[pi] != 100 * row) {
                        part2 += 100 * row;
                        continue :patternLoop;
                    }
                }
                for (1..grid[0].len) |col| {
                    if (check_col(grid, col) and reflections[pi] != col) {
                        part2 += col;
                        continue :patternLoop;
                    }
                }
            }
        }
        unreachable;
    }
    std.debug.print("{d}\n", .{part2});
}

fn print_grid(grid: [][]u8) void {
    for (grid) |row| {
        std.debug.print("{s}\n", .{row});
    }
}

fn check_row(grid: [][]const u8, row: usize) bool {
    for (0..row) |r| {
        const rr = row + (row - r) - 1;
        if (rr >= grid.len) {
            continue;
        }
        for (0..grid[0].len) |c| {
            if (grid[r][c] != grid[rr][c]) {
                return false;
            }
        }
    }
    return true;
}

fn check_col(grid: [][]const u8, col: usize) bool {
    for (0..col) |c| {
        const cr = col + (col - c) - 1;
        if (cr >= grid[0].len) {
            continue;
        }
        for (0..grid.len) |r| {
            if (grid[r][c] != grid[r][cr]) {
                return false;
            }
        }
    }
    return true;
}

fn swap(grid: [][]u8, row: usize, col: usize) void {
    grid[row][col] = if (grid[row][col] == '.') '#' else '.';
}
