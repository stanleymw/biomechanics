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
        fonts.Family.ArkPixel,
        fonts.Size.Medium,
        null,
    );
    defer rl.unloadFont(mainFont);

    rl.drawFPS(0, 0);
    // rl.setExitKey(.null);
    rl.setTargetFPS(240);
    rg.guiSetStyle(rg.GuiControl.default, rg.GuiDefaultProperty.text_size, fonts.Size.Medium);

    rg.guiSetFont(mainFont);

    // Textures unloading (assets are lazily loaded)
    defer assets.assetPool.deinitAll();

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
                        switch (poi.render(mousePos)) {
                            .Pressed => {
                                location = poi.location;
                            },
                            .Hovered => {
                                const dat: [*:0]const u8 = @ptrCast(poi.location.getInfo().name);
                                const bounds = rl.measureTextEx(mainFont, dat, fonts.Size.Medium, 0);
                                rl.drawRectangleRec(
                                    rl.Rectangle.init(
                                        mousePos.x - (bounds.x / 2) - consts.tooltip_padding,
                                        mousePos.y + 16,
                                        bounds.x + (2 * consts.tooltip_padding),
                                        bounds.y,
                                    ),
                                    rl.Color.black,
                                );

                                rl.drawTextEx(
                                    mainFont,
                                    dat,
                                    rl.Vector2.init(mousePos.x - (bounds.x / 2), mousePos.y + 16),
                                    fonts.Size.Medium,
                                    0,
                                    rl.Color.white,
                                );
                            },
                            else => {},
                        }
                    }
                    if (location != null) {
                        currentScreen = types.Screen{ .LocationInfo = location.? };
                    }
                },
                .Play => |*place| {
                    gui.drawTextureCentered(0.8, 0, assets.playBg.getOrLoad());
                    if (gui.backBtn(mousePos)) {
                        currentScreen = .{ .ComponentInfo = place.location };
                    }
                    const location = place.location.getInfo();

                    if (game.levelUnloaded())
                        game.loadLevel(location.levels[place.level]);

                    if (game.loop()) {
                        if (place.level < location.levels.len - 1) {
                            place.level += 1;
                            game.loadLevel(location.levels[place.level]);
                        } else {
                            currentScreen = .Globe;
                            for (&pois, 0..) |*poi, idx| {
                                if (poi.location == place.location) {
                                    poi.isCompleted = true;
                                    if (idx + 1 < pois.len) {
                                        pois[idx + 1].isLocked = false;
                                    } // else game is complete

                                    break;
                                }
                            }
                            // TODO: display area completion
                        }
                    }
                },
                .Info => {
                    currentScreen = .Globe;
                },
                .LocationInfo => |*location| {
                    if (gui.backBtn(mousePos)) {
                        currentScreen = .Globe; // .{ .LocationInfo = location.* };
                    }
                    const info = location.getInfo();
                    const anchor = rl.Vector2.init(190, 75);
                    const tex = info.image_name.getOrLoad();
                    const tex_h = @as(f32, @floatFromInt(tex.height));
                    const scale_factor = (utils.renderSize().x - 2 * anchor.x) / @as(f32, @floatFromInt(tex.width));

                    rl.drawTextEx(
                        mainFont,
                        @ptrCast(info.name),
                        anchor,
                        fonts.Size.Medium,
                        0,
                        rl.Color.light_gray,
                    );
                    tex.drawEx(
                        anchor.add(utils.yv(fonts.Size.Medium)),
                        0.0,
                        scale_factor,
                        rl.Color.white,
                    );
                    if (gui.imgBtn(
                        1.0,
                        anchor.add(utils.yv(scale_factor * tex_h + 20)),
                        assets.continueBtn.getOrLoad(),
                        assets.continueBtnHover.getOrLoad(),
                        assets.continueBtnPress.getOrLoad(),
                        mousePos,
                    )) {
                        currentScreen = .{ .ComponentInfo = location.* };
                    }

                    text_view.setText(info.info);
                    //text_view.render();

                    // RENDER IMAGE OF MACHINE
                },
                .ComponentInfo => |*location| {
                    if (gui.backBtn(mousePos)) {
                        currentScreen = .{ .LocationInfo = location.* };
                    }
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
