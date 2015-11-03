//@author: vvvv group
//@help: Effect processing for skinned mesh with directional light.
//@tags: skeleton, bones, collada, shading
//@credits: SlimDX

static const int MaxMatrices = 60;
float4x4 SkinningMatrices[MaxMatrices];
float4x4 tV: VIEW;
float4x4 tVP : VIEWPROJECTION;
float4x4 tWV : WORLDVIEW;
float4x4 tWVT: WORLDVIEWTRANSPOSE;
float4x4 tWVP: WORLDVIEWPROJECTION;

float r;
float d;
float4 hilightColor :COLOR <string uiname="Hilight Color";>;
float3 lightPosition <string uiname="Light Position";>;
float3 eyePosition <string uiname="Eye Position";>;

struct VSInput
{
	float4 Position			: POSITION;
	float4 BlendWeights		: BLENDWEIGHT;
	int4   BlendIndices		: BLENDINDICES;
	float3 Normal			: NORMAL;
	float3 TextureCoordinates	: TEXCOORD0;
	float3 Tangent          : TEXCOORD1;
};

struct VSOutput
{
	float4 Position			: POSITION;
	
	float3 L : TEXCOORD1;
	float3 V : TEXCOORD2;
	float3 N : TEXCOORD3;
	float3 T : TEXCOORD4;

};

float3 blend3 (float3 x)
{
	float3 y = 1-x*x;
	y = max(y, float3(0, 0, 0));
	return y;
}

VSOutput VS(VSInput input)
{
	VSOutput output = (VSOutput)0;

        /*
         * ---------- Skinning ----------
         */
	float4 blendWeights = input.BlendWeights;
	int4 indices = input.BlendIndices;
	
	float4 pos = 0;
	float3 norm = 0;

        for (int i = 0; i < 4; i++)
        {
            pos = pos + mul(input.Position, SkinningMatrices[indices[i]]) * blendWeights[i];
	    norm = norm + mul(input.Normal, SkinningMatrices[indices[i]]) * blendWeights[i];
        }
        /*
         * -------- End Skinning --------
         */

	output.Position = mul(pos, tWVP);
	
	// diffraction
	//float3 P = mul(input.Position, tWV);
	float3 P = mul(output.Position, tWV);
	output.L = normalize(mul(lightPosition, tV) - P);
	output.V = normalize(mul(eyePosition, tV) - P);
	//float3 H = L + V;
	output.N = mul((float3x3)tWVT, input.Normal);
	output.T = mul((float3x3)tWVT, input.Tangent);

	return output;
}

float4 PS(VSOutput input)  : COLOR
{

	float3 H = input.L + input.V;
	float u = dot(input.T, H) * d;
	float3 w = dot(input.N, H);
	float3 e = r * u / w;
	float3 c = exp(-e * e);
	float4 anis = hilightColor * float4(c.x, c.y, c.z, 1);
	
	if (u < 0) u = -u;
	
	float4 cdiff = float4(0, 0, 0, 1);
	for (int n = 1; n < 8; n++)
	{
		float y = 2 * u / n -1;
		cdiff.xyz += blend3(float3(4*(y-0.75), 4*(y-0.5), 4*(y-0.25)));
	}
	
	float4 color0 = cdiff + anis;
	
	return color0;
}

technique SkinnedMesh
{
	pass P0
	{
		VertexShader = compile vs_3_0 VS();
		PixelShader = compile ps_3_0 PS();
	}
}
