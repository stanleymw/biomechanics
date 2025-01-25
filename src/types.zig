const rl = @import("raylib");

pub const PuzzlePiece = struct { marked: bool };

// u4 used cuz 16 possible values
pub const LevelData = struct {
    horizontal_wires: []const u4,
    vertical_wires: []const u4,
    diag_up_wires: []const u4,
    diag_down_wires: []const u4,
    state: [15][15]?PuzzlePiece,
    target_state: [15][15]?PuzzlePiece,
};

pub const LocationData = struct {
    name: []const u8,
    info: []const u8,
    image_name: []const u8,
    levels: []LevelData,
};
