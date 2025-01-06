const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const screenWidth = 1280;
const screenHeight = 720;
const fontSize = 64;

const Screen = enum { MainMenu, Globe, Play };

fn drawTextureCentered(scaleFactor: f32, rotation: f32, texture: rl.Texture) void {
    const scaledWidth = @as(f32, @floatFromInt(texture.width)) * scaleFactor;
    const scaledHeight = @as(f32, @floatFromInt(texture.height)) * scaleFactor;
    rl.drawTextureEx(texture, rl.Vector2.init(rl.getScreenWidth() / 2 - scaledWidth / 2, rl.getScreenHeight() / 2 - scaledHeight / 2), rotation, scaleFactor, rl.Color.white);
}

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fontSize);

    //const ascii = range(256);
    const mainFont = rl.loadFontEx(
        "resources/font.otf",
        fontSize,
        null,
    );
    const boldFont = rl.loadFontEx(
        "resources/bold-font.otf",
        fontSize,
        null,
    );
    rg.guiSetFont(mainFont);

    var currentScreen: Screen = .MainMenu;

    const globeTexture = rl.loadTextureFromImage(rl.loadImage("resources/globe.png"));

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(rl.Color.white);

            switch (currentScreen) {
                .MainMenu => {
                    rl.drawTextEx(boldFont, "Game", rl.Vector2.init(190, 200), 100, 0, rl.Color.light_gray);
                    if (rg.guiButton(rl.Rectangle.init(10, 10, 256, 64), "Play !!") > 0) {
                        currentScreen = .Globe;
                    }
                },
                .Globe => {
                    drawTextureCentered(7.0, 0, globeTexture);
                    const x: [2][2]f32 = .{ .{ 0.5, 0.5 }, .{ 0.75, 0.75 } };
                    for (x) |point| {
                        rl.drawCircle(point[0] * rl.getScreenWidth(), point[1] * rl.getScreenHeight(), 5, rl.Color.red);
                    }
                },
                .Play => {},
            }
        }
    }
}
