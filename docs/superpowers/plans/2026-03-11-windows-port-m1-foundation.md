# Windows Port Milestone 1: Foundation — Implementation Plan

> **For agentic workers:** REQUIRED: Use lril-superpowers:subagent-driven-development (if subagents available) or lril-superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Get a Win32 window rendering a PowerShell session via D3D11 and ConPTY — proving the end-to-end pipeline works on Windows 11.

**Architecture:** Add `.win32` app runtime, `.direct3d11` renderer backend, and wire them through Ghostty's existing compile-time polymorphism. Use FreeType (already cross-platform) for font rendering in this milestone — DirectWrite comes in M2. The terminal core, parser, scrollback, and cell rendering logic are shared unchanged.

**Tech Stack:** Zig 0.15.2, Win32 API, Direct3D 11, DXGI 1.2, HLSL, FreeType, HarfBuzz, ConPTY, libxev (IOCP backend)

**Spec:** `docs/superpowers/specs/2026-03-11-windows-port-design.md`

---

## File Map

### New Files

| File | Responsibility |
|------|---------------|
| `src/apprt/win32.zig` | Win32 apprt module root — exports App, Surface, runtime selection |
| `src/apprt/win32/App.zig` | Application lifecycle, Win32 message loop + libxev integration |
| `src/apprt/win32/Surface.zig` | Terminal surface — child HWND, input translation, D3D11 swap chain host |
| `src/apprt/win32/Window.zig` | Top-level window — HWND creation, resize, DPI, basic chrome |
| `src/renderer/Direct3D11.zig` | D3D11 GraphicsAPI — device creation, swap chain, frame presentation |
| `src/renderer/d3d11/Frame.zig` | Frame context — begin/end frame, clear render target |
| `src/renderer/d3d11/RenderPass.zig` | Render pass — bind state, iterate steps, draw calls |
| `src/renderer/d3d11/Pipeline.zig` | Vertex + pixel shader pair + input layout |
| `src/renderer/d3d11/buffer.zig` | Generic typed GPU buffer (vertex, index, constant) |
| `src/renderer/d3d11/Texture.zig` | ID3D11Texture2D + ShaderResourceView |
| `src/renderer/d3d11/Sampler.zig` | ID3D11SamplerState |
| `src/renderer/d3d11/Target.zig` | Swap chain render target + off-screen FBO |
| `src/renderer/d3d11/shaders.zig` | HLSL shader compilation, embedded bytecode |
| `src/renderer/d3d11/api.zig` | D3D11/DXGI COM vtable declarations |
| `pkg/windows/d3d11.zig` | D3D11 COM interface bindings (IDirect3DDevice11, etc.) |
| `pkg/windows/dxgi.zig` | DXGI COM interface bindings (IDXGIFactory2, IDXGISwapChain1, etc.) |
| `pkg/windows/d3dcompiler.zig` | D3DCompile function binding |
| `src/renderer/shaders/hlsl/cell_vs.hlsl` | HLSL cell vertex shader |
| `src/renderer/shaders/hlsl/cell_ps.hlsl` | HLSL cell pixel shader |

### Modified Files

| File | Change |
|------|--------|
| `src/apprt/runtime.zig` | Add `.win32` variant to `Runtime` enum |
| `src/renderer/backend.zig` | Add `.direct3d11` variant to `Backend` enum |
| `src/font/backend.zig` | Add `.directwrite_harfbuzz` variant (stub — uses freetype for M1) |
| `src/build/Config.zig` | Add Windows defaults for runtime, renderer, font backend |
| `src/apprt.zig` | Add `win32` import (line ~18) and `.win32` branch in runtime switch (line ~44) |
| `src/renderer.zig` | Add `pub const Direct3D11 = @import("renderer/Direct3D11.zig")` (line ~19) and `.direct3d11` branch (line ~39) |
| `src/os/main.zig` | Ensure Windows-specific OS utils are exported |
| `src/config/path.zig` | Add Windows config directory paths (%APPDATA%) |
| `src/os/homedir.zig` | Windows home directory via SHGetKnownFolderPath |
| `src/os/shell.zig` | Windows default shell detection (%COMSPEC%, PowerShell) |
| `build.zig` | Add Windows build target configuration |

---

## Chunk 1: Build System & Platform Enums

### Task 1: Add Win32 Runtime Variant

**Files:**
- Modify: `src/apprt/runtime.zig`
- Modify: `src/build/Config.zig`

- [ ] **Step 1: Add `.win32` to the Runtime enum**

In `src/apprt/runtime.zig`, add `win32` variant and update `default()`:

```zig
pub const Runtime = enum {
    none,
    gtk,
    win32,

    pub fn default(target: std.Target) Runtime {
        return switch (target.os.tag) {
            .linux, .freebsd => .gtk,
            .windows => .win32,
            else => .none,
        };
    }
};
```

- [ ] **Step 2: Update Config.zig to handle win32 runtime**

In `src/build/Config.zig`, find where `app_runtime` default is set and add Windows:

```zig
// In the init function, where app_runtime is determined:
const app_runtime: ApprtRuntime = b.option(
    ApprtRuntime,
    "app-runtime",
    "The app runtime to use",
) orelse ApprtRuntime.default(target.result);
```

Verify `ApprtRuntime.default` now returns `.win32` for Windows targets.

- [ ] **Step 3: Build to verify enum compiles**

Run: `zig build -Dtarget=x86_64-windows --help` (or just check it parses)
Expected: No compile errors related to the new enum variant

- [ ] **Step 4: Commit**

```bash
git add src/apprt/runtime.zig src/build/Config.zig
git commit -m "build: add win32 app runtime variant"
```

### Task 2: Add Direct3D11 Renderer Variant

**Files:**
- Modify: `src/renderer/backend.zig`
- Modify: `src/build/Config.zig`

- [ ] **Step 1: Add `.direct3d11` to the Backend enum**

In `src/renderer/backend.zig`:

```zig
pub const Backend = enum {
    opengl,
    metal,
    webgl,
    direct3d11,

    pub fn default(
        target: std.Target,
        wasm_target: WasmTarget,
    ) Backend {
        if (target.cpu.arch == .wasm32) {
            return switch (wasm_target) {
                .browser => .webgl,
            };
        }
        if (target.os.tag.isDarwin()) return .metal;
        if (target.os.tag == .windows) return .direct3d11;
        return .opengl;
    }
};
```

- [ ] **Step 2: Commit**

```bash
git add src/renderer/backend.zig
git commit -m "build: add direct3d11 renderer backend variant"
```

### Task 3: Add Font Backend Variant for Windows

**Files:**
- Modify: `src/font/backend.zig`

- [ ] **Step 1: Add `.directwrite_harfbuzz` variant**

For M1, this will actually resolve to FreeType+HarfBuzz internally. The variant exists so the build config is correct; the actual DirectWrite implementation comes in M2.

```zig
pub const Backend = enum {
    freetype,
    fontconfig_freetype,
    coretext,
    coretext_freetype,
    coretext_harfbuzz,
    coretext_noshape,
    web_canvas,
    directwrite_harfbuzz,

    pub fn default(
        target: std.Target,
        wasm_target: WasmTarget,
    ) Backend {
        if (target.cpu.arch == .wasm32) {
            return switch (wasm_target) {
                .browser => .web_canvas,
            };
        }
        if (target.os.tag.isDarwin()) return .coretext;
        if (target.os.tag == .windows) return .directwrite_harfbuzz;
        return .fontconfig_freetype;
    }

    pub fn hasFreetype(self: Backend) bool {
        return switch (self) {
            .freetype,
            .fontconfig_freetype,
            .coretext_freetype,
            .directwrite_harfbuzz, // M1: uses FreeType under the hood
            => true,
            .coretext,
            .coretext_harfbuzz,
            .coretext_noshape,
            .web_canvas,
            => false,
        };
    }

    pub fn hasHarfbuzz(self: Backend) bool {
        return switch (self) {
            .freetype,
            .fontconfig_freetype,
            .coretext_freetype,
            .coretext_harfbuzz,
            .directwrite_harfbuzz,
            => true,
            .coretext,
            .coretext_noshape,
            .web_canvas,
            => false,
        };
    }

    pub fn hasCoretext(self: Backend) bool {
        return switch (self) {
            .coretext,
            .coretext_freetype,
            .coretext_harfbuzz,
            .coretext_noshape,
            => true,
            .freetype,
            .fontconfig_freetype,
            .web_canvas,
            .directwrite_harfbuzz,
            => false,
        };
    }

    pub fn hasFontconfig(self: Backend) bool {
        return switch (self) {
            .fontconfig_freetype => true,
            else => false,
        };
    }

    pub fn hasDirectwrite(self: Backend) bool {
        return switch (self) {
            .directwrite_harfbuzz => true,
            else => false,
        };
    }
};
```

- [ ] **Step 2: Commit**

```bash
git add src/font/backend.zig
git commit -m "build: add directwrite_harfbuzz font backend variant"
```

### Task 4: Windows Config Paths

**Files:**
- Modify: `src/config/path.zig`
- Modify: `src/os/homedir.zig`
- Modify: `src/os/shell.zig`

- [ ] **Step 1: Read current implementations**

Read `src/config/path.zig`, `src/os/homedir.zig`, `src/os/shell.zig` to understand the existing platform switches and XDG logic.

- [ ] **Step 2: Add Windows config directory**

In `src/config/path.zig`, add a Windows branch that uses `SHGetKnownFolderPath(FOLDERID_RoamingAppData)` to return `%APPDATA%\ghostty\config`. Use `std.os.windows` for the API call.

- [ ] **Step 3: Add Windows home directory**

In `src/os/homedir.zig`, add a Windows branch using `SHGetKnownFolderPath(FOLDERID_Profile)` or `USERPROFILE` environment variable.

- [ ] **Step 4: Add Windows default shell detection**

In `src/os/shell.zig`, add a Windows branch:
- Check `GHOSTTY_SHELL` env var first (existing behavior)
- Fall back to `COMSPEC` env var (typically `C:\Windows\system32\cmd.exe`)
- If neither, hard-code `powershell.exe`

- [ ] **Step 5: Commit**

```bash
git add src/config/path.zig src/os/homedir.zig src/os/shell.zig
git commit -m "os: add Windows config paths, home dir, and shell detection"
```

### Task 4b: OS Utils & Build Plumbing for Windows

**Files:**
- Modify: `src/os/main.zig`
- Modify: `build.zig`

- [ ] **Step 1: Verify `src/os/main.zig` exports Windows utils**

Read `src/os/main.zig` and ensure `windows.zig` is imported and exported for the Windows target. Add a Windows branch if missing.

- [ ] **Step 2: Add Windows library linking to `build.zig`**

Read `build.zig` and find where platform-specific libraries are linked (search for `linkFramework` or `linkSystemLibrary` for macOS). Add a Windows-specific block:

```zig
if (target.result.os.tag == .windows) {
    exe.linkSystemLibrary("d3d11");
    exe.linkSystemLibrary("dxgi");
    exe.linkSystemLibrary("d3dcompiler_47");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("ole32");
    exe.linkSystemLibrary("dwmapi");
}
```

- [ ] **Step 3: Verify build still compiles for existing targets**

Run: `zig build --help` (ensure no syntax errors in build.zig)

- [ ] **Step 4: Commit**

```bash
git add src/os/main.zig build.zig
git commit -m "build: add Windows library linking and OS utils export"
```

---

## Chunk 2: D3D11/DXGI COM Bindings

### Task 5: DXGI COM Interface Bindings

**Files:**
- Create: `pkg/windows/dxgi.zig`

- [ ] **Step 1: Create DXGI bindings file**

Define COM vtable structs for the DXGI interfaces needed:

```zig
const std = @import("std");
const windows = std.os.windows;
const HRESULT = windows.HRESULT;
const GUID = windows.GUID;
const BOOL = windows.BOOL;
const UINT = c_uint;
const HWND = windows.HWND;

// IUnknown base
pub const IUnknown = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        QueryInterface: *const fn (*IUnknown, *const GUID, *?*anyopaque) callconv(.C) HRESULT,
        AddRef: *const fn (*IUnknown) callconv(.C) u32,
        Release: *const fn (*IUnknown) callconv(.C) u32,
    };

    pub fn release(self: *IUnknown) void {
        _ = self.vtable.Release(self);
    }
};

// IDXGIFactory2
pub const IDXGIFactory2 = extern struct {
    vtable: *const VTable,
    // ... vtable entries for CreateSwapChainForHwnd, etc.
};

// IDXGISwapChain1
pub const IDXGISwapChain1 = extern struct {
    vtable: *const VTable,
    // ... vtable entries for Present, ResizeBuffers, GetBuffer, etc.
};

// DXGI_SWAP_CHAIN_DESC1, DXGI_SWAP_EFFECT, DXGI_FORMAT, etc.
pub const DXGI_FORMAT = enum(u32) {
    B8G8R8A8_UNORM = 87,
    R8G8B8A8_UNORM = 28,
    // ... other formats as needed
};

pub const DXGI_SWAP_EFFECT = enum(u32) {
    FLIP_DISCARD = 4,
};

pub const DXGI_SWAP_CHAIN_DESC1 = extern struct {
    Width: UINT,
    Height: UINT,
    Format: DXGI_FORMAT,
    Stereo: BOOL,
    SampleDesc: DXGI_SAMPLE_DESC,
    BufferUsage: u32,
    BufferCount: UINT,
    Scaling: u32,
    SwapEffect: DXGI_SWAP_EFFECT,
    AlphaMode: u32,
    Flags: u32,
};

// CreateDXGIFactory2 function import
pub extern "dxgi" fn CreateDXGIFactory2(
    Flags: UINT,
    riid: *const GUID,
    ppFactory: *?*anyopaque,
) callconv(.C) HRESULT;
```

This is a large file — define all DXGI types and COM vtables needed for swap chain creation and management. Follow the pattern of listing every vtable slot in order (including inherited IUnknown/IDXGIObject methods) to get correct offsets.

- [ ] **Step 2: Write a basic compile test**

Add a `test` block at the bottom of the file:

```zig
test "dxgi type sizes" {
    // Verify struct layout matches expected COM vtable sizes
    try std.testing.expect(@sizeOf(DXGI_SWAP_CHAIN_DESC1) > 0);
}
```

- [ ] **Step 3: Commit**

```bash
git add pkg/windows/dxgi.zig
git commit -m "pkg: add DXGI COM interface bindings for Windows"
```

### Task 6: D3D11 COM Interface Bindings

**Files:**
- Create: `pkg/windows/d3d11.zig`

- [ ] **Step 1: Create D3D11 bindings file**

Define COM vtable structs for D3D11 interfaces:

- `ID3D11Device` — `CreateBuffer`, `CreateTexture2D`, `CreateShaderResourceView`, `CreateRenderTargetView`, `CreateVertexShader`, `CreatePixelShader`, `CreateInputLayout`, `CreateSamplerState`, `CreateBlendState`
- `ID3D11DeviceContext` — `IASetVertexBuffers`, `IASetIndexBuffer`, `IASetInputLayout`, `IASetPrimitiveTopology`, `VSSetShader`, `VSSetConstantBuffers`, `PSSetShader`, `PSSetShaderResources`, `PSSetSamplers`, `PSSetConstantBuffers`, `OMSetRenderTargets`, `OMSetBlendState`, `RSSetViewports`, `Draw`, `DrawIndexed`, `DrawInstanced`, `Map`, `Unmap`, `ClearRenderTargetView`, `UpdateSubresource`
- `ID3D11Resource`, `ID3D11Buffer`, `ID3D11Texture2D`, `ID3D11ShaderResourceView`, `ID3D11RenderTargetView`
- `ID3D11VertexShader`, `ID3D11PixelShader`, `ID3D11InputLayout`
- `ID3D11SamplerState`, `ID3D11BlendState`

Also define:
- `D3D11_BUFFER_DESC`, `D3D11_TEXTURE2D_DESC`, `D3D11_SUBRESOURCE_DATA`
- `D3D11_INPUT_ELEMENT_DESC`, `D3D11_VIEWPORT`
- `D3D11_BLEND_DESC`, `D3D11_SAMPLER_DESC`
- `D3D11CreateDevice` extern function import

- [ ] **Step 2: Write compile test**

```zig
test "d3d11 type sizes" {
    try std.testing.expect(@sizeOf(D3D11_BUFFER_DESC) > 0);
    try std.testing.expect(@sizeOf(D3D11_VIEWPORT) == 24); // 6 floats
}
```

- [ ] **Step 3: Commit**

```bash
git add pkg/windows/d3d11.zig
git commit -m "pkg: add D3D11 COM interface bindings for Windows"
```

### Task 7: D3DCompiler Bindings

**Files:**
- Create: `pkg/windows/d3dcompiler.zig`

- [ ] **Step 1: Create D3DCompiler bindings**

```zig
const std = @import("std");
const windows = std.os.windows;
const HRESULT = windows.HRESULT;
const dxgi = @import("dxgi.zig");

pub const ID3DBlob = extern struct {
    vtable: *const VTable,

    pub const VTable = extern struct {
        // IUnknown
        QueryInterface: *const anyopaque,
        AddRef: *const fn (*ID3DBlob) callconv(.C) u32,
        Release: *const fn (*ID3DBlob) callconv(.C) u32,
        // ID3DBlob
        GetBufferPointer: *const fn (*ID3DBlob) callconv(.C) *anyopaque,
        GetBufferSize: *const fn (*ID3DBlob) callconv(.C) usize,
    };

    pub fn getBufferPointer(self: *ID3DBlob) *anyopaque {
        return self.vtable.GetBufferPointer(self);
    }

    pub fn getBufferSize(self: *ID3DBlob) usize {
        return self.vtable.GetBufferSize(self);
    }

    pub fn release(self: *ID3DBlob) void {
        _ = self.vtable.Release(self);
    }
};

pub extern "d3dcompiler_47" fn D3DCompile(
    pSrcData: [*]const u8,
    SrcDataSize: usize,
    pSourceName: ?[*:0]const u8,
    pDefines: ?*const anyopaque,
    pInclude: ?*const anyopaque,
    pEntrypoint: [*:0]const u8,
    pTarget: [*:0]const u8,
    Flags1: u32,
    Flags2: u32,
    ppCode: *?*ID3DBlob,
    ppErrorMsgs: *?*ID3DBlob,
) callconv(.C) HRESULT;
```

- [ ] **Step 2: Commit**

```bash
git add pkg/windows/d3dcompiler.zig
git commit -m "pkg: add D3DCompiler bindings for Windows"
```

---

## Chunk 3: D3D11 Renderer Implementation

### Task 8: D3D11 Renderer Shell — Device & Swap Chain

**Files:**
- Create: `src/renderer/Direct3D11.zig`
- Create: `src/renderer/d3d11/api.zig`

- [ ] **Step 1: Create api.zig re-export**

`src/renderer/d3d11/api.zig` re-exports the COM bindings for convenient use within the renderer:

```zig
pub const d3d11 = @import("../../pkg/windows/d3d11.zig");
pub const dxgi = @import("../../pkg/windows/dxgi.zig");
pub const d3dcompiler = @import("../../pkg/windows/d3dcompiler.zig");
```

- [ ] **Step 2: Create Direct3D11.zig with device initialization**

Implement the top-level `GraphicsAPI` struct with:

```zig
const Self = @This();

// Required comptime constants
pub const swap_chain_count = 3; // Triple buffering
pub const custom_shader_target: shadertoy.Target = .hlsl;
pub const custom_shader_y_is_down = true;

// Required type aliases (will be implemented in subsequent tasks)
pub const Target = @import("d3d11/Target.zig");
pub const Frame = @import("d3d11/Frame.zig");
pub const RenderPass = @import("d3d11/RenderPass.zig");
pub const Pipeline = @import("d3d11/Pipeline.zig");
pub const Buffer = @import("d3d11/buffer.zig").Buffer;
pub const Texture = @import("d3d11/Texture.zig");
pub const Sampler = @import("d3d11/Sampler.zig");
pub const shaders = @import("d3d11/shaders.zig");

// State
device: *d3d11.ID3D11Device,
context: *d3d11.ID3D11DeviceContext,
factory: *dxgi.IDXGIFactory2,
swap_chain: ?*dxgi.IDXGISwapChain1,
blending: configpkg.Config.AlphaBlending,

pub fn init(alloc: Allocator, opts: rendererpkg.Options) !Self { ... }
pub fn deinit(self: *Self) void { ... }
```

The `init` function:
1. Call `D3D11CreateDevice(null, .HARDWARE, null, flags, &feature_levels, ...)`
2. Query `IDXGIDevice` → `GetAdapter` → `GetParent` to get `IDXGIFactory2`
3. Store device, context, factory

- [ ] **Step 3: Implement surfaceSize and beginFrame stubs**

Add the remaining required GraphicsAPI methods as stubs that return errors or defaults. This lets us compile and iterate.

- [ ] **Step 4: Commit**

```bash
git add src/renderer/Direct3D11.zig src/renderer/d3d11/api.zig
git commit -m "renderer: add Direct3D11 device initialization"
```

### Task 9: D3D11 Buffer Type

**Files:**
- Create: `src/renderer/d3d11/buffer.zig`

- [ ] **Step 1: Implement generic Buffer**

The Buffer must be a function that returns a type parameterized on element type T:

```zig
pub fn Buffer(comptime T: type) type {
    return struct {
        const Self = @This();

        buffer: *d3d11.ID3D11Buffer,
        len: usize,

        pub const Options = struct {
            usage: d3d11.D3D11_USAGE,
            bind_flags: u32,
            cpu_access: u32,
        };

        pub fn init(opts: Options, len: usize) !Self { ... }
        pub fn initFill(opts: Options, data: []const T) !Self { ... }
        pub fn deinit(self: *const Self) void { ... }
        pub fn sync(self: *Self, data: []const T) !void { ... }
    };
}
```

`init` creates a `D3D11_BUFFER_DESC` and calls `device.CreateBuffer`.
`sync` uses `context.Map` / `context.Unmap` for dynamic buffers, or `UpdateSubresource` for default buffers.

- [ ] **Step 2: Commit**

```bash
git add src/renderer/d3d11/buffer.zig
git commit -m "renderer/d3d11: implement Buffer type"
```

### Task 10: D3D11 Texture Type

**Files:**
- Create: `src/renderer/d3d11/Texture.zig`

- [ ] **Step 1: Implement Texture**

```zig
pub const Texture = struct {
    texture: *d3d11.ID3D11Texture2D,
    srv: *d3d11.ID3D11ShaderResourceView,
    width: usize,
    height: usize,

    pub const Options = struct {
        format: dxgi.DXGI_FORMAT,
        usage: d3d11.D3D11_USAGE,
        bind_flags: u32,
        cpu_access: u32,
    };

    pub fn init(opts: Options, width: usize, height: usize, data: ?[]const u8) !Self { ... }
    pub fn deinit(self: Self) void { ... }
    pub fn replaceRegion(self: Self, x: usize, y: usize, w: usize, h: usize, data: []const u8) !void { ... }
};
```

`init` creates `D3D11_TEXTURE2D_DESC`, calls `CreateTexture2D`, then `CreateShaderResourceView`.
`replaceRegion` uses `Map`/`Unmap` or `UpdateSubresource` to update a sub-rectangle.

- [ ] **Step 2: Commit**

```bash
git add src/renderer/d3d11/Texture.zig
git commit -m "renderer/d3d11: implement Texture type"
```

### Task 11: D3D11 Sampler Type

**Files:**
- Create: `src/renderer/d3d11/Sampler.zig`

- [ ] **Step 1: Implement Sampler**

```zig
pub const Sampler = struct {
    sampler: *d3d11.ID3D11SamplerState,

    pub const Options = struct {
        filter: d3d11.D3D11_FILTER,
        address_mode: d3d11.D3D11_TEXTURE_ADDRESS_MODE,
    };

    pub fn init(opts: Options) !Self { ... }
    pub fn deinit(self: Self) void { ... }
};
```

- [ ] **Step 2: Commit**

```bash
git add src/renderer/d3d11/Sampler.zig
git commit -m "renderer/d3d11: implement Sampler type"
```

### Task 12: D3D11 Pipeline Type

**Files:**
- Create: `src/renderer/d3d11/Pipeline.zig`

- [ ] **Step 1: Implement Pipeline**

```zig
pub const Pipeline = struct {
    vertex_shader: *d3d11.ID3D11VertexShader,
    pixel_shader: *d3d11.ID3D11PixelShader,
    input_layout: *d3d11.ID3D11InputLayout,
    blend_state: ?*d3d11.ID3D11BlendState,

    pub const Options = struct {
        vertex_bytecode: []const u8,
        pixel_bytecode: []const u8,
        input_elements: []const d3d11.D3D11_INPUT_ELEMENT_DESC,
        blending_enabled: bool = true,
    };

    pub fn init(comptime VertexAttributes: ?type, opts: Options) !Self { ... }
    pub fn deinit(self: *const Self) void { ... }
};
```

`init` creates vertex shader, pixel shader, input layout, and optionally blend state from the device.

- [ ] **Step 2: Commit**

```bash
git add src/renderer/d3d11/Pipeline.zig
git commit -m "renderer/d3d11: implement Pipeline type"
```

### Task 13: D3D11 Target Type

**Files:**
- Create: `src/renderer/d3d11/Target.zig`

- [ ] **Step 1: Implement Target**

The render target wraps either a swap chain back buffer or an off-screen texture:

```zig
pub const Target = struct {
    rtv: *d3d11.ID3D11RenderTargetView,
    width: usize,
    height: usize,

    pub const Options = struct {
        device: *d3d11.ID3D11Device,
        swap_chain: ?*dxgi.IDXGISwapChain1,
        texture: ?*d3d11.ID3D11Texture2D,
    };

    pub fn init(opts: Options) !Self { ... }
    pub fn deinit(self: Self) void { ... }
};
```

For swap chain targets: `swap_chain.GetBuffer(0, IID_ID3D11Texture2D)` → `device.CreateRenderTargetView`.
For off-screen targets: use provided texture directly.

- [ ] **Step 2: Commit**

```bash
git add src/renderer/d3d11/Target.zig
git commit -m "renderer/d3d11: implement Target type"
```

### Task 14: D3D11 Frame & RenderPass

**Files:**
- Create: `src/renderer/d3d11/Frame.zig`
- Create: `src/renderer/d3d11/RenderPass.zig`

- [ ] **Step 1: Implement Frame**

```zig
pub const Frame = struct {
    context: *d3d11.ID3D11DeviceContext,
    target: *Target,

    pub fn begin(opts: Options, renderer: *GenericRenderer, target: *Target) !Self { ... }
    pub fn renderPass(self: *const Self, attachments: []const RenderPass.Options.Attachment) RenderPass { ... }
    pub fn complete(self: *const Self, sync: bool) void { ... }
};
```

`begin` clears the render target view. `renderPass` creates a RenderPass. `complete` is a no-op (presentation handled separately).

- [ ] **Step 2: Implement RenderPass**

```zig
pub const RenderPass = struct {
    context: *d3d11.ID3D11DeviceContext,
    target: Target,

    pub fn begin(opts: Options) Self { ... }
    pub fn step(self: *Self, s: Step) void { ... }
    pub fn complete(self: *const Self) void { ... }
};
```

`step` binds the pipeline's shaders, sets vertex/index buffers, textures, samplers, constant buffers, sets viewport, and calls `DrawIndexed` or `DrawInstanced`.

- [ ] **Step 3: Commit**

```bash
git add src/renderer/d3d11/Frame.zig src/renderer/d3d11/RenderPass.zig
git commit -m "renderer/d3d11: implement Frame and RenderPass"
```

### Task 15: HLSL Cell Shader

**Files:**
- Create: `src/renderer/d3d11/shaders.zig`
- Create: `src/renderer/shaders/hlsl/cell_vs.hlsl`
- Create: `src/renderer/shaders/hlsl/cell_ps.hlsl`

- [ ] **Step 1: Create HLSL vertex shader**

Port the OpenGL cell vertex shader to HLSL. The vertex shader:
- Takes per-instance cell data (position, glyph atlas coordinates, colors, flags)
- Computes screen-space quad vertices
- Passes UV coordinates and color to pixel shader

```hlsl
// cell_vs.hlsl
cbuffer Uniforms : register(b0) {
    float4x4 projection;
    float2 cell_size;
    float2 grid_size;
    // ... other uniforms matching OpenGL
};

struct VSInput {
    // Per-instance cell attributes
    uint2 grid_pos : GRID_POS;
    uint2 glyph_pos : GLYPH_POS;
    uint2 glyph_size : GLYPH_SIZE;
    uint2 glyph_offset : GLYPH_OFFSET;
    uint4 fg_color : FG_COLOR;
    uint4 bg_color : BG_COLOR;
    uint mode : MODE;
    uint vertex_id : SV_VertexID;
};

struct VSOutput {
    float4 position : SV_Position;
    float2 tex_coord : TEXCOORD0;
    float4 fg_color : COLOR0;
    float4 bg_color : COLOR1;
    uint mode : MODE;
};

VSOutput main(VSInput input) { ... }
```

- [ ] **Step 2: Create HLSL pixel shader**

```hlsl
// cell_ps.hlsl
Texture2D glyph_atlas : register(t0);
SamplerState atlas_sampler : register(s0);

struct PSInput {
    float4 position : SV_Position;
    float2 tex_coord : TEXCOORD0;
    float4 fg_color : COLOR0;
    float4 bg_color : COLOR1;
    uint mode : MODE;
};

float4 main(PSInput input) : SV_Target {
    // Mode 0: background only
    // Mode 1: glyph from atlas with fg color
    // Mode 2: color glyph (emoji)
    // ... port from OpenGL fragment shader
}
```

- [ ] **Step 3: Create shaders.zig to compile and load HLSL**

```zig
pub const Shaders = struct {
    cell_pipeline: Pipeline,
    // image_pipeline: Pipeline, // TODO: M1 skips images

    pub fn init(device: *d3d11.ID3D11Device) !Shaders { ... }
    pub fn deinit(self: *Shaders) void { ... }
};
```

Use `D3DCompile` to compile HLSL source at build time (embedded as string literals) or at runtime for development.

- [ ] **Step 4: Commit**

```bash
git add src/renderer/d3d11/shaders.zig src/renderer/shaders/hlsl/cell_vs.hlsl src/renderer/shaders/hlsl/cell_ps.hlsl
git commit -m "renderer/d3d11: add HLSL cell shaders and shader compilation"
```

### Task 16: Wire D3D11 into Renderer Module

**Files:**
- Modify: `src/renderer.zig` (or `src/renderer/renderer.zig`)

- [ ] **Step 1: Read current renderer module**

Read the file that selects between Metal/OpenGL to understand the import pattern.

- [ ] **Step 2: Add Direct3D11 import and selection**

First, add the import alongside Metal and OpenGL (line ~18 area):

```zig
pub const Metal = @import("renderer/Metal.zig");
pub const OpenGL = @import("renderer/OpenGL.zig");
pub const Direct3D11 = @import("renderer/Direct3D11.zig");  // ADD THIS
pub const WebGL = @import("renderer/WebGL.zig");
```

Then add the `.direct3d11` branch in the Renderer switch (line ~38):

```zig
pub const Renderer = switch (build_config.renderer) {
    .metal => GenericRenderer(Metal),
    .opengl => GenericRenderer(OpenGL),
    .direct3d11 => GenericRenderer(Direct3D11),  // ADD THIS
    .webgl => WebGL,
};
```

- [ ] **Step 3: Commit**

```bash
git add src/renderer.zig
git commit -m "renderer: wire Direct3D11 backend into renderer selection"
```

---

## Chunk 4: Win32 Application Runtime

### Task 17: Win32 Apprt Module Shell

**Files:**
- Create: `src/apprt/win32.zig`
- Modify: `src/apprt.zig`

- [ ] **Step 1: Create win32.zig module root**

Minimal module that exports the required App and Surface types:

```zig
const std = @import("std");
const builtin = @import("builtin");

pub const App = @import("win32/App.zig");
pub const Surface = @import("win32/Surface.zig");

pub fn resourcesDir() ?[]const u8 {
    // TODO: return exe-relative resources path
    return null;
}
```

- [ ] **Step 2: Add win32 to apprt.zig**

In `src/apprt.zig`, add the import alongside the other runtime imports (line ~18 area):

```zig
pub const gtk = @import("apprt/gtk.zig");
pub const none = @import("apprt/none.zig");
pub const win32 = @import("apprt/win32.zig");  // ADD THIS
pub const browser = @import("apprt/browser.zig");
```

Then add the `.win32` branch in the runtime switch (line ~43):

```zig
pub const runtime = switch (build_config.artifact) {
    .exe => switch (build_config.app_runtime) {
        .none => none,
        .gtk => gtk,
        .win32 => win32,  // ADD THIS
    },
    .lib => embedded,
    .wasm_module => browser,
};
```

- [ ] **Step 3: Commit**

```bash
git add src/apprt/win32.zig src/apprt.zig
git commit -m "apprt: add win32 module shell"
```

### Task 18: Win32 Window Creation

**Files:**
- Create: `src/apprt/win32/Window.zig`

- [ ] **Step 1: Implement Window**

```zig
const std = @import("std");
const windows = std.os.windows;

const Self = @This();

hwnd: windows.HWND,
width: u32,
height: u32,
dpi: u32,

const CLASS_NAME = std.unicode.utf8ToUtf16LeStringLiteral("GhosttyWindow");

pub fn init(width: u32, height: u32) !Self {
    // RegisterClassExW with wndProc callback
    // CreateWindowExW with WS_OVERLAPPEDWINDOW
    // ShowWindow, UpdateWindow
}

pub fn deinit(self: *Self) void {
    // DestroyWindow
}

fn wndProc(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM) callconv(.C) LRESULT {
    return switch (msg) {
        WM_SIZE => { ... },      // Update size, notify renderer
        WM_DPICHANGED => { ... }, // Update DPI, rescale
        WM_CLOSE => { ... },     // PostQuitMessage
        WM_DESTROY => { ... },
        else => DefWindowProcW(hwnd, msg, wparam, lparam),
    };
}
```

- [ ] **Step 2: Commit**

```bash
git add src/apprt/win32/Window.zig
git commit -m "apprt/win32: implement Window with HWND creation"
```

### Task 19: Win32 App — Message Loop + libxev

**Files:**
- Create: `src/apprt/win32/App.zig`

- [ ] **Step 1: Implement App with hybrid event loop**

The key challenge: Win32 needs a message pump (`GetMessage`/`DispatchMessage`) AND libxev needs to process IOCP events for PTY I/O. Solution: use `MsgWaitForMultipleObjectsEx` which blocks until either a Windows message arrives or an I/O completion occurs.

```zig
const std = @import("std");
const xev = @import("xev");
const CoreApp = @import("../../App.zig");

const Self = @This();

core_app: *CoreApp,
windows: std.ArrayList(*Window),
loop: xev.Loop,
should_quit: bool,

pub fn init(self: *Self, core_app: *CoreApp, opts: struct {}) !void {
    // REQUIRED: Initialize COM before any D3D11/DXGI calls
    _ = windows.ole32.CoInitializeEx(null, windows.COINIT_APARTMENTTHREADED);

    // REQUIRED: Set per-monitor DPI awareness before creating any windows
    _ = SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);

    self.core_app = core_app;
    self.windows = std.ArrayList(*Window).init(core_app.alloc);
    self.loop = try xev.Loop.init(.{});
    self.should_quit = false;
}

pub fn run(self: *Self) !void {
    while (!self.should_quit) {
        // Process all pending Win32 messages
        var msg: MSG = undefined;
        while (PeekMessageW(&msg, null, 0, 0, PM_REMOVE) != 0) {
            if (msg.message == WM_QUIT) {
                self.should_quit = true;
                break;
            }
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }

        // Run libxev for pending I/O events (non-blocking)
        self.loop.run(.no_wait) catch {};

        // If nothing to do, block waiting for either Win32 messages or IOCP
        if (!self.should_quit) {
            MsgWaitForMultipleObjectsEx(
                0,    // nCount (IOCP handles managed internally by xev)
                null, // pHandles
                100,  // timeout ms (poll periodically)
                QS_ALLINPUT,
                MWMO_INPUTAVAILABLE,
            );
        }
    }
}

pub fn wakeup(self: *Self) void {
    // Post a custom message to wake up the message loop from another thread
    PostMessageW(self.windows.items[0].hwnd, WM_APP, 0, 0);
}

pub fn terminate(self: *Self) void {
    self.should_quit = true;
}

pub fn performAction(
    self: *Self,
    target: apprt.Target,
    comptime action: apprt.Action.Key,
    value: apprt.Action.Value(action),
) !bool {
    // Handle core actions — minimal set for M1:
    switch (action) {
        .quit => { self.should_quit = true; return true; },
        .new_window => { ... },
        else => return false, // Not implemented yet
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add src/apprt/win32/App.zig
git commit -m "apprt/win32: implement App with Win32+libxev hybrid event loop"
```

### Task 20: Win32 Surface

**Files:**
- Create: `src/apprt/win32/Surface.zig`

- [ ] **Step 1: Implement Surface — child HWND + input translation**

```zig
const std = @import("std");
const CoreSurface = @import("../../Surface.zig");
const apprt = @import("../../apprt.zig");

const Self = @This();

core_surface: CoreSurface,
hwnd: windows.HWND,
parent_window: *Window,
app: *App,
width: u32,
height: u32,

pub fn init(self: *Self, app: *App, window: *Window) !void {
    // Create child HWND within the window
    // Initialize core_surface with self as the apprt surface
}

pub fn deinit(self: *Self) void { ... }
pub fn close(self: *Self, process_active: bool) void { ... }

pub fn getContentScale(self: *const Self) !apprt.ContentScale {
    const dpi = GetDpiForWindow(self.hwnd);
    const scale = @as(f32, @floatFromInt(dpi)) / 96.0;
    return .{ .x = scale, .y = scale };
}

pub fn getSize(self: *const Self) !apprt.SurfaceSize {
    return .{ .width = self.width, .height = self.height };
}

pub fn getCursorPos(self: *const Self) !apprt.CursorPos {
    var point: POINT = undefined;
    GetCursorPos(&point);
    ScreenToClient(self.hwnd, &point);
    return .{ .x = @floatFromInt(point.x), .y = @floatFromInt(point.y) };
}

pub fn supportsClipboard(self: *const Self, clipboard_type: apprt.Clipboard) bool {
    _ = self;
    _ = clipboard_type;
    return false; // M1: clipboard deferred to M3
}

pub fn clipboardRequest(self: *Self, clipboard_type: apprt.Clipboard, state: apprt.ClipboardRequest) !bool {
    _ = self; _ = clipboard_type; _ = state;
    return false; // M1: clipboard deferred to M3
}

pub fn setClipboard(self: *Self, clipboard_type: apprt.Clipboard, contents: []const apprt.ClipboardContent, confirm: bool) !void {
    _ = self; _ = clipboard_type; _ = contents; _ = confirm;
    // M1: clipboard deferred to M3
}

pub fn defaultTermioEnv(self: *Self) !std.process.EnvMap {
    var env = std.process.EnvMap.init(self.app.core_app.alloc);
    try env.put("TERM", "xterm-256color");
    try env.put("COLORTERM", "truecolor");
    return env;
}

// Window procedure for this surface's child HWND
fn surfaceWndProc(hwnd: HWND, msg: UINT, wparam: WPARAM, lparam: LPARAM) LRESULT {
    switch (msg) {
        WM_KEYDOWN, WM_SYSKEYDOWN => {
            // Translate scancode → Ghostty key, call core_surface.keyCallback
        },
        WM_CHAR => {
            // UTF-16 → UTF-8, call core_surface.charCallback
        },
        WM_MOUSEMOVE => {
            // Extract x,y, call core_surface.cursorPosCallback
        },
        WM_LBUTTONDOWN, WM_RBUTTONDOWN, WM_MBUTTONDOWN => {
            // Call core_surface.mouseButtonCallback
        },
        WM_MOUSEWHEEL => {
            // Extract delta, call core_surface.scrollCallback
        },
        else => return DefWindowProcW(hwnd, msg, wparam, lparam),
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add src/apprt/win32/Surface.zig
git commit -m "apprt/win32: implement Surface with input translation"
```

---

## Chunk 5: Integration & End-to-End

### Task 21: Compile & Fix All Integration Errors

**Files:**
- Various — fix all compilation errors when building for Windows

Library linking was added in Task 4b. Now we compile the full project and fix integration issues.

- [ ] **Step 1: Attempt native Windows build**

Run: `zig build`
Collect all compilation errors.

- [ ] **Step 2: Fix errors iteratively**

Common expected issues:
- Missing switch cases for `.win32` in apprt code throughout the codebase
- Missing switch cases for `.direct3d11` in renderer code
- Missing switch cases for `.directwrite_harfbuzz` in font code
- POSIX-specific code in `src/os/` needing Windows branches
- `@compileError` guards on Windows-unsupported features
- FreeType/HarfBuzz C library compilation issues for Windows target

Fix each by adding the appropriate Windows branch or stub.

- [ ] **Step 3: Get a clean compile**

Run: `zig build`
Expected: Compiles successfully, produces `ghostty.exe`

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "fix: resolve all Windows compilation errors for M1 foundation"
```

### Task 22: First Window Test

**Files:**
- None new — testing existing code

- [ ] **Step 1: Run ghostty.exe**

Run: `zig build run`
Expected: A Win32 window appears with a D3D11-cleared background (solid color).

- [ ] **Step 2: Debug and fix any runtime crashes**

Common issues:
- COM initialization (`CoInitializeEx` needed before D3D11)
- HWND null checks
- DPI awareness initialization
- Swap chain creation failures (check DXGI debug layer)

Fix iteratively until the window appears and stays open.

- [ ] **Step 3: Commit fixes**

```bash
git add -A
git commit -m "fix: runtime fixes for first Win32 window display"
```

### Task 23: ConPTY + PowerShell Integration

**Files:**
- Verify: `src/pty.zig` (WindowsPty already exists)
- Verify: `src/Command.zig` (startWindows already exists)
- Modify: `src/termio/Exec.zig` (ensure Windows read thread works)

- [ ] **Step 1: Verify PTY creates PowerShell session**

The existing `WindowsPty` and `Command.startWindows` should already work. Verify by:
1. Setting a breakpoint or log in `WindowsPty.open`
2. Running ghostty.exe
3. Confirming PowerShell.exe is spawned as child process (check Task Manager)

- [ ] **Step 2: Verify terminal output reaches renderer**

Add temporary debug logging in `src/termio/stream_handler.zig` to confirm that PowerShell output bytes flow through:
PTY → ReadThread → termio.processOutput → Parser → Terminal state

- [ ] **Step 3: Verify rendered cells exist**

Add temporary logging in the generic renderer's `drawFrame` to confirm cells are being built from terminal state.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: verify ConPTY + PowerShell pipeline on Windows"
```

### Task 24: Text on Screen

**Files:**
- Verify: D3D11 renderer draws cells from terminal state

- [ ] **Step 1: Ensure glyph atlas is populated**

FreeType should rasterize glyphs into the atlas. Verify the atlas texture is being uploaded to D3D11 via `Texture.replaceRegion`.

- [ ] **Step 2: Verify cell shader draws glyphs**

Run ghostty.exe. You should see PowerShell prompt text rendered in the window.

Common issues to debug:
- Projection matrix incorrect (text off-screen)
- UV coordinates wrong (garbled glyphs)
- Blend state not set (invisible text)
- Vertex buffer layout mismatch with HLSL input

- [ ] **Step 3: Fix rendering issues iteratively**

Debug using D3D11 debug layer (`D3D11_CREATE_DEVICE_DEBUG` flag) and PIX or RenderDoc for GPU debugging.

- [ ] **Step 4: Verify keyboard input works**

Type in the window. Characters should be sent to PowerShell via ConPTY and echoed back through the terminal.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: end-to-end text rendering on Windows via D3D11"
```

### Task 25: Basic Resize & Scrollback

**Files:**
- Modify: `src/apprt/win32/Window.zig` (WM_SIZE handler)
- Modify: `src/apprt/win32/Surface.zig` (resize notification)

- [ ] **Step 1: Handle WM_SIZE**

When the window resizes:
1. Call `swap_chain.ResizeBuffers` to match new size
2. Recreate render target view
3. Notify terminal of new grid dimensions via `core_surface.resize`
4. Notify PTY of new size via `pty.setSize`

- [ ] **Step 2: Test resize**

Run ghostty.exe, resize the window by dragging edges. Terminal should:
- Reflow text correctly
- Not crash or show artifacts
- Update PowerShell's `$Host.UI.RawUI.WindowSize`

- [ ] **Step 3: Test scrollback**

Run a command that produces lots of output (e.g., `dir /s C:\Windows`). Scroll should work if WM_MOUSEWHEEL is wired to `core_surface.scrollCallback`.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: window resize and scrollback on Windows"
```

---

## Milestone 1 Completion Criteria

When all tasks are complete, you should have:

- [ ] `ghostty.exe` launches on Windows 11
- [ ] A Win32 window appears with proper DPI scaling
- [ ] PowerShell is spawned via ConPTY
- [ ] Terminal text is rendered via D3D11 with FreeType glyphs
- [ ] Keyboard input works (type commands, see output)
- [ ] Window resize works (terminal reflows, no artifacts)
- [ ] Mouse wheel scrollback works
- [ ] No crashes on normal usage

**What this does NOT include (deferred to later milestones):**
- DirectWrite fonts (M2)
- HarfBuzz shaping (M2)
- Tabs, splits (M4)
- IME input (M6)
- Custom shaders (M6)
- Shell integration scripts (M5)
- Clipboard (M3)
- Selection (M3)
- Installer (M7)
