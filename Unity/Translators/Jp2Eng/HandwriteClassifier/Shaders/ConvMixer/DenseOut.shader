Shader "HandwriteClassify/Layers/DenseOut"
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

                    uint k = px.x + px.y * 57;

                    float s = 0.0;
                    for (uint l = 0; l < _WeightBiasLoopID.z; l++)
                    {
                        s += _LayersTex[layersPos[_InputID.x].xy + uint2(l, 0)] *
                            getConstDense(_WeightsTex, _WeightBiasLoopID.x, uint2(l, k));
                    }

                    // bias
                    s = s + getConst(_WeightsTex, _WeightBiasLoopID.y, k);

                    col = k < 3225 ? s : -10.0;
                    // if (k == 548)
                    // {
                    //     buffer[0] = s;
                    // }
                }

                return col;
            }
            ENDCG
        }
    }
}
