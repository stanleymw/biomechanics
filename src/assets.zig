const rl = @import("raylib");

pub const Asset = struct {
    texture: ?rl.Texture = null,
    file_path: [*:0]const u8,

    pub fn init(comptime fp: [*:0]const u8) Asset {
        return Asset{ .file_path = fp };
    }

    pub fn getOrLoad(self: *Asset) rl.Texture2D {
        if (self.texture == null)
            self.texture = rl.Texture.fromImage(rl.Image.init(self.file_path));
        return self.texture.?;
    }

    pub fn deinit(self: *Asset) void {
        if (self.texture) |x| {
            x.unload();
        }
    }
};

pub var poiPinTex = Asset.init("resources/poi-ani.png");
pub var poiPinLockedTex = Asset.init("resources/locked-pin.png");
pub var poiPinHoverTex = Asset.init("resources/poi-hover-ani.png");
pub var poiPinCompletedTex = Asset.init("resources/checked-pin.png");

pub var globeTexture = Asset.init("resources/globe.png");
pub var gameLogo = Asset.init("resources/logo.png");
pub var spaceBg = Asset.init("resources/space.png");

pub var playBtn = Asset.init("resources/play-btn.png");
pub var playBtnHover = Asset.init("resources/play-btn-hover.png");
pub var playBtnPress = Asset.init("resources/play-btn-press.png");

pub var standard_node = Asset.init("resources/POI/standard-node.png");

pub var n_type_silicon_node = Asset.init("resources/POI/SolarPanel/Nodes/0.png");
pub var p_type_silicon_node = Asset.init("resources/POI/SolarPanel/Nodes/1.png");
pub var sealant_node = Asset.init("resources/POI/SolarPanel/Nodes/2.png");
pub var screw_node = Asset.init("resources/POI/SolarPanel/Nodes/3.png");
