Shader "Unlit/Marble"
{
	Properties
	{
		//_MainTex("Texture", 2D) = "white" {}
		_Color("Base color",Color) = (.34,.85,.92,1)
	}
		SubShader
	{
			Lighting off
		/*Tags { "RenderType" = "Opaque" }
		LOD 100*/

		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"

			#pragma vertex CustomRenderTextureVertexShader	
			#pragma fragment frag
			#pragma target 3.0
			// make fog work
			//#pragma multi_compile_fog

			float4 _Color;

			fixed2 random2(float2 st) {
				st = float2(dot(st,fixed2(127.1,311.7)),
							dot(st,fixed2(269.0,183.3)));
				return -1.0 + 2.0*frac(sin(st)*43758.5453123);
			}

			float Noise(float2 st) {

				float2 p = floor(st);
				float2 f = floor(st);
				float2 u = f * f*(3.0 - 2.0*f);

				float v00 = random2(p + fixed2(0, 0));
				float v10 = random2(p + fixed2(1, 0));
				float v01 = random2(p + fixed2(0, 1));
				float v11 = random2(p + fixed2(1, 1));

				return lerp(lerp(dot(random2(v00 + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
								 dot(random2(v10 + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
							lerp(dot(random2(v01 + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
								 dot(random2(v11 + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
			}

			float4 frag(v2f_customrendertexture i) : SV_Target{

				fixed4 col = fixed4(0,0,0,1);
				float noise = (Noise(i.globalTexcoord * 4.0 + _Time.y *0.05))
							+ (Noise(i.globalTexcoord * 8.0 + _Time.y *0.20))*0.5
							+ (Noise(i.globalTexcoord * 16.0 + _Time.y*0.80))*0.25;

			noise = noise / (1.0 + 0.5 + 0.25);
			noise = sin(100 * noise);
			noise = noise * 0.5 + 0.5;

			return float4(noise * _Color.r, noise * _Color.g, noise * _Color.b, 1);
			}



			ENDCG
		}
	}
}
