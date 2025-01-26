const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub const ScrollingTextView = struct {
    bounds: rl.Rectangle,
    content_height: f32,
    scroll: rl.Vector2,
    view: rl.Rectangle,
    text_color: rl.Color,
    background_color: rl.Color,
    text: []const u8,
    font_size: i32,
    font: rl.Font,

    pub fn init(x: f32, y: f32, width: f32, height: f32, initial_text: []const u8, font: rl.Font) ScrollingTextView {
        return ScrollingTextView{
            .bounds = rl.Rectangle{
                .x = x,
                .y = y,
                .width = width,
                .height = height,
            },
            .content_height = height,
            .scroll = rl.Vector2.zero(),
            .view = rl.Rectangle.init(0, 0, 0, 0),
            .font_size = 30,
            .text_color = rl.Color.black,
            .background_color = rl.Color.ray_white,
            .text = initial_text,
            .font = font,
        };
    }

    pub fn setText(self: *ScrollingTextView, text: []const u8) void {
        self.text = text;
        // Calculate content height based on number of lines
        var line_count: usize = 1;
        for (text) |char| {
            if (char == '\n') line_count += 1;
        }
        self.content_height = @as(f32, @floatFromInt(line_count)) *
            @as(f32, @floatFromInt(5 + self.font_size));
    }

    pub fn render(self: *ScrollingTextView) void {
        const content = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = self.bounds.width - 20,
            .height = self.content_height,
        };

        // Convert scroll result to Vector2
        const scroll_result = rg.guiScrollPanel(
            self.bounds,
            null,
            content,
            &self.scroll,
            &self.view,
        );
        self.scroll = .{
            .x = @floatFromInt(scroll_result),
            .y = self.scroll.y,
        };

        rl.beginScissorMode(
            @as(i32, @intFromFloat(self.bounds.x)),
            @as(i32, @intFromFloat(self.bounds.y)),
            @as(i32, @intFromFloat(self.bounds.width)),
            @as(i32, @intFromFloat(self.bounds.height)),
        );

        var current_y: f32 = self.bounds.y + self.scroll.y;

        // Render each line

        var iter = std.mem.splitScalar(u8, self.text, '\n');
        while (iter.next()) |line| {
            rl.drawTextEx(
                self.font,
                @ptrCast(line),
                rl.Vector2.init(self.bounds.x + 4, current_y),
                @as(f32, @floatFromInt(self.font_size)),
                1.0,
                self.text_color,
            );
            current_y += @as(f32, @floatFromInt(self.font_size)) + 5;
        }

        rl.endScissorMode();
    }
};
