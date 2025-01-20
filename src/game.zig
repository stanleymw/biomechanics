const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const N = 4;

var horizontal = false;
var idx: i32 = 0;

const PuzzlePiece = struct { marked: bool };

var World: [15][15]?PuzzlePiece = undefined;

pub fn render() void {
    // rl.drawRectangle(0, 0, 128, 128, rl.Color.red);

    if (rl.isKeyPressed(rl.KeyboardKey.space)) {
        horizontal = !horizontal;
    }

    if (horizontal) {
        if (rl.isKeyPressed(rl.KeyboardKey.down)) {
            idx += 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.up)) {
            idx -= 1;
        }
        idx = @mod(idx, N);
        rl.drawRectangle(
            0,
            idx * 160 - 8,
            160 * N,
            144,
            rl.colorAlpha(rl.Color.blue, 0.5),
        );
    } else {
        if (rl.isKeyPressed(rl.KeyboardKey.right)) {
            idx += 1;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.left)) {
            idx -= 1;
        }
        idx = @mod(idx, N);
        rl.drawRectangle(
            idx * 160 - 8,
            0,
            144,
            160 * N,
            rl.colorAlpha(rl.Color.blue, 0.5),
        );
    }

    for (0..N * N) |i| {
        World[@mod(i, N)][@divFloor(i, N)] = PuzzlePiece{ .marked = false };

        // rl.drawRectangle((@mod(x, N)) * 160, @divFloor(x, N) * 160, 128, 128, rl.colorFromHSV(@as(f32, @floatFromInt((x + 1))) * 360.0 / (N * N), 1, 0.5));
    }
    World[1][1].?.marked = true;

    for (World, 0..) |row, e| {
        for (row, 0..) |pieceMaybe, z| {
            if (pieceMaybe) |piece| {
                rl.drawRectangle(
                    @as(i32, @intCast(e)) * 160,
                    @as(i32, @intCast(z)) * 160,
                    128,
                    128,
                    if (piece.marked) rl.Color.red else rl.Color.light_gray,
                );
            }
        }
    }
}
