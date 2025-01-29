const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const types = @import("types.zig");
const gui = @import("gui.zig");
const utils = @import("utils.zig");
const assets = @import("assets.zig");

const N = 3;

var selectedIndex: usize = 0;

const Direction = enum(u2) { Vertical, DiagonalUp, Horizontal, DiagonalDown };
var cursorState: Direction = .Vertical;

var Level: types.LevelData = undefined;
var level_loaded = false;

pub fn levelUnloaded() bool {
    return !level_loaded;
}

pub fn loadLevel(level: types.LevelData) void {
    level_loaded = true;
    Level = level;
}

fn isSameSizeAsTargetStateWire(typ: Direction, idx: usize) bool {
    switch (typ) {
        .Horizontal => {
            var count: u8 = 0;
            for (Level.state[idx]) |x| {
                if (x) |_| {
                    count += 1;
                }
            }
            var target_count: u8 = 0;
            for (Level.target_state[idx]) |x| {
                if (x) |_| {
                    target_count += 1;
                }
            }
            return count == target_count;
        },
        .Vertical => {
            var count: u8 = 0;
            for (Level.state) |x| {
                if (x[idx]) |_| {
                    count += 1;
                }
            }
            var target_count: u8 = 0;
            for (Level.target_state) |x| {
                if (x[idx]) |_| {
                    target_count += 1;
                }
            }
            return count == target_count;
        },
        else => {
            unreachable;
        },
    }
    unreachable;
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
    if (!isContiguous(.Vertical, idx)) {
        return;
    }
    if (!isSameSizeAsTargetStateWire(.Vertical, idx)) {
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
        for (1..Level.state[0].len) |x| {
            Level.state[@intCast(@as(i32, @intCast(x)) + amount)][idx] = Level.state[x][idx];
            Level.state[x][idx] = null;
        }
    }
}

fn shiftDiagDown(idx: usize, amount: i32) void {
    if (amount < 0) {
        if (Level.state[idx][0] != null) return;
        for (1..2 * Level.state[0].len - 2) |x| {
            Level.state[@intCast(@as(i32, @intCast(idx - x)) + amount)][@intCast(@as(i32, @intCast(x)) + amount)] = Level.state[idx - x][x];
            Level.state[idx - x][x] = null;
        }
    }
}

fn shiftDiagUp(idx: usize, amount: i32) void {
    if (amount >= 0) {
        if (Level.state[0][idx] != null) {
            return; // prevent from shifting out of the world
        }
        var i = idx;
        while (i > 0) : (i -= 1) {
            Level.state[idx - i][i] = Level.state[idx - i + 1][i - 1];
        }
    } else {}
}

fn shiftRow(idx: usize, amount: i32) void {
    if (!isContiguous(.Horizontal, idx)) {
        return;
    }
    if (!isSameSizeAsTargetStateWire(.Horizontal, idx)) {
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
        for (1..Level.state[0].len) |x| {
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
                const coord = indexToWorldPos(pos) + (block_size >> 1);
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
                const coord = indexToWorldPos(pos) + (block_size >> 1);
                rl.drawLine(
                    rl.getRenderWidth() - coord,
                    0,
                    rl.getRenderWidth(),
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

fn markingToColor(mark: u8) rl.Color {
    return switch (mark) {
        0 => rl.Color.light_gray,
        1 => rl.Color.red,
        else => unreachable,
    };
}

fn markingToTexture(mark: u8) rl.Texture2D {
    return Level.markingPictures[mark].getOrLoad();
}

fn hasWon() bool {
    for (Level.target_state, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                if (Level.state[e][z]) |otro| {
                    if (!std.meta.eql(piece, otro)) {
                        return false;
                    }
                } else {
                    return false;
                }
            } else {
                // this is null
                if (Level.state[e][z] != null) {
                    return false;
                }
            }
        }
    }
    return true;
}

pub fn loop() bool {
    block_size = @divTrunc(rl.getRenderHeight(), @as(i32, @intCast(Level.state.len)));
    padding = block_size >> 3;
    // rl.drawRectangle(0, 0, 128, 128, rl.Color.red);

    if (rl.isKeyPressed(.space) or directionToWires(cursorState).len == 0) {
        var val = @intFromEnum(cursorState) +% 1;
        while (true) : (val +%= 1) {
            cursorState = @enumFromInt(val);
            if (directionToWires(cursorState).len != 0) {
                break;
            }
        }

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
            selectedIndex = @mod(selectedIndex, directionToWires(cursorState).len);

            if (rl.isKeyPressed(.up)) {
                shiftColumn(Level.vertical_wires[selectedIndex], -1);
            }
            if (rl.isKeyPressed(.down)) {
                shiftColumn(Level.vertical_wires[selectedIndex], 1);
            }
        },
        .DiagonalUp => {
            if (rl.isKeyPressed(.down)) {
                selectedIndex +%= 1;
            }
            if (rl.isKeyPressed(.up)) {
                selectedIndex -%= 1;
            }

            selectedIndex = @mod(selectedIndex, directionToWires(cursorState).len);

            if (rl.isKeyPressed(.right)) {
                shiftDiagUp(selectedIndex, 1);
            }
            if (rl.isKeyPressed(.left)) {}
        },
        .Horizontal => {
            if (rl.isKeyPressed(.down)) {
                selectedIndex +%= 1;
            }
            if (rl.isKeyPressed(.up)) {
                selectedIndex -%= 1;
            }

            selectedIndex = @mod(selectedIndex, directionToWires(cursorState).len);

            if (rl.isKeyPressed(.right)) {
                shiftRow(Level.horizontal_wires[selectedIndex], 1);
            }
            if (rl.isKeyPressed(.left)) {
                shiftRow(Level.horizontal_wires[selectedIndex], -1);
            }
        },
        .DiagonalDown => {
            if (rl.isKeyPressed(.down)) {
                selectedIndex +%= 1;
            }
            if (rl.isKeyPressed(.up)) {
                selectedIndex -%= 1;
            }

            selectedIndex = @mod(selectedIndex, directionToWires(cursorState).len);

            if (rl.isKeyPressed(.right)) {
                shiftRow(Level.horizontal_wires[selectedIndex], 1);
            }
            if (rl.isKeyPressed(.left)) {
                shiftRow(Level.horizontal_wires[selectedIndex], -1);
            }
        },
    }
    renderWiresForDirectionWithSelectedIndex(.Vertical, selectedIndex, cursorState == .Vertical);
    renderWiresForDirectionWithSelectedIndex(.Horizontal, selectedIndex, cursorState == .Horizontal);
    renderWiresForDirectionWithSelectedIndex(.DiagonalUp, selectedIndex, cursorState == .DiagonalUp);
    renderWiresForDirectionWithSelectedIndex(.DiagonalDown, selectedIndex, cursorState == .DiagonalDown);

    const rendering_target: bool = rl.isKeyDown(.q);

    // render pieces
    for (if (rendering_target) Level.target_state else Level.state, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                const block_size_f: f32 = @floatFromInt(block_size);
                gui.drawTextureCenteredAtPoint(
                    2.0,
                    0.0,
                    rl.Vector2.init(
                        @as(f32, @floatFromInt(z)) * block_size_f + block_size_f / 2,
                        @as(f32, @floatFromInt(e)) * block_size_f + block_size_f / 2,
                    ),
                    markingToTexture(piece.marking),
                );
            }
        }
    }

    if (rendering_target) {
        rl.drawText("Target State", 0, 0, 48, rl.Color.white);
    }
    if (hasWon()) {
        if (gui.imgBtn(
            0.6,
            utils.renderSize().scale(0.5),
            assets.completedComponent.getOrLoad(),
            null,
            null,
            rl.getMousePosition(),
        )) {
            return true;
        }
    }
    return false;
}
