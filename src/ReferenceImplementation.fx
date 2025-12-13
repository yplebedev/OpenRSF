#include "header\OpenRSF.fxh"
#define qf tex2D(ReShade::BackBuffer, uv).rgb

uniform float s<ui_type = "slider";> = 1.0;

void main(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float3 output : SV_Target0) {
	output = getInverse(getACESSDR(getReinhardHDR(getAutoLSRGB(qf), 10.0)));
}

technique ORSFRef {
	pass Test {
		VertexShader = PostProcessVS;
		PixelShader = main;
	}
}