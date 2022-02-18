Shader "HandwriteClassify/ButtonsIn"
{
    Properties
    {
        _HandwriteTex ("Handwrite Input", 2D) = "black" {}
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
            Texture2D<float> _HandwriteTex;
            Texture2D<float> _LayersTex;
            float4 _LayersTex_TexelSize;
            float4 _WeightBiasLoopID;
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

                uint4 WBLID = _WeightBiasLoopID;

                uint2 px = i.uv.xy * _LayersTex_TexelSize.zw;
                uint4 renderPos = layersPos[WBLID.w];
                bool renderArea = insideArea(renderPos, px);
                clip(renderArea ? 1.0 : -1.0);

                float col = _LayersTex.Load(uint3(px, 0));

                float VbtnSel = _LayersTex[txVBtnSel];
                uint VbtnState = floor(_LayersTex[txVBtnState]);
                float VbtnEnter = _LayersTex[txVBtnEnter];
                float HbtnSel = _LayersTex[txHBtnSel];
                uint HbtnState = floor(_LayersTex[txHBtnState]);
                float HbtnEnter = _LayersTex[txHBtnEnter];
                int cursorPos = _LayersTex[txCursorPos];

                // erase, delete, enter buttons
                const uint4 vertBoxSize = uint4(113, 197, 25, 53);

                float3 touchPosCount = 0.0;
                for (uint i = vertBoxSize.x; i < vertBoxSize.y; i++)
                {
                    for (uint j = vertBoxSize.z; j < vertBoxSize.w; j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float depth = _HandwriteTex[uint2(i, jx)].r;
                        bool hit = abs(depth - 0.5) <= 0.0075;
                        touchPosCount.xy += hit ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit ? 1.0 : 0.0;
                    }
                }
                touchPosCount.xy = touchPosCount.xy / max(touchPosCount.z, 1.);
                touchPosCount.xy -= float2(vertBoxSize.xz);
                touchPosCount.xy = floor(saturate(touchPosCount /
                    float2(vertBoxSize.y - vertBoxSize.x,
                    vertBoxSize.w - vertBoxSize.z)) * 3.0);
                touchPosCount.x += 1;

                VbtnSel = touchPosCount.x;

                if (VbtnState == HAND_IDLE)
                {
                    // Idle until something touches
                    VbtnState = touchPosCount.z > INPUT_THRESHOLD ?
                        HAND_DOWN : HAND_IDLE;
                }
                else if (VbtnState == HAND_DOWN)
                {
                    if (VbtnEnter < 0.5)
                    {
                        // decrement cursor
                        cursorPos = abs(VbtnSel - 2.0) < eps ?
                            max(cursorPos - 1, 0) : cursorPos;
                        VbtnEnter = 1.0;
                    }
                    VbtnState = touchPosCount.z <= INPUT_THRESHOLD ?
                        HAND_UP : VbtnState;
                }
                else if (VbtnState == HAND_UP)
                {
                    VbtnEnter = 0.0;
                    VbtnState = HAND_IDLE;
                }
                else
                {
                    VbtnState = HAND_IDLE;
                }

                // prediction selection
                const uint4 horzBoxSize = uint4(203, 233, 62, 195);

                touchPosCount = 0.0;
                for (uint i = horzBoxSize.x; i < horzBoxSize.y; i++)
                {
                    for (uint j = horzBoxSize.z; j < horzBoxSize.w; j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float depth = _HandwriteTex[uint2(i, jx)].r;
                        bool hit = abs(depth - 0.5) <= 0.0075;
                        touchPosCount.xy += hit ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit ? 1.0 : 0.0;
                    }
                }
                touchPosCount.xy = touchPosCount.xy / max(touchPosCount.z, 1.);
                touchPosCount.xy -= float2(horzBoxSize.xz);
                touchPosCount.xy = floor(saturate(touchPosCount /
                    float2(horzBoxSize.y - horzBoxSize.x,
                    horzBoxSize.w - horzBoxSize.z)) * 5.0);
                touchPosCount.y += 1;

                HbtnSel = touchPosCount.y;

                if (HbtnState == HAND_IDLE)
                {
                    // Idle until something touches
                    HbtnState = touchPosCount.z > INPUT_THRESHOLD ?
                        HAND_DOWN : HAND_IDLE;
                }
                else if (HbtnState == HAND_DOWN)
                {
                    if (HbtnEnter < 0.5)
                    {
                        // decrement cursor
                        cursorPos = min(cursorPos + 1, 20);
                        HbtnEnter = 1.0;
                    }
                    HbtnState = touchPosCount.z <= INPUT_THRESHOLD ?
                        HAND_UP : HbtnState;
                }
                else if (HbtnState == HAND_UP)
                {
                    HbtnEnter = 0.0;
                    HbtnState = HAND_IDLE;
                }
                else
                {
                    HbtnState = HAND_IDLE;
                }

                //buffer[0] = float4(touchPosCount.xyz, HbtnState);

                StoreValue(txVBtnSel,         VbtnSel,                  col, px);
                StoreValue(txVBtnState,       float(VbtnState),         col, px);
                StoreValue(txVBtnEnter,       VbtnEnter,                col, px);
                StoreValue(txHBtnSel,         HbtnSel,                  col, px);
                StoreValue(txHBtnState,       float(HbtnState),         col, px);
                StoreValue(txHBtnEnter,       HbtnEnter,                col, px);
                StoreValue(txCursorPos,       float(cursorPos),         col, px);
                return col;
            }
            ENDCG
        }
    }
}
