const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Hand = struct {
    cards: [5]u8,
    bid: i64,
};

pub fn main() !void {
    try run(false);
    try run(true);
}

fn run(jokers: bool) !void {
    var hands = std.ArrayList(Hand).init(allocator);
    const lines = try util.file_lines(allocator, "07.txt");
    for (lines) |line| {
        const parts = try util.fields(allocator, line);
        var hand = Hand{
            .cards = undefined,
            .bid = try util.atoi(parts[1]),
        };
        for (0..hand.cards.len) |i| {
            const c = parts[0][i];
            hand.cards[i] = switch (c) {
                'A' => 14,
                'K' => 13,
                'Q' => 12,
                'J' => if (jokers) 1 else 11,
                'T' => 10,
                else => c - '0',
            };
        }
        try hands.append(hand);
    }
    std.mem.sort(Hand, hands.items, {}, card_less_than);
    var sum: i64 = 0;
    for (hands.items, 0..) |hand, i| {
        sum += hand.bid * @as(i64, @intCast(i + 1));
    }
    std.debug.print("{d}\n", .{sum});
}

fn card_less_than(_: void, a: Hand, b: Hand) bool {
    const ta = hand_type(a);
    const tb = hand_type(b);
    if (ta != tb) {
        return ta < tb;
    }
    for (0..a.cards.len) |i| {
        if (a.cards[i] != b.cards[i]) {
            return a.cards[i] < b.cards[i];
        }
    }
    return false;
}

fn hand_type(h: Hand) i64 {
    var counts = std.AutoHashMap(u8, usize).init(allocator);
    var jokers: usize = 0;
    for (h.cards) |c| {
        if (c == 1) { // joker
            jokers += 1;
            continue;
        }
        const entry = counts.getOrPut(c) catch unreachable;
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }
    var ofakind = std.mem.zeroes([5]i64);
    var it = counts.iterator();
    while (it.next()) |entry| {
        ofakind[entry.value_ptr.* - 1] += 1;
    }
    if (jokers == 5) {
        ofakind[4] = 1;
    } else if (jokers > 0) {
        var i: usize = ofakind.len;
        while (i > 0) {
            i -= 1;
            if (ofakind[i] > 0) {
                ofakind[i] -= 1;
                ofakind[i + jokers] += 1;
                break;
            }
        }
    }
    if (ofakind[4] > 0) {
        return 7;
    }
    if (ofakind[3] > 0) {
        return 6;
    }
    if (ofakind[2] > 0 and ofakind[1] > 0) {
        return 5;
    }
    if (ofakind[2] > 0) {
        return 4;
    }
    if (ofakind[1] > 1) {
        return 3;
    }
    if (ofakind[1] > 0) {
        return 2;
    }
    return 1;
}
