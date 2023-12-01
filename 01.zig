const std = @import("std");
const util = @import("util.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const lines = try util.file_lines(allocator, "01.txt");

    const digits1 = [_][]const u8{
        "0", "1", "2", "3", "4",
        "5", "6", "7", "8", "9",
    };
    const digits2 = [_][]const u8{
        "0",    "1",   "2",     "3",     "4",
        "5",    "6",   "7",     "8",     "9",
        "zero", "one", "two",   "three", "four",
        "five", "six", "seven", "eight", "nine",
    };

    std.debug.print("{d}\n", .{find_sum(lines, &digits1)});
    std.debug.print("{d}\n", .{find_sum(lines, &digits2)});
}

fn find_sum(lines: []const []const u8, digits: []const []const u8) i64 {
    var sum: i64 = 0;
    for (lines) |line| {
        var min: i64 = 1000;
        var max: i64 = -1;
        var min_digit: []const u8 = "";
        var max_digit: []const u8 = "";
        for (digits) |digit| {
            if (std.mem.indexOf(u8, line, digit)) |i| {
                const j: i64 = @intCast(i);
                if (j < min) {
                    min = j;
                    min_digit = digit;
                }
            }
            if (std.mem.lastIndexOf(u8, line, digit)) |i| {
                const j: i64 = @intCast(i);
                if (j > max) {
                    max = j;
                    max_digit = digit;
                }
            }
        }
        const n = 10 * val(min_digit) + val(max_digit);
        sum += n;
    }
    return sum;
}

fn val(s: []const u8) i64 {
    if (eql(s, "0") or eql(s, "zero")) {
        return 0;
    } else if (eql(s, "1") or eql(s, "one")) {
        return 1;
    } else if (eql(s, "2") or eql(s, "two")) {
        return 2;
    } else if (eql(s, "3") or eql(s, "three")) {
        return 3;
    } else if (eql(s, "4") or eql(s, "four")) {
        return 4;
    } else if (eql(s, "5") or eql(s, "five")) {
        return 5;
    } else if (eql(s, "6") or eql(s, "six")) {
        return 6;
    } else if (eql(s, "7") or eql(s, "seven")) {
        return 7;
    } else if (eql(s, "8") or eql(s, "eight")) {
        return 8;
    } else if (eql(s, "9") or eql(s, "nine")) {
        return 9;
    }
    unreachable;
}

fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}
