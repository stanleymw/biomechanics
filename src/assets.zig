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

pub const SoundWrapper = struct {
    sound: rl.Sound,
    pub fn play(self: SoundWrapper) void {
        rl.playSound(self.sound);
    }
    pub fn stop(self: SoundWrapper) void {
        rl.stopSound(self.sound);
    }
    pub fn isPlaying(self: SoundWrapper) bool {
        return rl.isSoundPlaying(self.sound);
    }
    pub fn loadFrom(fp: [*:0]const u8) SoundWrapper {
        return .{ .sound = rl.loadSound(fp) };
    }
    pub fn deinit(self: SoundWrapper) void {
        rl.unloadSound(self.sound);
    }
};

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
                else if (comptime T == SoundWrapper)
                    self.asset = SoundWrapper.loadFrom(self.file_path);
            }
            return self.asset.?;
        }

        pub fn deinit(self: *Asset(T)) void {
            if (self.asset) |x| {
                if (comptime T == rl.Texture)
                    x.unload()
                else if (comptime T == SoundWrapper) {
                    x.deinit();
                }
            }
        }
    };
}
// aliases for easier usage
pub const TAsset = Asset(rl.Texture);
pub const SAsset = Asset(SoundWrapper);

pub var poiPinTex = TAsset.init("resources/poi-ani.png");
pub var poiPinLockedTex = TAsset.init("resources/locked-pin.png");
pub var poiPinHoverTex = TAsset.init("resources/poi-hover-ani.png");
pub var poiPinCompletedTex = TAsset.init("resources/checked-pin.png");

pub var globeTexture = TAsset.init("resources/globe.png");
pub var gameLogo = TAsset.init("resources/logo.png");
pub var spaceBg = TAsset.init("resources/space.png");
pub var playBg = TAsset.init("resources/play-bg.png");

pub var desertCutscene = TAsset.init("resources/cutscenes/desert.png");
pub var labCutscene = TAsset.init("resources/cutscenes/lab.png");
pub var endingCutscene = TAsset.init("resources/cutscenes/ending.png");

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

pub var absorber_1_node = TAsset.init("resources/POI/NuclearReactor/Nodes/absorber-1.png");
pub var absorber_2_node = TAsset.init("resources/POI/NuclearReactor/Nodes/absorber-2.png");
pub var absorber_3_node = TAsset.init("resources/POI/NuclearReactor/Nodes/absorber-3.png");
pub var control_rod_node = TAsset.init("resources/POI/NuclearReactor/Nodes/control-rod.png");
pub var steam_plate_node = TAsset.init("resources/POI/NuclearReactor/Nodes/steam-plate.png");
pub var columns_node = TAsset.init("resources/POI/NuclearReactor/Nodes/columns.png");

pub var injection_walls_1_node = TAsset.init("resources/POI/CarbonCapture/Nodes/injection-walls-1.png");
pub var injection_walls_2_node = TAsset.init("resources/POI/CarbonCapture/Nodes/injection-walls-2.png");
pub var injection_walls_3_node = TAsset.init("resources/POI/CarbonCapture/Nodes/injection-walls-3.png");
pub var pipeline_segment_node = TAsset.init("resources/POI/CarbonCapture/Nodes/pipeline-segment.png");
pub var solvent_node = TAsset.init("resources/POI/CarbonCapture/Nodes/solvent.png");

pub var assetPool = AssetPool(rl.Texture).init(&.{
    &poiPinTex,
    &poiPinLockedTex,
    &poiPinHoverTex,
    &poiPinCompletedTex,

    &globeTexture,
    &gameLogo,
    &spaceBg,
    &playBg,

    &desertCutscene,
    &labCutscene,
    &endingCutscene,

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

    &absorber_1_node,
    &absorber_2_node,
    &absorber_3_node,
    &control_rod_node,
    &steam_plate_node,
    &columns_node,

    &injection_walls_1_node,
    &injection_walls_2_node,
    &injection_walls_3_node,
    &pipeline_segment_node,
    &solvent_node,
});

pub var introductionSpeech1 = SAsset.init("resources/audio/intro1.ogg");

pub var introductionSpeech2 = SAsset.init("resources/audio/intro2.ogg");
pub var endingSpeech = SAsset.init("resources/audio/ending.ogg");

pub var click_sfx = SAsset.init("resources/sfx/click.mp3");
pub var slide_sfx = SAsset.init("resources/sfx/slide.mp3");

pub var soundPool = AssetPool(SoundWrapper).init(&.{
    &introductionSpeech1,
    &introductionSpeech2,
    &endingSpeech,

    &click_sfx,
    &slide_sfx,
});
