#include "header\OpenRSF.fxh"

void main(float4 vpos : SV_Position, float2 uv : TEXCOORD, out float3 output : SV_Target0) {
	output = xyz2lsrgb(cg2xyz(xyz2cg(lsrbg2xyz(tex2D(ReShade::BackBuffer, uv).rgb))));
}

technique ORSFRef {
	pass Test {
		VertexShader = PostProcessVS;
		PixelShader = main;
	}
}