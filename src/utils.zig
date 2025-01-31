const rl = @import("raylib");

pub fn renderSize() rl.Vector2 {
    return rl.Vector2.init(
        @as(f32, @floatFromInt(rl.getScreenWidth())),
        @as(f32, @floatFromInt(rl.getScreenHeight())),
    );
}

pub fn texSize(tex: rl.Texture) rl.Vector2 {
    return rl.Vector2.init(
        @as(f32, @floatFromInt(tex.width)),
        @as(f32, @floatFromInt(tex.height)),
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
/// rectangle from vec2 with with and height
pub fn withWH(v: rl.Vector2, w: f32, h: f32) rl.Rectangle {
    return rl.Rectangle.init(v.x, v.y, w, h);
}
