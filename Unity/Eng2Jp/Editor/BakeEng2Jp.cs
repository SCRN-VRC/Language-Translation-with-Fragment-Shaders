#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class eng2jp : EditorWindow
{
    public TextAsset source0;
    string SavePath;

    [MenuItem("Tools/SCRN/Bake eng2jp Weights")]
    static void Init()
    {
        var window = GetWindowWithRect<eng2jp>(new Rect(0, 0, 400, 250));
        window.Show();
    }
    
    void OnGUI()
    {
        GUILayout.Label("Bake eng2jp", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        source0 = (TextAsset) EditorGUILayout.ObjectField("Bake eng2jp Weights (.bytes):", source0, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!") && source0 != null) {
            string path = AssetDatabase.GetAssetPath(source0);
            int fileDir = path.LastIndexOf("/");
            SavePath = path.Substring(0, fileDir) + "/baked-eng2jp.asset";
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        const int width = 8192;
        const int height = 8192;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;
        
        ExtractFromBin(tex, source0);
        AssetDatabase.CreateAsset(tex, SavePath);
        AssetDatabase.SaveAssets();

        ShowNotification(new GUIContent("Done"));
    }

    void writeBlock(Texture2D tex, BinaryReader br0, int totalFloats, int destX, int destY, int width)
    {
        for (int i = 0; i < totalFloats; i++)
        {
            int x = i % width;
            int y = i / width;
            tex.SetPixel(x + destX, y + destY,
                new Color(br0.ReadSingle(), 0, 0, 0)); //br0.ReadSingle()
        }
    }

    void ExtractFromBin(Texture2D tex, TextAsset srcIn0)
    {
        Stream s0 = new MemoryStream(srcIn0.bytes);
        BinaryReader br0 = new BinaryReader(s0);
        //writeBlock(tex, br0, 25165824, 0, 0, 3072); //const0
        for (int i = 0; i < 44337; i++)
        {
            int x = (i % 6) * 512;
            int y = i / 6;
            writeBlock(tex, br0, 512, x, y, 512); //const0
        }
        writeBlock(tex, br0, 262144, 3584, 6656, 512); //const1
        writeBlock(tex, br0, 512, 5137, 7168, 1); //const2
        writeBlock(tex, br0, 262144, 3584, 7168, 512); //const3
        writeBlock(tex, br0, 512, 5262, 7168, 1); //const4
        writeBlock(tex, br0, 262144, 6656, 6656, 512); //const5
        writeBlock(tex, br0, 512, 5254, 7168, 1); //const6
        writeBlock(tex, br0, 262144, 4608, 6144, 512); //const7
        writeBlock(tex, br0, 512, 5253, 7168, 1); //const8
        writeBlock(tex, br0, 524288, 4609, 3072, 1024); //const9
        writeBlock(tex, br0, 1024, 7686, 0, 1); //const10
        writeBlock(tex, br0, 524288, 3585, 1024, 512); //const11
        writeBlock(tex, br0, 512, 5252, 7168, 1); //const12
        writeBlock(tex, br0, 512, 5250, 7168, 1); //const13
        writeBlock(tex, br0, 512, 5248, 7168, 1); //const14
        writeBlock(tex, br0, 512, 5246, 7168, 1); //const15
        writeBlock(tex, br0, 512, 5244, 7168, 1); //const16
        writeBlock(tex, br0, 262144, 6144, 5632, 512); //const17
        writeBlock(tex, br0, 512, 5242, 7168, 1); //const18
        writeBlock(tex, br0, 262144, 6144, 5120, 512); //const19
        writeBlock(tex, br0, 512, 5240, 7168, 1); //const20
        writeBlock(tex, br0, 262144, 3072, 5120, 512); //const21
        writeBlock(tex, br0, 512, 5238, 7168, 1); //const22
        writeBlock(tex, br0, 262144, 6144, 4608, 512); //const23
        writeBlock(tex, br0, 512, 5236, 7168, 1); //const24
        writeBlock(tex, br0, 524288, 5633, 3072, 1024); //const25
        writeBlock(tex, br0, 1024, 7692, 0, 1); //const26
        writeBlock(tex, br0, 524288, 3585, 0, 512); //const27
        writeBlock(tex, br0, 512, 5228, 7168, 1); //const28
        writeBlock(tex, br0, 512, 5227, 7168, 1); //const29
        writeBlock(tex, br0, 512, 5226, 7168, 1); //const30
        writeBlock(tex, br0, 512, 5224, 7168, 1); //const31
        writeBlock(tex, br0, 512, 5222, 7168, 1); //const32
        writeBlock(tex, br0, 262144, 6656, 4096, 512); //const33
        writeBlock(tex, br0, 512, 5220, 7168, 1); //const34
        writeBlock(tex, br0, 262144, 7680, 3584, 512); //const35
        writeBlock(tex, br0, 512, 5218, 7168, 1); //const36
        writeBlock(tex, br0, 262144, 5632, 3584, 512); //const37
        writeBlock(tex, br0, 512, 5216, 7168, 1); //const38
        writeBlock(tex, br0, 262144, 4608, 3584, 512); //const39
        writeBlock(tex, br0, 512, 5214, 7168, 1); //const40
        writeBlock(tex, br0, 524288, 3072, 3584, 1024); //const41
        writeBlock(tex, br0, 1024, 7687, 0, 1); //const42
        writeBlock(tex, br0, 524288, 4097, 0, 512); //const43
        writeBlock(tex, br0, 512, 5212, 7168, 1); //const44
        writeBlock(tex, br0, 512, 5210, 7168, 1); //const45
        writeBlock(tex, br0, 512, 5202, 7168, 1); //const46
        writeBlock(tex, br0, 512, 5201, 7168, 1); //const47
        writeBlock(tex, br0, 512, 5200, 7168, 1); //const48
        writeBlock(tex, br0, 262144, 3584, 4096, 512); //const49
        writeBlock(tex, br0, 512, 5198, 7168, 1); //const50
        writeBlock(tex, br0, 262144, 4608, 4096, 512); //const51
        writeBlock(tex, br0, 512, 5196, 7168, 1); //const52
        writeBlock(tex, br0, 262144, 5632, 4096, 512); //const53
        writeBlock(tex, br0, 512, 5194, 7168, 1); //const54
        writeBlock(tex, br0, 262144, 7680, 6656, 512); //const55
        writeBlock(tex, br0, 512, 5192, 7168, 1); //const56
        writeBlock(tex, br0, 524288, 4609, 2560, 1024); //const57
        writeBlock(tex, br0, 1024, 7690, 0, 1); //const58
        writeBlock(tex, br0, 524288, 5121, 1024, 512); //const59
        writeBlock(tex, br0, 512, 5190, 7168, 1); //const60
        writeBlock(tex, br0, 512, 5188, 7168, 1); //const61
        writeBlock(tex, br0, 512, 5186, 7168, 1); //const62
        writeBlock(tex, br0, 512, 5184, 7168, 1); //const63
        writeBlock(tex, br0, 512, 5176, 7168, 1); //const64
        writeBlock(tex, br0, 262144, 6656, 4608, 512); //const65
        writeBlock(tex, br0, 512, 5175, 7168, 1); //const66
        writeBlock(tex, br0, 262144, 7680, 4608, 512); //const67
        writeBlock(tex, br0, 512, 5174, 7168, 1); //const68
        writeBlock(tex, br0, 262144, 3584, 5120, 512); //const69
        writeBlock(tex, br0, 512, 5172, 7168, 1); //const70
        writeBlock(tex, br0, 262144, 4608, 5120, 512); //const71
        writeBlock(tex, br0, 512, 5170, 7168, 1); //const72
        writeBlock(tex, br0, 524288, 6814, 1024, 1024); //const73
        writeBlock(tex, br0, 1024, 7685, 0, 1); //const74
        writeBlock(tex, br0, 524288, 4097, 1024, 512); //const75
        writeBlock(tex, br0, 512, 5168, 7168, 1); //const76
        writeBlock(tex, br0, 512, 5166, 7168, 1); //const77
        writeBlock(tex, br0, 512, 5164, 7168, 1); //const78
        writeBlock(tex, br0, 512, 5162, 7168, 1); //const79
        writeBlock(tex, br0, 512, 5160, 7168, 1); //const80
        writeBlock(tex, br0, 262144, 4608, 5632, 512); //const81
        writeBlock(tex, br0, 512, 5158, 7168, 1); //const82
        writeBlock(tex, br0, 262144, 5632, 5632, 512); //const83
        writeBlock(tex, br0, 512, 5150, 7168, 1); //const84
        writeBlock(tex, br0, 262144, 6656, 5632, 512); //const85
        writeBlock(tex, br0, 512, 5149, 7168, 1); //const86
        writeBlock(tex, br0, 262144, 7680, 5632, 512); //const87
        writeBlock(tex, br0, 512, 5148, 7168, 1); //const88
        writeBlock(tex, br0, 524288, 3585, 2560, 1024); //const89
        writeBlock(tex, br0, 1024, 7683, 0, 1); //const90
        writeBlock(tex, br0, 524288, 5633, 0, 512); //const91
        writeBlock(tex, br0, 512, 5146, 7168, 1); //const92
        writeBlock(tex, br0, 512, 5144, 7168, 1); //const93
        writeBlock(tex, br0, 512, 5142, 7168, 1); //const94
        writeBlock(tex, br0, 512, 5140, 7168, 1); //const95
        writeBlock(tex, br0, 512, 5138, 7168, 1); //const96
        writeBlock(tex, br0, 1653248, 3072, 0, 512); //const97
        writeBlock(tex, br0, 262144, 3072, 6656, 512); //const98
        writeBlock(tex, br0, 512, 5136, 7168, 1); //const99
        writeBlock(tex, br0, 262144, 4096, 6656, 512); //const100
        writeBlock(tex, br0, 512, 5134, 7168, 1); //const101
        writeBlock(tex, br0, 262144, 5120, 6656, 512); //const102
        writeBlock(tex, br0, 512, 5132, 7168, 1); //const103
        writeBlock(tex, br0, 262144, 6144, 6656, 512); //const104
        writeBlock(tex, br0, 512, 5124, 7168, 1); //const105
        writeBlock(tex, br0, 262144, 7168, 6656, 512); //const106
        writeBlock(tex, br0, 512, 5123, 7168, 1); //const107
        writeBlock(tex, br0, 262144, 3072, 7168, 512); //const108
        writeBlock(tex, br0, 512, 5122, 7168, 1); //const109
        writeBlock(tex, br0, 262144, 4096, 7168, 512); //const110
        writeBlock(tex, br0, 512, 5120, 7168, 1); //const111
        writeBlock(tex, br0, 262144, 4608, 7168, 512); //const112
        writeBlock(tex, br0, 512, 5121, 7168, 1); //const113
        writeBlock(tex, br0, 524288, 5633, 2560, 1024); //const114
        writeBlock(tex, br0, 1024, 7691, 0, 1); //const115
        writeBlock(tex, br0, 524288, 4609, 0, 512); //const116
        writeBlock(tex, br0, 512, 5125, 7168, 1); //const117
        writeBlock(tex, br0, 512, 5126, 7168, 1); //const118
        writeBlock(tex, br0, 512, 5127, 7168, 1); //const119
        writeBlock(tex, br0, 512, 5128, 7168, 1); //const120
        writeBlock(tex, br0, 512, 5129, 7168, 1); //const121
        writeBlock(tex, br0, 512, 5130, 7168, 1); //const122
        writeBlock(tex, br0, 512, 5131, 7168, 1); //const123
        writeBlock(tex, br0, 262144, 5632, 6656, 512); //const124
        writeBlock(tex, br0, 512, 5133, 7168, 1); //const125
        writeBlock(tex, br0, 262144, 4608, 6656, 512); //const126
        writeBlock(tex, br0, 512, 5135, 7168, 1); //const127
        writeBlock(tex, br0, 262144, 7680, 6144, 512); //const128
        writeBlock(tex, br0, 512, 5263, 7168, 1); //const129
        writeBlock(tex, br0, 262144, 7168, 6144, 512); //const130
        writeBlock(tex, br0, 512, 5139, 7168, 1); //const131
        writeBlock(tex, br0, 262144, 6656, 6144, 512); //const132
        writeBlock(tex, br0, 512, 5141, 7168, 1); //const133
        writeBlock(tex, br0, 262144, 6144, 6144, 512); //const134
        writeBlock(tex, br0, 512, 5143, 7168, 1); //const135
        writeBlock(tex, br0, 262144, 5632, 6144, 512); //const136
        writeBlock(tex, br0, 512, 5145, 7168, 1); //const137
        writeBlock(tex, br0, 262144, 5120, 6144, 512); //const138
        writeBlock(tex, br0, 512, 5147, 7168, 1); //const139
        writeBlock(tex, br0, 524288, 6814, 1536, 1024); //const140
        writeBlock(tex, br0, 1024, 7682, 0, 1); //const141
        writeBlock(tex, br0, 524288, 4609, 1024, 512); //const142
        writeBlock(tex, br0, 512, 5151, 7168, 1); //const143
        writeBlock(tex, br0, 512, 5152, 7168, 1); //const144
        writeBlock(tex, br0, 512, 5153, 7168, 1); //const145
        writeBlock(tex, br0, 512, 5154, 7168, 1); //const146
        writeBlock(tex, br0, 512, 5155, 7168, 1); //const147
        writeBlock(tex, br0, 512, 5156, 7168, 1); //const148
        writeBlock(tex, br0, 512, 5157, 7168, 1); //const149
        writeBlock(tex, br0, 262144, 5120, 5632, 512); //const150
        writeBlock(tex, br0, 512, 5159, 7168, 1); //const151
        writeBlock(tex, br0, 262144, 4096, 5632, 512); //const152
        writeBlock(tex, br0, 512, 5161, 7168, 1); //const153
        writeBlock(tex, br0, 262144, 3584, 5632, 512); //const154
        writeBlock(tex, br0, 512, 5163, 7168, 1); //const155
        writeBlock(tex, br0, 262144, 3072, 5632, 512); //const156
        writeBlock(tex, br0, 512, 5165, 7168, 1); //const157
        writeBlock(tex, br0, 262144, 7680, 5120, 512); //const158
        writeBlock(tex, br0, 512, 5167, 7168, 1); //const159
        writeBlock(tex, br0, 262144, 7168, 5120, 512); //const160
        writeBlock(tex, br0, 512, 5169, 7168, 1); //const161
        writeBlock(tex, br0, 262144, 5120, 5120, 512); //const162
        writeBlock(tex, br0, 512, 5171, 7168, 1); //const163
        writeBlock(tex, br0, 262144, 4096, 5120, 512); //const164
        writeBlock(tex, br0, 512, 5173, 7168, 1); //const165
        writeBlock(tex, br0, 524288, 6657, 3072, 1024); //const166
        writeBlock(tex, br0, 1024, 7688, 0, 1); //const167
        writeBlock(tex, br0, 524288, 6145, 0, 512); //const168
        writeBlock(tex, br0, 512, 5177, 7168, 1); //const169
        writeBlock(tex, br0, 512, 5178, 7168, 1); //const170
        writeBlock(tex, br0, 512, 5179, 7168, 1); //const171
        writeBlock(tex, br0, 512, 5180, 7168, 1); //const172
        writeBlock(tex, br0, 512, 5181, 7168, 1); //const173
        writeBlock(tex, br0, 512, 5182, 7168, 1); //const174
        writeBlock(tex, br0, 512, 5183, 7168, 1); //const175
        writeBlock(tex, br0, 262144, 5632, 4608, 512); //const176
        writeBlock(tex, br0, 512, 5185, 7168, 1); //const177
        writeBlock(tex, br0, 262144, 5120, 4608, 512); //const178
        writeBlock(tex, br0, 512, 5187, 7168, 1); //const179
        writeBlock(tex, br0, 262144, 4608, 4608, 512); //const180
        writeBlock(tex, br0, 512, 5189, 7168, 1); //const181
        writeBlock(tex, br0, 262144, 4096, 4608, 512); //const182
        writeBlock(tex, br0, 512, 5191, 7168, 1); //const183
        writeBlock(tex, br0, 262144, 7168, 4096, 512); //const184
        writeBlock(tex, br0, 512, 5193, 7168, 1); //const185
        writeBlock(tex, br0, 262144, 6144, 4096, 512); //const186
        writeBlock(tex, br0, 512, 5195, 7168, 1); //const187
        writeBlock(tex, br0, 262144, 5120, 4096, 512); //const188
        writeBlock(tex, br0, 512, 5197, 7168, 1); //const189
        writeBlock(tex, br0, 262144, 4096, 4096, 512); //const190
        writeBlock(tex, br0, 512, 5199, 7168, 1); //const191
        writeBlock(tex, br0, 524288, 6657, 2560, 1024); //const192
        writeBlock(tex, br0, 1024, 7684, 0, 1); //const193
        writeBlock(tex, br0, 524288, 6657, 0, 512); //const194
        writeBlock(tex, br0, 512, 5203, 7168, 1); //const195
        writeBlock(tex, br0, 512, 5204, 7168, 1); //const196
        writeBlock(tex, br0, 512, 5205, 7168, 1); //const197
        writeBlock(tex, br0, 512, 5206, 7168, 1); //const198
        writeBlock(tex, br0, 512, 5207, 7168, 1); //const199
        writeBlock(tex, br0, 512, 5208, 7168, 1); //const200
        writeBlock(tex, br0, 512, 5209, 7168, 1); //const201
        writeBlock(tex, br0, 262144, 6656, 3584, 512); //const202
        writeBlock(tex, br0, 512, 5211, 7168, 1); //const203
        writeBlock(tex, br0, 262144, 6144, 3584, 512); //const204
        writeBlock(tex, br0, 512, 5213, 7168, 1); //const205
        writeBlock(tex, br0, 262144, 4096, 3584, 512); //const206
        writeBlock(tex, br0, 512, 5215, 7168, 1); //const207
        writeBlock(tex, br0, 262144, 5120, 3584, 512); //const208
        writeBlock(tex, br0, 512, 5217, 7168, 1); //const209
        writeBlock(tex, br0, 262144, 7168, 3584, 512); //const210
        writeBlock(tex, br0, 512, 5219, 7168, 1); //const211
        writeBlock(tex, br0, 262144, 3072, 4096, 512); //const212
        writeBlock(tex, br0, 512, 5221, 7168, 1); //const213
        writeBlock(tex, br0, 262144, 7680, 4096, 512); //const214
        writeBlock(tex, br0, 512, 5223, 7168, 1); //const215
        writeBlock(tex, br0, 262144, 3072, 4608, 512); //const216
        writeBlock(tex, br0, 512, 5225, 7168, 1); //const217
        writeBlock(tex, br0, 524288, 6814, 2048, 1024); //const218
        writeBlock(tex, br0, 1024, 7681, 0, 1); //const219
        writeBlock(tex, br0, 524288, 7169, 0, 512); //const220
        writeBlock(tex, br0, 512, 5229, 7168, 1); //const221
        writeBlock(tex, br0, 512, 5230, 7168, 1); //const222
        writeBlock(tex, br0, 512, 5231, 7168, 1); //const223
        writeBlock(tex, br0, 512, 5232, 7168, 1); //const224
        writeBlock(tex, br0, 512, 5233, 7168, 1); //const225
        writeBlock(tex, br0, 512, 5234, 7168, 1); //const226
        writeBlock(tex, br0, 512, 5235, 7168, 1); //const227
        writeBlock(tex, br0, 262144, 3584, 4608, 512); //const228
        writeBlock(tex, br0, 512, 5237, 7168, 1); //const229
        writeBlock(tex, br0, 262144, 7168, 4608, 512); //const230
        writeBlock(tex, br0, 512, 5239, 7168, 1); //const231
        writeBlock(tex, br0, 262144, 5632, 5120, 512); //const232
        writeBlock(tex, br0, 512, 5241, 7168, 1); //const233
        writeBlock(tex, br0, 262144, 6656, 5120, 512); //const234
        writeBlock(tex, br0, 512, 5243, 7168, 1); //const235
        writeBlock(tex, br0, 262144, 7168, 5632, 512); //const236
        writeBlock(tex, br0, 512, 5245, 7168, 1); //const237
        writeBlock(tex, br0, 262144, 3072, 6144, 512); //const238
        writeBlock(tex, br0, 512, 5247, 7168, 1); //const239
        writeBlock(tex, br0, 262144, 3584, 6144, 512); //const240
        writeBlock(tex, br0, 512, 5249, 7168, 1); //const241
        writeBlock(tex, br0, 262144, 4096, 6144, 512); //const242
        writeBlock(tex, br0, 512, 5251, 7168, 1); //const243
        writeBlock(tex, br0, 524288, 3585, 3072, 1024); //const244
        writeBlock(tex, br0, 1024, 7689, 0, 1); //const245
        writeBlock(tex, br0, 524288, 5121, 0, 512); //const246
        writeBlock(tex, br0, 512, 5255, 7168, 1); //const247
        writeBlock(tex, br0, 512, 5256, 7168, 1); //const248
        writeBlock(tex, br0, 512, 5257, 7168, 1); //const249
        writeBlock(tex, br0, 512, 5258, 7168, 1); //const250
        writeBlock(tex, br0, 512, 5259, 7168, 1); //const251
        writeBlock(tex, br0, 512, 5260, 7168, 1); //const252
        writeBlock(tex, br0, 512, 5261, 7168, 1); //const253
        writeBlock(tex, br0, 1653248, 3585, 2048, 3229); //const254
        writeBlock(tex, br0, 3229, 3584, 0, 1); //const255
    }
}

#endif