Shader "Translator/Jp2Eng/Encoder/EncoderEmbeddingLayer"
{
    Properties
    {
        _WeightsTex ("Baked Weights", 2D) = "black" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _WeightBiasLoopID ("Weight, Bias, Loop Max, CurID", Vector) = (0, 0, 0, 0)
        _MaxDist ("Max Distance", Float) = 0.02
    }
    SubShader
    {
        Tags { "Queue"="Overlay+1" "ForceNoShadowCasting"="True" "IgnoreProjector"="True" }
        ZWrite Off
        ZTest Always
        Cull Front
        
        Pass
        {
            Lighting Off
            SeparateSpecular Off
            Fog { Mode Off }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "Jp2EngInclude.cginc"

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

            RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _WeightsTex;
            Texture2D<float> _LayersTex;
            float4 _LayersTex_TexelSize;
            uint4 _WeightBiasLoopID;
            float _MaxDist;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = float4(v.uv * 2 - 1, 0, 1);
                #ifdef UNITY_UV_STARTS_AT_TOP
                v.uv.y = 1-v.uv.y;
                #endif
                o.uv.xy = UnityStereoTransformScreenSpaceTex(v.uv);
                o.uv.z = distance(_WorldSpaceCameraPos,
                   mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz) > _MaxDist ? -1.0 : 1.0;
                o.uv.z = unity_OrthoParams.w ? o.uv.z : -1.0;
                return o;
            }

            float frag (v2f i) : SV_Target
            {
                clip(i.uv.z);

                uint2 px = i.uv.xy * _LayersTex_TexelSize.zw;
                uint4 renderPos = layersPos[_WeightBiasLoopID.w];
                bool renderArea = insideArea(renderPos, px);
                clip(renderArea ? 1.0 : -1.0);

                float col = _LayersTex.Load(uint3(px, 0));
                px -= renderPos.xy;

                uint TLState = floor(_LayersTex[txTLState]);
                uint laC = floor(_LayersTex[txLayerCounter]);

                uint l = px.x;
                uint k = px.y;
                float s = 0.0;

                if (TLState == ST_ENC_EMBED){
                    uint word = round(getWordJp(_LayersTex, k));
                    s = getEmbeddingJp(_WeightsTex, uint2(word, l)) * 22.627417; // scaling factor sqrt(512.0)
                    s += posEncoding(k, l, 512.0);
                    col = s;
                    //if (k == 10 && l == 500) buffer[0] = col;
                }
                else if (TLState == ST_ENCODER && laC == 0)
                {
                    // copy encoder output
                    s = getLayer(_LayersTex, 14, px.yx);
                    col = s;
                }
                return col;
            }
            ENDCG
        }
    }
}
