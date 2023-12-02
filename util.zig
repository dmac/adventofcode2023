const std = @import("std");

pub fn file_lines(allocator: std.mem.Allocator, filename: []const u8) ![][]u8 {
    const f = try std.fs.cwd().openFile(filename, .{});
    defer f.close();
    var buf = std.io.bufferedReader(f.reader());
    var lines = std.ArrayList([]u8).init(allocator);
    while (try buf.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1e6)) |line| {
        try lines.append(line);
    }
    return lines.items;
}

pub fn file_ints(allocator: std.mem.Allocator, filename: []const u8) ![]i64 {
    const lines = try file_lines(allocator, filename);
    var ints = std.ArrayList(i64).init(allocator);
    for (lines) |line| {
        const n = try std.fmt.parseInt(i64, line, 10);
        try ints.append(n);
    }
    return ints.items;
}

pub fn atoi(s: []const u8) !i64 {
    return try std.fmt.parseInt(i64, s, 10);
}

pub fn tokenize(allocator: std.mem.Allocator, s: []const u8, delims: []const u8) ![][]const u8 {
    var tokens = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.tokenizeAny(u8, s, delims);
    while (it.next()) |t| {
        try tokens.append(t);
    }
    return tokens.items;
}

pub fn fields(allocator: std.mem.Allocator, s: []const u8) ![][]const u8 {
    return tokenize(allocator, s, " \n\t");
}
