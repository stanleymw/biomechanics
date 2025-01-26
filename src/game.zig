const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const types = @import("types.zig");

const N = 3;

var selectedIndex: usize = 0;

const Direction = enum(u2) { Vertical, DiagonalUp, Horizontal, DiagonalDown };
var cursorState: Direction = .Vertical;

var Level: types.LevelData = undefined;

pub fn createWorld() void {
    for (0..N * N) |i| {
        Level.state[6 + @mod(i, N)][6 + @divFloor(i, N)] = types.PuzzlePiece{ .marked = false };

        // rl.drawRectangle((@mod(x, N)) * 160, @divFloor(x, N) * 160, 128, 128, rl.colorFromHSV(@as(f32, @floatFromInt((x + 1))) * 360.0 / (N * N), 1, 0.5));
    }
    Level.state[6][7].?.marked = true;

    Level.horizontal_wires = &[_]u8{ 6, 7, 8 };
    Level.vertical_wires = &[_]u8{ 6, 7, 8 };
    Level.diag_up_wires = &[_]u8{ 12, 13, 14 };
    Level.diag_down_wires = &[_]u8{ 12, 13, 14 };
}

fn isShiftable(indices: []const u8, idx: usize) bool {
    for (indices) |x| {
        if (@as(usize, @intCast(x)) == idx) {
            return true;
        }
    }
    return false;
}

fn isContiguous(typ: Direction, idx: usize) bool {
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

fn shiftDiagDown(idx: usize, amount: i32) void {
    if (!isShiftable(Level.diag_down_wires, idx) or !isContiguous(.DiagonalDown, idx))
        return;
    if (amount < 0) {
        if (Level.state[idx][0] != null) return;
        for (1..2 * Level.state[0].len - 2) |x| {
            Level.state[@intCast(@as(i32, @intCast(idx - x)) + amount)][@intCast(@as(i32, @intCast(x)) + amount)] = Level.state[idx - x][x];
            Level.state[idx - x][x] = null;
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

var block_size: i32 = 0;
var padding: i32 = 0;

fn indexToWorldPos(pos: u8) i32 {
    return pos * block_size + (block_size >> 1);
}

fn renderWiresForDirectionWithSelectedIndex(direction: Direction, idx: usize, is_active: bool) void {
    const wires = directionToWires(direction);
    switch (direction) {
        .Vertical => {
            for (wires, 0..) |pos, loc| {
                const coord = indexToWorldPos(pos);
                rl.drawLine(
                    coord,
                    0,
                    coord,
                    rl.getRenderHeight(),
                    if (is_active and loc == idx) rl.Color.red else rl.Color.gray,
                );
            }
        },
        .DiagonalUp => {
            for (wires, 0..) |pos, loc| {
                const coord = indexToWorldPos(pos);
                rl.drawLine(
                    0,
                    coord,
                    coord,
                    0,
                    if (is_active and loc == idx) rl.Color.red else rl.Color.gray,
                );
            }
        },
        .Horizontal => {
            for (wires, 0..) |pos, loc| {
                const coord = indexToWorldPos(pos);
                rl.drawLine(
                    0,
                    coord,
                    rl.getRenderWidth(),
                    coord,
                    if (is_active and loc == idx) rl.Color.red else rl.Color.gray,
                );
            }
        },
        .DiagonalDown => {
            for (wires, 0..) |pos, loc| {
                const coord = indexToWorldPos(pos);
                rl.drawLine(
                    coord,
                    0,
                    0,
                    coord,
                    if (is_active and loc == idx) rl.Color.red else rl.Color.gray,
                );
            }
        },
    }
}

fn directionToWires(dir: Direction) []const u8 {
    return switch (dir) {
        .Vertical => Level.vertical_wires,
        .Horizontal => Level.horizontal_wires,
        .DiagonalDown => Level.diag_down_wires,
        .DiagonalUp => Level.diag_up_wires,
    };
}

pub fn render() void {
    block_size = @divTrunc(rl.getScreenHeight(), @as(i32, @intCast(Level.state.len)));
    padding = block_size >> 3;
    // rl.drawRectangle(0, 0, 128, 128, rl.Color.red);

    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        cursorState = @enumFromInt(@intFromEnum(cursorState) +% 1);
        selectedIndex = 0;
    }

    switch (cursorState) {
        .Vertical => {
            if (rl.isKeyPressed(.right)) {
                selectedIndex +%= 1;
            }
            if (rl.isKeyPressed(.left)) {
                selectedIndex -%= 1;
            }
            selectedIndex = @mod(selectedIndex, Level.vertical_wires.len);

            if (rl.isKeyPressed(.up)) {
                shiftColumn(Level.vertical_wires[selectedIndex], -1);
            }
            if (rl.isKeyPressed(.down)) {
                shiftColumn(Level.vertical_wires[selectedIndex], 1);
            }
        },
        .DiagonalUp => {},
        .Horizontal => {
            if (rl.isKeyPressed(.down)) {
                selectedIndex +%= 1;
            }
            if (rl.isKeyPressed(.up)) {
                selectedIndex -%= 1;
            }

            selectedIndex = @mod(selectedIndex, Level.horizontal_wires.len);

            if (rl.isKeyPressed(.right)) {
                shiftRow(Level.horizontal_wires[selectedIndex], 1);
            }
            if (rl.isKeyPressed(.left)) {
                shiftRow(Level.horizontal_wires[selectedIndex], -1);
            }
        },
        .DiagonalDown => {},
    }
    renderWiresForDirectionWithSelectedIndex(.Vertical, selectedIndex, cursorState == .Vertical);
    renderWiresForDirectionWithSelectedIndex(.Horizontal, selectedIndex, cursorState == .Horizontal);

    // render pieces
    for (Level.state, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                rl.drawRectangle(
                    (@as(i32, @intCast(z)) * block_size) + padding,
                    (@as(i32, @intCast(e)) * block_size) + padding,
                    block_size - (2 * padding),
                    block_size - (2 * padding),
                    if (piece.marked) rl.Color.red else rl.Color.light_gray,
                );
            }
        }
    }
}
