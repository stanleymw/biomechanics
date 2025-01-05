const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

fn range(len: usize) []i32 {
    return @as([*]i32, undefined)[0..len];
}

const screenWidth = 1920;
const screenHeight = 1080;
const fontSize = 64;

const Screen = enum { MainMenu, Globe, Play };

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fontSize);

    const ascii = range(256);
    rg.guiSetFont(rl.loadFontEx(
        "resources/font.otf",
        fontSize,
        ascii,
    ));

    //var showMessageBox = false;
    var currentScreen: Screen = .MainMenu;

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(rl.Color.white);

            switch (currentScreen) {
                .MainMenu => {
                    rl.drawText("Feelz", 190, 200, 20, rl.Color.light_gray);
                    if (rg.guiButton(rl.Rectangle.init(10, 10, 256, 64), "Sentir") > 0) {
                        currentScreen = .Globe;
                    }

                    // if (showMessageBox) {
                    //     if (rg.guiMessageBox(rl.Rectangle.init(screenWidth / 2, screenHeight / 2, 512, 256), "#191#Message Box", "Hi! This is a message!", "Nice;Cool") >= 0) {
                    //         showMessageBox = false;
                    //     }
                    // }
                },
                .Globe => {},
                .Play => {},
            }
        }
    }
}
