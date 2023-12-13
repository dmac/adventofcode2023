const std = @import("std");

pub fn file_bytes(allocator: std.mem.Allocator, filename: []const u8) ![]u8 {
    const f = try std.fs.cwd().openFile(filename, .{});
    defer f.close();
    return try f.reader().readAllAlloc(allocator, 1e9);
}

pub fn file_lines(allocator: std.mem.Allocator, filename: []const u8) ![][]u8 {
    const f = try std.fs.cwd().openFile(filename, .{});
    defer f.close();
    var buf = std.io.bufferedReader(f.reader());
    var lines = std.ArrayList([]u8).init(allocator);
    while (try buf.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1e6)) |line| {
        try lines.append(line);
    }
    return lines.toOwnedSlice();
}

pub fn file_ints(allocator: std.mem.Allocator, filename: []const u8) ![]i64 {
    const lines = try file_lines(allocator, filename);
    var ints = std.ArrayList(i64).init(allocator);
    for (lines) |line| {
        const n = try std.fmt.parseInt(i64, line, 10);
        try ints.append(n);
    }
    return ints.toOwnedSlice();
}

pub fn atoi(s: []const u8) !i64 {
    return try std.fmt.parseInt(i64, s, 10);
}

pub fn tokenize(allocator: std.mem.Allocator, s: []const u8, delims: []const u8) ![][]u8 {
    var tokens = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.tokenizeAny(u8, s, delims);
    while (it.next()) |t| {
        try tokens.append(t);
    }
    return tokens.toOwnedSlice();
}

pub fn fields(allocator: std.mem.Allocator, s: []const u8) ![][]const u8 {
    return tokenize(allocator, s, &std.ascii.whitespace);
}

pub fn split(allocator: std.mem.Allocator, s: []u8, sep: []const u8) ![][]u8 {
    var list = std.ArrayList([]u8).init(allocator);
    var it = std.mem.split(u8, s, sep);
    while (it.next()) |sub| {
        try list.append(@constCast(sub));
    }
    return try list.toOwnedSlice();
}

pub fn Point(comptime T: type) type {
    return struct {
        row: T,
        col: T,
    };
}

// neighbors returns the (row, col) points in a 2D grid that are immediately
// adjacent to a rectangular region in the grid. The region is defined by its
// top-left corner, width, and height. Diagonal neighbors are included.
pub fn neighbors(
    allocator: std.mem.Allocator,
    rows: usize,
    cols: usize,
    topleft_row: usize,
    topleft_col: usize,
    width: usize,
    height: usize,
) ![]Point(usize) {
    std.debug.assert(width > 0);
    std.debug.assert(height > 0);
    var points = std.ArrayList(Point(usize)).init(allocator);
    // top neighbors
    if (topleft_row > 0) {
        const r = topleft_row - 1;
        var c = if (topleft_col > 0) topleft_col - 1 else topleft_col;
        while (c <= topleft_col + width and c < cols) : (c += 1) {
            const p = Point(usize){ .row = r, .col = c };
            try points.append(p);
        }
    }
    // bottom neighbors
    if (topleft_row + height < rows) {
        const r = topleft_row + height;
        var c = if (topleft_col > 0) topleft_col - 1 else topleft_col;
        while (c <= topleft_col + width and c < cols) : (c += 1) {
            const p = Point(usize){ .row = r, .col = c };
            try points.append(p);
        }
    }
    // left neighbors
    if (topleft_col > 0) {
        var r = topleft_row;
        const c = topleft_col - 1;
        while (r < topleft_row + height and r < rows) : (r += 1) {
            const p = Point(usize){ .row = r, .col = c };
            try points.append(p);
        }
    }
    // right neighbors
    if (topleft_col + width < cols) {
        var r = topleft_row;
        const c = topleft_col + width;
        while (r < topleft_row + height and r < rows) : (r += 1) {
            const p = Point(usize){ .row = r, .col = c };
            try points.append(p);
        }
    }
    return points.toOwnedSlice();
}

pub fn lcm(a: anytype, b: anytype) @TypeOf(a, b) {
    const pa: u64 = @abs(a);
    const pb: u64 = @abs(b);
    const gcd = std.math.gcd(pa, pb);
    const _lcm = pa / gcd * pb;
    return @as(@TypeOf(a, b), @intCast(_lcm));
}
