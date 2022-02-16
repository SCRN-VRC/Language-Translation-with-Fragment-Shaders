Shader "HandwriteClassify/Layers/InputLayer"
{
    Properties
    {
        _WeightsTex ("Baked Weights", 2D) = "black" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _InputTex ("Input Texture", 2D) = "black" {}
        _WeightBiasLoopID ("Weight, Bias, Loop Max, CurID", Vector) = (0, 0, 0, 0)
        _BatchNormID ("Batch Norm IDs", Vector) = (0, 0, 0, 0)
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
            #include "ConvMixerModel.cginc"

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
            
            sampler2D _InputTex;
            float4 _InputTex_TexelSize;

            Texture2D<float> _WeightsTex;
            Texture2D<float> _LayersTex;
            float4 _LayersTex_TexelSize;
            uint4 _WeightBiasLoopID;
            uint4 _BatchNormID;
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

            float frag (v2f ps) : SV_Target
            {
                clip(ps.uv.z);

                uint2 px = ps.uv.xy * _LayersTex_TexelSize.zw;
                uint4 renderPos = layersPos[_WeightBiasLoopID.w];
                bool renderArea = insideArea(renderPos, px);
                clip(renderArea ? 1.0 : -1.0);

                float col = _LayersTex[px];
                uint layerCount = round(_LayersTex[txLayerCount]);

                if (layerCount == _WeightBiasLoopID.w)
                {
                    px -= renderPos.xy;

                    uint i = px.x % 32;
                    uint j = px.x / 32;
                    uint k = px.y;

                    uint i0 = i * 2, i1 = i0 + 1;
                    uint j0 = j * 2, j1 = j0 + 1;

                    // The input needs to be at a certain orientation cause 0,0 is different
                    // on different platforms, this is to undo the input camera flipping
                    float2 _00 = (float2(i0, j0) / 63); _00.x = 1. - _00.x;
                    float2 _01 = (float2(i0, j1) / 63); _01.x = 1. - _01.x;
                    float2 _10 = (float2(i1, j0) / 63); _10.x = 1. - _10.x;
                    float2 _11 = (float2(i1, j1) / 63); _11.x = 1. - _11.x;

                    // 2x2 kernel
                    float s = 
                        (1.0 - tex2D(_InputTex, _00)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 0, k), 2) +
                        (1.0 - tex2D(_InputTex, _01)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 1, k), 2) +
                        (1.0 - tex2D(_InputTex, _10)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 0, k), 2) +
                        (1.0 - tex2D(_InputTex, _11)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 1, k), 2);
                        // testGen(uint3(i0, j0, 0), 64..xx) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 0, k), 2) +
                        // testGen(uint3(i0, j1, 0), 64..xx) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 1, k), 2) +
                        // testGen(uint3(i1, j0, 0), 64..xx) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 0, k), 2) +
                        // testGen(uint3(i1, j1, 0), 64..xx) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 1, k), 2);

                    // bias
                    s = s + getConst(_WeightsTex, _WeightBiasLoopID.y, k);
                    // activation
                    s = GELU(s);
                    // batch norm
                    float gamma = getConst(_WeightsTex, _BatchNormID.x, k);
                    float beta = getConst(_WeightsTex, _BatchNormID.y, k);
                    float mean = getConst(_WeightsTex, _BatchNormID.z, k);
                    float variance = getConst(_WeightsTex, _BatchNormID.w, k);
                    s = batchNorm(s, gamma, beta, mean, variance);

                    col = s;
                    // if (i == 0 && j == 31 && k == 143)
                    //     buffer[0] = s;
                }

                return col;
            }
            ENDCG
        }
    }
}
