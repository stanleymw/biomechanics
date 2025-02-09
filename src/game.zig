const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const types = @import("types.zig");
const gui = @import("gui.zig");
const utils = @import("utils.zig");
const assets = @import("assets.zig");

const fonts = @import("fonts.zig");

const pi = std.math.pi;
const pi2 = std.math.tau;

var selectedIndex: usize = 0;

const Direction = enum(u2) { Vertical, DiagonalUp, Horizontal, DiagonalDown };
var cursorState: Direction = .Vertical;

const MouseState = struct {
    is_held: bool = false,
    started_hold_pos: rl.Vector2,
    started_row: usize,
    started_col: usize,
    current_shift_direction: Direction,
};

var mouse_state = MouseState{
    .is_held = false,

    .started_hold_pos = rl.Vector2.init(0, 0),
    .started_row = 0,
    .started_col = 0,

    .current_shift_direction = .Vertical,
};

var Level: types.LevelData = undefined;
var level_loaded = false;

pub fn levelUnloaded() bool {
    return !level_loaded;
}

var won = false;

pub fn loadLevel(level: types.LevelData) void {
    level_loaded = true;
    Level = level;
}

pub fn unloadLevel() void {
    level_loaded = false;
    won = false;
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
        .DiagonalUp => {
            const N = Level.state.len;
            const diag_len = @min(idx, 2 * N - idx);
            var xc: usize = @min(idx, N) - 1;
            var yc: usize = undefined;
            if (N >= idx) {
                yc = 0;
            } else {
                yc = idx - N;
            }

            var count: u8 = 0;
            const old_xc = xc;
            const old_yc = yc;

            for (0..diag_len - 1) |_| {
                if (Level.state[xc][yc]) |_| {
                    count += 1;
                }
                xc -= 1;
                yc += 1;
            }

            var target_count: u8 = 0;
            xc = old_xc;
            yc = old_yc;
            for (0..diag_len - 1) |_| {
                if (Level.target_state[xc][yc]) |_| {
                    target_count += 1;
                }
                xc -= 1;
                yc += 1;
            }
            return count == target_count;
        },
        .DiagonalDown => {
            const N = Level.state.len;
            const diag_len = @min(idx, 2 * N - idx);

            var yc: usize = N - (@min(idx, N));
            var xc: usize = undefined;
            if (N >= idx) {
                xc = 0;
            } else {
                xc = idx - N;
            }

            var count: u8 = 0;
            const old_xc = xc;
            const old_yc = yc;

            for (0..diag_len - 1) |_| {
                if (Level.state[xc][yc]) |_| {
                    count += 1;
                }

                xc += 1;
                yc += 1;
            }

            var target_count: u8 = 0;
            xc = old_xc;
            yc = old_yc;
            for (0..diag_len - 1) |_| {
                if (Level.target_state[xc][yc]) |_| {
                    target_count += 1;
                }
                xc += 1;
                yc += 1;
            }
            return count == target_count;
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
        .DiagonalUp => {
            const N = Level.state.len;
            const diag_len = @min(idx, 2 * N - idx);
            var xc: usize = @min(idx, N) - 1;
            var yc: usize = undefined;
            if (N >= idx) {
                yc = 0;
            } else {
                yc = idx - N;
            }
            var tracking = false;
            var left = false;

            for (0..diag_len - 1) |_| {
                if (Level.state[xc][yc]) |_| {
                    tracking = true;
                    if (left) {
                        return false;
                    }
                } else {
                    if (tracking) {
                        left = true;
                    }
                }

                xc -= 1;
                yc += 1;
            }
            return true;
        },
        .DiagonalDown => {
            const N = Level.state.len;
            const diag_len = @min(idx, 2 * N - idx);

            var yc: usize = N - (@min(idx, N));
            var xc: usize = undefined;
            if (N >= idx) {
                xc = 0;
            } else {
                xc = idx - N;
            }

            var tracking = false;
            var left = false;

            std.debug.print("START: xc={}, yc={} for idx={}\n", .{ xc, yc, idx });
            for (0..diag_len - 1) |_| {
                if (Level.state[xc][yc]) |_| {
                    std.debug.print("{} @ {},{}\n", .{ Level.state[xc][yc].?.marking, xc, yc });
                    tracking = true;
                    if (left) {
                        return false;
                    }
                } else {
                    std.debug.print("null @ {},{}\n", .{ xc, yc });
                    if (tracking) {
                        left = true;
                    }
                }

                xc += 1;
                yc += 1;
            }
            return true;
        },
    }
    unreachable;
}

fn shiftColumn(idx: usize, amount: i32) bool {
    if (!isContiguous(.Vertical, idx)) {
        return false;
    }
    if (!isSameSizeAsTargetStateWire(.Vertical, idx)) {
        return false;
    }

    if (amount >= 0) {
        var i = (Level.state[0].len - 2);
        if (Level.state[i + 1][idx] != null) {
            return false;
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
            return false;
        }
        for (1..Level.state[0].len) |x| {
            Level.state[@intCast(@as(i32, @intCast(x)) + amount)][idx] = Level.state[x][idx];
            Level.state[x][idx] = null;
        }
    }

    assets.slide_sfx.getOrLoad().play();
    return true;
}

fn shiftDiagDown(idx: usize, amount: i32) bool {
    if (!isContiguous(.DiagonalDown, idx)) {
        std.debug.print("NOT CONTIGUOUS\n", .{});
        return false;
    }
    if (!isSameSizeAsTargetStateWire(.DiagonalDown, idx)) {
        return false;
    }

    const N = Level.state.len;
    const diag_len = @min(idx, 2 * N - idx);

    var yc: usize = N - (@min(idx, N));
    var xc: usize = undefined;
    if (N >= idx) {
        xc = 0;
    } else {
        xc = idx - N;
    }

    if (amount < 0) {
        // var j = count;
        const tmp: usize = xc;
        xc = N - yc - 1;
        yc = N - tmp - 1;

        var firsty = true;
        for (0..diag_len - 1) |_| {
            std.debug.print("SHIFT DIAGDOWN UP: {} {} for IDX={}\n", .{ xc, yc, idx });
            if (firsty and Level.state[xc][yc] != null) {
                return false;
            } else {
                firsty = false;
            }

            Level.state[xc][yc] = Level.state[xc - 1][yc - 1];
            Level.state[xc - 1][yc - 1] = null;
            xc -= 1;
            yc -= 1;
        }
    } else {
        var firsty = true;
        for (0..diag_len - 1) |_| {
            std.debug.print("SHIFT DIAGDOWn DOWN: {} {} for IDX={}\n", .{ xc, yc, idx });
            if (firsty and Level.state[xc][yc] != null) {
                return false;
            } else {
                firsty = false;
            }
            Level.state[xc][yc] = Level.state[xc + 1][yc + 1];
            Level.state[xc + 1][yc + 1] = null;
            xc += 1;
            yc += 1;
        }
    }

    assets.slide_sfx.getOrLoad().play();
    return true;
}

fn shiftDiagUp(idx: usize, amount: i32) bool {
    if (!isContiguous(.DiagonalUp, idx)) {
        std.debug.print("NOT CONTIGUOUS\n", .{});
        return false;
    }
    if (!isSameSizeAsTargetStateWire(.DiagonalUp, idx)) {
        return false;
    }

    const N = Level.state.len;
    const diag_len = @min(idx, 2 * N - idx);
    var xc: usize = @min(idx, N) - 1;
    var yc: usize = undefined;
    if (N >= idx) {
        yc = 0;
    } else {
        yc = idx - N;
    }
    if (amount >= 0) {
        // var j = count;
        const tmp: usize = xc;
        xc = yc;
        yc = tmp;

        var firsty = true;
        for (0..diag_len - 1) |_| {
            if (firsty and Level.state[xc][yc] != null) {
                return false;
            } else {
                firsty = false;
            }

            Level.state[xc][yc] = Level.state[xc + 1][yc - 1];
            Level.state[xc + 1][yc - 1] = null;
            xc += 1;
            yc -= 1;
        }
    } else {
        var firsty = true;
        for (0..diag_len - 1) |_| {
            std.debug.print("SHIFT DIAGUP DOWN: {} {} for IDX={}\n", .{ xc, yc, idx });
            if (firsty and Level.state[xc][yc] != null) {
                return false;
            } else {
                firsty = false;
            }
            Level.state[xc][yc] = Level.state[xc - 1][yc + 1];
            Level.state[xc - 1][yc + 1] = null;
            xc -= 1;
            yc += 1;
        }
    }

    assets.slide_sfx.getOrLoad().play();
    return true;
}

fn shiftRow(idx: usize, amount: i32) bool {
    if (!isContiguous(.Horizontal, idx)) {
        return false;
    }
    if (!isSameSizeAsTargetStateWire(.Horizontal, idx)) {
        return false;
    }

    if (amount >= 0) {
        var i = (Level.state[0].len - 2);
        if (Level.state[idx][i + 1] != null) {
            return false;
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
            return false;
        }
        for (1..Level.state[0].len) |x| {
            Level.state[idx][@intCast(@as(i32, @intCast(x)) + amount)] = Level.state[idx][x];
            Level.state[idx][x] = null;
        }
    }

    assets.slide_sfx.getOrLoad().play();
    return true;
}

var block_size: i32 = 0;
var padding: i32 = 0;

fn indexToWorldPos(pos: u8) i32 {
    return pos * block_size + (block_size >> 1);
}

fn worldPosToIndex(pos: f32) u8 {
    if (pos < 1.0) {
        return 0;
    }
    return @intCast(@divFloor(@as(i32, @intFromFloat(pos)), block_size));
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
                _ = shiftColumn(Level.vertical_wires[selectedIndex], -1);
            }
            if (rl.isKeyPressed(.down)) {
                _ = shiftColumn(Level.vertical_wires[selectedIndex], 1);
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
                _ = shiftDiagUp(Level.diag_up_wires[selectedIndex] + 1, 1);
            }
            if (rl.isKeyPressed(.left)) {
                _ = shiftDiagUp(Level.diag_up_wires[selectedIndex] + 1, -1);
            }
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
                _ = shiftRow(Level.horizontal_wires[selectedIndex], 1);
            }
            if (rl.isKeyPressed(.left)) {
                _ = shiftRow(Level.horizontal_wires[selectedIndex], -1);
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
                _ = shiftDiagDown(Level.diag_down_wires[selectedIndex] + 1, -1);
            }
            if (rl.isKeyPressed(.left)) {
                _ = shiftDiagDown(Level.diag_down_wires[selectedIndex] + 1, 1);
            }
        },
    }
    renderWiresForDirectionWithSelectedIndex(.Vertical, selectedIndex, cursorState == .Vertical);
    renderWiresForDirectionWithSelectedIndex(.Horizontal, selectedIndex, cursorState == .Horizontal);
    renderWiresForDirectionWithSelectedIndex(.DiagonalUp, selectedIndex, cursorState == .DiagonalUp);
    renderWiresForDirectionWithSelectedIndex(.DiagonalDown, selectedIndex, cursorState == .DiagonalDown);

    const current_mouse_pos = rl.getMousePosition();
    if (rl.isMouseButtonDown(.left)) {
        if (!mouse_state.is_held) {
            mouse_state.is_held = true;

            mouse_state.started_hold_pos = current_mouse_pos;
            mouse_state.started_col = worldPosToIndex(current_mouse_pos.x);
            mouse_state.started_row = worldPosToIndex(current_mouse_pos.y);

            if (Level.state[mouse_state.started_row][mouse_state.started_col] == null) {
                mouse_state.is_held = false;
            }
        }
        if (mouse_state.is_held) {
            // calculate how far it is from the start pos
            // rl.drawLineEx(mouse_state.started_hold_pos, current_mouse_pos, 2.0, rl.Color.green);
            const angle = std.math.atan2(
                mouse_state.started_hold_pos.y - current_mouse_pos.y,
                mouse_state.started_hold_pos.x - current_mouse_pos.x,
            );

            // const ir = worldPosToIndex(current_mouse_pos.x);
            // const ic = worldPosToIndex(current_mouse_pos.y);

            // rl.drawRectangle(ir * block_size, ic * block_size, block_size, block_size, rl.Color.green);

            // if (ir != mouse_state.started_row or ic != mouse_state.started_col) {
            if (true) {
                var shiftUp: bool = undefined;
                var shiftDir: Direction = undefined;
                if (angle <= -pi + pi / 6.0) {
                    shiftDir = .Horizontal;
                    shiftUp = true;
                } else if (angle <= -pi + pi / 3.0) {
                    shiftDir = .DiagonalDown;
                    shiftUp = false;
                } else if (angle <= -pi + pi / 2.0 + pi / 6.0) {
                    shiftDir = .Vertical;
                    shiftUp = false;
                } else if (angle <= -pi + pi / 2.0 + pi / 6.0 + pi / 6.0) {
                    shiftDir = .DiagonalUp;
                    shiftUp = false;
                } else if (angle <= 0 + pi / 6.0) {
                    shiftDir = .Horizontal;
                    shiftUp = false;
                } else if (angle <= pi / 3.0) {
                    shiftDir = .DiagonalDown;
                    shiftUp = true;
                } else if (angle <= pi / 2.0 + pi / 6.0) {
                    shiftDir = .Vertical;
                    shiftUp = true;
                } else if (angle <= pi / 2.0 + pi / 3.0) {
                    shiftDir = .DiagonalUp;
                    shiftUp = true;
                } else {
                    shiftDir = .Horizontal;
                    shiftUp = true;
                }

                mouse_state.current_shift_direction = shiftDir;
                // std.debug.print("{}: {}\n", .{ shiftDir, shiftUp });
            }
        }
    } else {
        if (mouse_state.is_held) {
            mouse_state.is_held = false;

            // const ir = worldPosToIndex(current_mouse_pos.x);
            // const ic = worldPosToIndex(current_mouse_pos.y);
            // calculate all the changes
            switch (mouse_state.current_shift_direction) {
                .Vertical => {
                    const now: i32 = @intCast(worldPosToIndex(current_mouse_pos.y));
                    const prev: i32 = @intCast(mouse_state.started_row);

                    for (0..@intCast(@abs(prev - now))) |x| {
                        _ = shiftColumn(mouse_state.started_col, if (prev > now) -1 else 1);
                        std.debug.print("shift no: {}\n", .{x});
                    }
                    std.debug.print("delta: {}\n", .{prev - now});
                },
                .DiagonalUp => {},
                .Horizontal => {
                    const now: i32 = @intCast(worldPosToIndex(current_mouse_pos.x));
                    const prev: i32 = @intCast(mouse_state.started_col);

                    for (0..@intCast(@abs(prev - now))) |x| {
                        _ = shiftRow(mouse_state.started_row, if (prev > now) -1 else 1);
                        std.debug.print("shift no: {}\n", .{x});
                    }
                    std.debug.print("delta: {}\n", .{prev - now});
                },
                .DiagonalDown => {},
            }
        }
    }

    const rendering_target: bool = rl.isKeyDown(.q);

    // render pieces
    for (if (rendering_target) Level.target_state else Level.state, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                const block_size_f: f32 = @floatFromInt(block_size);

                var block_x: f32 = @as(f32, @floatFromInt(z)) * block_size_f + block_size_f / 2;
                var block_y: f32 = @as(f32, @floatFromInt(e)) * block_size_f + block_size_f / 2;

                if (mouse_state.is_held) {
                    switch (mouse_state.current_shift_direction) {
                        .Vertical => {
                            if (z == mouse_state.started_col) {
                                block_y += current_mouse_pos.y - mouse_state.started_hold_pos.y;
                            }
                        },
                        .DiagonalUp => {
                            // block_x += current_mouse_pos.x - mouse_state.started_hold_pos.x;
                            // block_y += current_mouse_pos.y - mouse_state.started_hold_pos.y;
                        },
                        .Horizontal => {
                            if (e == mouse_state.started_row) {
                                block_x += current_mouse_pos.x - mouse_state.started_hold_pos.x;
                            }
                        },
                        .DiagonalDown => {
                            // block_x += current_mouse_pos.x - mouse_state.started_hold_pos.x;
                            // block_y += current_mouse_pos.y - mouse_state.started_hold_pos.y;
                        },
                    }
                }

                gui.drawTextureCenteredAtPoint(
                    2.0,
                    0.0,
                    rl.Vector2.init(
                        block_x,
                        block_y,
                    ),
                    markingToTexture(piece.marking),
                );
            }
        }
    }

    if (rendering_target) {
        rl.drawTextEx(
            fonts.main_font,
            "Target State",
            rl.Vector2.init(10, 64),
            fonts.Size.Large,
            0,
            rl.Color.white,
        );
    }

    if (rl.isKeyDown(.right_bracket) or hasWon()) {
        if (!won) {
            won = true;
            assets.win_sfx.getOrLoad().play();
        }

        rl.drawTextEx(
            fonts.main_font,
            "Click to continue...",
            rl.Vector2.init(10, @floatFromInt(rl.getRenderHeight() - 64)),
            fonts.Size.Medium,
            0,
            rl.Color.white,
        );

        if (gui.imgBtn(
            0.6,
            utils.renderSize().scale(0.5),
            assets.completedComponent.getOrLoad(),
            null,
            null,
            rl.getMousePosition(),
        )) {
            won = false;
            return true;
        }
    } else {
        won = false;
    }
    return false;
}
