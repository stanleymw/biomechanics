const rl = @import("raylib");

const PuzzlePiece = bool;

// u4 used cuz 16 possible values
const LevelData = struct {
    x_wires: []u4,
    y_wires: []u4,
    starting_state: [15][15]?PuzzlePiece,
    target_state: [15][15]?PuzzlePiece,
};

const LocationData = struct {
    name: []const u8,
    info: []const u8,
    image_name: []const u8,
    levels: []LevelData,
};

pub const locationInfoText = [_][]const u8{
    // Solar
    \\ Photovoltaic Cells: These are the fundamental units that convert sunlight into electrical energy through the photovoltaic effect. Typically made from silicon, they are interconnected to form a solar panel.
    \\ Encapsulation Layers: Protective layers, usually made of ethylene-vinyl acetate (EVA), encase the photovoltaic cells to shield them from moisture and mechanical damage.
    \\ Glass Cover: A tempered glass layer covers the front of the panel, protecting the cells from environmental factors like hail, wind, and debris while allowing sunlight to pass through.
    \\ Backsheet: The rear layer of the panel, often made of durable polymer, provides electrical insulation and protection from environmental stressors.
    \\ Frame: An aluminum frame surrounds the panel, providing structural support and facilitating mounting onto various surfaces.
    \\ Junction Box: Located on the backside, the junction box houses electrical connections and bypass diodes, enabling safe and efficient current flow.
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
    \\ y
    ,
    \\ z
};
