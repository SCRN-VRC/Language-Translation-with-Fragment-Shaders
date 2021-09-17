Shader "Translator/Eng2Jp/TransformerDataIn"
{
    Properties
    {
        _WordTex ("CharToWord Mapping", 2D) = "black" {}
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

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float4> _WordTex;
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
                uint2 ipx = px;
                px -= renderPos.xy;

                // input characters
                if (px.x < 2)
                {

                }
                // input sentence encoded from characters
                else if (px.x == 2)
                {
                    // static const float DEBUG_SENTENCE[22] =
                    // {
                    //     2.0, 25.0, 241.0, 8.0, 11140.0, 7.0, 10.0, 246.0, 9.0, 1271.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
                    // };
                    // col = DEBUG_SENTENCE[px.y];

                    uint TLState = floor(_LayersTex[txTLState]);
                    uint tokenPointer = floor(_LayersTex[txTokenPointer]);
                    uint token = round(_LayersTex[txToken]);
                    float tokenSuccess = _LayersTex[txTokenSuccess];
                    float clearBtn = _LayersTex[txClearBtn];

                    // always a SOS at the beginning
                    col = px.y == 0 ? 2.0 : col;

                    // save token
                    if (tokenSuccess > 0.5 && tokenPointer == px.y)
                    {
                        col = token;
                    }

                    // add a EOS at the end
                    if (TLState == ST_ENDTOKEN)
                    {
                        uint lastPos = 1;
                        for (uint i = lastPos; i < TOKEN_MAX; i++)
                        {
                            float curToken = _LayersTex[renderPos + uint2(2, i)];
                            lastPos = curToken >= 3.0 ? i + 1 : lastPos;
                        }
                        
                        col = px.y == lastPos ? 1.0 : col;
                    }

                    // clear text
                    if (clearBtn > 0.5 && TLState == ST_FINISH)
                    {
                        col = 0.0;
                    }
                }
                // other variables
                else
                {
                    uint TLState = floor(_LayersTex[txTLState]);
                    uint TLPrevState = floor(_LayersTex[txTLPrevState]);
                    uint layerCounter = floor(_LayersTex[txLayerCounter]);
                    uint loopCounter = floor(_LayersTex[txLoopCounter]);
                    uint decSeqLen = floor(_LayersTex[txDecSeqLen]);
                    uint nextWord = round(_LayersTex[txNextWord]);
                    int startChar = floor(_LayersTex[txStartChar]);
                    int endChar = floor(_LayersTex[txEndChar]);
                    uint tokenPointer = floor(_LayersTex[txTokenPointer]);
                    uint token = round(_LayersTex[txToken]);
                    float tokenSuccess = _LayersTex[txTokenSuccess];

                    float startBtn = _LayersTex[txStartBtn];

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
                        // measure between spaces, if characters start at 0,
                        // there's a space at -1
                        startChar = -1;
                        endChar = -1;
                        tokenPointer = 0;
                        token = 0;
                        tokenSuccess = 0.0;
                        TLState = ST_NEXTSEQ;
                    }
                    else if (TLState == ST_TOKENIZE)
                    {
                        uint bitField[TOKEN_MAX];
                        for (uint i = 0; i < TOKEN_MAX; i++) bitField[i] = 0;
                        uint c = 0;
                        for (int j = startChar + 1; j < endChar && c < TOKEN_MAX; j++)
                        {
                            bitField[c] = getCharSeq(_LayersTex, j);
                            c++;
                        }
                        uint4 joined = 0;
                        joined.r = (bitField[4] | bitField[3] << 6 | bitField[2] << 12 | bitField[1] << 18 | bitField[0] << 24);
                        joined.g = (bitField[9] | bitField[8] << 6 | bitField[7] << 12 | bitField[6] << 18 | bitField[5] << 24);
                        joined.b = (bitField[14] | bitField[13] << 6 | bitField[12] << 12 | bitField[11] << 18 | bitField[10] << 24);
                        joined.a = (bitField[19] | bitField[18] << 6 | bitField[17] << 12 | bitField[16] << 18 | bitField[15] << 24);

                        int tokenRtn = getToken(_WordTex, joined, bitField[0]);

                        // int2 offs;
                        // offs.x = (18365 % 211) * 2;
                        // offs.y = (18365 / 211) * 2;

                        // uint4 _00 = _WordTex[offs];
                        // uint4 _10 = _WordTex[offs + uint2(1, 0)];
                        // uint4 _01 = _WordTex[offs + uint2(0, 1)];
                        // float val = _WordTex[offs + int2(1, 1)].x;

                        // uint4 word;
                        // word.r = (_00.b >> 6) | (_00.g << 6) | (_00.r << 18);
                        // word.g = _10.r | (_00.a << 12) | (_00.b & 0x3f) << 24;
                        // word.b = (_10.a >> 6) | (_10.b << 6) | (_10.g << 18);
                        // word.a = _01.g | (_01.r << 12) | (_10.a & 0x3f) << 24;

                        // buffer[0] = joined;

                        if (tokenRtn >= 3)
                        {
                            tokenSuccess = 1.0;
                            token = tokenRtn;
                            tokenPointer++;
                        }
                        TLState = ST_NEXTSEQ;
                    }
                    else if (TLState == ST_NEXTSEQ)
                    {
                        tokenSuccess = 0.0;
                        int dist = 0;
                        // at least 1 word between spaces
                        while (dist < 2 && endChar < CHAR_MAX)
                        {
                            startChar = endChar;
                            endChar = endChar + 1;
                            uint word = getCharSeq(_LayersTex, endChar);
                            while (word > 0 && endChar < CHAR_MAX)
                            {
                                endChar++;
                                word = getCharSeq(_LayersTex, endChar);
                            }
                            dist = endChar - startChar;
                        }
                        TLState = (endChar >= CHAR_MAX) ? ST_ENDTOKEN : ST_TOKENIZE;
                    }
                    else if (TLState == ST_ENDTOKEN)
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
                        // go thru encoder all layers, loop MAX_LOOPS times
                        layerCounter = layerCounter + 1;
                        loopCounter = layerCounter >= DEC_LAYERS ?
                            loopCounter + 1 : loopCounter;
                        layerCounter = layerCounter >= DEC_LAYERS ?
                            0 : layerCounter;
                        TLState = loopCounter >= MAX_LOOPS ? ST_DEC_FINAL : ST_DECODER;
                    }
                    else if (TLState == ST_DEC_FINAL)
                    {
                        // run the final dense layer
                        TLState = ST_DEC_OUT;
                    }
                    else if (TLState == ST_DEC_OUT)
                    {
                        // get the output word of highest probability
                        nextWord = getNextWord(_LayersTex, decSeqLen);
                        TLState = (nextWord != 2 && (decSeqLen + 1) <= 22)?
                            ST_DEC_COPY : ST_FINISH;
                    }
                    else if (TLState == ST_FINISH)
                    {
                        TLState = (startBtn > 0.5) ? ST_INPUT : ST_FINISH;
                    }
                    else
                    {
                        TLState = ST_FINISH;
                    }

                    // buffer[0] = float4(
                    //     _LayersTex[layersPos[43] + uint2(2, 0)],
                    //     _LayersTex[layersPos[43] + uint2(2, 1)],
                    //     _LayersTex[layersPos[43] + uint2(2, 2)],
                    //      _LayersTex[txClearBtn]
                    // );

                    // buffer[0] = float4(
                    //     tokenSuccess, tokenPointer, token, TLState
                    // );

                    StoreValue(txTLState,       float(TLState),        col, ipx);
                    StoreValue(txTLPrevState,   float(TLPrevState),    col, ipx);
                    StoreValue(txLayerCounter,  float(layerCounter),   col, ipx);
                    StoreValue(txLoopCounter,   float(loopCounter),    col, ipx);
                    StoreValue(txDecSeqLen,     float(decSeqLen),      col, ipx);
                    StoreValue(txNextWord,      float(nextWord),       col, ipx);
                    StoreValue(txStartChar,     float(startChar),      col, ipx);
                    StoreValue(txEndChar,       float(endChar),        col, ipx);
                    StoreValue(txTokenPointer,  float(tokenPointer),   col, ipx);
                    StoreValue(txToken,         float(token),          col, ipx);
                    StoreValue(txTokenSuccess,  tokenSuccess,          col, ipx);
                }

                return col;
            }
            ENDCG
        }
    }
}
