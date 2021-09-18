Shader "Translator/KeyboardDisplay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
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

            fixed4 frag (v2f i) : SV_Target
            {
                clip(unity_OrthoParams.w ? -1 : 1);
                fixed4 col = tex2D(_MainTex, i.uv);

                uint3 touchControl;
                touchControl.x = floor(_LayersTex[txPosX]);
                touchControl.y = floor(_LayersTex[txPosY]);
                touchControl.z = floor(_LayersTex[txCount]);

                uint2 gridUV = floor(i.uv * float2(10, 5));

                if (touchControl.z > INPUT_THRESHOLD && all(gridUV == touchControl.xy))
                {
                    col.rgb *= float3(1.5, 0.2, 0.2);
                }

                clip(col.a - 0.01);
                return col;
            }
            ENDCG
        }
    }
}
