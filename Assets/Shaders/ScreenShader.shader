Shader "Unlit/ScreenShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 normal :NORMAL;
                float2 uv : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 WorldNormal : TEXCOORD1;
                float3 WorldPos : TEXCOORD2;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.WorldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                o.WorldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float zoom = 1.f;
	            float xZoomed = (i.uv.x - 0.5) * zoom + 0.5;
	            float yZoomed = (i.uv.y - 0.5) * zoom + 0.5;
                // sample the texture
                float distortionFactorX = 0.f;
                float distortionFactorY = 0.5f;
                float distortionCenterX = 1.f;
                float distortionCenterY = 1.f;

                float distortionBowY = 1.5f;
                // perform distortion for curved screen (follows a parabola)
	            i.uv.x += distortionFactorX * (-2.0 * xZoomed + distortionCenterX) * yZoomed * (yZoomed - 1.0);	
	            i.uv.y += distortionFactorY * (-2.0 * pow(yZoomed, distortionBowY) + distortionCenterY) * xZoomed * (xZoomed - 1.0);
                half4 col = tex2D(_MainTex, i.uv);
                //half4 col = half4(i.WorldNormal, 1);
                return col;
            }
            ENDCG
        }
    }
}
