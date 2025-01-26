const rl = @import("raylib");

pub const Screen = union(enum) { MainMenu, Globe, Play: Place, LocationInfo: Location, Info };

pub const Location = enum(u4) { SolarPanels, CarbonCapture, Nuclear };
pub const Place = struct {
    location: Location,
    level: u3,
};

pub const PuzzlePiece = struct { marking: u8 = 0 };

// u4 used cuz 16 possible values
pub const LevelData = struct {
    horizontal_wires: []const u8,
    vertical_wires: []const u8,
    diag_up_wires: []const u8,
    diag_down_wires: []const u8,
    state: [15][15]?PuzzlePiece,
    target_state: [15][15]?PuzzlePiece,
};

pub const LocationData = struct {
    name: []const u8,
    info: []const u8,
    image_name: []const u8,
    levels: []LevelData,
};
