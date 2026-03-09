#include "header\OpenRSF.fxh"
#define qf tex2D(ReShade::BackBuffer, uv).rgb

uniform float miplevel<ui_type = "slider"; ui_min = 0.0; ui_max = 10.0;> = 0.0;

texture tFinalBlurred { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16; };
sampler sFinalBlurred { Texture = tFinalBlurred; };

void main(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float4 sRGB : SV_Target0) {
	float3 n = UVtoOCT(tex2D(ORSFShared::sTexN, uv).xy);
	sRGB = .5 * n + .5;
}

technique ORSFRef {
	pass Test {
		VertexShader = PostProcessVS;
		PixelShader = main;
	}
}