const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const fonts = @import("fonts.zig");
const game = @import("game.zig");
const gui = @import("gui.zig");

const screenWidth = 1080;
const screenHeight = 1080;

const Screen = union(enum) { MainMenu, Globe, Play: Place, LocationInfo: Location, Info };

const Location = enum(u4) { SolarPanels, CarbonCapture, Nuclear, Desalination };
const Place = struct {
    location: Location,
    level: u3,
};

fn renderSize() rl.Vector2 {
    return rl.Vector2.init(
        @as(f32, @floatFromInt(rl.getScreenWidth())),
        @as(f32, @floatFromInt(rl.getScreenHeight())),
    );
}

fn drawTextureProCenteredAtPoint(
    scaleFactor: f32,
    rotation: f32,
    pos: rl.Vector2,
    texture: rl.Texture2D,
    rec: rl.Rectangle,
) void {
    const scaledWidth = rec.width * scaleFactor;
    const scaledHeight = rec.height * scaleFactor;
    rl.drawTexturePro(
        texture,
        rec,
        rl.Rectangle.init(pos.x, pos.y, scaledWidth, scaledHeight),
        rl.Vector2.init(scaledWidth / 2, scaledHeight / 2),
        rotation,
        rl.Color.white,
    );
}

fn drawTextureCenteredAtPoint(scaleFactor: f32, rotation: f32, pos: rl.Vector2, texture: rl.Texture2D) void {
    const scaledWidth = @as(f32, @floatFromInt(texture.width)) * scaleFactor;
    const scaledHeight = @as(f32, @floatFromInt(texture.height)) * scaleFactor;
    rl.drawTextureEx(texture, pos.subtract(rl.Vector2.init(scaledWidth / 2, scaledHeight / 2)), rotation, scaleFactor, rl.Color.white);
}

fn drawTextureCentered(scaleFactor: f32, rotation: f32, texture: rl.Texture2D) void {
    drawTextureCenteredAtPoint(scaleFactor, rotation, renderSize().scale(0.5), texture);
}

var poiPinTex: rl.Texture2D = undefined;
var poiPinLockedTex: rl.Texture2D = undefined;
var poiPinHoverTex: rl.Texture2D = undefined;
var poiPinCompletedTex: rl.Texture2D = undefined;

const PoiPin = struct {
    x: f32,
    y: f32,
    isLocked: bool = true,
    isCompleted: bool = false,
    location: Location,
    frameCounter: u16 = 0,
    currentFrame: u16 = 0,
    fps: u9 = 24,
    frameRect: rl.Rectangle,

    const Self = @This();
    fn init(location: Location, x: f32, y: f32, isLocked: bool) Self {
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

        const scaledPoint = renderSize().multiply(rl.Vector2.init(self.x, self.y));

        if (self.isLocked) {
            drawTextureCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinLockedTex);
        } else if (self.isCompleted) {
            drawTextureCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinCompletedTex);
        } else if (rl.checkCollisionPointRec(mPos, calculateClickBounds(100, scaledPoint.x, scaledPoint.y))) {
            pressed = rl.isMouseButtonPressed(.left);
            //drawTextureCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinHoverTex);
            drawTextureProCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinHoverTex, self.frameRect);
        } else {
            //drawTextureCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinTex);
            drawTextureProCenteredAtPoint(4.0, 0.0, scaledPoint, poiPinTex, self.frameRect);
            //rl.drawTextureRec(poiPinTex, self.frameRect, scaledPoint, rl.Color.white);
            std.debug.print(
                "frame rect: {d}, {d}, {d}, {d}\n",
                .{
                    self.frameRect.x,
                    self.frameRect.y,
                    self.frameRect.width,
                    self.frameRect.height,
                },
            );
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

    var currentScreen: Screen = .MainMenu;

    game.createWorld();

    // Textures
    const globeTexture = rl.loadTextureFromImage(rl.loadImage("resources/globe.png"));
    defer rl.unloadTexture(globeTexture);

    const gameLogo = rl.loadTextureFromImage(rl.loadImage("resources/logo.png"));
    defer rl.unloadTexture(gameLogo);

    const spaceBg = rl.loadTextureFromImage(rl.loadImage("resources/space.png"));
    defer rl.unloadTexture(spaceBg);

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
                    drawTextureCenteredAtPoint(0.8, 0.0, anchor, gameLogo);
                    if (rg.guiButton(rl.Rectangle.init(anchor.x - 128, anchor.y + 150, 256, 64), "Play") > 0) {
                        currentScreen = .Info;
                    }
                },
                .Globe => {
                    drawTextureCentered(8.435, 0, spaceBg);
                    drawTextureCentered(8.0, 0, globeTexture);
                    var location: ?Location = null;
                    for (0..pois.len) |idx| {
                        if (pois[idx].render(mousePos)) {
                            location = pois[idx].location;
                            pois[idx].isCompleted = true;
                        }
                    }
                    if (location != null) {
                        currentScreen = Screen{ .LocationInfo = location.? };
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
                        currentScreen = Screen{
                            .Play = Place{
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
