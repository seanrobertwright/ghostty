//! Wrapper for handling D3D11 samplers.
const Self = @This();

const std = @import("std");

/// Options for initializing a sampler.
pub const Options = struct {
    min_filter: Filter = .linear,
    mag_filter: Filter = .linear,
    wrap_s: WrapMode = .clamp_to_edge,
    wrap_t: WrapMode = .clamp_to_edge,

    pub const Filter = enum {
        nearest,
        linear,
    };

    pub const WrapMode = enum {
        clamp_to_edge,
        repeat,
    };
};

pub const Error = error{
    /// A D3D11 API call failed.
    D3D11Failed,
};

/// Initialize a sampler
pub fn init(
    opts: Options,
) Error!Self {
    _ = opts;
    return .{};
}

pub fn deinit(self: Self) void {
    _ = self;
    // TODO: Release D3D11 sampler resources
}
