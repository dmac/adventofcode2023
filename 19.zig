const std = @import("std");
const util = @import("util.zig");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Workflow = struct {
    name: []const u8,
    rules: []Rule,
};

const Rule = struct {
    lhs: u8 = 0,
    op: u8 = 0,
    rhs: i64 = 0,
    dst: []const u8 = &.{},
};

const Part = struct {
    x: i64 = 0,
    m: i64 = 0,
    a: i64 = 0,
    s: i64 = 0,
};

pub fn main() !void {
    const lines = try util.file_lines(allocator, "19.txt");
    var on_workflows = true;
    var workflows = std.ArrayList(Workflow).init(allocator);
    var parts = std.ArrayList(Part).init(allocator);
    for (lines) |line| {
        if (line.len == 0) {
            on_workflows = false;
            continue;
        }
        if (on_workflows) {
            const wf = try parse_workflow(line);
            try workflows.append(wf);
        } else {
            const part = try parse_part(line);
            try parts.append(part);
        }
    }

    var part1: i64 = 0;
    for (parts.items) |part| {
        if (run(workflows, part)) {
            part1 += part.x;
            part1 += part.m;
            part1 += part.a;
            part1 += part.s;
        }
    }
    std.debug.print("{d}\n", .{part1});
}

fn run(workflows: std.ArrayList(Workflow), part: Part) bool {
    var wf = get_workflow(workflows, "in");
    while (true) {
        const next = run_workflow(wf, part);
        if (std.mem.eql(u8, next, "A")) {
            return true;
        }
        if (std.mem.eql(u8, next, "R")) {
            return false;
        }
        wf = get_workflow(workflows, next);
    }
}

fn run_workflow(wf: Workflow, part: Part) []const u8 {
    for (wf.rules) |rule| {
        if (rule.lhs == 0) {
            return rule.dst;
        }
        const v = switch (rule.lhs) {
            'x' => part.x,
            'm' => part.m,
            'a' => part.a,
            's' => part.s,
            else => unreachable,
        };
        if (rule.op == '<' and v < rule.rhs) {
            return rule.dst;
        }
        if (rule.op == '>' and v > rule.rhs) {
            return rule.dst;
        }
    }
    unreachable;
}

fn get_workflow(workflows: std.ArrayList(Workflow), name: []const u8) Workflow {
    for (workflows.items) |wf| {
        if (std.mem.eql(u8, wf.name, name)) {
            return wf;
        }
    }
    unreachable;
}

fn parse_workflow(line: []const u8) !Workflow {
    var it = std.mem.tokenizeAny(u8, line, "{}");
    const name = it.next().?;
    var rules = std.ArrayList(Rule).init(allocator);
    var rit = std.mem.tokenizeScalar(u8, it.next().?, ',');
    while (rit.next()) |rs| {
        var rule = Rule{};
        if (std.mem.containsAtLeast(u8, rs, 1, ":")) {
            var eq_it = std.mem.splitScalar(u8, rs, ':');
            const eq = eq_it.next().?;
            const dst = eq_it.next().?;
            rule.lhs = eq[0];
            rule.op = eq[1];
            rule.rhs = try util.atoi(eq[2..]);
            rule.dst = dst;
        } else {
            rule.dst = rs;
        }
        try rules.append(rule);
    }
    return .{
        .name = name,
        .rules = try rules.toOwnedSlice(),
    };
}

fn parse_part(line: []const u8) !Part {
    var part = Part{};
    const s = std.mem.trim(u8, line, "{}");
    var kvs = std.mem.splitScalar(u8, s, ',');
    while (kvs.next()) |kv| {
        const n = try util.atoi(kv[2..]);
        switch (kv[0]) {
            'x' => part.x = n,
            'm' => part.m = n,
            'a' => part.a = n,
            's' => part.s = n,
            else => unreachable,
        }
    }
    return part;
}
