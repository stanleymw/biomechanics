const types = @import("types.zig");
const LevelData = types.LevelData;
const LocationData = types.LocationData;
const StateBuilder = types.StateBuilder;
const assets = @import("assets.zig");

pub var solar_levels = [_]LevelData{
    LevelData{
        .vertical_wires = &[_]u8{ 6, 7 },
        .horizontal_wires = &[_]u8{ 6, 7 },
        .diag_up_wires = &[_]u8{},
        .diag_down_wires = &[_]u8{},
        .state = StateBuilder
            .empty()
            .box(6, 6, 8, 8, 0)
            .point(6, 6, 1)
            .point(7, 7, 2)
            .build(),
        .target_state = StateBuilder
            .empty()
            .box(6, 6, 8, 8, 0)
            .point(6, 6, 1)
            .point(6, 7, 2)
            .build(),
        .name = "PV Cells",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.n_type_silicon_node,
            &assets.p_type_silicon_node,
        },
        .texture = &assets.solarComponent0,
        .info =
        \\ These are the fundamental units that convert sunlight
        \\ into electrical energy through the photovoltaic effect.
        \\ Typically made from silicon, they are interconnected
        \\ to form a solar panel
        ,
        .locked = false,
    },
    LevelData{
        .vertical_wires = &[_]u8{ 6, 7, 8 },
        .horizontal_wires = &[_]u8{ 6, 7, 8 },
        .diag_up_wires = &[_]u8{},
        .diag_down_wires = &[_]u8{},
        .state = StateBuilder
            .empty()
            .box(6, 6, 9, 9, 0)
            .point(7, 6, 1)
            .build(),
        .target_state = StateBuilder
            .empty()
            .box(6, 6, 9, 9, 0)
            .point(6, 8, 1)
            .build(),
        .name = "Frame",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.screw_node,
        },
        .texture = &assets.solarComponent1,
        .info =
        \\ An aluminum frame surrounds the panel, providing
        \\ structural support and facilitating mounting onto
        \\ various surfaces.
        ,
    },
    LevelData{
        .vertical_wires = &[_]u8{ 6, 8 },
        .horizontal_wires = &[_]u8{ 6, 8 },
        .diag_up_wires = &[_]u8{},
        .diag_down_wires = &[_]u8{},
        .state = StateBuilder
            .empty()
            .hLine(6, 9, 6, 0)
            .hLine(6, 9, 8, 0)
            .vLine(8, 6, 9, 0)
            .vLine(6, 6, 9, 0)
            .point(8, 6, 1)
            .point(6, 8, 2)
            .build(),
        .target_state = StateBuilder
            .empty()
            .hLine(6, 9, 6, 0)
            .hLine(6, 9, 8, 0)
            .vLine(8, 6, 9, 0)
            .vLine(6, 6, 9, 0)
            .point(6, 6, 2)
            .point(8, 8, 1)
            .build(),
        .name = "Glass",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.sealant_node,
            &assets.screw_node,
        },
        .texture = &assets.solarComponent2,
        .info =
        \\ A tempered glass layer covers the front of the panel,
        \\ protecting the cells from environmental factors like
        \\ hail, wind, and debris while allowing sunlight to
        \\ pass through.
        ,
    },
};

pub var nuclear_levels = [_]LevelData{
    LevelData{
        .vertical_wires = &[_]u8{ 5, 7, 9 },
        .horizontal_wires = &[_]u8{7},
        .diag_up_wires = &[_]u8{},
        .diag_down_wires = &[_]u8{},
        .state = StateBuilder
            .empty()
            .vLine(5, 5, 8, 0)
            .vLine(7, 5, 8, 0)
            .vLine(9, 5, 8, 0)
            .hLine(4, 8, 7, 2)
            .point(8, 7, 0)
            .hLine(9, 11, 7, 2)
            .point(5, 8, 1)
            .point(7, 8, 1)
            .point(9, 8, 1)
            .build(),
        .target_state = StateBuilder
            .empty()
            .vLine(5, 6, 9, 0)
            .vLine(7, 6, 9, 0)
            .vLine(9, 6, 9, 0)
            .hLine(4, 8, 7, 2)
            .point(8, 7, 0)
            .hLine(9, 11, 7, 2)
            .point(5, 9, 1)
            .point(7, 9, 1)
            .point(9, 9, 1)
            .build(),
        .name = "Steam Generator",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.steam_plate_node,
            &assets.columns_node,
        },
        .texture = &assets.nuclearComponent1,
        .info =
        \\ Exchanges heat from the primary coolant loop to
        \\ generate steam for driving the turbines.
        ,
        .locked = false,
    },
    LevelData{
        .vertical_wires = &[_]u8{7},
        .horizontal_wires = &[_]u8{ 6, 7 },
        .diag_up_wires = &[_]u8{},
        .diag_down_wires = &[_]u8{},
        .state = StateBuilder
            .empty()
            .hLine(5, 11, 6, 0)
            .hLine(5, 11, 7, 0)
            .point(7, 5, 0)
            .hLine(8, 11, 6, 1)
            .hLine(5, 8, 7, 1)
            .build(),
        .target_state = StateBuilder
            .empty()
            .hLine(5, 11, 6, 0)
            .hLine(5, 11, 7, 0)
            .point(7, 5, 0)
            .hLine(5, 8, 6, 1)
            .hLine(8, 11, 7, 1)
            .build(),
        .name = "Control Rods",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.control_rod_node,
        },
        .texture = &assets.nuclearComponent2,
        .info =
        \\ Made of neutron-absorbing materials like boron or cadmium,
        \\ these rods regulate the fission reaction by adjusting
        \\ neutron flux.
        ,
        .locked = true,
    },
    LevelData{
        .vertical_wires = &[_]u8{},
        .horizontal_wires = &[_]u8{ 4, 7, 10 },
        .diag_up_wires = &[_]u8{ 9, 12, 18 },
        .diag_down_wires = &[_]u8{ 10, 16, 19 },
        .state = StateBuilder
            .empty()
            .hLine(5, 9, 4, 0)
            .hLine(2, 5, 7, 0)
            .diagUpLine(7, 2, 3, 0)
            .diagDownLine(10, 5, 3, 0)
            .diagUpLine(10, 8, 3, 0)
            .diagDownLine(7, 11, 3, 0)
            .diagUpLine(6, 6, 3, 0)
            .diagDownLine(10, 8, 3, 0)
            .hLine(5, 9, 10, 0)
            .point(5, 10, 1)
            .point(5, 4, 3)
            .point(11, 7, 2)
            .build(),
        .target_state = StateBuilder
            .empty()
            .hLine(5, 9, 4, 0)
            .hLine(2, 5, 7, 0)
            .diagUpLine(7, 2, 3, 0)
            .diagDownLine(10, 5, 3, 0)
            .diagUpLine(10, 8, 3, 0)
            .diagDownLine(7, 11, 3, 0)
            .diagUpLine(6, 6, 3, 0)
            .diagDownLine(10, 8, 3, 0)
            .hLine(5, 9, 10, 0)
            .point(4, 7, 3)
            .point(6, 8, 1)
            .point(6, 6, 2)
            .build(),
        .name = "Nuclear Core",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.absorber_1_node,
            &assets.absorber_2_node,
            &assets.absorber_3_node,
        },
        .texture = &assets.nuclearComponent0,
        .info =
        \\ Contains fuel assemblies composed of fissile material,
        \\ typically uranium-235 or plutonium-239, where nuclear
        \\ fission occurs.
        ,
        .locked = true,
    },
};

pub var carbon_levels = [_]LevelData{
    LevelData{
        .vertical_wires = &[_]u8{},
        .horizontal_wires = &[_]u8{ 6, 10 },
        .diag_up_wires = &[_]u8{ 12, 18 },
        .diag_down_wires = &[_]u8{ 12, 18 },
        .state = StateBuilder
            .empty()
            .hLine(6, 9, 6, 0)
            .hLine(6, 9, 10, 0)
            .point(9, 9, 0)
            .point(5, 9, 0)
            .diagDownLine(8, 10, 2, 0)
            .diagUpLine(8, 4, 2, 0)
            .point(10, 8, 1)
            .build(),
        .target_state = StateBuilder
            .empty()
            .hLine(6, 9, 6, 0)
            .hLine(6, 9, 10, 0)
            .point(9, 9, 0)
            .point(5, 9, 0)
            .diagDownLine(8, 10, 2, 0)
            .diagUpLine(8, 4, 2, 0)
            .point(4, 8, 1)
            .build(),
        .name = "Capture Unit",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.solvent_node,
        },
        .texture = &assets.carbonComponent0,
        .info =
        \\ This system extracts carbon deoxide from flue gases
        \\ produced during industrial processes or power generation.
        ,
        .locked = false,
    },
    LevelData{
        .vertical_wires = &[_]u8{},
        .horizontal_wires = &[_]u8{7},
        .diag_up_wires = &[_]u8{14},
        .diag_down_wires = &[_]u8{14},
        .state = StateBuilder
            .empty()
            .hLine(5, 10, 7, 0)
            .diagUpLine(9, 5, 4, 0)
            .diagDownLine(9, 9, 4, 0)
            .point(8, 7, 1)
            .point(9, 7, 1)
            .build(),
        .target_state = StateBuilder
            .empty()
            .hLine(5, 10, 7, 0)
            .diagUpLine(9, 5, 4, 0)
            .diagDownLine(9, 9, 4, 0)
            .point(5, 9, 1)
            .point(9, 9, 1)
            .build(),
        .name = "Transport",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.pipeline_segment_node,
        },
        .texture = &assets.carbonComponent1,
        .info =
        \\ Compressed carbon deoxide is transported via pipelines,
        \\ ships, or trucks to storage sites. Pipelines are the
        \\ most common method for large-scale carbon deoxide
        \\ transport.
        ,
        .locked = true,
    },
    LevelData{
        .vertical_wires = &[_]u8{},
        .horizontal_wires = &[_]u8{8},
        .diag_up_wires = &[_]u8{13},
        .diag_down_wires = &[_]u8{13},
        .state = StateBuilder
            .empty()
            .hLine(5, 10, 8, 0)
            .point(7, 6, 0)
            .point(6, 7, 1)
            .point(8, 7, 2)
            .point(7, 8, 3)
            .build(),
        .target_state = StateBuilder
            .empty()
            .hLine(5, 10, 8, 0)
            .point(7, 6, 1)
            .point(6, 7, 0)
            .point(8, 7, 0)
            .point(5, 8, 3)
            .point(9, 8, 2)
            .build(),
        .name = "Injection Wells",
        .markingPictures = &[_]*assets.TAsset{
            &assets.standard_node,
            &assets.injection_walls_1_node,
            &assets.injection_walls_2_node,
            &assets.injection_walls_3_node,
        },
        .texture = &assets.carbonComponent2,
        .info =
        \\ These are used to inject carbon deoxide into deep
        \\ geological formations, such as depleted oil and gas
        \\ fields or deep saline aquifers, for long-term storage.
        ,
        .locked = true,
    },
};

pub var location_data = [_]LocationData{
    LocationData{
        .name = "West Africa - Solar Panel",
        .image_name = &assets.solarMachine,
        .levels = &solar_levels,
        .info =
        \\Solar panels generate electricity without emitting greenhouse gases
        \\during operation, significantly reducing reliance on fossil fuels.
        \\This leads to a decrease in air pollutants and helps to control
        \\climate change.
        ,
    },
    LocationData{
        .name = "Eastern North America - Carbon Capture",
        .image_name = &assets.carbonMachine,
        .image_scale = 0.8,
        .info =
        \\Carbon capture technology plays an important role in controlling
        \\climate change by reducing the amount of carbon deoxide being
        \\released into the atmosphere from industrial activities and power
        \\generation. The carbon capture system captures and stores carbon
        \\deoxide emissions, thus decreasing greenhouse gas concentrations
        \\that contribute to global warming.
        ,
        .levels = &carbon_levels,
    },
    LocationData{
        .name = "Eastern South America - Nuclear Power",
        .image_name = &assets.nuclearMachine,
        .image_scale = 0.6,
        .levels = &nuclear_levels,
        .info =
        \\Nuclear reactors produce incredible amounts of electricity with
        \\no greenhouse gas emissions during operation, contributing to
        \\reduced air pollution and climate change mitigation
        ,
    },
};
