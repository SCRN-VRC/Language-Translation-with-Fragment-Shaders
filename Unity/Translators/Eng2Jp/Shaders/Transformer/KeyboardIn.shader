Shader "Translator/Eng2Jp/KeyboardIn"
{
    Properties
    {
        _KeyTex ("Keyboard In", 2D) = "black" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
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
            #include "Eng2JpInclude.cginc"

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
            Texture2D<float> _KeyTex;
            Texture2D<float> _LayersTex;
            float4 _LayersTex_TexelSize;
            float4 _KeyTex_TexelSize;
            float _MaxDist;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
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
                uint4 renderPos = layersPos[46];
                bool renderArea = insideArea(renderPos, px);
                clip(renderArea ? 1.0 : -1.0);

                float col = _LayersTex.Load(uint3(px, 0));
                uint2 ipx = px;
                px -= renderPos.xy;

                int pointer = round(_LayersTex[txPointer]);
                uint inputState = round(_LayersTex[txInputState]);
                float onEnter = _LayersTex[txEnter];
                float startBtn = _LayersTex[txStartBtn];
                float clearBtn = _LayersTex[txClearBtn];

                if (_Time.y < 1.0)
                {
                    pointer = 0;
                    inputState = KEY_IDLE;
                    onEnter = 0.0;
                    startBtn = 0.0;
                }

                float3 touchPosCount = 0.0;
                // Since the bounding box is 3x larger than normal
                // we just start at the 1/3 and end at 2/3
                uint Ws = uint(_KeyTex_TexelSize.z / 3.0);
                uint We = Ws * 2;
                uint Hs = uint(_KeyTex_TexelSize.w / 3.0);
                uint He = Hs * 2;
                for (uint i = Ws; i < We; i++)
                {
                    for (uint j = Hs; j < He; j += 2)
                    {
                        uint jx = (i & 0x1) == 0 ? j : j + 1;
                        float depth = _KeyTex[uint2(i, jx)].r;
                        //buffer[0] = hit;
                        bool hit = abs(depth - 0.5) <= 0.0075;
                        touchPosCount.xy += hit ? float2(i, jx) : 0..xx;
                        touchPosCount.z += hit ? 1.0 : 0.0;
                    }
                }

                // 256 x 128 -> 10 x 5 grid
                touchPosCount.xy = touchPosCount.xy / max(touchPosCount.z, 1.);
                touchPosCount.xy -= float2(Ws, Hs);
                touchPosCount.xy = floor(touchPosCount.xy * 0.117185);
                // x is flipped
                touchPosCount.x = 9.0 - touchPosCount.x;

                //buffer[0] = touchPosCount.xyzz;

                if (inputState == KEY_IDLE)
                {
                    // Idle until something touches
                    inputState = touchPosCount.z > INPUT_THRESHOLD ?
                        KEY_DOWN : KEY_IDLE;
                }
                else if (inputState == KEY_DOWN)
                {
                    if (onEnter < 0.5)
                    {
                        int id = px.x + px.y * 16;
                        float char = getCharMap(uint2(touchPosCount.xy));
                        bool notSpecial = (char >= 0.0 && char < 100.0);
                        if (notSpecial)
                        {
                            col = id == pointer ? char : col;
                            pointer = min(pointer + 1, CHAR_MAX);
                        }
                        // backspace
                        else if (round(char) == 100)
                        {
                            pointer = max(pointer - 1, 0.0);
                            col = id == pointer ? 0.0 : col;
                        }
                        // return
                        else if (round(char) == 101)
                        {
                            startBtn = 1.0;
                        }
                        // clear
                        else if (round(char) == 102)
                        {
                            clearBtn = 1.0;
                            pointer = 0;
                            col = id < CHAR_MAX ? 0 : col;
                        }
                        onEnter = 1.0;
                    }
                    // Nothing's touching anymore
                    inputState = touchPosCount.z <= INPUT_THRESHOLD ?
                        KEY_UP : KEY_DOWN;
                }
                else if (inputState == KEY_UP)
                {
                    inputState = KEY_IDLE;
                    onEnter = 0.0;
                    startBtn = 0.0;
                    clearBtn = 0.0;
                }
                else
                {
                    inputState = KEY_IDLE;
                }

                StoreValue(txPointer,       float(pointer),        col, ipx);
                StoreValue(txInputState,    float(inputState),     col, ipx);
                StoreValue(txPosX,          touchPosCount.x,       col, ipx);
                StoreValue(txPosY,          touchPosCount.y,       col, ipx);
                StoreValue(txCount,         touchPosCount.z,       col, ipx);
                StoreValue(txEnter,         onEnter,               col, ipx);
                StoreValue(txStartBtn,      startBtn,              col, ipx);
                StoreValue(txClearBtn,      clearBtn,              col, ipx);
                return col;
            }
            ENDCG
        }
    }
}
