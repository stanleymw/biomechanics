const types = @import("types.zig");
const LevelData = types.LevelData;
const LocationData = types.LocationData;
const StateBuilder = types.StateBuilder;
const assets = @import("assets.zig");

pub var location_data = [_]LocationData{
    LocationData{
        .name = "West Africa - Solar Panels",
        .image_name = &assets.solarMachine,
        .levels = &[_]LevelData{
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
            },
        },
        .info =
        \\ Photovoltaic Cells: These are the fundamental units that convert
        \\ sunlight into electrical energy through the photovoltaic effect.
        \\ Typically made from silicon, they are interconnected to form a
        \\ solar panel.
        \\
        \\ Encapsulation Layers: Protective layers, usually made of
        \\ ethylene-vinyl acetate (EVA), encase the photovoltaic cells to
        \\ shield them from moisture and mechanical damage.
        \\
        \\ Glass Cover: A tempered glass layer covers the front of the panel,
        \\ protecting the cells from environmental factors like hail, wind,
        \\ and debris while allowing sunlight to pass through.
        \\ 
        \\ Backsheet: The rear layer of the panel, often made of durable
        \\ polymer, provides electrical insulation and protection from
        \\ environmental stressors.
        \\ Frame: An aluminum frame surrounds the panel, providing structural
        \\ support and facilitating mounting onto various surfaces.
        \\ Junction Box: Located on the backside, the junction box houses
        \\ electrical connections and bypass diodes, enabling safe and
        \\ efficient current flow.
        \\ Operation:
        \\ Energy Capture: When sunlight strikes the photovoltaic cells, photons are absorbed, exciting electrons and creating electron-hole pairs. 
        \\ Energy Conversion: The movement of these electrons generates a direct current (DC).
        \\ Energy Utilization: An inverter converts the DC into alternating current (AC), which can then be used to power electrical devices or fed into the power grid.
        \\ Environmental Contribution:
        \\ -Solar panels generate electricity without emitting greenhouse gases during operation, significantly reducing reliance on fossil fuels. This leads to a decrease in air pollutants and helps to control climate change.
        \\
        \\ Repair:
        \\ Photovoltaic Cell: 
        \\ Inspection: Technicians visually inspect the panel for cracks, discoloration, or hot spots, which may indicate a damaged cell.
        \\ Testing: Electrical tests, such as using a multimeter, assess the performance of the suspected cell to confirm damage.
        \\ Bypass Diode Check: Examine the bypass diodes in the junction box to ensure they are functioning correctly, as faulty diodes can affect cell performance.
        \\ Replacement: If a cell is confirmed to be damaged, the panel may need to be replaced entirely, as individual cell replacement is often impractical due to the encapsulation and sealing of the panel.
        \\ Reinstallation and Testing: After replacement, the panel is reinstalled, and the system is tested to ensure it operates efficiently.
        ,
    },
    LocationData{
        .name = "Eastern South America - Nuclear Power",
        .image_name = &assets.nuclearMachine,
        .levels = &[_]LevelData{
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
                .name = "Nuclear Core",
                .markingPictures = &[_]*assets.TAsset{
                    &assets.standard_node,
                    &assets.n_type_silicon_node,
                    &assets.p_type_silicon_node,
                },
                .locked = false,
            },
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
                    .hLine(4, 11, 7, 0)
                    .point(5, 8, 1)
                    .point(7, 8, 1)
                    .point(9, 8, 1)
                    .build(),
                .target_state = StateBuilder
                    .empty()
                    .vLine(5, 6, 9, 0)
                    .vLine(7, 6, 9, 0)
                    .vLine(9, 6, 9, 0)
                    .hLine(4, 11, 7, 0)
                    .point(5, 9, 1)
                    .point(7, 9, 1)
                    .point(9, 9, 1)
                    .build(),
                .name = "Steam Generator",
                .markingPictures = &[_]*assets.TAsset{
                    &assets.standard_node,
                    &assets.n_type_silicon_node,
                },
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
                    &assets.n_type_silicon_node,
                    &assets.p_type_silicon_node,
                },
                .locked = false,
            },
        },
        .info = "placeholder info",
    },
    LocationData{
        .name = "Eastern North America - Carbon Capture",
        .image_name = &assets.carbonMachine,
        .info = "placeholder info",
        .levels = &[_]LevelData{},
    },
};
