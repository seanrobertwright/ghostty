//! Represents a D3D11 render target.
//!
//! A render target backed by a D3D11 render target view, which could
//! be a swap chain back buffer or an offscreen texture.
const Self = @This();

const std = @import("std");

/// Options for initializing a Target
pub const Options = struct {
    /// Desired width
    width: usize,
    /// Desired height
    height: usize,
};

/// Current width of this target.
width: usize,
/// Current height of this target.
height: usize,

pub fn init(opts: Options) !Self {
    return .{
        .width = opts.width,
        .height = opts.height,
    };
}

pub fn deinit(self: *Self) void {
    _ = self;
    // TODO: Release D3D11 render target resources
}
