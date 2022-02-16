Shader "HandwriteClassify/Controller"
{
    Properties
    {
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _HandwriteTex ("Handwrite Input", 2D) = "black" {}
        _VertBtnTex ("Vertical Buttons", 2D) = "black" {}
        _HorzBtnTex ("Horizontal Buttons", 2D) = "black" {}
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
            Texture2D<float> _VertBtnTex;
            Texture2D<float> _HorzBtnTex;
            float4 _LayersTex_TexelSize;
            float4 _HandwriteTex_TexelSize;
            float4 _VertBtnTex_TexelSize;
            float4 _HorzBtnTex_TexelSize;
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
                float horzSel = _LayersTex[txHorzSel];
                float vertSel = _LayersTex[txVertSel];
                uint horzState = floor(_LayersTex[txHorzState]);
                uint vertState = floor(_LayersTex[txVertState]);
                int cursorPos = floor(_LayersTex[txCursorPos]);

                if (_Time.y < 1.0)
                {
                    layerCount = 0.0;
                    inputState = HAND_IDLE;
                    horzSel = 0;
                    vertSel = 0;
                    horzState = 0;
                    vertState = 0;
                    cursorPos = 0;
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
                for (uint i = 0; i < uint(_HandwriteTex_TexelSize.z); i++)
                {
                    for (uint j = 0; j < uint(_HandwriteTex_TexelSize.w); j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float hit = _HandwriteTex[uint2(i, jx)].r;
                        touchPosCount.xy += hit > 0.1 ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit > 0.1 ? 1.0 : 0.0;
                    }
                }

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
                    px -= txInputBuffer;
                    col = _Time.y < 1.0 ? 0.0 : col; // fill empty
                    // user selects input character
                    if (horzState == HAND_UP)
                    {
                        uint word = round(_LayersTex[txTop1.xy + uint2(horzSel - 1, 0)]);
                        col = px.x == cursorPos ? word : col;
                    }
                    // backspace
                    else if (vertState == HAND_UP && abs(vertSel - 2.0) < eps)
                    {
                        col = px.x == (cursorPos - 1) ? 2.0 : col;
                        col = px.x == (cursorPos) ? 0.0 : col;
                    }
                }

                // Horizontal buttons input
                
                touchPosCount = 0.0;
                for (uint i = 0; i < uint(_HorzBtnTex_TexelSize.z); i++)
                {
                    for (uint j = 0; j < uint(_HorzBtnTex_TexelSize.w); j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float hit = _HorzBtnTex[uint2(i, jx)].r;
                        touchPosCount.xy += hit > 0.1 ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit > 0.1 ? 1.0 : 0.0;
                    }
                }

                if (horzState == HAND_IDLE)
                {
                    // Idle until something touches
                    horzState = touchPosCount.z > INPUT_THRESHOLD ?
                        HAND_DOWN : HAND_IDLE;
                }
                else if (horzState == HAND_DOWN)
                {
                    if (touchPosCount.z <= INPUT_THRESHOLD)
                    {
                        horzState = HAND_UP;
                    }
                    else
                    {
                        horzSel = floor(5.0 - (touchPosCount.x / max(touchPosCount.z, 1.0)
                            / _HorzBtnTex_TexelSize.z * 5.0) + 1.0);
                    }
                }
                else if (horzState == HAND_UP)
                {
                    // increment cursor
                    cursorPos = min(cursorPos + 1, 20);
                    horzState = HAND_IDLE;
                }
                else
                {
                    horzState = HAND_IDLE;
                }

                // Vertical buttons input

                touchPosCount = 0.0;
                for (uint i = 0; i < uint(_VertBtnTex_TexelSize.z); i++)
                {
                    for (uint j = 0; j < uint(_VertBtnTex_TexelSize.w); j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float hit = _VertBtnTex[uint2(i, jx)].r;
                        touchPosCount.xy += hit > 0.1 ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit > 0.1 ? 1.0 : 0.0;
                    }
                }

                if (vertState == HAND_IDLE)
                {
                    // Idle until something touches
                    vertState = touchPosCount.z > INPUT_THRESHOLD ?
                        HAND_DOWN : HAND_IDLE;
                }
                else if (vertState == HAND_DOWN)
                {
                    if (touchPosCount.z <= INPUT_THRESHOLD)
                    {
                        vertState = HAND_UP;
                    }
                    else
                    {
                        vertSel = floor(3.0 - (touchPosCount.y / max(touchPosCount.z, 1.0)
                            / _VertBtnTex_TexelSize.w * 3.0) + 1.0);
                    }
                }
                else if (vertState == HAND_UP)
                {
                    // decrement cursor
                    cursorPos = abs(vertSel - 2.0) < eps ?
                        max(cursorPos - 1, 0) : cursorPos;
                    vertState = HAND_IDLE;
                }
                else
                {
                    vertState = HAND_IDLE;
                }

                //buffer[0] = cursorPos;
                StoreValue(txLayerCount,    layerCount,            col, px);
                StoreValue(txInputState,    float(inputState),     col, px);
                StoreValue(txHorzSel,       horzSel,               col, px);
                StoreValue(txVertSel,       vertSel,               col, px);
                StoreValue(txHorzState,     float(horzState),      col, px);
                StoreValue(txVertState,     float(vertState),      col, px);
                StoreValue(txCursorPos,     float(cursorPos),      col, px);
                return col;
            }
            ENDCG
        }
    }
}
