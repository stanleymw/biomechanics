const rl = @import("raylib");

pub fn Asset(comptime file_path: [*:0]const u8) type {
    return struct {
        texture: ?rl.Texture = null,
        const Self = @This();
        pub fn getOrLoad(self: *Self) rl.Texture2D {
            if (self.texture == null)
                self.texture = rl.Texture.fromImage(rl.Image.init(file_path));
            return self.texture.?;
        }
        pub fn deinit(self: *Self) void {
            if (self.texture) |x| {
                x.unload();
            }
        }
    };
}

pub var poiPinTex = Asset("resources/poi-ani.png"){};
pub var poiPinLockedTex = Asset("resources/locked-pin.png"){};
pub var poiPinHoverTex = Asset("resources/poi-hover-ani.png"){};
pub var poiPinCompletedTex = Asset("resources/checked-pin.png"){};

pub var globeTexture = Asset("resources/globe.png"){};
pub var gameLogo = Asset("resources/logo.png"){};
pub var spaceBg = Asset("resources/space.png"){};

pub var playBtn = Asset("resources/play-btn.png"){};
pub var playBtnHover = Asset("resources/play-btn-hover.png"){};
pub var playBtnPress = Asset("resources/play-btn-press.png"){};
