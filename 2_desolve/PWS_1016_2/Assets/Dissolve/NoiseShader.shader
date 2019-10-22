Shader "Unlit/NoiseShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Threshold("_Threshold", Range(0.0, 1.0)) = 0.66666
	}
    SubShader
    {
		Lighting off

        Pass
        {
            CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

		float4 _MainTex_ST;

		v2f vert(appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv;
			return o;
		}

		fixed2 random2(float2 st)
			{
				st = float2(dot(st, fixed2(337.1, 811.7)),
						    dot(st, fixed2(149.5, 693.3)));

				return -1.0 + 2.0 * frac(sin(st) * 43758.87647886);
			}

		float Noise(float2 st) 
		{
			float2 p = floor(st);
			float2 f = frac(st);
			float2 u = f * f * (3.0 - 2.0 * f);

			float v00 = random2(p + fixed2(0, 0));
			float v10 = random2(p + fixed2(1, 0));
			float v01 = random2(p + fixed2(0, 1));
			float v11 = random2(p + fixed2(1, 1));

			return lerp(lerp(dot(random2(p + float2(0.0, 0.0)), f - float2(0.0, 0.0)),
							 dot(random2(p + float2(1.0, 0.0)), f - float2(1.0, 0.0)), u.x),
						lerp(dot(random2(p + float2(0.0, 1.0)), f - float2(0.0, 1.0)),
							 dot(random2(p + float2(1.0, 1.0)), f - float2(1.0, 1.0)), u.x), u.y);
		}

		sampler2D _MainTex;

		float Fbm(float2 st)
		{
			float a1 = 1;
			float a2 = 0.2;
			float a3 = 0.74;

			float noise = Noise(st*4.0) + Noise(st*8.0)+ Noise(st *16);
			noise = noise / (a1 + a2 + a3); //normalize
			noise = noise * 0.5 + 0.5;

			return noise;
		}

		float _Threshold;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col;

				float fbm = Fbm(i.uv * 5.0);

				col.xyz = tex2D(_MainTex, float2(fbm, 0.0));
				col.a = 0.0f;

				if (_Threshold < fbm) discard;

				return col;
            }
            ENDCG
        }
    }
}