//@author: vvvv group
//@help: this is a very basic template. use it to start writing your own effects. if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects
//@tags:
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWVT: WORLDVIEWTRANSPOSE;

float r;
float d;
float4 hiliteColor :COLOR <string uiname="Hilite Color";>;
float3 lightPosition <string uiname="Light Position";>;
float3 eyePosition <string uiname="Eye Position";>;

//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
	
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

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 position : POSITION,
	float3 normal : NORMAL,
    float4 TexCd : TEXCOORD0,
	float3 tangent : TEXCOORD1)
{
    //declare output struct
    vs2ps Out;

    //transform position
	float4 position0 = mul(position, tWVP);
	Out.Pos = position0;
    //Out.Pos = mul(position, tWVP);
    
	float3 P = mul(position, tWV);
	Out.L = normalize(mul(lightPosition, tV) - P);
	Out.V = normalize(mul(eyePosition, tV) - P);
	//float3 H = L + V;
	Out.N = mul((float3x3)tWVT, normal);
	Out.T = mul((float3x3)tWVT, tangent);
	
    //transform texturecoordinates
    Out.TexCd = mul(TexCd, tTex);

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{
    float4 col = tex2D(Samp, In.TexCd);
    return col;
}

float4 DiffractionPS(vs2ps In): COLOR
{
	float3 H = In.L + In.V;
	float u = dot(In.T, H) * d;
	float3 w = dot(In.N, H);
	float3 e = r * u / w;
	float3 c = exp(-e * e);
	float4 anis = hiliteColor * float4(c.x, c.y, c.z, 1);
	
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

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TSimpleShader
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}

technique TDiffractionShader
{
	pass P0
	{
		VertexShader = compile vs_1_1 VS();
		PixelShader  = compile ps_2_0 DiffractionPS();
	}
}

technique TFixedFunction
{
    pass P0
    {
        //transforms
        WorldTransform[0]   = (tW);
        ViewTransform       = (tV);
        ProjectionTransform = (tP);

        //texturing
        Sampler[0] = (Samp);
        TextureTransform[0] = (tTex);
        TexCoordIndex[0] = 0;
        TextureTransformFlags[0] = COUNT2;
        //Wrap0 = U;  // useful when mesh is round like a sphere
        
        Lighting       = FALSE;

        //shaders
        VertexShader = NULL;
        PixelShader  = NULL;
    }
}