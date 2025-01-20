const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const fonts = @import("fonts.zig");
const game = @import("game.zig");

const screenWidth = 1920;
const screenHeight = 1080;

const Screen = enum { MainMenu, Globe, Play };

fn drawTextureCentered(scaleFactor: f32, rotation: f32, texture: rl.Texture) void {
    const scaledWidth = @as(f32, @floatFromInt(texture.width)) * scaleFactor;
    const scaledHeight = @as(f32, @floatFromInt(texture.height)) * scaleFactor;
    rl.drawTextureEx(texture, rl.Vector2.init(screenWidth / 2 - scaledWidth / 2, screenHeight / 2 - scaledHeight / 2), rotation, scaleFactor, rl.Color.white);
}

var poiPinTex: rl.Texture2D = undefined;
var poiPinLockedTex: rl.Texture2D = undefined;
var poiPinHoverTex: rl.Texture2D = undefined;

const PoiPin = struct {
    x: f32,
    y: f32,
    isLocked: bool = true,

    const Self = @This();
    fn calculateClickBounds(size: f32, x: f32, y: f32) rl.Rectangle {
        return rl.Rectangle.init(x - size / 2, y - size / 2, size, size);
    }
    fn render(self: *Self, mPos: rl.Vector2) bool {
        var pressed = false;

        const newX = @as(f32, @floatFromInt(rl.getScreenWidth())) * self.x;
        const newY = @as(f32, @floatFromInt(rl.getScreenHeight())) * self.y;

        const tex =
            if (self.isLocked)
            poiPinLockedTex
        else if (rl.checkCollisionPointRec(mPos, calculateClickBounds(50, newX, newY))) block: {
            pressed = rl.isMouseButtonPressed(.left);
            break :block poiPinHoverTex;
        } else poiPinTex;

        rl.drawTextureEx(
            tex,
            rl.Vector2.init(newX, newY),
            0.0,
            1.0,
            rl.Color.white,
        );

        return pressed;
    }
};

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    const mainFont = fonts.loadFont(fonts.Family.ComputerModern, fonts.Size.Medium);

    rl.drawFPS(0, 0);

    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fonts.Size.Medium);

    rg.guiSetFont(mainFont);

    var currentScreen: Screen = .MainMenu;

    game.createWorld();

    const globeTexture = rl.loadTextureFromImage(rl.loadImage("resources/globe.png"));
    poiPinTex = rl.loadTextureFromImage(rl.loadImage("resources/poi.png"));
    poiPinLockedTex = rl.loadTextureFromImage(rl.loadImage("resources/poi.png"));
    poiPinHoverTex = rl.loadTextureFromImage(rl.loadImage("resources/poi.png"));

    var mousePos = rl.Vector2.init(0, 0);
    const pois = [_]PoiPin{
        .{ .x = 0.5, .y = 0.5 },
        .{ .x = 0.75, .y = 0.2 },
    };

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(rl.Color.white);
            mousePos = rl.getMousePosition();

            switch (currentScreen) {
                .MainMenu => {
                    rl.drawTextEx(mainFont, "Game", rl.Vector2.init(190, 200), fonts.Size.Medium, 0, rl.Color.light_gray);

                    if (rg.guiButton(rl.Rectangle.init(10, 10, 256, 64), "Play") > 0) {
                        currentScreen = .Globe;
                    }
                },
                .Globe => {
                    drawTextureCentered(8.0, 0, globeTexture);
                    var none_pressed = true;
                    for (pois) |pin| {
                        none_pressed = none_pressed and !@constCast(&pin).render(mousePos);
                    }
                    if (!none_pressed) {
                        currentScreen = .Play;
                    }
                },
                .Play => {
                    game.render();
                },
            }

            rl.drawFPS(0, 0);
        }
    }
}
