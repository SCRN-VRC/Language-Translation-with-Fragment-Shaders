Shader "Translator/0_Preview"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale ("Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float3 viridis_quintic( float x )
            {
                x = saturate( x );
                float4 x1 = float4( 1.0, x, x * x, x * x * x ); // 1 x x2 x3
                float4 x2 = x1 * x1.w * x; // x4 x5 x6 x7
                return float3(
                    dot( x1.xyzw, float4( +0.280268003, -0.143510503, +2.225793877, -14.815088879 ) ) + dot( x2.xy, float2( +25.212752309, -11.772589584 ) ),
                    dot( x1.xyzw, float4( -0.002117546, +1.617109353, -1.909305070, +2.701152864 ) ) + dot( x2.xy, float2( -1.685288385, +0.178738871 ) ),
                    dot( x1.xyzw, float4( +0.300805501, +2.614650302, -12.019139090, +28.933559110 ) ) + dot( x2.xy, float2( -33.491294770, +13.762053843 ) ) );
            }

            float4 frag (v2f i) : SV_Target
            {
                float val = tex2D(_MainTex, i.uv).r * _Scale;
                val = val < 0.0 ? -tanh(val) * _Scale * 0.5 : val;
                float3 col = viridis_quintic(val);
                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
