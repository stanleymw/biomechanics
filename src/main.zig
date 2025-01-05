const rl = @import("raylib");
const rg = @import("raygui");

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 720;

    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(240);

    var showMessageBox = false;

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();

            rl.clearBackground(rl.Color.white);

            rl.drawText("Congrats! You created your first window!", 190, 200, 20, rl.Color.light_gray);
            if (rg.guiButton(rl.Rectangle.init(10, 10, 64, 16), "Sentir") > 0) {
                showMessageBox = true;
            }

            if (showMessageBox) {
                if (rg.guiMessageBox(rl.Rectangle.init(85, 70, 250, 100), "#191#Message Box", "Hi! This is a message!", "Nice;Cool") >= 0) {
                    showMessageBox = false;
                }
            }
        }
    }
}
