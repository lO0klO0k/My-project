Shader "Unlit/CylinderScreenShader"
{
    Properties
    {
        _ScreenHeight("Screen Height", Range(0.0001,5)) = 1
        _MainTex ("Texture", 2D) = "white" {}
        _XX("XXOO", Range(-1,1)) = 0
        _YY("YYOO", Range(-1,1)) = 1
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
                float3 PosWS : TEXCOORD2;
                float4 PosLS : TEXCOORD3;
                float4 PosCS : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScreenHeight;
            float _XX;
            float _YY;

            v2f vert (appdata v)
            {
                v2f o;
                o.PosLS = v.vertex;
                
                float3 LS = normalize(float3(o.PosLS.r,o.PosLS.g,0));

                float2 BasicZero = normalize(float2(_XX, _YY));
                
                float theta = acos(dot(LS, float3(0 , 1, 0))) / (UNITY_PI);
                
                float z = (o.PosLS.b  + _ScreenHeight/2.f) / _ScreenHeight;

                o.uv = float2(theta, z);
                o.PosCS = UnityObjectToClipPos(v.vertex);
                o.WorldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                o.PosWS = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(o.uv, _MainTex);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = 0;
                if(i.uv.x <= 1.f && i.uv.x >= 0.f && i.uv.y <= 1.f && i.uv.y >= 0.f)
                {
                    col = tex2D(_MainTex, i.uv);
                }
                return col;
            }
            ENDCG
        }
    }
}
