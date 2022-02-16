Shader "HandwriteClassify/VertBtns"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "ConvMixer/ConvMixerModel.cginc"

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

            float4 frag (v2f i) : SV_Target
            {
                clip(unity_OrthoParams.w ? -1 : 1);
                uint vertState = floor(_LayersTex[txVertState]);
                float vertSel = (4.0 - (_LayersTex[txVertSel])) *
                    ((vertState != HAND_IDLE) ? 1.0 : -10.0) - 1.0;
                // color the selection red
                float red = abs(i.uv.y - 0.1667 * (1.0 + 2.0 * vertSel)) < 0.1667 ? 1.0 : 0.0;
                float4 col = tex2D(_MainTex, i.uv);
                col = lerp(float4(red, 0..xx, red), col, col.a);

                clip(col.a - 0.0001);
                return col;
            }
            ENDCG
        }
    }
}
