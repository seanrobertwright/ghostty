//! Re-exports for Direct3D 11 COM bindings.
//!
//! This module will re-export the D3D11 COM bindings once they are available
//! from Chunk 2. For now, it provides placeholder types.

/// Placeholder for D3D11 buffer type.
pub const Buffer = opaque {};

/// Placeholder for D3D11 primitive topology.
pub const Primitive = enum(u32) {
    triangle = 4,
    triangle_strip = 5,
};
