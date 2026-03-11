//! Wrapper for handling D3D11 render pipelines.
const Self = @This();

const std = @import("std");

/// Options for initializing a render pipeline.
pub const Options = struct {
    /// HLSL source or bytecode of the vertex shader
    vertex_fn: [:0]const u8,
    /// HLSL source or bytecode of the pixel shader
    fragment_fn: [:0]const u8,

    /// Vertex step function
    step_fn: StepFunction = .per_vertex,

    /// Whether to enable blending.
    blending_enabled: bool = true,

    pub const StepFunction = enum {
        constant,
        per_vertex,
        per_instance,
    };
};

stride: usize,

blending_enabled: bool,

pub fn init(comptime VertexAttributes: ?type, opts: Options) !Self {
    _ = opts;
    return .{
        .stride = if (VertexAttributes) |VA| @sizeOf(VA) else 0,
        .blending_enabled = false,
    };
}

pub fn deinit(self: *const Self) void {
    _ = self;
    // TODO: Release D3D11 pipeline resources
}
