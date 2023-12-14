const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    const grid = try util.file_lines(allocator, "14.txt");

    const cycle_len: usize = 14; // by inspection
    var cycles = try allocator.alloc(usize, 2 * cycle_len);
    for (cycles) |*c| {
        c.* = 0;
    }

    tilt_north(grid);
    std.debug.print("{d}\n", .{north_load(grid)});

    tilt_west(grid);
    tilt_south(grid);
    tilt_east(grid);
    cycles[0] = north_load(grid);
    var idx: usize = 1;

    for (1..1000000000) |_| {
        tilt_north(grid);
        tilt_west(grid);
        tilt_south(grid);
        tilt_east(grid);
        const load = north_load(grid);
        cycles[idx] = load;
        idx = @mod(idx + 1, cycles.len);

        var found = true;
        for (0..@divExact(cycles.len, 2)) |j| {
            if (cycles[j] != cycles[j + cycle_len]) {
                found = false;
                break;
            }
        }
        if (found) {
            const x = @divTrunc(1000000000, cycle_len) + 1;
            const y = cycles.len - (cycle_len * x - 1000000000);
            std.debug.print("{d}\n", .{cycles[y - 1]});
            break;
        }
    }
}

fn north_load(grid: [][]u8) usize {
    var load: usize = 0;
    for (grid, 0..) |line, row| {
        for (line) |c| {
            if (c == 'O') {
                load += grid.len - row;
            }
        }
    }
    return load;
}

fn print_grid(grid: [][]u8) void {
    for (grid) |line| {
        std.debug.print("{s}\n", .{line});
    }
}

fn tilt_north(grid: [][]u8) void {
    for (0..grid[0].len) |col| {
        for (0..grid.len) |row| {
            if (grid[row][col] == 'O') {
                var r: usize = row;
                while (r > 0 and grid[r - 1][col] == '.') : (r -= 1) {
                    grid[r - 1][col] = 'O';
                    grid[r][col] = '.';
                }
            }
        }
    }
}

fn tilt_west(grid: [][]u8) void {
    for (0..grid.len) |row| {
        for (0..grid[0].len) |col| {
            if (grid[row][col] == 'O') {
                var c: usize = col;
                while (c > 0 and grid[row][c - 1] == '.') : (c -= 1) {
                    grid[row][c - 1] = 'O';
                    grid[row][c] = '.';
                }
            }
        }
    }
}

fn tilt_south(grid: [][]u8) void {
    for (0..grid[0].len) |col| {
        var row: usize = grid.len;
        while (row > 0) {
            row -= 1;
            if (grid[row][col] == 'O') {
                var r: usize = row;
                while (r < grid.len - 1 and grid[r + 1][col] == '.') : (r += 1) {
                    grid[r + 1][col] = 'O';
                    grid[r][col] = '.';
                }
            }
        }
    }
}

fn tilt_east(grid: [][]u8) void {
    for (0..grid.len) |row| {
        var col: usize = grid[0].len;
        while (col > 0) {
            col -= 1;
            if (grid[row][col] == 'O') {
                var c: usize = col;
                while (c < grid[0].len - 1 and grid[row][c + 1] == '.') : (c += 1) {
                    grid[row][c + 1] = 'O';
                    grid[row][c] = '.';
                }
            }
        }
    }
}
