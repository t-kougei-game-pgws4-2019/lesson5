Shader "Unlit/Dissove"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainTex("_GradationTex", 2D) = "white" {}
		_MainTex("_AlphaTex", 2D) = "white" {}
		_Threshold("Threshold",Range(0.0,1.5)) = 0.0666
		_Color("Base color",Color) = (.34,.85,.92,1)
		_Speed("Speed",float) = 0.0
	}
		SubShader
	{
			Lighting off
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				CGPROGRAM
	
				#pragma vertex vert
				#pragma fragment frag
				// make fog work
				//#pragma multi_compile_fog

				#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
			
			sampler2D _MainTex;
			sampler2D _GradationTex;
			sampler2D _AlphaTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Speed;
			float _Threshold;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o, o.vertex);
				return o;
			}

			fixed2 random2(float2 st) {
				st = float2(dot(st, fixed2(127.1, 311.7)),
					dot(st, fixed2(269.0, 183.3)));
				return -1.0 + 2.0*frac(sin(st)*43758.5453123);
			}

			float Noise(float2 st) {

				float2 p = floor(st);
				float2 f = frac(st);
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

			float Fbm(float2 st) {
				return (
					Noise(st) +
					Noise(st*2.0)*0.5 +
					Noise(st*4.0)*0.25 +
					Noise(st*8.0)*0.125 +
					Noise(st*16.0)*0.0625 +
					Noise(st*32.0)*0.03125)/(1.0+0.5+0.25+0.125+0.0625+0.03125);

			}

			//追加したやつ
				fixed4 frag(v2f i) : SV_Target
				{
					float fbm = Fbm(i.uv) + _Threshold + sin(_Time.y);
					if (1.0 < fbm)discard;

					fixed4 albedo = tex2D(_MainTex, i.uv);
					fixed4 col = tex2D(_GradationTex, float2(fbm, 0.0));
					fixed alpha = tex2D(_AlphaTex, float2(fbm, 0.0)).x;

					col.xyz = lerp(col, albedo, alpha)*_Color;
					col.a = 1.0;

					return col;
				}

				ENDCG
			}
	}
}