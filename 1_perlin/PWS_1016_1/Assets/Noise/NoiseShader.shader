Shader "Unlit/NoiseShader"
{
    SubShader
    {
		Lighting off

        Pass
        {
            CGPROGRAM

            #include "UnityCustomRenderTexture.cginc"

			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag
			#pragma target 3.0

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

            fixed4 frag (v2f_customrendertexture i) : SV_Target
            {
				float a1 = 1;
				float a2 = 0.2;
				float a3 = 0.74;

				fixed4 col = fixed4(1,1,1,1);

				float noise = (Noise(i.globalTexcoord * 4.0 + _Time.y * 0.1)) * a1
							+ (Noise(i.globalTexcoord * 8.0 + _Time.y * 0.84)) * a2
							+ (Noise(i.globalTexcoord * 16.0 + _Time.y * 0.13)) * a3;
				noise = noise / (a1 + a2 + a3); //normalize
				noise = sin(50 * noise);
				noise = noise * 0.5 + 0.5;

				float noise2 = noise;
				float noise3 = noise;

				if (noise < 0.85) {
					noise = 0.0;
				}

				if (noise2 >= 0.85) {
					noise2 = 0.0;
				}
				if (noise2 <= 0.1) {
					noise2 = 0.0;
				}

				if (noise3 > 0.1) {
					noise3 = 0.0;
				}
				else if (noise3 <= 0.1) {
					noise3 = 1.0;
				}

				return float4(noise, noise2, noise3, 1);

				/*return col;*/
            }
            ENDCG
        }
    }
}
