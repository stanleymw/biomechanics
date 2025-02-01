const std = @import("std");

pub fn unwrap(comptime T: type, val: anyerror!T) T {
    if (val) |v| {
        return v;
    } else |v| {
        std.debug.panic("Panic in unwrapping error union! Error: {any}\n", .{v});
    }
}
