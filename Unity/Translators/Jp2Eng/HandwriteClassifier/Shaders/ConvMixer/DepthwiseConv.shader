Shader "HandwriteClassify/Layers/DepthwiseConv"
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

                    uint i0 = i, i1 = i0 + 1, i2 = i0 + 2, i3 = i0 + 3, i4 = i0 + 4;
                    uint j0 = j, j1 = j0 + 1, j2 = j0 + 2, j3 = j0 + 3, j4 = j0 + 4;
                    
                    // 5x5 depthwise kernel
                    float s = 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i0, j0, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 0, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i0, j1, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 1, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i0, j2, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 2, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i0, j3, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 3, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i0, j4, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(0, 4, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i1, j0, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 0, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i1, j1, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 1, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i1, j2, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 2, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i1, j3, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 3, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i1, j4, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(1, 4, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i2, j0, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(2, 0, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i2, j1, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(2, 1, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i2, j2, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(2, 2, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i2, j3, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(2, 3, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i2, j4, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(2, 4, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i3, j0, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(3, 0, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i3, j1, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(3, 1, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i3, j2, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(3, 2, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i3, j3, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(3, 3, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i3, j4, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(3, 4, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i4, j0, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(4, 0, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i4, j1, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(4, 1, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i4, j2, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(4, 2, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i4, j3, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(4, 3, k), 5) + 
                        padLayerEven(_LayersTex, _InputID.x, uint3(i4, j4, k), uint2(32, 32)) * getConst(_WeightsTex, _WeightBiasLoopID.x, uint3(4, 4, k), 5);

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

                    // if (i == 31 && j == 1 && k == 2 && _WeightBiasLoopID.w == 1)
                    // {
                    //     buffer[0] = getLayer(_LayersTex, _InputID.x, uint3(31, 1, 2));
                    // }
                    col = s;
                }

                return col;
            }
            ENDCG
        }
    }
}
