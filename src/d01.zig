//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;

pub export fn get_solution_1() u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const nums = parse_data(u32, "data/d01.txt", gpa.allocator()) orelse return 0;
    defer nums.deinit();

    var sum: u32 = 0;
    for (nums.items) |num| {
        sum += num / 3 - 2;
    }

    return sum;
}

pub export fn get_solution_2() i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const nums = parse_data(i32, "data/d01.txt", gpa.allocator()) orelse return 0;
    defer nums.deinit();

    var sum: i32 = 0;

    for (nums.items) |n| {
        var num = n;
        while (num > 0) {
            num = @divFloor(num, 3) - 2;
            if (num > 0) sum += num;
        }
    }

    return sum;
}

fn parse_data(T: type, path: []const u8, allocator: std.mem.Allocator) ?std.ArrayList(T) {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Error opening file: {!}\n", .{err});
        return null;
    };
    defer file.close();

    const data = file.readToEndAlloc(allocator, 1024) catch |err| {
        std.log.err("Error opening file: {!}\n", .{err});
        return null;
    };
    defer allocator.free(data);

    var nums = std.ArrayList(T).init(allocator);

    // when the file is read in, a \n character is at the end for some reason
    // make slice which is one byte shorter to remove the final \n and make the iterator
    // not return an empty string.
    var iter = std.mem.splitScalar(u8, data[0 .. data.len - 1], '\n');
    while (iter.next()) |num_str| {
        //if (num_str.len < 1) continue;
        if (std.fmt.parseInt(T, num_str, 10)) |num| {
            nums.append(num) catch {
                std.log.err("ran out of memory\n", .{});
            };
        } else |err| {
            std.log.err("Error while parsing number: {!}\n", .{err});
            return null;
        }
    }

    return nums;
}
