const std = @import("std");
const Allocator = std.mem.Allocator;
const file = @embedFile("data/d03.txt");

const Line = struct {
    length: i16,
    dir: Dir,
};

const Dir = enum {
    up,
    right,
    down,
    left,

    fn from_u8(dir: u8) Dir {
        return switch (dir) {
            'U' => Dir.up,
            'R' => Dir.right,
            'D' => Dir.down,
            'L' => Dir.left,
            else => unreachable,
        };
    }
};

/// Point { x, y }
const Point = struct {
    i16,
    i16,
};

fn equals(self: *const Point, other: *const Point) bool {
    return self[0] == other[0] and self[1] == other[1];
}

fn manhattan(point: Point) u16 {
    return @abs(point[0]) + @abs(point[1]);
}

pub fn get_solution_1() u16 {
    const ropes = parse(file) catch |err| {
        std.log.err("Error while parsing file: {!}.\n", .{err});
        return 0;
    };
    defer ropes[0].deinit();
    defer ropes[1].deinit();

    var rope1_points = walk_rope(ropes[0].items, std.heap.page_allocator) catch unreachable;
    defer rope1_points.deinit();
    var rope2_points = walk_rope(ropes[1].items, std.heap.page_allocator) catch unreachable;
    defer rope2_points.deinit();

    var rope1_points_iter = rope1_points.keyIterator();
    var overlapping = std.ArrayList(Point).init(std.heap.page_allocator);
    defer overlapping.deinit();

    while (rope1_points_iter.next()) |p| {
        if (rope2_points.contains(p.*)) {
            overlapping.append(p.*) catch unreachable;
        }
    }

    var min: u16 = 65535;

    for (overlapping.items) |point| {
        if (point[0] != 0 or point[1] != 0) {
            min = @min(min, manhattan(point));
        }
    }

    return min;
}

fn walk_rope(rope: []const Line, allocator: Allocator) Allocator.Error!std.AutoHashMap(Point, void) {
    var current: Point = .{ 0, 0 };
    var points = std.AutoHashMap(Point, void).init(allocator);
    try points.put(current, {});

    for (rope) |rope_line| {
        const dir: Point = switch (rope_line.dir) {
            .down => .{ 0, -1 },
            .right => .{ 1, 0 },
            .left => .{ -1, 0 },
            .up => .{ 0, 1 },
        };
        for (0..@as(usize, @intCast(rope_line.length))) |_| {
            current = .{ current[0] + dir[0], current[1] + dir[1] };
            try points.put(current, {});
        }
    }

    return points;
}

fn parse(data: []const u8) !struct { std.ArrayList(Line), std.ArrayList(Line) } {
    const new_line_pos = std.mem.indexOf(u8, data, "\n") orelse unreachable;
    var first_rope = std.ArrayList(Line).init(std.heap.page_allocator);
    var second_rope = std.ArrayList(Line).init(std.heap.page_allocator);

    try parse_rope(data[0..new_line_pos], &first_rope);
    try parse_rope(data[new_line_pos + 1 .. data.len - 1], &second_rope);

    return .{ first_rope, second_rope };
}

fn parse_rope(data: []const u8, lines: *std.ArrayList(Line)) !void {
    var iter = std.mem.splitScalar(u8, data, ',');

    while (iter.next()) |line| {
        const dir = Dir.from_u8(line[0]);
        const length = try std.fmt.parseInt(i16, line[1..], 10);
        try lines.append(.{ .dir = dir, .length = length });
    }
}
