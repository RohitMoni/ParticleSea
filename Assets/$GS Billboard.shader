Shader "Custom/GS Billboard" 
{
	Properties 
	{
		_SpriteTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
		_Size ("Size", Range(0, 3)) = 0.5
	}

	SubShader 
	{
		Pass
		{
			Tags { "Queue"="Transparent" "RenderType"="Transparent" "ForceNoShadowCasting" = "True"}
			Blend One OneMinusSrcAlpha
			Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
			LOD 200
		
			CGPROGRAM
				#pragma vertex VS_Main
				#pragma fragment FS_Main
				#pragma geometry GS_Main
				#include "UnityCG.cginc" 

				// **************************************************************
				// Data structures												*
				// **************************************************************
				struct GS_INPUT
				{
					float4	pos		: POSITION;
					float3	normal	: NORMAL;
					float2  tex0	: TEXCOORD0;
				};

				struct FS_INPUT
				{
					float4	pos		: POSITION;
					float2  tex0	: TEXCOORD0;
				};


				// **************************************************************
				// Vars															*
				// **************************************************************

				float _Size;
				float4x4 _VP;
				Texture2D _SpriteTex;
				SamplerState sampler_SpriteTex;

				// **************************************************************
				// Shader Programs												*
				// **************************************************************

				// Vertex Shader ------------------------------------------------
				GS_INPUT VS_Main(appdata_base v)
				{
					GS_INPUT output = (GS_INPUT)0;

					output.pos =  mul(_Object2World, v.vertex);
					output.normal = v.normal;
					output.tex0 = float2(0, 0);

					return output;
				}

				// Geometry Shader -----------------------------------------------------
				[maxvertexcount(12)]
				void GS_Main(triangle GS_INPUT p[3], inout TriangleStream<FS_INPUT> triStream)
				{
					for (int i = 0; i < 3; i++)
					{

						float3 look = normalize(_WorldSpaceCameraPos - p[i].pos);
						float3 up = float3(0, 1, 0);
						float3 right = normalize(cross(up, look));
						up = cross(look, right);
					
						float halfS = 0.5f * _Size;
							
						float4 v[4];
						v[0] = float4(p[i].pos + halfS * right - halfS * up, 1.0f);
						v[1] = float4(p[i].pos + halfS * right + halfS * up, 1.0f);
						v[2] = float4(p[i].pos - halfS * right - halfS * up, 1.0f);
						v[3] = float4(p[i].pos - halfS * right + halfS * up, 1.0f);

						float4x4 vp = mul(UNITY_MATRIX_MVP, _World2Object);
						FS_INPUT pIn;
						pIn.pos = mul(vp, v[0]);
						pIn.tex0 = float2(1.0f, 0.0f);
						triStream.Append(pIn);

						pIn.pos =  mul(vp, v[1]);
						pIn.tex0 = float2(1.0f, 1.0f);
						triStream.Append(pIn);

						pIn.pos =  mul(vp, v[2]);
						pIn.tex0 = float2(0.0f, 0.0f);
						triStream.Append(pIn);

						pIn.pos =  mul(vp, v[3]);
						pIn.tex0 = float2(0.0f, 1.0f);
						triStream.Append(pIn);

						triStream.RestartStrip();
					}
				}



				// Fragment Shader -----------------------------------------------
				float4 FS_Main(FS_INPUT input) : COLOR
				{
					fixed4 color = _SpriteTex.Sample(sampler_SpriteTex, input.tex0);
					
					return color;
				}

			ENDCG
		}
	} 
}
