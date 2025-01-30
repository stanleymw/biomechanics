const rl = @import("raylib");

pub fn renderSize() rl.Vector2 {
    return rl.Vector2.init(
        @as(f32, @floatFromInt(rl.getScreenWidth())),
        @as(f32, @floatFromInt(rl.getScreenHeight())),
    );
}

pub fn xv(x: f32) rl.Vector2 {
    return rl.Vector2.init(x, 0);
}
pub fn yv(y: f32) rl.Vector2 {
    return rl.Vector2.init(0, y);
}
pub fn v2(x: f32, y: f32) rl.Vector2 {
    return rl.Vector2.init(x, y);
}
