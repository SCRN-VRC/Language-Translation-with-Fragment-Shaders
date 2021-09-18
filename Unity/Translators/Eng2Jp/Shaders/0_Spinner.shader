Shader "Translator/0_Spinner"
{
    Properties
    {
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
        
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha 
        Cull Off
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./Transformer/Eng2JpInclude.cginc"

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
            Texture2D<float> _LayersTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2 rotate(float2 v, float a) {
                float s;
                float c;
                sincos(a, s, c);
                float2x2 m = float2x2(c, -s, s, c);
                return mul(m, v);
            }

            float4 frag (v2f i) : SV_Target
            {
                uint state = floor(_LayersTex[txTLState]);
                clip((state == ST_FINISH || state == ST_FINISH) ? -1 : 1);
                i.uv = rotate(i.uv - 0.5, _Time.y * 3.0) + 0.5;
                float4 col = tex2D(_MainTex, i.uv);
                clip(col.a - 0.01);
                return col;
            }
            ENDCG
        }
    }
}
