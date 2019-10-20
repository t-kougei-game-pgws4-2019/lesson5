Shader "Unlit/UpdateVelocity"
{
    Properties
    {
       _HeightTex("Height Map",2D)="white"{}
	}
		SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always

		Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
		//LOD 100

		Pass
		{
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment frag

			sampler2D _HeightTex;

		float4 frag(v2f_customrendertexture i) : SV_Target{

			float2 f = tex2D(_HeightTex,i.localTexcoord);
			return float4(ddy(f.x), -ddx(f.y), 0.0, 1.0)*10.0;


		}


            ENDCG
        }
    }
}
