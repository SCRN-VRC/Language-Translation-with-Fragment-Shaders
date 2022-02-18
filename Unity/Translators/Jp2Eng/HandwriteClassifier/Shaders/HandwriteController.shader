Shader "HandwriteClassify/HandwriteController"
{
    Properties
    {
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _HandwriteTex ("Handwrite Input", 2D) = "black" {}
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
            #include "./ConvMixer/ConvMixerModel.cginc"

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
            Texture2D<float> _LayersTex;
            Texture2D<float> _HandwriteTex;
            float4 _LayersTex_TexelSize;
            float4 _HandwriteTex_TexelSize;
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
                float layerCount = _LayersTex[txLayerCount];
                uint inputState = floor(_LayersTex[txInputState]);

                if (_Time.y < 1.0)
                {
                    layerCount = 11.0;
                    inputState = HAND_IDLE;
                }

                // classify scores
                if (round(layerCount) == 11 && all(px <= txTop5Val))
                {
                    float ind1, ind2, ind3, ind4, ind5;
                    float val1, val2, val3, val4, val5;
                    ind1 = ind2 = ind3 = ind4 = ind5 = -1.0;
                    val1 = val2 = val3 = val4 = val5 = MIN_FLOAT;
                    for (uint i = 0; i < 3225; i++)
                    {
                        float val = getOutput(_LayersTex, i);
                        if (val > val1)
                        {
                            val5 = val4; ind5 = ind4;
                            val4 = val3; ind4 = ind3;
                            val3 = val2; ind3 = ind2;
                            val2 = val1; ind2 = ind1;
                            val1 = val; ind1 = i;
                        }
                    }

                    // +3 cause the classifier skips the 3 special tokens
                    StoreValue(txTop1, ind1 + 3, col, px);
                    StoreValue(txTop2, ind2 + 3, col, px);
                    StoreValue(txTop3, ind3 + 3, col, px);
                    StoreValue(txTop4, ind4 + 3, col, px);
                    StoreValue(txTop5, ind5 + 3, col, px);
                    // exp for softmax calcs in the graph
                    StoreValue(txTop1Val, exp(val1), col, px);
                    StoreValue(txTop2Val, exp(val2), col, px);
                    StoreValue(txTop3Val, exp(val3), col, px);
                    StoreValue(txTop4Val, exp(val4), col, px);
                    StoreValue(txTop5Val, exp(val5), col, px);

                    //buffer[0] = float4(ind1, ind2, ind3, ind4);
                }

                // Handwrite input
                float3 touchPosCount = 0.0;
                // Since the bounding box is 2x larger
                uint Ws = uint(_HandwriteTex_TexelSize.z * 0.25);
                uint We = Ws * 3;
                uint Hs = uint(_HandwriteTex_TexelSize.w * 0.25);
                uint He = Hs * 3;
                for (uint i = Ws; i < We; i++)
                {
                    for (uint j = Hs; j < He; j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float depth = _HandwriteTex[uint2(i, jx)].r;
                        bool hit = abs(depth - 0.5) <= 0.0075;
                        touchPosCount.xy += hit ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit ? 1.0 : 0.0;
                    }
                }
                //buffer[0] = float4(touchPosCount.xyz, 0);
                if (inputState == HAND_IDLE)
                {
                    // Idle until something touches
                    inputState = touchPosCount.z > INPUT_THRESHOLD ?
                        HAND_DOWN : HAND_IDLE;
                }
                else if (inputState == HAND_DOWN)
                {
                    inputState = touchPosCount.z <= INPUT_THRESHOLD ?
                        HAND_UP : HAND_DOWN;
                }
                else if (inputState == HAND_UP)
                {
                    inputState = HAND_IDLE;
                }
                else
                {
                    inputState = HAND_IDLE;
                }

                // increment layers
                layerCount = inputState == HAND_UP ? 0 : min(layerCount + 1.0, 12.0);
                
                // translator input buffer logic
                if (all(px >= txInputBuffer))
                {

                    float VbtnSel = _LayersTex[txVBtnSel];
                    uint VbtnState = floor(_LayersTex[txVBtnState]);
                    float VbtnEnter = _LayersTex[txVBtnEnter];
                    float HbtnSel = _LayersTex[txHBtnSel];
                    uint HbtnState = floor(_LayersTex[txHBtnState]);
                    float HbtnEnter = _LayersTex[txHBtnEnter];
                    int cursorPos = _LayersTex[txCursorPos];

                    px -= txInputBuffer;
                    col = _Time.y < 1.0 ? 0.0 : col; // fill empty
                    // user selects input character
                    if (HbtnState == HAND_DOWN && HbtnEnter < 1.0)
                    {
                        uint word = round(_LayersTex[txTop1.xy + uint2(HbtnSel - 1, 0)]);
                        col = px.x == cursorPos ? word : col;
                    }
                    // backspace
                    else if (VbtnState == HAND_DOWN && VbtnEnter < 1.0 && abs(VbtnSel - 2.0) < eps)
                    {
                        col = px.x == (cursorPos - 1) ? 2.0 : col;
                        col = px.x == (cursorPos) ? 0.0 : col;
                    }
                }

                //buffer[0] = cursorPos;
                StoreValue(txLayerCount,    layerCount,            col, px);
                StoreValue(txInputState,    float(inputState),     col, px);
                return col;
            }
            ENDCG
        }
    }
}
