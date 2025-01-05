const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

pub const Sizes = struct {
    pub const Large = 64;
    pub const Medium = 48;
    pub const Small = 36;
};

pub var ComputerModern = struct {
    pub var Large = rl.loadFontEx("resources/font.otf", Sizes.Large, null);
    pub var Medium = rl.loadFontEx("resources/font.otf", Sizes.Medium, null);
    pub var Small = rl.loadFontEx("resources/font.otf", Sizes.Small, null);
};

pub var Inter = struct {
    pub var Large = rl.loadFontEx("resources/inter.ttf", Sizes.Large, null);
    pub var Medium = rl.loadFontEx("resources/inter.ttf", Sizes.Medium, null);
    pub var Small = rl.loadFontEx("resources/inter.ttf", Sizes.Small, null);
};
