const data = @embedFile("data/d02.txt");
const LEN = size();

const D = u32;

const opcodes = [2]*const (fn (D, D) D){ &add, &mul };

fn add(a: D, b: D) D {
    return a + b;
}

fn mul(a: D, b: D) D {
    return a * b;
}

pub fn get_solution_1() D {
    var program: [LEN]D = undefined;

    parse(&program) catch return 0;
    program[1] = 12;
    program[2] = 2;
    run(&program);

    return program[0];
}

pub fn get_solution_2() usize {
    for (0..100) |noun| {
        for (0..100) |verb| {
            var program: [LEN]D = undefined;

            parse(&program) catch return 0;
            program[1] = @intCast(noun);
            program[2] = @intCast(verb);
            run(&program);

            if (program[0] == 19690720) {
                return 100 * noun + verb;
            }
        }
    }

    unreachable;
}

fn run(program: []D) void {
    var current: usize = 0;

    while (current < LEN - 4) : (current += 4) {
        const opcode = program[current];
        const a = program[current + 1];
        const b = program[current + 2];
        const dest = program[current + 3];

        if (opcode == 99) return;

        program[dest] = opcodes[opcode - 1](program[a], program[b]);
    }
}

fn parse(buf: []D) !void {
    var iter = std.mem.splitScalar(u8, data[0 .. data.len - 1], ',');
    var i: usize = 0;

    while (iter.next()) |number| {
        buf[i] = std.fmt.parseInt(D, number, 10) catch |err| {
            std.log.err("unable to parse number: {s}\n", .{number});
            return err;
        };
        i += 1;
    }

    std.debug.assert(i == LEN);
}

fn size() comptime_int {
    comptime {
        var i = 1;
        for (data) |c| {
            if (c == ',') {
                i += 1;
            }
        }
        return i;
    }
}

const std = @import("std");
