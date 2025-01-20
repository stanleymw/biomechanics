const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const N = 4;

var horizontal = false;
var selectedIndex: usize = 0;

const PuzzlePiece = struct { marked: bool };

var World: [15][15]?PuzzlePiece = undefined;

pub fn createWorld() void {
    for (0..N * N) |i| {
        World[@mod(i, N)][@divFloor(i, N)] = PuzzlePiece{ .marked = false };

        // rl.drawRectangle((@mod(x, N)) * 160, @divFloor(x, N) * 160, 128, 128, rl.colorFromHSV(@as(f32, @floatFromInt((x + 1))) * 360.0 / (N * N), 1, 0.5));
    }
    World[1][1].?.marked = true;
}

fn shiftColumn(idx: usize, amount: i32) void {
    if (amount >= 0) {
        var i = (World[0].len - 2);
        if (World[i + 1][idx] != null) {
            return;
        }
        while (i >= 0) : (i -= 1) {
            World[@intCast(@as(i32, @intCast(i)) + amount)][idx] = World[i][idx];
            World[i][idx] = null;

            if (i == 0) {
                break;
            }
        }
    } else {
        if (World[0][idx] != null) {
            return;
        }
        for (1..World[0].len - 1) |x| {
            World[@intCast(@as(i32, @intCast(x)) + amount)][idx] = World[x][idx];
            World[x][idx] = null;
        }
    }
}

fn shiftRow(idx: usize, amount: i32) void {
    if (amount >= 0) {
        var i = (World[0].len - 2);
        if (World[idx][i + 1] != null) {
            return;
        }
        while (i >= 0) : (i -= 1) {
            World[idx][@intCast(@as(i32, @intCast(i)) + amount)] = World[idx][i];
            World[idx][i] = null;

            if (i == 0) {
                break;
            }
        }
    } else {
        if (World[idx][0] != null) {
            return;
        }
        for (1..World[0].len - 1) |x| {
            World[idx][@intCast(@as(i32, @intCast(x)) + amount)] = World[idx][x];
            World[idx][x] = null;
        }
    }
}

pub fn render() void {
    // rl.drawRectangle(0, 0, 128, 128, rl.Color.red);

    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        horizontal = !horizontal;
    }

    if (horizontal) {
        if (rl.isKeyPressed(rl.KeyboardKey.down)) {
            selectedIndex +%= 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.up)) {
            selectedIndex -%= 1;
        }

        selectedIndex = @mod(selectedIndex, N);

        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            shiftRow(selectedIndex, 1);
        }
        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            shiftRow(selectedIndex, -1);
        }

        rl.drawRectangle(
            0,
            @as(i32, @intCast(selectedIndex)) * 160 - 8,
            rl.getScreenWidth(),
            144,
            rl.colorAlpha(rl.Color.blue, 0.5),
        );
    } else {
        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            selectedIndex +%= 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            selectedIndex -%= 1;
        }
        selectedIndex = @mod(selectedIndex, N);

        if (rl.isKeyPressed(rl.KeyboardKey.down)) {
            shiftColumn(selectedIndex, 1);
        }
        if (rl.isKeyPressed(rl.KeyboardKey.up)) {
            shiftColumn(selectedIndex, -1);
        }

        rl.drawRectangle(
            @as(i32, @intCast(selectedIndex)) * 160 - 8,
            0,
            144,
            rl.getScreenHeight(),
            rl.colorAlpha(rl.Color.blue, 0.5),
        );
    }

    for (World, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                rl.drawRectangle(
                    @as(i32, @intCast(z)) * 160,
                    @as(i32, @intCast(e)) * 160,
                    128,
                    128,
                    if (piece.marked) rl.Color.red else rl.Color.light_gray,
                );
            }
        }
    }
}
