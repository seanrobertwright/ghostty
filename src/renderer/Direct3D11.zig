//! Graphics API wrapper for Direct3D 11.
pub const Direct3D11 = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const builtin = @import("builtin");
const shadertoy = @import("shadertoy.zig");
const apprt = @import("../apprt.zig");
const font = @import("../font/main.zig");
const configpkg = @import("../config.zig");
const rendererpkg = @import("../renderer.zig");
const Renderer = rendererpkg.GenericRenderer(Direct3D11);

pub const GraphicsAPI = Direct3D11;
pub const Target = @import("d3d11/Target.zig");
pub const Frame = @import("d3d11/Frame.zig");
pub const RenderPass = @import("d3d11/RenderPass.zig");
pub const Pipeline = @import("d3d11/Pipeline.zig");
const bufferpkg = @import("d3d11/buffer.zig");
pub const Buffer = bufferpkg.Buffer;
pub const Sampler = @import("d3d11/Sampler.zig");
pub const Texture = @import("d3d11/Texture.zig");
pub const shaders = @import("d3d11/shaders.zig");

/// Custom shader target. Since shadertoy.Target only has .glsl and .msl,
/// we use .glsl for now and will add HLSL support later via SPIR-V cross.
pub const custom_shader_target: shadertoy.Target = .glsl;

/// In D3D11, the fragCoord convention is +Y = down.
pub const custom_shader_y_is_down = true;

/// Triple buffering for D3D11 swap chain.
pub const swap_chain_count: comptime_int = 3;

const log = std.log.scoped(.direct3d11);

alloc: std.mem.Allocator,

/// Alpha blending mode
blending: configpkg.Config.AlphaBlending,

/// The most recently presented target, in case we need to present it again.
last_target: ?Target = null,

pub fn init(alloc: Allocator, opts: rendererpkg.Options) error{}!Direct3D11 {
    return .{
        .alloc = alloc,
        .blending = opts.config.blending,
    };
}

pub fn deinit(self: *Direct3D11) void {
    self.* = undefined;
}

/// This is called early right after surface creation.
pub fn surfaceInit(surface: *apprt.Surface) !void {
    _ = surface;
    // TODO: Initialize D3D11 device and swap chain
}

/// This is called just prior to spinning up the renderer
/// thread for final main thread setup requirements.
pub fn finalizeSurfaceInit(self: *const Direct3D11, surface: *apprt.Surface) !void {
    _ = self;
    _ = surface;
}

/// Callback called by renderer.Thread when it begins.
pub fn threadEnter(self: *const Direct3D11, surface: *apprt.Surface) !void {
    _ = self;
    _ = surface;
    // D3D11 is free-threaded, no special thread setup needed.
}

/// Callback called by renderer.Thread when it exits.
pub fn threadExit(self: *const Direct3D11) void {
    _ = self;
}

/// Actions taken before doing anything in `drawFrame`.
pub fn drawFrameStart(self: *Direct3D11) void {
    _ = self;
}

/// Actions taken after `drawFrame` is done.
pub fn drawFrameEnd(self: *Direct3D11) void {
    _ = self;
}

pub fn initShaders(
    self: *const Direct3D11,
    alloc: Allocator,
    custom_shaders: []const [:0]const u8,
) !shaders.Shaders {
    _ = alloc;
    return try shaders.Shaders.init(
        self.alloc,
        custom_shaders,
    );
}

/// Get the current size of the runtime surface.
pub fn surfaceSize(self: *const Direct3D11) !struct { width: u32, height: u32 } {
    _ = self;
    @panic("TODO: D3D11 surfaceSize");
}

/// Initialize a new render target which can be presented by this API.
pub fn initTarget(self: *const Direct3D11, width: usize, height: usize) !Target {
    _ = self;
    return Target.init(.{
        .width = width,
        .height = height,
    });
}

/// Present the provided target.
pub fn present(self: *Direct3D11, target: Target) !void {
    self.last_target = target;
    // TODO: D3D11 present via swap chain
}

/// Present the last presented target again.
pub fn presentLastTarget(self: *Direct3D11) !void {
    if (self.last_target) |target| try self.present(target);
}

/// Returns the options to use when constructing buffers.
pub inline fn bufferOptions(self: Direct3D11) bufferpkg.Options {
    _ = self;
    return .{};
}

pub const instanceBufferOptions = bufferOptions;
pub const uniformBufferOptions = bufferOptions;
pub const fgBufferOptions = bufferOptions;
pub const bgBufferOptions = bufferOptions;
pub const imageBufferOptions = bufferOptions;
pub const bgImageBufferOptions = bufferOptions;

/// Returns the options to use when constructing textures.
pub inline fn textureOptions(self: Direct3D11) Texture.Options {
    _ = self;
    return .{
        .format = .rgba,
        .min_filter = .linear,
        .mag_filter = .linear,
        .wrap_s = .clamp_to_edge,
        .wrap_t = .clamp_to_edge,
    };
}

/// Returns the options to use when constructing samplers.
pub inline fn samplerOptions(self: Direct3D11) Sampler.Options {
    _ = self;
    return .{
        .min_filter = .linear,
        .mag_filter = .linear,
        .wrap_s = .clamp_to_edge,
        .wrap_t = .clamp_to_edge,
    };
}

/// Pixel format for image texture options.
pub const ImageTextureFormat = enum {
    /// 1 byte per pixel grayscale.
    gray,
    /// 4 bytes per pixel RGBA.
    rgba,
    /// 4 bytes per pixel BGRA.
    bgra,

    fn toTextureFormat(self: ImageTextureFormat) Texture.Format {
        return switch (self) {
            .gray => .red,
            .rgba => .rgba,
            .bgra => .bgra,
        };
    }
};

/// Returns the options to use when constructing textures for images.
pub inline fn imageTextureOptions(
    self: Direct3D11,
    format: ImageTextureFormat,
    srgb: bool,
) Texture.Options {
    _ = self;
    _ = srgb;
    return .{
        .format = format.toTextureFormat(),
        .min_filter = .linear,
        .mag_filter = .linear,
        .wrap_s = .clamp_to_edge,
        .wrap_t = .clamp_to_edge,
    };
}

/// Initializes a Texture suitable for the provided font atlas.
pub fn initAtlasTexture(
    self: *const Direct3D11,
    atlas: *const font.Atlas,
) Texture.Error!Texture {
    _ = self;
    const format: Texture.Format = switch (atlas.format) {
        .grayscale => .red,
        .bgra => .bgra,
        else => @panic("unsupported atlas format for D3D11 texture"),
    };

    return try Texture.init(
        .{
            .format = format,
            .min_filter = .nearest,
            .mag_filter = .nearest,
            .wrap_s = .clamp_to_edge,
            .wrap_t = .clamp_to_edge,
        },
        atlas.size,
        atlas.size,
        null,
    );
}

/// Begin a frame.
pub inline fn beginFrame(
    self: *const Direct3D11,
    renderer: *Renderer,
    target: *Target,
) !Frame {
    _ = self;
    return try Frame.begin(.{}, renderer, target);
}
