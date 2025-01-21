const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const fonts = @import("fonts.zig");
const game = @import("game.zig");

const screenWidth = 1920;
const screenHeight = 1080;

const Screen = union(enum) { MainMenu, Globe, Play: Place, LocationInfo: Location, Info };

const Location = enum(u4) { SolarPanels, CarbonCapture, Nuclear, Desalination };
const Place = struct {
    location: Location,
    level: u3,
};

fn drawTextureCenteredAtPoint(scaleFactor: f32, rotation: f32, x: f32, y: f32, texture: rl.Texture2D) void {
    const scaledWidth = @as(f32, @floatFromInt(texture.width)) * scaleFactor;
    const scaledHeight = @as(f32, @floatFromInt(texture.height)) * scaleFactor;
    rl.drawTextureEx(texture, rl.Vector2.init(x - scaledWidth / 2, y - scaledHeight / 2), rotation, scaleFactor, rl.Color.white);
}

fn drawTextureCentered(scaleFactor: f32, rotation: f32, texture: rl.Texture2D) void {
    drawTextureCenteredAtPoint(scaleFactor, rotation, screenWidth / 2, screenHeight / 2, texture);
}

var poiPinTex: rl.Texture2D = undefined;
var poiPinLockedTex: rl.Texture2D = undefined;
var poiPinHoverTex: rl.Texture2D = undefined;

const PoiPin = struct {
    x: f32,
    y: f32,
    isLocked: bool = true,
    isCompleted: bool = false,
    location: Location,

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
        else if (rl.checkCollisionPointRec(mPos, calculateClickBounds(100, newX, newY))) block: {
            //std.debug.print("pressed!: {}", .{pressed});
            pressed = rl.isMouseButtonPressed(.left);
            break :block poiPinHoverTex;
        } else poiPinTex;

        drawTextureCenteredAtPoint(4.0, 0.0, newX, newY, tex);

        return pressed;
    }
};

pub const ScrollingTextView = struct {
    bounds: rl.Rectangle,
    content_height: f32,
    scroll: rl.Vector2,
    view: rl.Rectangle,
    text_color: rl.Color,
    background_color: rl.Color,
    text: []const u8,
    font_size: i32,
    font: rl.Font,

    pub fn init(x: f32, y: f32, width: f32, height: f32, initial_text: []const u8, font: rl.Font) ScrollingTextView {
        return ScrollingTextView{
            .bounds = rl.Rectangle{
                .x = x,
                .y = y,
                .width = width,
                .height = height,
            },
            .content_height = height,
            .scroll = rl.Vector2.init(0, 0),
            .view = rl.Rectangle.init(0, 0, 0, 0),
            .font_size = 30,
            .text_color = rl.Color.black,
            .background_color = rl.Color.ray_white,
            .text = initial_text,
            .font = font,
        };
    }

    pub fn setText(self: *ScrollingTextView, text: []const u8) void {
        self.text = text;
        // Calculate content height based on number of lines
        var line_count: usize = 1;
        for (text) |char| {
            if (char == '\n') line_count += 1;
        }
        self.content_height = @as(f32, @floatFromInt(line_count)) *
            @as(f32, @floatFromInt(self.font_size)) * 1.5;
    }

    pub fn render(self: *ScrollingTextView) void {
        const content = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = self.bounds.width - 20,
            .height = self.content_height,
        };

        // Convert scroll result to Vector2
        const scroll_result = rg.guiScrollPanel(self.bounds, null, content, &self.scroll, &self.view);
        self.scroll = .{
            .x = @floatFromInt(scroll_result),
            .y = self.scroll.y,
        };

        rl.beginScissorMode(
            @as(i32, @intFromFloat(self.bounds.x)),
            @as(i32, @intFromFloat(self.bounds.y)),
            @as(i32, @intFromFloat(self.bounds.width)),
            @as(i32, @intFromFloat(self.bounds.height)),
        );

        const y: f32 = self.bounds.y - self.scroll.y;
        //var line_start: usize = 0;
        var current_y: f32 = y;

        // Render each line

        var iter = std.mem.splitScalar(u8, self.text, '\n');
        while (iter.next()) |line| {
            rl.drawTextEx(
                self.font,
                @ptrCast(line),
                rl.Vector2.init(self.bounds.x + 4, current_y),
                @as(f32, @floatFromInt(self.font_size)),
                1.0,
                self.text_color,
            );
            current_y += @as(f32, @floatFromInt(self.font_size)) * 1.5 + 5;
        }
        // for (self.text, 0..) |char, i| {
        //     if (char == '\n' or i == self.text.len - 1) {
        //         const line_end = if (char == '\n') i else i + 1;
        //         rl.drawText(
        //             @ptrCast(self.text[line_start..line_end]),
        //             @as(i32, @intFromFloat(self.bounds.x + 4)),
        //             @as(i32, @intFromFloat(current_y)),
        //             self.font_size,
        //             self.text_color,
        //         );
        //         line_start = i + 1;
        //         current_y += @as(f32, @floatFromInt(self.font_size)) * 1.5 + 10;
        //     }
        // }

        rl.endScissorMode();
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
    var pois = [_]PoiPin{
        .{ .location = .SolarPanels, .x = 0.5, .y = 0.5, .isLocked = false },
        .{ .location = .Nuclear, .x = 0.75, .y = 0.2 },
    };

    const info_anchor = rl.Vector2.init(190, 200);
    var text_view = ScrollingTextView.init(
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
            rl.clearBackground(rl.Color.white);
            mousePos = rl.getMousePosition();

            switch (currentScreen) {
                .MainMenu => {
                    rl.drawTextEx(mainFont, "Game", rl.Vector2.init(190, 200), fonts.Size.Medium, 0, rl.Color.light_gray);

                    if (rg.guiButton(rl.Rectangle.init(10, 10, 256, 64), "Play") > 0) {
                        currentScreen = .Info;
                    }
                },
                .Globe => {
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
