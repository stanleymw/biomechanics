const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

fn range(len: usize) []i32 {
    return @as([*]i32, undefined)[0..len];
}

const screenWidth = 1280;
const screenHeight = 720;
const fontSize = 36;
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
