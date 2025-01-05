const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

fn range(len: usize) []i32 {
    return @as([*]i32, undefined)[0..len];
}

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, 30);
    const fontData = @embedFile("resources/font.otf");

    const ascii = range(256);
    rg.guiSetFont(rl.loadFontFromMemory(
        ".otf",
        fontData,
        30,
        ascii,
    ));

    var showMessageBox = false;

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();

            rl.clearBackground(rl.Color.white);

            rl.drawText("Feelz", 190, 200, 20, rl.Color.light_gray);
            if (rg.guiButton(rl.Rectangle.init(10, 10, 128, 48), "Sentir") > 0) {
                showMessageBox = true;
            }

            if (showMessageBox) {
                if (rg.guiMessageBox(rl.Rectangle.init(85, 70, 512, 256), "#191#Message Box", "Hi! This is a message!", "Nice;Cool") >= 0) {
                    showMessageBox = false;
                }
            }
        }
    }
}
