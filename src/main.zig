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

    rl.initAudioDevice();
    defer rl.closeAudioDevice();

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
    defer assets.soundPool.deinitAll();

    // runtime data
    var startedCutscene = false;
    var finishedAudio1 = false;
    //var finishedAudio2 = false;
    var startTime: ?f64 = null;
    const sound1 = assets.introductionSpeech1.getOrLoad().sound;
    const sound2 = assets.introductionSpeech2.getOrLoad().sound;

    var currentScreen: types.Screen = .MainMenu;
    var current_text: *const []const u8 = &"";

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
        gui.PoiPin.init(.Nuclear, 0.60, 0.65, false),
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
                                const bounds = rl.measureTextEx(mainFont, dat, fonts.Size.Small, 0);
                                rl.drawRectangleRec(
                                    rl.Rectangle.init(
                                        mousePos.x - (bounds.x / 2) - consts.tooltip_padding,
                                        mousePos.y + 32,
                                        bounds.x + (2 * consts.tooltip_padding),
                                        bounds.y,
                                    ),
                                    rl.Color.black,
                                );

                                rl.drawTextEx(
                                    mainFont,
                                    dat,
                                    rl.Vector2.init(mousePos.x - (bounds.x / 2), mousePos.y + 32),
                                    fonts.Size.Small,
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

                    const location = place.location.getInfo();
                    if (gui.backBtn(mousePos)) {
                        currentScreen = .{ .ComponentInfo = place.location };
                        game.unloadLevel();
                        std.debug.print("unloaded: {}\n", .{game.levelUnloaded()});
                    } else {
                        if (game.levelUnloaded()) {
                            game.loadLevel(location.levels[place.level]);
                            std.debug.print("loaded: {s}\n", .{location.levels[place.level].name});
                        }
                    }

                    if (game.loop()) {
                        if (place.level < location.levels.len - 1) {
                            place.level += 1;
                            game.loadLevel(location.levels[place.level]);
                            std.debug.print("loaded: {s} due to win\n", .{location.levels[place.level].name});
                        } else {
                            currentScreen = .Globe;
                            game.unloadLevel();
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
                    // rendering bg
                    const asset = if (!finishedAudio1)
                        assets.desertCutscene.getOrLoad()
                    else
                        assets.labCutscene.getOrLoad();
                    asset.drawEx(
                        rl.Vector2.zero(),
                        0,
                        utils.renderSize().x / @as(f32, @floatFromInt(asset.width)),
                        rl.Color.white,
                    );

                    const bounds = rl.measureTextEx(
                        mainFont,
                        @ptrCast(current_text.*),
                        fonts.Size.Medium,
                        0,
                    );

                    rl.drawRectangleRec(
                        rl.Rectangle.init(
                            utils.renderSize().x / 2 - (bounds.x / 2) - consts.tooltip_padding,
                            utils.renderSize().y / 2 - 100,
                            bounds.x + (2 * consts.tooltip_padding),
                            bounds.y,
                        ),
                        rl.Color.black,
                    );

                    rl.drawTextEx(
                        mainFont,
                        @ptrCast(current_text.*),
                        utils.renderSize().scale(0.5).add(utils.v2(-(bounds.x / 2), -100)),
                        fonts.Size.Medium,
                        0,
                        rl.Color.white,
                    );

                    if (!startedCutscene) {
                        startTime = rl.getTime();
                        startedCutscene = true;

                        rl.playSound(sound1);
                        continue;
                    }
                    // time since audio started
                    const time_delta = rl.getTime() - startTime.?;

                    if (!finishedAudio1) {
                        switch (@as(u8, @intFromFloat(time_delta))) {
                            0...2 => current_text = &"Beginning in the second half of the 21st century,",
                            3...9 => current_text = &"a series of climate disasters made 38% of the land\nonce suitable for nurturing humanity unlivable.",
                            else => current_text = &"By 2075, for the first time in history since the black\ndeath, the global population decreased.",
                        }
                    } else {
                        switch (@as(u8, @intFromFloat(time_delta))) {
                            0...4 => current_text = &"In the following decades, the UN has redoubled its\nefforts to fight climate change.",
                            5...8 => current_text = &"At the heart of its campaign has been a new department,\nheaded by you,",
                            9...11 => current_text = &"for the development of technologies that work\nwith nature to rebuild the planet.",
                            12...18 => current_text = &"You stand on the edge of triumph, about to oversee\nthe completion of these machines to save your species,",
                            19...20 => current_text = &"which are 25 years in the making.",
                            else => current_text = &"Only a few problems remain to be solved before the biomechanics\nof the earth are put back into balance.",
                        }
                    }

                    // skipping w/ mouse
                    if (rl.isMouseButtonPressed(.left)) {
                        if (!finishedAudio1) {
                            rl.stopSound(sound1);
                            finishedAudio1 = true;
                            rl.playSound(sound2);
                            startTime = rl.getTime();
                        } else {
                            rl.stopSound(sound2);
                            currentScreen = .Globe;
                        }
                    }
                    if (!finishedAudio1 and time_delta > 16.5) {
                        finishedAudio1 = true;
                        rl.playSound(sound2);
                        startTime = rl.getTime();
                    }
                    if (finishedAudio1 and time_delta > 26.5) {
                        rl.stopSound(sound2);
                        currentScreen = .Globe;
                    }

                    // if (!(finishedAudio1 or rl.isSoundPlaying(sound1))) {
                    //     finishedAudio1 = true;
                    //     rl.playSound(sound2);
                    //     continue;
                    // }
                    // if (finishedAudio1 and !rl.isSoundPlaying(sound2)) {
                    //     finishedAudio2 = true;
                    // }
                    // std.debug.print("test: {}\n", .{rl.isSoundPlaying(sound1)});

                    // if (time_delta > 42.5) { // (finishedAudio1 and finishedAudio2) {
                    //     currentScreen = .Globe;
                    // }

                    //currentScreen = .Globe;
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
                            std.debug.print("request {s}....\n", .{lev.name});

                            game.unloadLevel();
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
