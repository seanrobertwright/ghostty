//! Wrapper for handling D3D11 render passes.
const Self = @This();

const std = @import("std");

const Sampler = @import("Sampler.zig");
const Target = @import("Target.zig");
const Texture = @import("Texture.zig");
const Pipeline = @import("Pipeline.zig");
const BufferHandle = @import("buffer.zig").Handle;

/// Options for beginning a render pass.
pub const Options = struct {
    /// Color attachments for this render pass.
    attachments: []const Attachment,

    /// Describes a color attachment.
    pub const Attachment = struct {
        target: union(enum) {
            texture: Texture,
            target: Target,
        },
        clear_color: ?[4]f32 = null,
    };
};

/// Describes a step in a render pass.
pub const Step = struct {
    pipeline: Pipeline,
    uniforms: ?BufferHandle = null,
    buffers: []const ?BufferHandle = &.{},
    textures: []const ?Texture = &.{},
    samplers: []const ?Sampler = &.{},
    draw: Draw,

    /// Describes the draw call for this step.
    pub const Draw = struct {
        type: PrimitiveType,
        vertex_count: usize,
        instance_count: usize = 1,

        pub const PrimitiveType = enum(u32) {
            triangle = 4,
            triangle_strip = 5,
        };
    };
};

attachments: []const Options.Attachment,

step_number: usize = 0,

/// Begin a render pass.
pub fn begin(
    opts: Options,
) Self {
    return .{
        .attachments = opts.attachments,
    };
}

/// Add a step to this render pass.
pub fn step(self: *Self, s: Step) void {
    _ = s;
    defer self.step_number += 1;
    @panic("TODO: D3D11 render pass step");
}

/// Complete this render pass.
pub fn complete(self: *const Self) void {
    _ = self;
    // TODO: D3D11 render pass completion
}
