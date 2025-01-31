const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

pub const Size = struct {
    pub const Large = 64;
    pub const Medium = 48;
    pub const Small = 36;
};

pub const Family = struct {
    pub const ComputerModern = "resources/font.otf";
    pub const ArkPixel = "resources/ark-pixel-10px.otf";
};

pub fn loadFont(f: [*:0]const u8, s: i32) rl.Font {
    return rl.loadFontEx(f, s, null);
}

pub var main_font: rl.Font = undefined;
