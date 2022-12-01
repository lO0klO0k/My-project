Shader "Unlit/FromMiddle_CylinderScreenShader"
{
    Properties
    {
        _ScreenHeight("Screen Height", Range(0.0001,5)) = 1
        _MainTex ("MainTex", 2D) = "white" {}
        _EndOfScreenAngle("ScreenAngle", Range(0.1, 180)) = 90
        _SplitScreen("SplitScreen", int) = 3
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
            float _EndOfScreenAngle;
            int _SplitScreen;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.PosLS = v.vertex;
                
                float3 LS = normalize(float3(o.PosLS.x,o.PosLS.y,0));
                float rad = _EndOfScreenAngle * UNITY_PI / 180;
                float2 EndScreenDir = float2(cos(rad), sin(rad));
                float2 StartScreenDir = float2(1, 0);
                //从屏幕中心到两边的角度
                float SideAngle = acos(dot(StartScreenDir, EndScreenDir));
                float TotalAngel = 2 * SideAngle;
                float theta = 0;
                float z = 0;

                if(o.PosLS.g >= 0)
                {
                    theta = 0.5 + 0.5 * acos(dot(LS, float3(StartScreenDir, 0))) / SideAngle;
                
                    z = (o.PosLS.b  + _ScreenHeight/2.f) / _ScreenHeight;
                }
                else
                {
                    theta = 0.5 - 0.5*acos(dot(LS, float3(1, 0, 0))) / SideAngle;
                
                    z = (o.PosLS.b  + _ScreenHeight/2.f) / _ScreenHeight;
                }  

                o.uv = float2(theta, z);
                o.PosCS = UnityObjectToClipPos(v.vertex);
                o.WorldNormal = UnityObjectToWorldNormal(v.normal.xyz);
                o.PosWS = mul(unity_ObjectToWorld, v.vertex);
                //o.uv = TRANSFORM_TEX(o.uv, _MainTex);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = 0;
                if(i.uv.x <= 1.f && i.uv.x >= 0.f && i.uv.y <= 1.f && i.uv.y >= 0.f)
                {
                    col = tex2D(_MainTex, i.uv);
                }else
                {
                    col = 0;
                }

                return col;
            }
            ENDCG
        }
    }
}
