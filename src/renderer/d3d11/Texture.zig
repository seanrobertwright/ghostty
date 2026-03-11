//! Wrapper for handling D3D11 textures.
const Self = @This();

const std = @import("std");

pub const Format = enum {
    rgba,
    bgra,
    red,
    srgba,
};

pub const Filter = enum {
    nearest,
    linear,
};

pub const WrapMode = enum {
    clamp_to_edge,
    repeat,
};

/// Options for initializing a texture.
pub const Options = struct {
    format: Format = .rgba,
    min_filter: Filter = .linear,
    mag_filter: Filter = .linear,
    wrap_s: WrapMode = .clamp_to_edge,
    wrap_t: WrapMode = .clamp_to_edge,
};

/// The width of this texture.
width: usize,
/// The height of this texture.
height: usize,

/// Format for this texture.
format: Format,

pub const Error = error{
    /// A D3D11 API call failed.
    D3D11Failed,
};

/// Initialize a texture
pub fn init(
    opts: Options,
    width: usize,
    height: usize,
    data: ?[]const u8,
) Error!Self {
    _ = data;
    return .{
        .width = width,
        .height = height,
        .format = opts.format,
    };
}

pub fn deinit(self: Self) void {
    _ = self;
    // TODO: Release D3D11 texture resources
}

/// Replace a region of the texture with the provided data.
pub fn replaceRegion(
    self: Self,
    x: usize,
    y: usize,
    width: usize,
    height: usize,
    data: []const u8,
) Error!void {
    _ = self;
    _ = x;
    _ = y;
    _ = width;
    _ = height;
    _ = data;
    @panic("TODO: D3D11 replaceRegion");
}
