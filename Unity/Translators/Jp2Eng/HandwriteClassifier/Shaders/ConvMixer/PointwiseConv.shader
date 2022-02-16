Shader "HandwriteClassify/Layers/PointwiseConv"
{
    Properties
    {
        _WeightsTex ("Baked Weights", 2D) = "black" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _WeightBiasLoopID ("Weight, Bias, Loop Max, CurID", Vector) = (0, 0, 0, 0)
        _BatchNormID ("Batch Norm IDs", Vector) = (0, 0, 0, 0)
        _InputID ("Input Layer ID", Vector) = (0, 0, 0, 0)
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
            Texture2D<float> _WeightsTex;
            Texture2D<float> _LayersTex;
            float4 _LayersTex_TexelSize;
            uint4 _WeightBiasLoopID;
            uint4 _BatchNormID;
            uint4 _InputID;
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
                    
                    float s = 0.0;

                    for (uint l = 0; l < _WeightBiasLoopID.z; l++)
                    {
                        float layerAdd = getLayer(_LayersTex, _InputID.x, uint3(i, j, l)) +
                            getLayer(_LayersTex, _InputID.y, uint3(i, j, l));
                        s += layerAdd * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, l, k), 1);
                    }

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

                    // if (i == 31 && j == 1 && k == 2 && _WeightBiasLoopID.w == 8)
                    // {
                    //     buffer[0] = s;
                    // }
                    col = s;
                }

                return col;
            }
            ENDCG
        }
    }
}
