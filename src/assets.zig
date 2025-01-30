const rl = @import("raylib");

pub fn AssetPool(comptime T: type) type {
    return struct {
        assets: []const *Asset(T),
        fn init(assets: []const *Asset(T)) AssetPool(T) {
            return .{ .assets = assets };
        }
        pub fn deinitAll(self: AssetPool(T)) void {
            for (self.assets) |x| {
                x.deinit();
            }
        }
    };
}

/// Audio or Texture Stream
pub fn Asset(comptime T: type) type {
    return struct {
        asset: ?T = null,
        file_path: [*:0]const u8,

        pub fn init(comptime fp: [*:0]const u8) Asset(T) {
            return .{ .file_path = fp };
        }

        pub fn getOrLoad(self: *Asset(T)) T {
            if (self.asset == null) {
                if (comptime T == rl.Texture)
                    self.asset = rl.Texture.fromImage(rl.Image.init(self.file_path))
                else if (comptime T == rl.Sound)
                    self.asset = rl.loadSound(self.file_path);
            }
            return self.asset.?;
        }

        pub fn deinit(self: *Asset(T)) void {
            if (self.asset) |x| {
                if (comptime T == rl.Texture)
                    x.unload()
                else if (comptime T == rl.Sound)
                    rl.unloadSound(x);
            }
        }
    };
}
// aliases for easier usage
pub const TAsset = Asset(rl.Texture);
pub const SAsset = Asset(rl.Sound);

pub var poiPinTex = TAsset.init("resources/poi-ani.png");
pub var poiPinLockedTex = TAsset.init("resources/locked-pin.png");
pub var poiPinHoverTex = TAsset.init("resources/poi-hover-ani.png");
pub var poiPinCompletedTex = TAsset.init("resources/checked-pin.png");

pub var globeTexture = TAsset.init("resources/globe.png");
pub var gameLogo = TAsset.init("resources/logo.png");
pub var spaceBg = TAsset.init("resources/space.png");
pub var playBg = TAsset.init("resources/play-bg.png");

pub var completedComponent = TAsset.init("resources/component-win.png");
pub var completedMachine = TAsset.init("resources/machine-win.png");

pub var solarMachine = TAsset.init("resources/POI/SolarPanel/machine.png");
pub var nuclearMachine = TAsset.init("resources/POI/NuclearReactor/machine.png");
pub var carbonMachine = TAsset.init("resources/POI/CarbonCapture/machine.png");

pub var backBtn = TAsset.init("resources/back-btn.png");
pub var checkmark = TAsset.init("resources/checkmark.png");
pub var lock = TAsset.init("resources/lock.png");

pub var playBtn = TAsset.init("resources/play-btn.png");
pub var playBtnHover = TAsset.init("resources/play-btn-hover.png");
pub var playBtnPress = TAsset.init("resources/play-btn-press.png");

pub var continueBtn = TAsset.init("resources/continue-btn.png");
pub var continueBtnHover = TAsset.init("resources/continue-btn-hover.png");
pub var continueBtnPress = TAsset.init("resources/continue-btn-pressed.png");

pub var standard_node = TAsset.init("resources/POI/standard-node.png");

pub var n_type_silicon_node = TAsset.init("resources/POI/SolarPanel/Nodes/0.png");
pub var p_type_silicon_node = TAsset.init("resources/POI/SolarPanel/Nodes/1.png");
pub var sealant_node = TAsset.init("resources/POI/SolarPanel/Nodes/2.png");
pub var screw_node = TAsset.init("resources/POI/SolarPanel/Nodes/3.png");

pub var assetPool = AssetPool(rl.Texture).init(&.{
    &poiPinTex,
    &poiPinLockedTex,
    &poiPinHoverTex,
    &poiPinCompletedTex,

    &globeTexture,
    &gameLogo,
    &spaceBg,
    &playBg,

    &completedComponent,
    &completedMachine,

    &solarMachine,
    &nuclearMachine,
    &carbonMachine,

    &backBtn,
    &checkmark,
    &lock,

    &playBtn,
    &playBtnHover,
    &playBtnPress,

    &continueBtn,
    &continueBtnHover,
    &continueBtnPress,

    &standard_node,

    &n_type_silicon_node,
    &p_type_silicon_node,
    &sealant_node,
    &screw_node,
});

// pub var introductionSpeech = SAsset.init("");

// pub var soundPool = AssetPool(rl.Sound).init(&.{
//     &introductionSpeech
// });
