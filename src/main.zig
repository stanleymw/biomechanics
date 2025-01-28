const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");

const location_info = @import("location_info.zig");

const fonts = @import("fonts.zig");
const game = @import("game.zig");
const gui = @import("gui.zig");
const utils = @import("utils.zig");
const types = @import("types.zig");
const consts = @import("consts.zig");
const assets = @import("assets.zig");

const screenWidth = 1080;
const screenHeight = 1080;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "game2");
    defer rl.closeWindow(); // Close window and OpenGL context

    const mainFont = rl.Font.initEx(
        fonts.Family.ComputerModern,
        fonts.Size.Medium,
        null,
    );
    defer rl.unloadFont(mainFont);

    rl.drawFPS(0, 0);
    rl.setExitKey(.null);
    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fonts.Size.Medium);

    rg.guiSetFont(mainFont);

    // Textures unloading (assets are lazily loaded)
    defer assets.globeTexture.deinit();
    defer assets.gameLogo.deinit();
    defer assets.spaceBg.deinit();
    defer assets.playBtn.deinit();
    defer assets.playBtnHover.deinit();
    defer assets.playBtnPress.deinit();
    defer assets.poiPinTex.deinit();
    defer assets.poiPinLockedTex.deinit();
    defer assets.poiPinHoverTex.deinit();
    defer assets.poiPinCompletedTex.deinit();

    // runtime data
    var currentScreen: types.Screen = .MainMenu;

    var mousePos = rl.Vector2.zero();

    const info_anchor = rl.Vector2.init(190, 200);
    var text_view = gui.ScrollingTextView.init(
        info_anchor.x,
        info_anchor.y + 50,
        750,
        500,
        "",
        mainFont,
    );

    var pois = [_]gui.PoiPin{
        gui.PoiPin.init(.SolarPanels, 0.75, 0.45, false),
        gui.PoiPin.init(.Nuclear, 0.60, 0.65, true),
        gui.PoiPin.init(.CarbonCapture, 0.44, 0.37, true),
    };

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
                    gui.drawTextureCenteredAtPoint(0.8, 0.0, anchor, assets.gameLogo.getOrLoad());
                    if (gui.imgBtn(
                        1.0,
                        rl.Vector2.init(anchor.x, anchor.y + 175),
                        assets.playBtn.getOrLoad(),
                        assets.playBtnHover.getOrLoad(),
                        assets.playBtnPress.getOrLoad(),
                        mousePos,
                    )) {
                        currentScreen = .Info;
                    }
                },
                .Globe => {
                    gui.drawTextureCentered(8.435, 0, assets.spaceBg.getOrLoad());
                    gui.drawTextureCentered(8.0, 0, assets.globeTexture.getOrLoad());
                    var location: ?types.Location = null;
                    for (&pois) |*poi| {
                        if (poi.render(mousePos)) {
                            location = poi.location;
                            poi.isCompleted = true;
                        }
                    }
                    if (location != null) {
                        currentScreen = types.Screen{ .LocationInfo = location.? };
                    }
                },
                .Play => |*place| {
                    const location = place.location.getInfo();

                    if (game.levelUnloaded())
                        game.loadLevel(location.levels[place.level]);

                    if (game.loop()) {
                        if (place.level < location.levels.len - 1) {
                            place.level += 1;
                            game.loadLevel(location.levels[place.level]);
                        } else {
                            currentScreen = .Globe;
                            // if (@intFromEnum(place.location) < @typeInfo(types.Location).Enum.decls.len - 1) {
                            //     currentScreen = types.Screen{
                            //         .LocationInfo = @enumFromInt(@intFromEnum(place.location) + 1),
                            //     };
                            // } else currentScreen = .Ending;
                        }
                    }
                },
                .Info => {
                    currentScreen = .Globe;
                },
                .LocationInfo => |*location| {
                    const text = location.getInfo().info;
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

                    for (location.getInfo().levels, 0..) |lev, ix| {
                        if (rg.guiButton(
                            rl.Rectangle.init(info_anchor.x, info_anchor.y + 600 + @as(f32, @floatFromInt(75 * ix)), 500, 50),
                            lev.name,
                        ) == 1) {
                            currentScreen = .{
                                .Play = .{
                                    .level = @intCast(ix),
                                    .location = location.*,
                                },
                            };
                        }
                    }

                    // RENDER IMAGE OF MACHINE
                },
                .Ending => {
                    rl.drawTextEx(
                        mainFont,
                        "Game Completed !!\nThanks for playing!!",
                        utils.renderSize().scale(0.5),
                        fonts.Size.Medium,
                        0,
                        rl.Color.light_gray,
                    );
                },
            }

            rl.drawFPS(0, 0);
        }
    }
}
