const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const fonts = @import("fonts.zig");
const game = @import("game.zig");
const gui = @import("gui.zig");
const utils = @import("utils.zig");
const types = @import("types.zig");

const screenWidth = 1080;
const screenHeight = 1080;

var poiPinTex: rl.Texture2D = undefined;
var poiPinLockedTex: rl.Texture2D = undefined;
var poiPinHoverTex: rl.Texture2D = undefined;
var poiPinCompletedTex: rl.Texture2D = undefined;

const PoiPin = struct {
    x: f32,
    y: f32,
    isLocked: bool = true,
    isCompleted: bool = false,
    location: types.Location,
    frameCounter: u16 = 0,
    currentFrame: u16 = 0,
    fps: u9 = 24,
    frameRect: rl.Rectangle,

    const Self = @This();
    fn init(location: types.Location, x: f32, y: f32, isLocked: bool) Self {
        return Self{
            .x = x,
            .y = y,
            .isLocked = isLocked,
            .location = location,
            .frameRect = rl.Rectangle.init(0, 0, 32, 32),
        };
    }
    fn calculateClickBounds(size: f32, x: f32, y: f32) rl.Rectangle {
        return rl.Rectangle.init(x - size / 2, y - size / 2, size, size);
    }
    fn render(self: *Self, mPos: rl.Vector2) bool {
        var pressed = false;
        if (!self.isLocked and !self.isCompleted) {
            self.frameCounter += 1;

            if (self.frameCounter >= (target_fps / self.fps)) {
                self.frameCounter = 0;
                self.currentFrame += 1;

                if (self.currentFrame > 21) self.currentFrame = 0;

                self.frameRect.x = @as(f32, @floatFromInt(self.currentFrame)) * 32;
            }
        } else self.currentFrame = 0;

        const scaledPoint = utils.renderSize().multiply(rl.Vector2.init(self.x, self.y));

        if (self.isLocked) {
            gui.drawTextureCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinLockedTex);
        } else if (self.isCompleted) {
            gui.drawTextureCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinCompletedTex);
        } else if (rl.checkCollisionPointRec(mPos, calculateClickBounds(100, scaledPoint.x, scaledPoint.y))) {
            pressed = rl.isMouseButtonPressed(.left);
            gui.drawTextureProCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinHoverTex, self.frameRect);
        } else {
            gui.drawTextureProCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinTex, self.frameRect);
        }

        return pressed;
    }
};

const target_fps = 240;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    const mainFont = fonts.loadFont(fonts.Family.ComputerModern, fonts.Size.Medium);
    defer rl.unloadFont(mainFont);

    rl.drawFPS(0, 0);
    rl.setExitKey(.null);
    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fonts.Size.Medium);

    rg.guiSetFont(mainFont);

    var currentScreen: types.Screen = .MainMenu;

    game.createWorld();

    // Textures
    const globeTexture = rl.loadTextureFromImage(rl.loadImage("resources/globe.png"));
    defer rl.unloadTexture(globeTexture);

    const gameLogo = rl.loadTextureFromImage(rl.loadImage("resources/logo.png"));
    defer rl.unloadTexture(gameLogo);

    const spaceBg = rl.loadTextureFromImage(rl.loadImage("resources/space.png"));
    defer rl.unloadTexture(spaceBg);

    const playBtn = rl.loadTextureFromImage(rl.loadImage("resources/play-btn.png"));
    defer rl.unloadTexture(playBtn);

    const playBtnHover = rl.loadTextureFromImage(rl.loadImage("resources/play-btn-hover.png"));
    defer rl.unloadTexture(playBtnHover);

    const playBtnPress = rl.loadTextureFromImage(rl.loadImage("resources/play-btn-press.png"));
    defer rl.unloadTexture(playBtnPress);

    poiPinTex = rl.loadTextureFromImage(rl.loadImage("resources/poi-ani.png"));
    defer rl.unloadTexture(poiPinTex);

    poiPinLockedTex = rl.loadTextureFromImage(rl.loadImage("resources/locked-pin.png"));
    defer rl.unloadTexture(poiPinLockedTex);

    poiPinHoverTex = rl.loadTextureFromImage(rl.loadImage("resources/poi-hover-ani.png"));
    defer rl.unloadTexture(poiPinHoverTex);

    poiPinCompletedTex = rl.loadTextureFromImage(rl.loadImage("resources/checked-pin.png"));
    defer rl.unloadTexture(poiPinCompletedTex);

    // runtime data
    var mousePos = rl.Vector2.init(0, 0);
    var pois = [_]PoiPin{
        PoiPin.init(.SolarPanels, 0.5, 0.5, false),
        PoiPin.init(.Nuclear, 0.75, 0.2, true),
    };

    const info_anchor = rl.Vector2.init(190, 200);
    var text_view = gui.ScrollingTextView.init(
        info_anchor.x,
        info_anchor.y + 50,
        750,
        500,
        "",
        mainFont,
    );

    // Main game loop
    while (!rl.windowShouldClose()) {
        // drawing stuff
        {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(rl.Color.black);
            mousePos = rl.getMousePosition();

            switch (currentScreen) {
                .MainMenu => {
                    const anchor = rl.Vector2.init(@as(f32, @floatFromInt(rl.getScreenWidth())) / 2.0, 300);
                    gui.drawTextureCenteredAtPoint(0.8, 0.0, anchor, gameLogo);
                    if (gui.imgBtn(
                        1.0,
                        rl.Vector2.init(anchor.x, anchor.y + 175),
                        playBtn,
                        playBtnHover,
                        playBtnPress,
                        mousePos,
                    )) {
                        currentScreen = .Info;
                    }
                },
                .Globe => {
                    gui.drawTextureCentered(8.435, 0, spaceBg);
                    gui.drawTextureCentered(8.0, 0, globeTexture);
                    var location: ?types.Location = null;
                    for (0..pois.len) |idx| {
                        if (pois[idx].render(mousePos)) {
                            location = pois[idx].location;
                            pois[idx].isCompleted = true;
                        }
                    }
                    if (location != null) {
                        currentScreen = types.Screen{ .LocationInfo = location.? };
                    }
                },
                .Play => {
                    game.render();
                },
                .Info => {
                    currentScreen = .Globe;
                },
                .LocationInfo => |*location| {
                    const info = @import("location_info.zig");
                    const text = info.locationInfoText[@as(u4, @intFromEnum(location.*))];
                    const anchor = rl.Vector2.init(190, 200);
                    rl.drawTextEx(
                        mainFont,
                        switch (location.*) {
                            .SolarPanels => "Solar Panel",
                            .Nuclear => "Nuclear",
                            else => "meow",
                        },
                        anchor,
                        fonts.Size.Medium,
                        0,
                        rl.Color.light_gray,
                    );
                    text_view.setText(text);
                    text_view.render();

                    if (rg.guiButton(
                        rl.Rectangle.init(info_anchor.x, info_anchor.y + 600, 500, 100),
                        "continue",
                    ) == 1) {
                        currentScreen = .{
                            .Play = .{
                                .level = 0,
                                .location = location.*,
                            },
                        };
                    }
                    // RENDER IMAGE OF MACHINE
                },
            }

            rl.drawFPS(0, 0);
        }
    }
}
