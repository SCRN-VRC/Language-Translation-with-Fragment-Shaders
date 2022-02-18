#ifndef __CONVMIXER__
#define __CONVMIXER__

#define mod(x,y) ((x)-(y)*floor((x)/(y))) // glsl mod
#define eps 0.001
#define MIN_FLOAT -1e6f

/* Weights */

static const uint4 weightsPos[56] =
{
    633, 563, 144, 4,       // const0
    576, 581, 144, 1,       // const1
    576, 579, 144, 1,       // const2
    576, 577, 144, 1,       // const3
    576, 575, 144, 1,       // const4
    576, 573, 144, 1,       // const5
    777, 538, 144, 25,       // const6
    720, 572, 144, 1,       // const7
    576, 571, 144, 1,       // const8
    777, 568, 144, 1,       // const9
    777, 564, 144, 1,       // const10
    777, 563, 144, 1,       // const11
    432, 513, 144, 144,       // const12
    777, 565, 144, 1,       // const13
    777, 566, 144, 1,       // const14
    633, 567, 144, 1,       // const15
    777, 567, 144, 1,       // const16
    633, 568, 144, 1,       // const17
    633, 538, 144, 25,       // const18
    633, 569, 144, 1,       // const19
    777, 569, 144, 1,       // const20
    576, 570, 144, 1,       // const21
    720, 570, 144, 1,       // const22
    864, 570, 144, 1,       // const23
    144, 513, 144, 144,       // const24
    720, 571, 144, 1,       // const25
    864, 571, 144, 1,       // const26
    576, 572, 144, 1,       // const27
    720, 581, 144, 1,       // const28
    864, 572, 144, 1,       // const29
    633, 513, 144, 25,       // const30
    720, 573, 144, 1,       // const31
    864, 573, 144, 1,       // const32
    576, 574, 144, 1,       // const33
    720, 574, 144, 1,       // const34
    864, 574, 144, 1,       // const35
    288, 513, 144, 144,       // const36
    720, 575, 144, 1,       // const37
    864, 575, 144, 1,       // const38
    576, 576, 144, 1,       // const39
    720, 576, 144, 1,       // const40
    864, 576, 144, 1,       // const41
    777, 513, 144, 25,       // const42
    720, 577, 144, 1,       // const43
    864, 577, 144, 1,       // const44
    576, 578, 144, 1,       // const45
    720, 578, 144, 1,       // const46
    864, 578, 144, 1,       // const47
    0, 513, 144, 144,       // const48
    720, 579, 144, 1,       // const49
    864, 579, 144, 1,       // const50
    576, 580, 144, 1,       // const51
    720, 580, 144, 1,       // const52
    864, 580, 144, 1,       // const53
    0, 0, 969, 513,       // const54
    576, 513, 57, 57       // const55
};

/* Outputs */

static const uint4 layersPos[13] =
{
    0, 0, 1024, 144,       // l0
    0, 144, 1024, 144,       // l1
    0, 288, 1024, 144,       // l2
    0, 432, 1024, 144,       // l3
    0, 576, 1024, 144,       // l4
    0, 720, 1024, 144,       // l5
    0, 864, 1024, 144,       // l6
    0, 1008, 1024, 144,       // l7
    0, 1152, 1024, 144,       // l8
    114, 1296, 144, 1,       // l9
    0, 1296, 57, 57,       // l10
    57, 1296, 57, 57,       // l11
    114, 1297, 4, 4,       // button input controller
};

// float testGen(uint3 pos, float2 size)
// {
//     float r;
//     size = size - 1;
//     if (pos.x > size.x || pos.y > size.y) return 0.0;
//     if (pos.z == 0)
//         r = (pos.x / size.x) * (pos.y / (size.y * 0.5));
//     else if (pos.z == 1)
//         r = ((size.x - pos.x) / size.x) * (pos.y /  size.y);
//     else
//         r = (pos.x / size.x) * ((size.y - pos.y) /  size.y);
//     return r;
// }

// https://www.johndcook.com/blog/cpp_erf/
float ERF(float x)
{
    // constants
    static const float a1 = 0.254829592;
    static const float a2 = -0.284496736;
    static const float a3 = 1.421413741;
    static const float a4 = -1.453152027;
    static const float a5 = 1.061405429;
    static const float p = 0.3275911;

    // Save the sign of x
    int sign = (x < 0) ? -1 : 1;
    x = abs(x);

    // A&S formula 7.1.26
    float t = 1.0 / (1.0 + p * x);
    float y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * exp(-x * x);

    return sign * y;
}

float GELU(float x)
{
    // poly approx
    return 0.5 * x * (1.0 + ERF(x / 1.4142135624));
}

float batchNorm(float x, float gamma, float beta, float mean, float var)
{
    //z1_hat = (x - pop_mean) / sqrt(pop_var + epsilon)
    //  BN1 = gamma * z1_hat + beta
    return ((x - mean) / sqrt(var + eps)) * gamma + beta;
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

float getLayer(Texture2D<float> tex, uint ID, uint3 input)
{
    uint2 pos;
    pos.x = input.x + input.y * 32;
    pos.y = input.z;
    return tex[layersPos[ID].xy + pos];
}

float padLayerEven(Texture2D<float> tex, uint ID, uint3 input, uint2 maxIn)
{
    input.xy -= 2;
    if (any(input.xy >= maxIn.xy)) return 0.0;
    return getLayer(tex, ID, input);
}

float getOutput(Texture2D<float> tex, uint input)
{
    uint2 pos;
    pos.x = input % 57;
    pos.y = input / 57;
    return tex[layersPos[10].xy + pos];
}

float getConst(Texture2D<float> tex, uint ID, uint3 off, uint step)
{
    uint2 pos;
    pos.x = off.z;
    pos.y = off.y + off.x * step;
    return tex[weightsPos[ID].xy + pos];
}

float getConst(Texture2D<float> tex, uint ID, uint off)
{
    return tex[weightsPos[ID].xy + uint2(off, 0)];
}

float getConstDense(Texture2D<float> tex, uint ID, uint2 off)
{
    uint2 pos;
    pos.x = off.y % 57 + (off.x % 17) * 57;
    pos.y = off.y / 57 + (off.x / 17) * 57;
    return tex[weightsPos[ID].xy + pos]; 
}

// Controller logic

#define sc_uint2 static const uint2

sc_uint2 txLayerCount = layersPos[11].xy + uint2(0, 0);
sc_uint2 txInputState = layersPos[11].xy + uint2(2, 0);
sc_uint2 txTop1 = layersPos[11].xy + uint2(3, 0);
sc_uint2 txTop2 = layersPos[11].xy + uint2(4, 0);
sc_uint2 txTop3 = layersPos[11].xy + uint2(5, 0);
sc_uint2 txTop4 = layersPos[11].xy + uint2(6, 0);
sc_uint2 txTop5 = layersPos[11].xy + uint2(7, 0);
sc_uint2 txTop1Val = layersPos[11].xy + uint2(8, 0);
sc_uint2 txTop2Val = layersPos[11].xy + uint2(9, 0);
sc_uint2 txTop3Val = layersPos[11].xy + uint2(10, 0);
sc_uint2 txTop4Val = layersPos[11].xy + uint2(11, 0);
sc_uint2 txTop5Val = layersPos[11].xy + uint2(12, 0);

// input buffer for translator
sc_uint2 txInputBuffer = layersPos[11].xy + uint2(37, 56);

sc_uint2 txVBtnSel = layersPos[12].xy + uint2(0, 0);
sc_uint2 txVBtnState = layersPos[12].xy + uint2(1, 0);
sc_uint2 txVBtnEnter = layersPos[12].xy + uint2(2, 0);
sc_uint2 txHBtnSel = layersPos[12].xy + uint2(0, 1);
sc_uint2 txHBtnState = layersPos[12].xy + uint2(1, 1);
sc_uint2 txHBtnEnter = layersPos[12].xy + uint2(2, 1);
sc_uint2 txCursorPos = layersPos[12].xy + uint2(0, 2);

#define INPUT_THRESHOLD     0.0
#define HAND_IDLE           0
#define HAND_DOWN           1
#define HAND_UP             2

#endif