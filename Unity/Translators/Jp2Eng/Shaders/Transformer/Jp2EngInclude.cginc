#ifndef __JP2ENG__
#define __JP2ENG__

/* Weights */

static const uint4 weightsPos[256] =
{
    0, 0, 0, 0,       // const0
    1536, 3584, 512, 512,       // const1
    6281, 3584, 1, 512,       // const2
    512, 3584, 512, 512,       // const3
    6280, 3584, 1, 512,       // const4
    5632, 3072, 512, 512,       // const5
    6278, 3584, 1, 512,       // const6
    4608, 3072, 512, 512,       // const7
    6276, 3584, 1, 512,       // const8
    7168, 1024, 1024, 512,       // const9
    6145, 0, 1, 1024,       // const10
    5632, 0, 512, 1024,       // const11
    6274, 3584, 1, 512,       // const12
    6272, 3584, 1, 512,       // const13
    6270, 3584, 1, 512,       // const14
    6268, 3584, 1, 512,       // const15
    6266, 3584, 1, 512,       // const16
    7680, 2048, 512, 512,       // const17
    6264, 3584, 1, 512,       // const18
    6656, 2048, 512, 512,       // const19
    6256, 3584, 1, 512,       // const20
    5632, 2048, 512, 512,       // const21
    6255, 3584, 1, 512,       // const22
    5120, 2048, 512, 512,       // const23
    6254, 3584, 1, 512,       // const24
    6156, 512, 1024, 512,       // const25
    6151, 0, 1, 1024,       // const26
    1024, 0, 512, 1024,       // const27
    6252, 3584, 1, 512,       // const28
    6250, 3584, 1, 512,       // const29
    6248, 3584, 1, 512,       // const30
    6246, 3584, 1, 512,       // const31
    6244, 3584, 1, 512,       // const32
    5120, 1536, 512, 512,       // const33
    6242, 3584, 1, 512,       // const34
    4096, 1536, 512, 512,       // const35
    6240, 3584, 1, 512,       // const36
    2560, 1536, 512, 512,       // const37
    6238, 3584, 1, 512,       // const38
    3584, 1536, 512, 512,       // const39
    6230, 3584, 1, 512,       // const40
    0, 1536, 1024, 512,       // const41
    6146, 0, 1, 1024,       // const42
    512, 0, 512, 1024,       // const43
    6229, 3584, 1, 512,       // const44
    6228, 3584, 1, 512,       // const45
    6226, 3584, 1, 512,       // const46
    6224, 3584, 1, 512,       // const47
    6222, 3584, 1, 512,       // const48
    512, 2048, 512, 512,       // const49
    6220, 3584, 1, 512,       // const50
    2560, 3584, 512, 512,       // const51
    6218, 3584, 1, 512,       // const52
    2560, 2048, 512, 512,       // const53
    6216, 3584, 1, 512,       // const54
    3584, 2048, 512, 512,       // const55
    6214, 3584, 1, 512,       // const56
    2048, 1024, 1024, 512,       // const57
    6155, 0, 1, 1024,       // const58
    2048, 0, 512, 1024,       // const59
    6212, 3584, 1, 512,       // const60
    6204, 3584, 1, 512,       // const61
    6203, 3584, 1, 512,       // const62
    6202, 3584, 1, 512,       // const63
    6200, 3584, 1, 512,       // const64
    512, 2560, 512, 512,       // const65
    6198, 3584, 1, 512,       // const66
    1536, 2560, 512, 512,       // const67
    6196, 3584, 1, 512,       // const68
    2560, 2560, 512, 512,       // const69
    6194, 3584, 1, 512,       // const70
    3584, 2560, 512, 512,       // const71
    6192, 3584, 1, 512,       // const72
    6144, 1024, 1024, 512,       // const73
    6147, 0, 1, 1024,       // const74
    4608, 0, 512, 1024,       // const75
    6190, 3584, 1, 512,       // const76
    6188, 3584, 1, 512,       // const77
    6186, 3584, 1, 512,       // const78
    6178, 3584, 1, 512,       // const79
    6177, 3584, 1, 512,       // const80
    512, 3072, 512, 512,       // const81
    6176, 3584, 1, 512,       // const82
    1536, 3072, 512, 512,       // const83
    6174, 3584, 1, 512,       // const84
    2560, 3072, 512, 512,       // const85
    6172, 3584, 1, 512,       // const86
    3584, 3072, 512, 512,       // const87
    6170, 3584, 1, 512,       // const88
    0, 1024, 1024, 512,       // const89
    6152, 0, 1, 1024,       // const90
    2560, 0, 512, 1024,       // const91
    6168, 3584, 1, 512,       // const92
    6166, 3584, 1, 512,       // const93
    6162, 3584, 1, 512,       // const94
    6160, 3584, 1, 512,       // const95
    6159, 3584, 1, 512,       // const96
    0, 0, 0, 0,       // const97
    1024, 3584, 512, 512,       // const98
    6151, 3584, 1, 512,       // const99
    2048, 3584, 512, 512,       // const100
    6150, 3584, 1, 512,       // const101
    3072, 3584, 512, 512,       // const102
    6148, 3584, 1, 512,       // const103
    4096, 3584, 512, 512,       // const104
    6146, 3584, 1, 512,       // const105
    5120, 3584, 512, 512,       // const106
    6144, 3584, 1, 512,       // const107
    5632, 3584, 512, 512,       // const108
    6145, 3584, 1, 512,       // const109
    4608, 3584, 512, 512,       // const110
    6147, 3584, 1, 512,       // const111
    3584, 3584, 512, 512,       // const112
    6149, 3584, 1, 512,       // const113
    3072, 1024, 1024, 512,       // const114
    6148, 0, 1, 1024,       // const115
    1536, 0, 512, 1024,       // const116
    6153, 3584, 1, 512,       // const117
    6154, 3584, 1, 512,       // const118
    6155, 3584, 1, 512,       // const119
    6156, 3584, 1, 512,       // const120
    6157, 3584, 1, 512,       // const121
    6158, 3584, 1, 512,       // const122
    6282, 3584, 1, 512,       // const123
    7680, 3072, 512, 512,       // const124
    6161, 3584, 1, 512,       // const125
    7168, 3072, 512, 512,       // const126
    6163, 3584, 1, 512,       // const127
    0, 3584, 512, 512,       // const128
    6165, 3584, 1, 512,       // const129
    6656, 3072, 512, 512,       // const130
    6167, 3584, 1, 512,       // const131
    6144, 3072, 512, 512,       // const132
    6169, 3584, 1, 512,       // const133
    4096, 3072, 512, 512,       // const134
    6171, 3584, 1, 512,       // const135
    3072, 3072, 512, 512,       // const136
    6173, 3584, 1, 512,       // const137
    2048, 3072, 512, 512,       // const138
    6175, 3584, 1, 512,       // const139
    1024, 1024, 1024, 512,       // const140
    6144, 0, 1, 1024,       // const141
    5120, 0, 512, 1024,       // const142
    6179, 3584, 1, 512,       // const143
    6180, 3584, 1, 512,       // const144
    6181, 3584, 1, 512,       // const145
    6182, 3584, 1, 512,       // const146
    6183, 3584, 1, 512,       // const147
    6184, 3584, 1, 512,       // const148
    6185, 3584, 1, 512,       // const149
    7168, 2560, 512, 512,       // const150
    6187, 3584, 1, 512,       // const151
    6656, 2560, 512, 512,       // const152
    6189, 3584, 1, 512,       // const153
    6144, 2560, 512, 512,       // const154
    6191, 3584, 1, 512,       // const155
    4096, 2560, 512, 512,       // const156
    6193, 3584, 1, 512,       // const157
    3072, 2560, 512, 512,       // const158
    6195, 3584, 1, 512,       // const159
    2048, 2560, 512, 512,       // const160
    6197, 3584, 1, 512,       // const161
    1024, 2560, 512, 512,       // const162
    6199, 3584, 1, 512,       // const163
    0, 2560, 512, 512,       // const164
    6201, 3584, 1, 512,       // const165
    5120, 1024, 1024, 512,       // const166
    6153, 0, 1, 1024,       // const167
    3584, 0, 512, 1024,       // const168
    6205, 3584, 1, 512,       // const169
    6206, 3584, 1, 512,       // const170
    6207, 3584, 1, 512,       // const171
    6208, 3584, 1, 512,       // const172
    6209, 3584, 1, 512,       // const173
    6210, 3584, 1, 512,       // const174
    6211, 3584, 1, 512,       // const175
    6144, 2048, 512, 512,       // const176
    6213, 3584, 1, 512,       // const177
    4096, 2048, 512, 512,       // const178
    6215, 3584, 1, 512,       // const179
    3072, 2048, 512, 512,       // const180
    6217, 3584, 1, 512,       // const181
    2048, 2048, 512, 512,       // const182
    6219, 3584, 1, 512,       // const183
    1024, 2048, 512, 512,       // const184
    6221, 3584, 1, 512,       // const185
    0, 2048, 512, 512,       // const186
    6223, 3584, 1, 512,       // const187
    7680, 1536, 512, 512,       // const188
    6225, 3584, 1, 512,       // const189
    7168, 1536, 512, 512,       // const190
    6227, 3584, 1, 512,       // const191
    4096, 1024, 1024, 512,       // const192
    6149, 0, 1, 1024,       // const193
    4096, 0, 512, 1024,       // const194
    6231, 3584, 1, 512,       // const195
    6232, 3584, 1, 512,       // const196
    6233, 3584, 1, 512,       // const197
    6234, 3584, 1, 512,       // const198
    6235, 3584, 1, 512,       // const199
    6236, 3584, 1, 512,       // const200
    6237, 3584, 1, 512,       // const201
    3072, 1536, 512, 512,       // const202
    6239, 3584, 1, 512,       // const203
    2048, 1536, 512, 512,       // const204
    6241, 3584, 1, 512,       // const205
    4608, 1536, 512, 512,       // const206
    6243, 3584, 1, 512,       // const207
    5632, 1536, 512, 512,       // const208
    6245, 3584, 1, 512,       // const209
    6144, 1536, 512, 512,       // const210
    6247, 3584, 1, 512,       // const211
    6656, 1536, 512, 512,       // const212
    6249, 3584, 1, 512,       // const213
    1536, 2048, 512, 512,       // const214
    6251, 3584, 1, 512,       // const215
    4608, 2048, 512, 512,       // const216
    6253, 3584, 1, 512,       // const217
    1024, 1536, 1024, 512,       // const218
    6154, 0, 1, 1024,       // const219
    3072, 0, 512, 1024,       // const220
    6257, 3584, 1, 512,       // const221
    6258, 3584, 1, 512,       // const222
    6259, 3584, 1, 512,       // const223
    6260, 3584, 1, 512,       // const224
    6261, 3584, 1, 512,       // const225
    6262, 3584, 1, 512,       // const226
    6263, 3584, 1, 512,       // const227
    7168, 2048, 512, 512,       // const228
    6265, 3584, 1, 512,       // const229
    4608, 2560, 512, 512,       // const230
    6267, 3584, 1, 512,       // const231
    5120, 2560, 512, 512,       // const232
    6269, 3584, 1, 512,       // const233
    5632, 2560, 512, 512,       // const234
    6271, 3584, 1, 512,       // const235
    7680, 2560, 512, 512,       // const236
    6273, 3584, 1, 512,       // const237
    0, 3072, 512, 512,       // const238
    6275, 3584, 1, 512,       // const239
    1024, 3072, 512, 512,       // const240
    6277, 3584, 1, 512,       // const241
    5120, 3072, 512, 512,       // const242
    6279, 3584, 1, 512,       // const243
    6156, 0, 1024, 512,       // const244
    6150, 0, 1, 1024,       // const245
    0, 0, 512, 1024,       // const246
    6283, 3584, 1, 512,       // const247
    6284, 3584, 1, 512,       // const248
    6285, 3584, 1, 512,       // const249
    6286, 3584, 1, 512,       // const250
    6164, 3584, 1, 512,       // const251
    6152, 3584, 1, 512,       // const252
    6287, 3584, 1, 512,       // const253
    0, 0, 0, 0,       // const254
    0, 0, 0, 0,       // const255
};

/* Second weights texture */

static const uint4 encodingPos[4] =

{
    0, 5544, 8192, 202,       // const0
    0, 0, 8192, 2772,       // const97
    0, 2772, 8192, 2772,       // const254
    0, 5746, 8192, 6,       // const255
};

/* Outputs */

static const uint4 layersPos[47] =
{
    0, 484, 512, 22,       // 0 encoder lmhaQ
    512, 440, 512, 22,       // 1 encoder lmhaK
    0, 440, 512, 22,       // 2 encoder lmhaV
    302, 0, 22, 176,       // 3 encoder lsatQK
    192, 0, 22, 176,       // 4 encoder lsoft
    128, 0, 64, 176,       // 5 encoder lsatSV
    0, 352, 512, 22,       // 6 encoder lmhaO
    568, 484, 1, 22,       // 7 encoder lmean1
    567, 484, 1, 22,       // 8 encoder lvar1
    0, 330, 512, 22,       // 9 encoder lnorm1
    0, 220, 1024, 22,       // 10 encoder lffn1
    512, 286, 512, 22,       // 11 encoder lffn2
    566, 484, 1, 22,       // 12 encoder lmean2
    563, 484, 1, 22,       // 13 encoder lvar2
    0, 286, 512, 22,       // 14 encoder lnorm2
    0, 462, 512, 22,       // 15 decoder lmha1Q
    0, 308, 512, 22,       // 16 decoder lmha1K
    512, 308, 512, 22,       // 17 decoder lmha1V
    258, 0, 22, 176,       // 18 decoder lsat1QK
    280, 0, 22, 176,       // 19 decoder lsoft1
    64, 0, 64, 176,       // 20 decoder lsat1SV
    512, 352, 512, 22,       // 21 decoder lmha1O
    0, 374, 512, 22,       // 22 decoder lnorm1
    571, 484, 1, 22,       // 23 decoder lmean1
    562, 484, 1, 22,       // 24 decoder lvar1
    512, 396, 512, 22,       // 25 decoder lmha2Q
    0, 418, 512, 22,       // 26 decoder lmha2K
    512, 418, 512, 22,       // 27 decoder lmha2V
    214, 0, 22, 176,       // 28 decoder lsat2QK
    236, 0, 22, 176,       // 29 decoder lsoft2
    0, 0, 64, 176,       // 30 decoder lsat2SV
    512, 462, 512, 22,       // 31 decoder lmha2O
    512, 374, 512, 22,       // 32 decoder lnorm2
    561, 484, 1, 22,       // 33 decoder lmean2
    569, 484, 1, 22,       // 34 decoder lvar2
    0, 242, 1024, 22,       // 35 decoder lffn1
    0, 396, 512, 22,       // 36 decoder lffn2
    512, 264, 512, 22,       // 37 decoder lnorm3
    564, 484, 1, 22,       // 38 decoder lmean3
    565, 484, 1, 22,       // 39 decoder lvar3
    0, 264, 512, 22,       // 40 encoder in
    512, 330, 512, 22,       // 41 decoder in
    0, 176, 1024, 44,       // 42 final out
    556, 484, 5, 22,       // 43 encoder_sentence
    570, 484, 1, 22,       // 44 decoder_sentence
    512, 484, 44, 22,       // 45 masks
    572, 484, 16, 8,       // 46 output render buffer
};

#define mod(x,y) ((x)-(y)*floor((x)/(y))) // glsl mod
#define epsilon 1.0e-6

#define sc_uint2 static const uint2

#define TOKEN_MAX                20

float relu(float x)
{
    return x > 0.0 ? x : 0.0;
}

inline bool insideArea(in uint4 area, uint2 px)
{
    if (px.x >= area.x && px.x < (area.x + area.z) &&
        px.y >= area.y && px.y < (area.y + area.w))
    {
        return true;
    }
    return false;
}

void StoreValue(in uint2 txPos, in float value, inout float col,
    in uint2 fragPos)
{
    col = all(fragPos == txPos) ? value : col;
}

float posEncoding(uint pos, uint i, float d_model)
{
    float angle_rates = 1.0f / pow(10000.0f, 2 * (i / 2) / d_model) * pos;
    float encode = i % 2 == 0 ? sin(angle_rates) : cos(angle_rates);
    return encode;
}

float getWordJp(Texture2D<float> tex, uint off)
{
    uint2 pos = layersPos[43].xy;
    return tex[pos + uint2(2, off)];
}

float getWordEng(Texture2D<float> tex, uint off)
{
    uint2 pos = layersPos[44].xy;
    return tex[pos + uint2(0, off)];
}

float getEncoderMask(Texture2D<float> tex, uint2 off)
{
    return tex[layersPos[45].xy + off.yx];
}

float getDecoderMask(Texture2D<float> tex, uint2 off)
{
    return tex[layersPos[45].xy + uint2(22, 0) + off.yx];
}

float getEmbeddingEng(Texture2D<float> tex, uint2 off)
{
    uint2 pos;
    pos.x = (off.x % 16) * 512 + off.y;
    pos.y = off.x / 16;
    return tex[encodingPos[1].xy + pos];
}

float getEmbeddingJp(Texture2D<float> tex, uint2 off)
{
    uint2 pos;
    pos.x = (off.x % 16) * 512 + off.y;
    pos.y = off.x / 16;
    return tex[encodingPos[0].xy + pos];
}

float getSplitHeads(Texture2D<float> tex, uint ID, uint3 i)
{
    uint2 pos = uint2(i.y, i.x * 64 + i.z);
    return tex[layersPos[ID].xy + pos.yx];
}

float getConst(Texture2D<float> tex, uint ID, uint2 off)
{
    return tex[weightsPos[ID].xy + off.yx];
}

float getWeightsFinal(Texture2D<float> tex, uint2 off)
{
    uint2 pos;
    pos.x = (off.y % 16) * 512 + off.x;
    pos.y = off.y / 16;
    return tex[encodingPos[2].xy + pos];
}

float getBiasFinal(Texture2D<float> tex, uint off)
{
    uint2 pos;
    pos.x = off % 8192;
    pos.y = off / 8192;
    return tex[encodingPos[3].xy + pos];
}

float getLayer(Texture2D<float> tex, uint ID, uint2 off)
{
    return tex[layersPos[ID].xy + off.yx];
}

float getLayer(Texture2D<float> tex, uint ID, uint3 off)
{
    uint2 pos;
    pos.x = off.z;
    pos.y = off.y + off.x * 22;
    return tex[layersPos[ID].xy + pos.xy];
}

float getSAT(Texture2D<float> tex, uint ID, uint2 i)
{
    uint x = i.x;
    uint y = i.y / 64;
    uint z = i.y % 64;
    return getLayer(tex, ID, uint3(y, x, z));
}

uint decoderSeqLen(Texture2D<float> tex)
{
    uint2 pos = layersPos[44].xy;
    uint i = 0;
    float word = 1.0;
    for (; i < 22; i++)
    {
        word = floor(tex[pos + uint2(0, i)]);
        if (abs(word) < 0.0001) break;
    }
    return i;
}

float getFinalDense(Texture2D<float> tex, uint off)
{
    uint2 pos;
    pos.x = off % 1024;
    pos.y = off / 1024;
    return tex[layersPos[42].xy + pos];
}

uint getNextWord(Texture2D<float> tex)
{
    uint id = 0;
    float best = getFinalDense(tex, id);
    for (uint i = 0; i < 44337; i++)
    {
        float cur = getFinalDense(tex, i);
        id = best < cur ? i : id;
        best = best < cur ? cur : best;
    }
    return id;
}

float getWordLen(Texture2D<float4> tex, uint nextWord)
{
    uint2 pos;
    pos.x = (nextWord % 211) * 2 + 1;
    pos.y = (nextWord / 211) * 2 + 1;
    return tex[pos].r;
}

void getWordChars(Texture2D<float4> tex, uint nextWord, inout uint bitField[TOKEN_MAX])
{
    uint2 pos;
    pos.x = (nextWord % 211) * 2;
    pos.y = (nextWord / 211) * 2;

    uint4 _00 = round(tex[pos]);
    uint4 _10 = round(tex[pos + uint2(1, 0)]);
    uint4 _01 = round(tex[pos + uint2(0, 1)]);

    bitField[0] = _00.r >> 6;
    bitField[1] = _00.r & 0x3F;
    bitField[2] = _00.g >> 6;
    bitField[3] = _00.g & 0x3F;
    bitField[4] = _00.b >> 6;
    bitField[5] = _00.b & 0x3F;
    bitField[6] = _00.a >> 6;
    bitField[7] = _00.a & 0x3F;

    bitField[8] = _10.r >> 6;
    bitField[9] = _10.r & 0x3F;
    bitField[10] = _10.g >> 6;
    bitField[11] = _10.g & 0x3F;
    bitField[12] = _10.b >> 6;
    bitField[13] = _10.b & 0x3F;
    bitField[14] = _10.a >> 6;
    bitField[15] = _10.a & 0x3F;

    bitField[16] = _01.r >> 6;
    bitField[17] = _01.r & 0x3F;
    bitField[18] = _01.g >> 6;
    bitField[19] = _01.g & 0x3F;
}

uint getCharSeq(Texture2D<float> tex, uint word)
{
    uint2 pos;
    pos.x = word % 16;
    pos.y = word / 16;
    return tex[layersPos[46].xy + pos];
}

/*
    Network state
*/

sc_uint2 txTLState = layersPos[43].xy + uint2(3, 0);
sc_uint2 txTLPrevState = layersPos[43].xy + uint2(3, 1);
sc_uint2 txLayerCounter = layersPos[43].xy + uint2(3, 2);
sc_uint2 txLoopCounter = layersPos[43].xy + uint2(3, 3);
sc_uint2 txDecSeqLen = layersPos[43].xy + uint2(3, 4);
sc_uint2 txNextWord = layersPos[43].xy + uint2(3, 5);
sc_uint2 txOutPos = layersPos[43].xy + uint2(3, 6);
sc_uint2 txOutLen = layersPos[43].xy + uint2(3, 7);

#define ST_INPUT                 0
#define ST_ENC_EMBED             1
#define ST_ENCODER               2
#define ST_DEC_COPY              3
#define ST_DEC_SEQ               4
#define ST_DEC_EMBED             5
#define ST_DECODER               6
#define ST_DEC_FINAL             7
#define ST_DEC_OUT               8
#define ST_FINISH                9
#define ST_TOKENIZE              10
#define ST_CONVERT               11
#define ST_UPDATE_POS            12

#define ENC_LAYERS               14
#define DEC_LAYERS               22
#define MAX_LOOPS                6

// Convmixer defines

sc_uint2 txVBtnSel = uint2(114, 1297) + uint2(0, 0);
sc_uint2 txVBtnState = uint2(114, 1297) + uint2(1, 0);
sc_uint2 txVBtnEnter = uint2(114, 1297) + uint2(2, 0);

#define HAND_IDLE           0
#define HAND_DOWN           1
#define HAND_UP             2

#endif