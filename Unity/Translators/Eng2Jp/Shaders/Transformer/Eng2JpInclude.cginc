#ifndef __ENG2JP__
#define __ENG2JP__

/* Weights */

static const uint4 weightsPos[256] =
{
    0, 0, 3072, 7390,       // const0
    3584, 6656, 512, 512,       // const1
    5137, 7168, 1, 512,       // const2
    3584, 7168, 512, 512,       // const3
    5262, 7168, 1, 512,       // const4
    6656, 6656, 512, 512,       // const5
    5254, 7168, 1, 512,       // const6
    4608, 6144, 512, 512,       // const7
    5253, 7168, 1, 512,       // const8
    4609, 3072, 1024, 512,       // const9
    7686, 0, 1, 1024,       // const10
    3585, 1024, 512, 1024,       // const11
    5252, 7168, 1, 512,       // const12
    5250, 7168, 1, 512,       // const13
    5248, 7168, 1, 512,       // const14
    5246, 7168, 1, 512,       // const15
    5244, 7168, 1, 512,       // const16
    6144, 5632, 512, 512,       // const17
    5242, 7168, 1, 512,       // const18
    6144, 5120, 512, 512,       // const19
    5240, 7168, 1, 512,       // const20
    3072, 5120, 512, 512,       // const21
    5238, 7168, 1, 512,       // const22
    6144, 4608, 512, 512,       // const23
    5236, 7168, 1, 512,       // const24
    5633, 3072, 1024, 512,       // const25
    7692, 0, 1, 1024,       // const26
    3585, 0, 512, 1024,       // const27
    5228, 7168, 1, 512,       // const28
    5227, 7168, 1, 512,       // const29
    5226, 7168, 1, 512,       // const30
    5224, 7168, 1, 512,       // const31
    5222, 7168, 1, 512,       // const32
    6656, 4096, 512, 512,       // const33
    5220, 7168, 1, 512,       // const34
    7680, 3584, 512, 512,       // const35
    5218, 7168, 1, 512,       // const36
    5632, 3584, 512, 512,       // const37
    5216, 7168, 1, 512,       // const38
    4608, 3584, 512, 512,       // const39
    5214, 7168, 1, 512,       // const40
    3072, 3584, 1024, 512,       // const41
    7687, 0, 1, 1024,       // const42
    4097, 0, 512, 1024,       // const43
    5212, 7168, 1, 512,       // const44
    5210, 7168, 1, 512,       // const45
    5202, 7168, 1, 512,       // const46
    5201, 7168, 1, 512,       // const47
    5200, 7168, 1, 512,       // const48
    3584, 4096, 512, 512,       // const49
    5198, 7168, 1, 512,       // const50
    4608, 4096, 512, 512,       // const51
    5196, 7168, 1, 512,       // const52
    5632, 4096, 512, 512,       // const53
    5194, 7168, 1, 512,       // const54
    7680, 6656, 512, 512,       // const55
    5192, 7168, 1, 512,       // const56
    4609, 2560, 1024, 512,       // const57
    7690, 0, 1, 1024,       // const58
    5121, 1024, 512, 1024,       // const59
    5190, 7168, 1, 512,       // const60
    5188, 7168, 1, 512,       // const61
    5186, 7168, 1, 512,       // const62
    5184, 7168, 1, 512,       // const63
    5176, 7168, 1, 512,       // const64
    6656, 4608, 512, 512,       // const65
    5175, 7168, 1, 512,       // const66
    7680, 4608, 512, 512,       // const67
    5174, 7168, 1, 512,       // const68
    3584, 5120, 512, 512,       // const69
    5172, 7168, 1, 512,       // const70
    4608, 5120, 512, 512,       // const71
    5170, 7168, 1, 512,       // const72
    6814, 1024, 1024, 512,       // const73
    7685, 0, 1, 1024,       // const74
    4097, 1024, 512, 1024,       // const75
    5168, 7168, 1, 512,       // const76
    5166, 7168, 1, 512,       // const77
    5164, 7168, 1, 512,       // const78
    5162, 7168, 1, 512,       // const79
    5160, 7168, 1, 512,       // const80
    4608, 5632, 512, 512,       // const81
    5158, 7168, 1, 512,       // const82
    5632, 5632, 512, 512,       // const83
    5150, 7168, 1, 512,       // const84
    6656, 5632, 512, 512,       // const85
    5149, 7168, 1, 512,       // const86
    7680, 5632, 512, 512,       // const87
    5148, 7168, 1, 512,       // const88
    3585, 2560, 1024, 512,       // const89
    7683, 0, 1, 1024,       // const90
    5633, 0, 512, 1024,       // const91
    5146, 7168, 1, 512,       // const92
    5144, 7168, 1, 512,       // const93
    5142, 7168, 1, 512,       // const94
    5140, 7168, 1, 512,       // const95
    5138, 7168, 1, 512,       // const96
    3072, 0, 512, 3229,       // const97
    3072, 6656, 512, 512,       // const98
    5136, 7168, 1, 512,       // const99
    4096, 6656, 512, 512,       // const100
    5134, 7168, 1, 512,       // const101
    5120, 6656, 512, 512,       // const102
    5132, 7168, 1, 512,       // const103
    6144, 6656, 512, 512,       // const104
    5124, 7168, 1, 512,       // const105
    7168, 6656, 512, 512,       // const106
    5123, 7168, 1, 512,       // const107
    3072, 7168, 512, 512,       // const108
    5122, 7168, 1, 512,       // const109
    4096, 7168, 512, 512,       // const110
    5120, 7168, 1, 512,       // const111
    4608, 7168, 512, 512,       // const112
    5121, 7168, 1, 512,       // const113
    5633, 2560, 1024, 512,       // const114
    7691, 0, 1, 1024,       // const115
    4609, 0, 512, 1024,       // const116
    5125, 7168, 1, 512,       // const117
    5126, 7168, 1, 512,       // const118
    5127, 7168, 1, 512,       // const119
    5128, 7168, 1, 512,       // const120
    5129, 7168, 1, 512,       // const121
    5130, 7168, 1, 512,       // const122
    5131, 7168, 1, 512,       // const123
    5632, 6656, 512, 512,       // const124
    5133, 7168, 1, 512,       // const125
    4608, 6656, 512, 512,       // const126
    5135, 7168, 1, 512,       // const127
    7680, 6144, 512, 512,       // const128
    5263, 7168, 1, 512,       // const129
    7168, 6144, 512, 512,       // const130
    5139, 7168, 1, 512,       // const131
    6656, 6144, 512, 512,       // const132
    5141, 7168, 1, 512,       // const133
    6144, 6144, 512, 512,       // const134
    5143, 7168, 1, 512,       // const135
    5632, 6144, 512, 512,       // const136
    5145, 7168, 1, 512,       // const137
    5120, 6144, 512, 512,       // const138
    5147, 7168, 1, 512,       // const139
    6814, 1536, 1024, 512,       // const140
    7682, 0, 1, 1024,       // const141
    4609, 1024, 512, 1024,       // const142
    5151, 7168, 1, 512,       // const143
    5152, 7168, 1, 512,       // const144
    5153, 7168, 1, 512,       // const145
    5154, 7168, 1, 512,       // const146
    5155, 7168, 1, 512,       // const147
    5156, 7168, 1, 512,       // const148
    5157, 7168, 1, 512,       // const149
    5120, 5632, 512, 512,       // const150
    5159, 7168, 1, 512,       // const151
    4096, 5632, 512, 512,       // const152
    5161, 7168, 1, 512,       // const153
    3584, 5632, 512, 512,       // const154
    5163, 7168, 1, 512,       // const155
    3072, 5632, 512, 512,       // const156
    5165, 7168, 1, 512,       // const157
    7680, 5120, 512, 512,       // const158
    5167, 7168, 1, 512,       // const159
    7168, 5120, 512, 512,       // const160
    5169, 7168, 1, 512,       // const161
    5120, 5120, 512, 512,       // const162
    5171, 7168, 1, 512,       // const163
    4096, 5120, 512, 512,       // const164
    5173, 7168, 1, 512,       // const165
    6657, 3072, 1024, 512,       // const166
    7688, 0, 1, 1024,       // const167
    6145, 0, 512, 1024,       // const168
    5177, 7168, 1, 512,       // const169
    5178, 7168, 1, 512,       // const170
    5179, 7168, 1, 512,       // const171
    5180, 7168, 1, 512,       // const172
    5181, 7168, 1, 512,       // const173
    5182, 7168, 1, 512,       // const174
    5183, 7168, 1, 512,       // const175
    5632, 4608, 512, 512,       // const176
    5185, 7168, 1, 512,       // const177
    5120, 4608, 512, 512,       // const178
    5187, 7168, 1, 512,       // const179
    4608, 4608, 512, 512,       // const180
    5189, 7168, 1, 512,       // const181
    4096, 4608, 512, 512,       // const182
    5191, 7168, 1, 512,       // const183
    7168, 4096, 512, 512,       // const184
    5193, 7168, 1, 512,       // const185
    6144, 4096, 512, 512,       // const186
    5195, 7168, 1, 512,       // const187
    5120, 4096, 512, 512,       // const188
    5197, 7168, 1, 512,       // const189
    4096, 4096, 512, 512,       // const190
    5199, 7168, 1, 512,       // const191
    6657, 2560, 1024, 512,       // const192
    7684, 0, 1, 1024,       // const193
    6657, 0, 512, 1024,       // const194
    5203, 7168, 1, 512,       // const195
    5204, 7168, 1, 512,       // const196
    5205, 7168, 1, 512,       // const197
    5206, 7168, 1, 512,       // const198
    5207, 7168, 1, 512,       // const199
    5208, 7168, 1, 512,       // const200
    5209, 7168, 1, 512,       // const201
    6656, 3584, 512, 512,       // const202
    5211, 7168, 1, 512,       // const203
    6144, 3584, 512, 512,       // const204
    5213, 7168, 1, 512,       // const205
    4096, 3584, 512, 512,       // const206
    5215, 7168, 1, 512,       // const207
    5120, 3584, 512, 512,       // const208
    5217, 7168, 1, 512,       // const209
    7168, 3584, 512, 512,       // const210
    5219, 7168, 1, 512,       // const211
    3072, 4096, 512, 512,       // const212
    5221, 7168, 1, 512,       // const213
    7680, 4096, 512, 512,       // const214
    5223, 7168, 1, 512,       // const215
    3072, 4608, 512, 512,       // const216
    5225, 7168, 1, 512,       // const217
    6814, 2048, 1024, 512,       // const218
    7681, 0, 1, 1024,       // const219
    7169, 0, 512, 1024,       // const220
    5229, 7168, 1, 512,       // const221
    5230, 7168, 1, 512,       // const222
    5231, 7168, 1, 512,       // const223
    5232, 7168, 1, 512,       // const224
    5233, 7168, 1, 512,       // const225
    5234, 7168, 1, 512,       // const226
    5235, 7168, 1, 512,       // const227
    3584, 4608, 512, 512,       // const228
    5237, 7168, 1, 512,       // const229
    7168, 4608, 512, 512,       // const230
    5239, 7168, 1, 512,       // const231
    5632, 5120, 512, 512,       // const232
    5241, 7168, 1, 512,       // const233
    6656, 5120, 512, 512,       // const234
    5243, 7168, 1, 512,       // const235
    7168, 5632, 512, 512,       // const236
    5245, 7168, 1, 512,       // const237
    3072, 6144, 512, 512,       // const238
    5247, 7168, 1, 512,       // const239
    3584, 6144, 512, 512,       // const240
    5249, 7168, 1, 512,       // const241
    4096, 6144, 512, 512,       // const242
    5251, 7168, 1, 512,       // const243
    3585, 3072, 1024, 512,       // const244
    7689, 0, 1, 1024,       // const245
    5121, 0, 512, 1024,       // const246
    5255, 7168, 1, 512,       // const247
    5256, 7168, 1, 512,       // const248
    5257, 7168, 1, 512,       // const249
    5258, 7168, 1, 512,       // const250
    5259, 7168, 1, 512,       // const251
    5260, 7168, 1, 512,       // const252
    5261, 7168, 1, 512,       // const253
    3585, 2048, 3229, 512,       // const254
    3584, 0, 1, 3229       // const255
};

/* Outputs */

static const uint4 layersPos[47] =
{
    0, 549, 512, 22,       // 0 encoder lmhaQ
    512, 505, 512, 22,       // 1 encoder lmhaK
    0, 505, 512, 22,       // 2 encoder lmhaV
    477, 0, 22, 176,       // 3 encoder lsatQK
    587, 0, 22, 176,       // 4 encoder lsoft
    413, 0, 64, 176,       // 5 encoder lsatSV
    0, 417, 512, 22,       // 6 encoder lmhaO
    568, 549, 1, 22,       // 7 encoder lmean1
    567, 549, 1, 22,       // 8 encoder lvar1
    0, 395, 512, 22,       // 9 encoder lnorm1
    0, 285, 1024, 22,       // 10 encoder lffn1
    512, 351, 512, 22,       // 11 encoder lffn2
    566, 549, 1, 22,       // 12 encoder lmean2
    563, 549, 1, 22,       // 13 encoder lvar2
    0, 351, 512, 22,       // 14 encoder lnorm2
    0, 527, 512, 22,       // 15 decoder lmha1Q
    0, 373, 512, 22,       // 16 decoder lmha1K
    512, 373, 512, 22,       // 17 decoder lmha1V
    565, 0, 22, 176,       // 18 decoder lsat1QK
    543, 0, 22, 176,       // 19 decoder lsoft1
    349, 0, 64, 176,       // 20 decoder lsat1SV
    512, 417, 512, 22,       // 21 decoder lmha1O
    0, 439, 512, 22,       // 22 decoder lnorm1
    571, 549, 1, 22,       // 23 decoder lmean1
    562, 549, 1, 22,       // 24 decoder lvar1
    512, 461, 512, 22,       // 25 decoder lmha2Q
    0, 483, 512, 22,       // 26 decoder lmha2K
    512, 483, 512, 22,       // 27 decoder lmha2V
    499, 0, 22, 176,       // 28 decoder lsat2QK
    521, 0, 22, 176,       // 29 decoder lsoft2
    285, 0, 64, 176,       // 30 decoder lsat2SV
    512, 527, 512, 22,       // 31 decoder lmha2O
    512, 439, 512, 22,       // 32 decoder lnorm2
    561, 549, 1, 22,       // 33 decoder lmean2
    569, 549, 1, 22,       // 34 decoder lvar2
    0, 307, 1024, 22,       // 35 decoder lffn1
    0, 461, 512, 22,       // 36 decoder lffn2
    512, 329, 512, 22,       // 37 decoder lnorm3
    564, 549, 1, 22,       // 38 decoder lmean3
    565, 549, 1, 22,       // 39 decoder lvar3
    0, 329, 512, 22,       // 40 encoder in
    512, 395, 512, 22,       // 41 decoder in
    0, 0, 285, 285,       // 42 final out
    556, 549, 5, 22,       // 43 encoder_sentence
    570, 549, 1, 22,       // 44 decoder_sentence
    512, 549, 44, 22,       // 45 masks
    572, 549, 16, 16,       // 46 keyboard_input
};

#define mod(x,y) ((x)-(y)*floor((x)/(y))) // glsl mod
#define epsilon 1.0e-6

#define sc_uint2 static const uint2

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

float getWordEng(Texture2D<float> tex, uint off)
{
    uint2 pos = layersPos[43].xy;
    return tex[pos + uint2(2, off)];
}

float getWordJp(Texture2D<float> tex, uint off)
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
    pos.y = off.x / 6;
    pos.x = off.y + (off.x % 6) * 512;
    return tex[weightsPos[0].xy + pos];
}

float getEmbeddingJp(Texture2D<float> tex, uint2 off)
{
    return tex[weightsPos[97].xy + off.yx];
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

float getFinalDense(Texture2D<float> tex, uint2 off)
{
    uint2 pos;
    pos.x = (off.x % 57) + (off.y % 5) * 57;
    pos.y = (off.x / 57) + (off.y / 5) * 57;
    return tex[layersPos[42].xy + pos];
}

uint getNextWord(Texture2D<float> tex, uint seqLen)
{
    uint id = 0;
    float best = getFinalDense(tex, uint2(id, seqLen - 1));
    for (uint i = 0; i < 3229; i++)
    {
        float cur = getFinalDense(tex, uint2(i, seqLen - 1));
        id = best < cur ? i : id;
        best = best < cur ? cur : best;
    }
    return id;
}

/* Keyboard input state */

sc_uint2 txPointer = layersPos[46].xy + uint2(0, 7);
sc_uint2 txInputState = layersPos[46].xy + uint2(1, 7);
sc_uint2 txPosX = layersPos[46].xy + uint2(2, 7);
sc_uint2 txPosY = layersPos[46].xy + uint2(3, 7);
sc_uint2 txCount = layersPos[46].xy + uint2(4, 7);
sc_uint2 txEnter = layersPos[46].xy + uint2(5, 7);
sc_uint2 txStartBtn = layersPos[46].xy + uint2(6, 7);
sc_uint2 txClearBtn = layersPos[46].xy + uint2(7, 7);

#define INPUT_THRESHOLD         15
#define CHAR_MAX                80
#define TOKEN_MAX               20
#define KEY_IDLE                0
#define KEY_DOWN                1
#define KEY_UP                  2

// Keyboard input to character index mapping
// Special commands are >= 100

static const float charMapping[50] =
{
    -1,                             // empty
    0, 0, 0, 0, 0, 0, 0,            // space bar
    -1, -1,                         // empty
    102, // clear
    38, // z
    36, // x
    15, // c
    34, // v
    14, // b
    26, // n
    25, // m
    100, // backspace
    101, // return
    13, // a
    31, // s
    16, // d
    18, // f
    19, // g
    20, // h
    22, // j
    23, // k
    24, // l
    1, // '
    29, // q
    35, // w
    17, // e
    30, // r
    32, // t
    37, // y
    33, // u
    21, // i
    27, // o
    28, // p
    3, // 1
    4, // 2
    5, // 3
    6, // 4
    7, // 5
    8, // 6
    9, // 7
    10, // 8
    11, // 9
    2 // 0
};

float getCharMap(uint2 px)
{
    return charMapping[px.x + px.y * 10];
}

// Starting index of the baked lookup map
// for every character
// -1 = no word starts with that character

static const int wordSearchIndex[40] =
{
    -1,     // 
    -1,     // '
    0,      // 0
    25,     // 1
    367,    // 2
    500,    // 3
    578,    // 4
    631,    // 5
    678,    // 6
    720,    // 7
    770,    // 8
    807,    // 9
    -1,     // _
    849,    // a
    3689,   // b
    6192,   // c
    10095,  // d
    12634,  // e
    14443,  // f
    16220,  // g
    17676,  // h
    19365,  // i
    21139,  // j
    21644,  // k
    22345,  // l
    23696,  // m
    26307,  // n
    27315,  // o
    28372,  // p
    31596,  // q
    31790,  // r
    34182,  // s
    38875,  // t
    41130,  // u
    42045,  // v
    42716,  // w
    43882,  // x
    43927,  // y
    44187,  // z
    44335   // end
};

// Converts a string of characters into a token from the known
// vocabulary

int getToken(Texture2D<float4> tex, uint4 input, uint firstChar)
{
    int start = wordSearchIndex[firstChar];
    if (start == -1) return -1;  // skip puntuation index
    int end = wordSearchIndex[firstChar + 1];
    end = end == -1 ? wordSearchIndex[firstChar + 2] : end; // skip puntuation index

    int token = -1.0;
    for (int i = start; i < end; i++)
    {
        int2 offs;
        offs.x = (i % 211) * 2;
        offs.y = (i / 211) * 2;

        uint4 _00 = round(tex[offs]);
        uint4 _10 = round(tex[offs + uint2(1, 0)]);
        uint4 _01 = round(tex[offs + uint2(0, 1)]);

        // pack it together for comparison
        uint4 word;
        word.r = (_00.b >> 6) | (_00.g << 6) | (_00.r << 18);
        word.g = _10.r | (_00.a << 12) | (_00.b & 0x3f) << 24;
        word.b = (_10.a >> 6) | (_10.b << 6) | (_10.g << 18);
        word.a = _01.g | (_01.r << 12) | (_10.a & 0x3f) << 24;

        // found a token
        if (all((word ^ input) == 0))
        {
            token = tex[offs + int2(1, 1)];
            break;
        }
    }

    return round(token);
}

uint getCharSeq(Texture2D<float> tex, int x)
{
    int2 offset;
    offset.x = x % 16;
    offset.y = x / 16;
    return round(tex[layersPos[46].xy + offset]);
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
sc_uint2 txStartChar = layersPos[43].xy + uint2(3, 6);
sc_uint2 txEndChar = layersPos[43].xy + uint2(3, 7);
sc_uint2 txTokenPointer = layersPos[43].xy + uint2(3, 8);
sc_uint2 txToken = layersPos[43].xy + uint2(3, 9);
sc_uint2 txTokenSuccess = layersPos[43].xy + uint2(3, 10);

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
#define ST_NEXTSEQ               11
#define ST_ENDTOKEN              12

#define ENC_LAYERS               14
#define DEC_LAYERS               22
#define MAX_LOOPS                6

#endif