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

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    const mainFont = fonts.loadFont(fonts.Family.ComputerModern, fonts.Size.Medium);

    rl.drawFPS(0, 0);

    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fonts.Size.Medium);

    rg.guiSetFont(mainFont);

    var currentScreen: Screen = .MainMenu;

    // const globeTexture = rl.loadTextureFromImage(rl.loadImage("resources/globe.png"));

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(rl.Color.white);

            switch (currentScreen) {
                .MainMenu => {
                    rl.drawTextEx(mainFont, "Game", rl.Vector2.init(190, 200), fonts.Size.Medium, 0, rl.Color.light_gray);

                    if (rg.guiButton(rl.Rectangle.init(10, 10, 256, 64), "Play") > 0) {
                        currentScreen = .Globe;
                    }
                },
                .Globe => {
                    // drawTextureCentered(8.0, 0, globeTexture);
                    game.render();
                },
                .Play => {},
            }

            rl.drawFPS(0, 0);
        }
    }
}
