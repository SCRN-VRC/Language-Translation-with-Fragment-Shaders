Shader "HandwriteClassify/HandwriteDisplay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv;
                // Clip ortho
                o.uv.z = unity_OrthoParams.w ? -1 : 1;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                clip(i.uv.z);
                float col = 1.0 - tex2D(_MainTex, i.uv);
                return float4(col.rrr, 1.0);
            }
            ENDCG
        }
    }
}
