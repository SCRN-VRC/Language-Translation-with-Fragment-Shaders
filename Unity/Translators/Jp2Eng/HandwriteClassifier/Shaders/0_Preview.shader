Shader "HandwriteClassify/0_Preview"
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

            float3 inferno_quintic( float x )
            {
                x = saturate( x );
                float4 x1 = float4( 1.0, x, x * x, x * x * x ); // 1 x x2 x3
                float4 x2 = x1 * x1.w * x; // x4 x5 x6 x7
                return float3(
                    dot( x1.xyzw, float4( -0.027780558, +1.228188385, +0.278906882, +3.892783760 ) ) + dot( x2.xy, float2( -8.490712758, +4.069046086 ) ),
                    dot( x1.xyzw, float4( +0.014065206, +0.015360518, +1.605395918, -4.821108251 ) ) + dot( x2.xy, float2( +8.389314011, -4.193858954 ) ),
                    dot( x1.xyzw, float4( -0.019628385, +3.122510347, -5.893222355, +2.798380308 ) ) + dot( x2.xy, float2( -3.608884658, +4.324996022 ) ) );
            }

            float4 frag (v2f i) : SV_Target
            {
                float val = tex2D(_MainTex, i.uv).r * _Scale;
                val = val < 0.0 ? -tanh(val) * _Scale * 0.5 : val;
                float3 col = inferno_quintic(val);
                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
