const rl = @import("raylib");

pub fn renderSize() rl.Vector2 {
    return rl.Vector2.init(
        @as(f32, @floatFromInt(rl.getScreenWidth())),
        @as(f32, @floatFromInt(rl.getScreenHeight())),
    );
}
