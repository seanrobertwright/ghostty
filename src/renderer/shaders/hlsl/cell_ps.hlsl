// Ghostty D3D11 cell pixel shader stub
// TODO: Implement actual cell pixel shader

struct PSInput {
    float4 position : SV_POSITION;
};

float4 main(PSInput input) : SV_TARGET {
    return float4(0.0, 0.0, 0.0, 1.0);
}
