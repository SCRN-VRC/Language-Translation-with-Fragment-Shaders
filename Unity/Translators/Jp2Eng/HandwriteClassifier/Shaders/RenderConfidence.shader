Shader "HandwriteClassify/RenderConfidence"
{
    Properties
    {
        _LayersTex ("Layers Texture", 2D) = "black" {}
        [HDR]_Color("Text Color", Color) = (1, 0, 0, 1)
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
            #include "./ConvMixer/ConvMixerModel.cginc"

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

            Texture2D<float> _LayersTex;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 mUV = i.uv;
                mUV.x = mod(mUV.x * 5., 1.0);
                uint ID = floor(i.uv.x * 5.);
                float scores[5] = {0, 0, 0, 0, 0};
                scores[0] = _LayersTex[txTop1Val.xy];
                scores[1] = _LayersTex[txTop2Val.xy];
                scores[2] = _LayersTex[txTop3Val.xy];
                scores[3] = _LayersTex[txTop4Val.xy];
                scores[4] = _LayersTex[txTop5Val.xy];

                float sum = 0.0;
                for (uint i = 0; i < 5; i++) sum += scores[i];

                // Softmax
                float confidence = scores[ID] / sum;

                // Vignette
                float2 vUV = mUV;
                vUV.y /= confidence;
                vUV *= (1.0 - vUV.yx);
                float vig = pow(vUV.x * vUV.y * 20.0, 0.25);
                clip(confidence - mUV.y - 0.001);

                return _Color * vig;
            }
            ENDCG
        }
    }
}
