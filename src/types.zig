const rl = @import("raylib");
const location_info = @import("location_info.zig");

pub const Screen = union(enum) { MainMenu, Globe, Play: Place, LocationInfo: Location, Info, Ending };

pub const Location = enum(u2) {
    SolarPanels,
    CarbonCapture,
    Nuclear,
    pub fn getInfo(self: Location) LocationData {
        return location_info.location_data[@intFromEnum(self)];
    }
};

pub const Place = struct {
    location: Location,
    level: u3,
};

pub const LevelState = [15][15]?PuzzlePiece;
pub const PuzzlePiece = struct { marking: u8 = 0 };

// u4 used cuz 16 possible values
pub const LevelData = struct {
    horizontal_wires: []const u8,
    vertical_wires: []const u8,
    diag_up_wires: []const u8,
    diag_down_wires: []const u8,
    state: LevelState,
    target_state: LevelState,
};

pub const LocationData = struct {
    name: []const u8,
    info: []const u8,
    image_name: []const u8,
    levels: []const LevelData,
    //component_image_names: []const u8,
};

pub const StateBuilder = struct {
    state: LevelState,
    const Self = @This();
    pub fn empty() Self {
        return fromState(.{.{null} ** 15} ** 15);
    }
    fn fromState(state: LevelState) Self {
        return .{ .state = state };
    }
    pub fn build(self: Self) LevelState {
        return self.state;
    }
    pub fn point(self: Self, x: u8, y: u8, marking: u8) Self {
        var state = self.state;
        state[y][x] = .{ .marking = marking };
        return fromState(state);
    }
    pub fn hLine(self: Self, x1: u8, x2: u8, y: u8, marking: u8) Self {
        var state = self.state;
        for (x1..x2) |x| {
            state[y][x] = .{ .marking = marking };
        }
        return fromState(self);
    }
    pub fn vLine(self: Self, x: u8, y1: u8, y2: u8, marking: u8) Self {
        var state = self.state;
        for (y1..y2) |y| {
            state[y][x] = .{ .marking = marking };
        }
        return fromState(self);
    }
    pub fn box(self: Self, x1: u8, y1: u8, x2: u8, y2: u8, marking: u8) Self {
        var state = self.state;
        for (x1..x2) |x| {
            for (y1..y2) |y| {
                state[y][x] = .{ .marking = marking };
            }
        }
        return fromState(state);
    }
};
