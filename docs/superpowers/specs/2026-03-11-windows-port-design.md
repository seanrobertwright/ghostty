# Ghostty Windows 11 Port — Design Specification

**Date:** 2026-03-11
**Status:** Approved
**Approach:** Native Win32 + Direct3D 11 + DirectWrite + HarfBuzz

## Goal

Port Ghostty to Windows 11 as a first-class native terminal emulator with feature parity to the Linux GTK build. Targets PowerShell, CMD, and WSL shells.

## Architecture Overview

The Windows port adds three new subsystems plugging into Ghostty's existing compile-time extension points:

```
┌─────────────────────────────────────────────────────┐
│                  Ghostty Core (shared)               │
│  Terminal Parser │ Screen/PageList │ Config │ Input  │
│  Surface.zig    │ App.zig         │ termio │ SIMD   │
└────────┬──────────────┬───────────────┬──────────────┘
         │              │               │
    ┌────▼────┐   ┌─────▼─────┐   ┌────▼────────┐
    │ apprt/  │   │ renderer/ │   │ font/       │
    │ win32/  │   │ D3D11.zig │   │ directwrite │
    │         │   │ d3d11/    │   │ .zig        │
    └────┬────┘   └─────┬─────┘   └────┬────────┘
         │              │               │
    ┌────▼──────────────▼───────────────▼──────────────┐
    │              Windows Platform Layer               │
    │  Win32 API │ DXGI │ D3D11 │ DirectWrite │ ConPTY │
    └──────────────────────────────────────────────────┘
```

### New Files & Directories

| Path | Purpose |
|------|---------|
| `src/apprt/win32/` | Win32 application runtime |
| `src/apprt/win32/App.zig` | App lifecycle, message loop, multi-window management |
| `src/apprt/win32/Surface.zig` | Terminal surface — D3D11 swap chain host, input translation |
| `src/apprt/win32/Window.zig` | Win32 HWND wrapper — chrome, tabs, splits layout |
| `src/renderer/Direct3D11.zig` | D3D11 GraphicsAPI implementation |
| `src/renderer/d3d11/` | D3D11 types: Frame, RenderPass, Pipeline, Buffer, Texture, Sampler |
| `src/renderer/d3d11/shaders.zig` | HLSL shader compilation and management |
| `src/font/face/directwrite.zig` | DirectWrite font face (discovery + rasterization) |
| `pkg/windows/d3d11.zig` | D3D11 COM interface bindings |
| `pkg/windows/dxgi.zig` | DXGI COM interface bindings |
| `pkg/windows/directwrite.zig` | DirectWrite COM interface bindings |
| `pkg/windows/d3dcompiler.zig` | D3DCompiler bindings |

### Existing Windows Code (Already Implemented)

- `src/pty.zig` — `WindowsPty` using ConPTY API
- `src/Command.zig` — `startWindows()` using `CreateProcessW`
- `src/os/windows.zig` — Windows API bindings and helpers
- `src/termio/Exec.zig` — Windows read thread via `ReadFile`
- libxev — IOCP backend for event loop

---

## Section 1: Win32 Application Runtime (`apprt/win32/`)

### App.zig — Application Lifecycle

- Registers Win32 window classes (`RegisterClassExW`) on startup
- Message loop using `MsgWaitForMultipleObjectsEx` to service both Win32 messages and libxev IOCP events
- Manages list of open windows and surfaces
- Handles application-level actions (new window, quit, config reload)
- Single-instance coordination via named mutex + named pipe IPC

### Window.zig — Window Chrome & Layout

- Top-level `WS_OVERLAPPEDWINDOW` with custom non-client area for tab bar
- **Tab bar:** Custom-drawn strip in non-client area (owner-draw). Drag-to-reorder via hit testing.
- **Split layout:** Tree-based split container (horizontal/vertical). Each leaf holds a Surface. Dividers are draggable resize handles. Layout recalculated on `WM_SIZE`.
- **DPI awareness:** Per-monitor DPI via `SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)`. Responds to `WM_DPICHANGED`.
- **Fullscreen:** Toggle via `SetWindowLong` style manipulation (remove `WS_OVERLAPPEDWINDOW`, set `WS_POPUP`, resize to monitor).
- **Window snapping:** Works automatically — Windows 11 snap layouts come for free with `WS_OVERLAPPEDWINDOW`.

### Surface.zig — Terminal Surface

- Each surface owns a terminal session (PTY + termio + renderer instance)
- Child HWND within split layout hosting D3D11 swap chain
- Input translation:
  - `WM_KEYDOWN`/`WM_KEYUP` → key events (scancode → Ghostty key mapping)
  - `WM_CHAR`/`WM_UNICHAR` → text input (UTF-16 surrogate pair handling)
  - `WM_MOUSEMOVE`/`WM_LBUTTONDOWN`/etc → mouse events
  - `WM_MOUSEWHEEL` → scroll events
- **IME:** `WM_IME_STARTCOMPOSITION`, `WM_IME_COMPOSITION`, `WM_IME_ENDCOMPOSITION` via IMM32. Position candidate window at cursor via `ImmSetCompositionWindow`.
- **Clipboard:** `OpenClipboard`/`GetClipboardData`/`SetClipboardData` with `CF_UNICODETEXT`
- **Cursor shapes:** `SetCursor` with standard IDC cursors + custom cursors for resize handles

### IPC — Multi-Instance Coordination

- Named mutex: `Global\GhosttyMutex-{config-class}`
- Named pipe: `\\.\pipe\ghostty-{config-class}`
- Messages: `new-window`, `new-tab`, `new-window-command`

### Shell Integration

- **PowerShell:** Inject via `$PROFILE` or `GHOSTTY_SHELL_INTEGRATION` env var
- **CMD:** Inject via AutoRun registry key or env var pointing to `.cmd` script
- **WSL:** Launch via `wsl.exe` — Ghostty's existing POSIX shell integration works inside WSL

---

## Section 2: Direct3D 11 Renderer

Implements the `GraphicsAPI` interface consumed by `Renderer(GraphicsAPI)`.

### Type Mapping

| Generic Type | D3D11 Implementation |
|---|---|
| `Target` | `IDXGISwapChain1` + `ID3D11RenderTargetView` per surface |
| `Frame` | Begin/end frame context, clears render target |
| `RenderPass` | Sets render target, viewport, blend state, iterates steps |
| `Step` | Binds buffers, textures, samplers, shaders, issues `DrawIndexed` |
| `Pipeline` | `ID3D11VertexShader` + `ID3D11PixelShader` + `ID3D11InputLayout` |
| `Buffer` | `ID3D11Buffer` (vertex, index, or constant buffer) |
| `Texture` | `ID3D11Texture2D` + `ID3D11ShaderResourceView` |
| `Sampler` | `ID3D11SamplerState` |

### Initialization

- `D3D11CreateDevice` with `D3D_FEATURE_LEVEL_11_0`
- `IDXGIFactory2::CreateSwapChainForHwnd` — one swap chain per Surface HWND
- Format: `DXGI_FORMAT_B8G8R8A8_UNORM`
- Present: `DXGI_SWAP_EFFECT_FLIP_DISCARD`
- VSync on: `Present(1, 0)` / VSync off: `Present(0, DXGI_PRESENT_ALLOW_TEARING)`
- Handle `DXGI_ERROR_DEVICE_REMOVED`/`DXGI_ERROR_DEVICE_RESET` by recreating device

### Resize

- On `WM_SIZE`: `IDXGISwapChain::ResizeBuffers`, recreate `ID3D11RenderTargetView`, update viewport

### Shaders (HLSL)

- **Cell shader** — Terminal cells (backgrounds, glyphs, cursor, decorations)
- **Image shader** — Inline images (Kitty graphics protocol)
- **Custom shader** — Post-processing Shadertoy-compatible pass
- Pre-compiled to DXBC at build time; custom user shaders compiled at runtime via `D3DCompile`
- `shadertoy.zig` gets new target: `.hlsl`

### Blend & Buffering

- Alpha blend: `SrcAlpha` / `InvSrcAlpha` (pre-multiplied alpha)
- Triple buffering: 3 sets of GPU buffers rotated per frame (matches Metal backend)

---

## Section 3: DirectWrite Font Backend

### Discovery

- `IDWriteFactory` singleton via `DWriteCreateFactory`
- System fonts: `IDWriteFactory::GetSystemFontCollection`
- Match by family: `FindFamilyName` → `GetFirstMatchingFont` (weight/style/stretch)
- Fallback: `IDWriteFontFallback::MapCharacters` (emoji, CJK, symbols)
- File fonts: `CreateFontFileReference` → `CreateFontFace`

### Rasterization

- `IDWriteGlyphRunAnalysis` or `IDWriteBitmapRenderTarget`
- Grayscale AA: `DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC` — 8-bit alpha to glyph atlas
- ClearType: `DWRITE_RENDERING_MODE_NATURAL_SYMMETRIC` + ClearType mode — RGB subpixel masks, cell shader handles 3-channel alpha
- GDI-compatible fallback: `DWRITE_RENDERING_MODE_GDI_CLASSIC`

### Metrics

- `IDWriteFontFace::GetMetrics` → ascent, descent, line gap, units per em
- Scale: `metric * fontSize / unitsPerEm`
- Underline/strikethrough positions from `DWRITE_FONT_METRICS`

### HarfBuzz Integration

- Extract font binary: `IDWriteFontFace::GetFiles` → `IDWriteFontFileStream::ReadFileFragment`
- `hb_blob_create` → `hb_face_create` → `hb_font_create`
- Same pattern as `coretext_harfbuzz` backend

### DPI Scaling

- Font size in DIPs → physical pixels using surface DPI
- On `WM_DPICHANGED`: recalculate font sizes, rebuild glyph atlas
- `IDWriteBitmapRenderTarget::SetPixelsPerDip`

---

## Section 4: Build System & Platform Integration

### Build Config Additions

- `AppRuntime`: add `.win32` (default when `target.os.tag == .windows`)
- `Renderer`: add `.direct3d11` (default when windows)
- `FontBackend`: add `.directwrite_harfbuzz` (default when windows)

### Windows API Bindings (`pkg/windows/`)

- COM vtable wrappers as Zig `extern struct` (follows `pkg/macos/` pattern)
- Files: `d3d11.zig`, `dxgi.zig`, `directwrite.zig`, `d3dcompiler.zig`
- Link: `d3d11.dll`, `dxgi.dll`, `dwrite.dll`, `d3dcompiler_47.dll`

### Config Paths

- Config: `%APPDATA%\ghostty\config`
- Cache: `%LOCALAPPDATA%\ghostty\cache`
- State: `%LOCALAPPDATA%\ghostty\state`
- Themes: `%APPDATA%\ghostty\themes`
- Via `SHGetKnownFolderPath`

### Platform-Specific Fixes

| File | Issue | Fix |
|---|---|---|
| `src/cli/edit_config.zig` | Uses `execve` | `ShellExecuteW` to open in default editor |
| `src/benchmark/CodepointWidth.zig` | `wcwidth` unavailable | Use Ghostty's Unicode tables |
| `src/os/homedir.zig` | Uses `getpwuid` | `SHGetKnownFolderPath(FOLDERID_Profile)` |
| `src/os/env.zig` | POSIX env assumptions | `GetEnvironmentVariableW` |
| `src/os/shell.zig` | `/etc/passwd` parsing | `%COMSPEC%` or PowerShell from registry |

### CI/CD

- Windows runner (`windows-latest`) in GitHub Actions
- Build matrix: Debug, ReleaseFast, ReleaseSafe
- Artifact: `ghostty.exe` + PDB symbols

### Executable

- Standalone `ghostty.exe` — no framework dependencies, Win32 API + system DLLs only
- Installer (MSI/MSIX) deferred to later milestone

---

## Milestone Decomposition

This design reaches GTK parity through incremental milestones, each producing a working terminal:

1. **Foundation** — Win32 window, D3D11 swap chain, solid color background, ConPTY spawning PowerShell, raw text output (no shaping). Prove the pipeline works end-to-end.
2. **Text Rendering** — DirectWrite + HarfBuzz integration, glyph atlas, cell shader rendering correct terminal text with colors and styles.
3. **Input & Interaction** — Keyboard input, mouse events, clipboard, scrollback, selection, resize, DPI handling.
4. **Tabs & Splits** — Tab bar, split layout, window management, multi-surface support.
5. **Shell Integration** — PowerShell/CMD/WSL shell integration scripts, working directory detection, prompt markers.
6. **Feature Parity** — Custom shaders (HLSL), Kitty graphics protocol, IME, notifications, IPC, config editor, search overlay.
7. **Polish & Release** — Installer, CI/CD, performance optimization, ClearType tuning, accessibility.
