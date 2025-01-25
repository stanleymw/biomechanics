const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const types = @import("types.zig");

const N = 4;

var selectedIndex: usize = 0;

const SelectorState = enum(u2) { Vertical, DiagonalUp, Horizontal, DiagonalDown };

var cursorState: SelectorState = .Vertical;

const PuzzlePiece = struct { marked: bool };

var Level: types.LevelData = undefined;

pub fn createWorld() void {
    for (0..N * N) |i| {
        Level.state[6 + @mod(i, N)][6 + @divFloor(i, N)] = types.PuzzlePiece{ .marked = false };

        // rl.drawRectangle((@mod(x, N)) * 160, @divFloor(x, N) * 160, 128, 128, rl.colorFromHSV(@as(f32, @floatFromInt((x + 1))) * 360.0 / (N * N), 1, 0.5));
    }
    Level.state[8][8].?.marked = true;

    Level.horizontal_wires = &[_]u4{ 1, 2, 3 };
    Level.vertical_wires = &[_]u4{4};
}

fn isShiftable(indices: []const u4, idx: usize) bool {
    for (indices) |x| {
        if (@as(usize, @intCast(x)) == idx) {
            return true;
        }
    }
    return false;
}

fn isContiguous(typ: SelectorState, idx: usize) bool {
    switch (typ) {
        .Horizontal => {
            var tracking = false;
            var left = false;
            for (Level.state[idx]) |x| {
                if (x) |_| {
                    // not null
                    tracking = true;

                    // if we already tracked a contiguous array and now came across something not in that
                    if (left) {
                        return false;
                    }
                } else {
                    if (tracking) {
                        left = true;
                    }
                }
            }
            return true;
        },
        .Vertical => {
            var tracking = false;
            var left = false;
            for (Level.state) |x| {
                if (x[idx]) |_| {
                    tracking = true;
                    if (left) {
                        return false;
                    }
                } else {
                    if (tracking) {
                        left = true;
                    }
                }
            }
            return true;
        },
        else => {
            unreachable;
        },
    }
    unreachable;
}

fn shiftColumn(idx: usize, amount: i32) void {
    if (!isShiftable(Level.vertical_wires, idx)) {
        return;
    }

    if (!isContiguous(.Vertical, idx)) {
        return;
    }

    if (amount >= 0) {
        var i = (Level.state[0].len - 2);
        if (Level.state[i + 1][idx] != null) {
            return;
        }
        while (i >= 0) : (i -= 1) {
            Level.state[@intCast(@as(i32, @intCast(i)) + amount)][idx] = Level.state[i][idx];
            Level.state[i][idx] = null;

            if (i == 0) {
                break;
            }
        }
    } else {
        if (Level.state[0][idx] != null) {
            return;
        }
        for (1..Level.state[0].len - 1) |x| {
            Level.state[@intCast(@as(i32, @intCast(x)) + amount)][idx] = Level.state[x][idx];
            Level.state[x][idx] = null;
        }
    }
}

fn shiftRow(idx: usize, amount: i32) void {
    if (!isShiftable(Level.horizontal_wires, idx)) {
        return;
    }

    if (!isContiguous(.Horizontal, idx)) {
        return;
    }

    if (amount >= 0) {
        var i = (Level.state[0].len - 2);
        if (Level.state[idx][i + 1] != null) {
            return;
        }
        while (i >= 0) : (i -= 1) {
            Level.state[idx][@intCast(@as(i32, @intCast(i)) + amount)] = Level.state[idx][i];
            Level.state[idx][i] = null;

            if (i == 0) {
                break;
            }
        }
    } else {
        if (Level.state[idx][0] != null) {
            return;
        }
        for (1..Level.state[0].len - 1) |x| {
            Level.state[idx][@intCast(@as(i32, @intCast(x)) + amount)] = Level.state[idx][x];
            Level.state[idx][x] = null;
        }
    }
}

pub fn render() void {
    const blockSize: i32 = @divTrunc(rl.getScreenHeight(), 16);
    // rl.drawRectangle(0, 0, 128, 128, rl.Color.red);

    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        cursorState = @enumFromInt(@intFromEnum(cursorState) +% 1);
    }

    if (cursorState == SelectorState.Vertical) {
        if (rl.isKeyPressed(rl.KeyboardKey.down)) {
            selectedIndex +%= 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.up)) {
            selectedIndex -%= 1;
        }

        selectedIndex = @mod(selectedIndex, Level.state.len);

        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            shiftRow(selectedIndex, 1);
        }
        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            shiftRow(selectedIndex, -1);
        }

        rl.drawRectangle(
            0,
            @as(i32, @intCast(selectedIndex)) * blockSize - 4,
            rl.getScreenWidth(),
            blockSize - 8,
            rl.colorAlpha(rl.Color.blue, 0.5),
        );
    } else {
        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            selectedIndex +%= 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            selectedIndex -%= 1;
        }
        selectedIndex = @mod(selectedIndex, Level.state[0].len);

        if (rl.isKeyPressed(rl.KeyboardKey.down)) {
            shiftColumn(selectedIndex, 1);
        }
        if (rl.isKeyPressed(rl.KeyboardKey.up)) {
            shiftColumn(selectedIndex, -1);
        }

        rl.drawRectangle(
            @as(i32, @intCast(selectedIndex)) * blockSize - 4,
            0,
            blockSize - 8,
            rl.getScreenHeight(),
            rl.colorAlpha(rl.Color.blue, 0.5),
        );
    }

    for (Level.state, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                rl.drawRectangle(
                    @as(i32, @intCast(z)) * blockSize,
                    @as(i32, @intCast(e)) * blockSize,
                    blockSize - 16,
                    blockSize - 16,
                    if (piece.marked) rl.Color.red else rl.Color.light_gray,
                );
            }
        }
    }
}
