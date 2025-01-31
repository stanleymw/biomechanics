const rl = @import("raylib");
const location_info = @import("location_info.zig");
const assets = @import("assets.zig");

pub const Screen = union(enum) {
    MainMenu,
    Globe,
    Play: Place,
    LocationInfo: Location,
    ComponentInfo: Location,
    Info,
    Ending,
};

pub const Location = enum(u2) {
    SolarPanels,
    Nuclear,
    CarbonCapture,
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
    name: [:0]const u8,
    markingPictures: []const *assets.TAsset,
    solved: bool = false,
    locked: bool = true,
};

pub const LocationData = struct {
    name: []const u8,
    info: []const u8,
    image_name: *assets.TAsset,
    levels: []const LevelData,
    //component_image_names: []const u8,
};

pub const StateBuilder = struct {
    state: LevelState,
    pub fn empty() StateBuilder {
        return fromState(.{.{null} ** 15} ** 15);
    }
    fn fromState(state: LevelState) StateBuilder {
        return .{ .state = state };
    }
    pub fn build(self: StateBuilder) LevelState {
        return self.state;
    }
    pub fn point(self: StateBuilder, x: u8, y: u8, marking: u8) StateBuilder {
        var state = self.state;
        state[y][x] = .{ .marking = marking };
        return fromState(state);
    }
    pub fn hLine(self: StateBuilder, x1: u8, x2: u8, y: u8, marking: u8) StateBuilder {
        var state = self.state;
        for (x1..x2) |x| {
            state[y][x] = .{ .marking = marking };
        }
        return fromState(state);
    }
    pub fn vLine(self: StateBuilder, x: u8, y1: u8, y2: u8, marking: u8) StateBuilder {
        var state = self.state;
        for (y1..y2) |y| {
            state[y][x] = .{ .marking = marking };
        }
        return fromState(state);
    }

    /// Draws a diagonal line starting at state[r][c] with specified len
    pub fn diagDownLine(self: StateBuilder, r: usize, c: usize, len: usize, marking: u8) StateBuilder {
        var state = self.state;

        var cx: usize = r;
        var cy: usize = c;
        for (0..len) |_| {
            state[cx][cy] = .{ .marking = marking };
            cx -= 1;
            cy -= 1;
        }

        return fromState(state);
    }

    /// Draws a diagonal line starting at state[r][c] with specified len
    pub fn diagUpLine(self: StateBuilder, r: usize, c: usize, len: usize, marking: u8) StateBuilder {
        var state = self.state;

        var cx = r;
        var cy = c;
        for (0..len) |_| {
            state[cx][cy] = .{ .marking = marking };
            cx -= 1;
            cy += 1;
        }

        return fromState(state);
    }

    pub fn box(self: StateBuilder, x1: u8, y1: u8, x2: u8, y2: u8, marking: u8) StateBuilder {
        var state = self.state;
        for (x1..x2) |x| {
            for (y1..y2) |y| {
                state[y][x] = .{ .marking = marking };
            }
        }
        return fromState(state);
    }
};
