Shader "Translator/Jp2Eng/TransformerDataIn"
{
    Properties
    {
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _ConvMixerTex ("CovMixer Input Texture", 2D) = "black" {}
        _WordToCharTex ("Baked Word to Char Texture", 2D) = "black" {}
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
            Texture2D<float> _LayersTex;
            Texture2D<float> _ConvMixerTex;
            Texture2D<float4> _WordToCharTex;
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
                uint2 ipx = px;
                px -= renderPos.xy;

                uint TLState = floor(_LayersTex[txTLState]);
                float outPos = floor(_LayersTex[txOutPos]);

                // input characters
                if (px.x < 2)
                {

                }
                // input sentence encoded from characters
                else if (px.x == 2)
                {
                    // static const float DEBUG_SENTENCE[22] =
                    //     { 1, 99, 59, 10, 237, 41, 12, 757, 8, 329, 27, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
                    // col = DEBUG_SENTENCE[px.y];
                    if (TLState == ST_TOKENIZE)
                    {
                        // append the end token
                        col = px.y == uint(outPos) ? 2.0 : col;
                    }
                    else
                    {
                        // copy the sentence over
                        col = px.y == 0 ? 1.0 : _ConvMixerTex[uint2(94 + px.y - 1, 1352)];
                    }
                }
                // other variables
                else
                {
                    uint TLPrevState = floor(_LayersTex[txTLPrevState]);
                    uint layerCounter = floor(_LayersTex[txLayerCounter]);
                    uint loopCounter = floor(_LayersTex[txLoopCounter]);
                    uint decSeqLen = floor(_LayersTex[txDecSeqLen]);
                    uint nextWord = round(_LayersTex[txNextWord]);
                    float outLen = floor(_LayersTex[txOutLen]);

                    float vertSel = _ConvMixerTex[txVertSel];
                    uint vertState = floor(_ConvMixerTex[txVertState]);

                    float startBtn = (vertState == HAND_UP && abs(vertSel - 3.0) < 0.001) ? 1.0 : 0.0;
                    float clearBtn = (vertState == HAND_UP && abs(vertSel - 2.0) < 0.001) ? 1.0 : 0.0;

                    TLState = _Time.y < 1.0 ? ST_FINISH : TLState;
                    TLPrevState = TLState;
                    
                    [branch]
                    if (TLState == ST_INPUT)
                    {
                        // reset counters
                        layerCounter = 1;
                        loopCounter = 0;
                        decSeqLen = 0;
                        nextWord = 0;
                        outPos = 0;
                        outLen = 0;
                        TLState = ST_TOKENIZE;
                    }
                    else if (TLState == ST_TOKENIZE)
                    {
                        TLState = ST_ENC_EMBED;
                    }
                    else if (TLState == ST_ENC_EMBED)
                    {
                        // create masks and do the encoding before
                        // encoder loop
                        TLState = ST_ENCODER;
                    }
                    else if (TLState == ST_ENCODER)
                    {
                        // go thru encoder all layers, loop MAX_LOOPS times
                        layerCounter = layerCounter + 1;
                        loopCounter = layerCounter >= ENC_LAYERS ?
                            loopCounter + 1 : loopCounter;
                        layerCounter = layerCounter >= ENC_LAYERS ?
                            0 : layerCounter;
                        TLState = loopCounter >= MAX_LOOPS ? ST_DEC_SEQ : ST_ENCODER;
                        // Stop if input cleared
                        TLState = clearBtn > 0.5 ? ST_FINISH : TLState;
                    }
                    else if (TLState == ST_DEC_COPY)
                    {
                        // copy decoder output sequence to input
                        TLState = ST_DEC_SEQ;
                    }
                    else if (TLState == ST_DEC_SEQ)
                    {
                        // reset decoder loop
                        layerCounter = 1;
                        loopCounter = 0;
                        TLState = ST_DEC_EMBED;
                    }
                    else if (TLState == ST_DEC_EMBED)
                    {
                        // get decoder input length
                        decSeqLen = decoderSeqLen(_LayersTex);
                        TLState = ST_DECODER;
                    }
                    else if (TLState == ST_DECODER)
                    {
                        // go thru decoder all layers, loop MAX_LOOPS times
                        layerCounter = layerCounter + 1;
                        loopCounter = layerCounter >= DEC_LAYERS ?
                            loopCounter + 1 : loopCounter;
                        layerCounter = layerCounter >= DEC_LAYERS ?
                            0 : layerCounter;
                        TLState = loopCounter >= MAX_LOOPS ? ST_DEC_FINAL : ST_DECODER;
                        // Stop if input cleared
                        TLState = clearBtn > 0.5 ? ST_FINISH : TLState;
                    }
                    else if (TLState == ST_DEC_FINAL)
                    {
                        // run the final dense layer
                        TLState = ST_DEC_OUT;
                    }
                    else if (TLState == ST_DEC_OUT)
                    {
                        // get the output word of highest probability
                        nextWord = getNextWord(_LayersTex);
                        TLState = (nextWord != 1 && (decSeqLen + 1) <= 22)?
                            ST_CONVERT : ST_FINISH;
                        //buffer[0] = decSeqLen;
                    }
                    else if (TLState == ST_CONVERT)
                    {
                        // convert words into characters to be rendered
                        outLen = getWordLen(_WordToCharTex, nextWord) + 1; // add a space
                        TLState = ST_UPDATE_POS;
                    }
                    else if (TLState == ST_UPDATE_POS)
                    {
                        // update rendering positions
                        outPos += outLen;
                        TLState = ST_DEC_COPY;
                    }
                    else if (TLState == ST_FINISH)
                    {
                        TLState = (startBtn > 0.5) ? ST_INPUT : ST_FINISH;
                    }
                    else
                    {
                        TLState = ST_FINISH;
                    }

                    StoreValue(txTLState,       float(TLState),        col, ipx);
                    StoreValue(txTLPrevState,   float(TLPrevState),    col, ipx);
                    StoreValue(txLayerCounter,  float(layerCounter),   col, ipx);
                    StoreValue(txLoopCounter,   float(loopCounter),    col, ipx);
                    StoreValue(txDecSeqLen,     float(decSeqLen),      col, ipx);
                    StoreValue(txNextWord,      float(nextWord),       col, ipx);
                    StoreValue(txOutPos,        outPos,                col, ipx);
                    StoreValue(txOutLen,        outLen,                col, ipx);
                }

                return col;
            }
            ENDCG
        }
    }
}
