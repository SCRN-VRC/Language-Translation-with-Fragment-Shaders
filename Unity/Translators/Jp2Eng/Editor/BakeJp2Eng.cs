#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class jp2eng : EditorWindow
{
    public TextAsset source0;
    string SavePath1;
    string SavePath2;

    [MenuItem("Tools/SCRN/Bake jp2eng Weights")]
    static void Init()
    {
        var window = GetWindowWithRect<jp2eng>(new Rect(0, 0, 400, 250));
        window.Show();
    }
    
    void OnGUI()
    {
        GUILayout.Label("Bake jp2eng", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        source0 = (TextAsset) EditorGUILayout.ObjectField("Bake jp2eng Weights (.bytes):", source0, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!") && source0 != null) {
            string path = AssetDatabase.GetAssetPath(source0);
            int fileDir = path.LastIndexOf("/");
            SavePath1 = path.Substring(0, fileDir) + "/baked-jp2eng-weights.asset";
            SavePath2 = path.Substring(0, fileDir) + "/baked-jp2eng-embedding.asset";
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        const int width = 8192;
        const int height = 4096;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;

        Texture2D tex2 = new Texture2D(width, width, TextureFormat.RFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;

        ExtractFromBin(tex, tex2, source0);
        AssetDatabase.CreateAsset(tex, SavePath1);
        AssetDatabase.CreateAsset(tex2, SavePath2);
        AssetDatabase.SaveAssets();

        ShowNotification(new GUIContent("Done"));
    }

    void writeBlock(Texture2D tex, BinaryReader br0, int totalFloats, int destX, int destY, int width)
    {
        //Debug.Log("Writing " + totalFloats + " at " + destX + ", " + destY);
        for (int i = 0; i < totalFloats; i++)
        {
            int x = i % width;
            int y = i / width;
            tex.SetPixel(x + destX, y + destY,
                new Color(br0.ReadSingle(), 0, 0, 0)); //br0.ReadSingle()
        }
    }

    void ExtractFromBin(Texture2D tex, Texture2D tex2, TextAsset srcIn0)
    {
        Stream s0 = new MemoryStream(srcIn0.bytes);
        BinaryReader br0 = new BinaryReader(s0);

        // Second texture
        //writeBlock(tex2, br0, 1654784, 0, 5544, 8192); //const0
        for (int i = 0; i < 3229; i++)
        {
            int x = (i % 16) * 512;
            int y = 5544 + i / 16;
            writeBlock(tex2, br0, 512, x, y, 512); //const0
        }
        // First texture
        writeBlock(tex, br0, 262144, 1536, 3584, 512); //const1
        writeBlock(tex, br0, 512, 6281, 3584, 1); //const2
        writeBlock(tex, br0, 262144, 512, 3584, 512); //const3
        writeBlock(tex, br0, 512, 6280, 3584, 1); //const4
        writeBlock(tex, br0, 262144, 5632, 3072, 512); //const5
        writeBlock(tex, br0, 512, 6278, 3584, 1); //const6
        writeBlock(tex, br0, 262144, 4608, 3072, 512); //const7
        writeBlock(tex, br0, 512, 6276, 3584, 1); //const8
        writeBlock(tex, br0, 524288, 7168, 1024, 1024); //const9
        writeBlock(tex, br0, 1024, 6145, 0, 1); //const10
        writeBlock(tex, br0, 524288, 5632, 0, 512); //const11
        writeBlock(tex, br0, 512, 6274, 3584, 1); //const12
        writeBlock(tex, br0, 512, 6272, 3584, 1); //const13
        writeBlock(tex, br0, 512, 6270, 3584, 1); //const14
        writeBlock(tex, br0, 512, 6268, 3584, 1); //const15
        writeBlock(tex, br0, 512, 6266, 3584, 1); //const16
        writeBlock(tex, br0, 262144, 7680, 2048, 512); //const17
        writeBlock(tex, br0, 512, 6264, 3584, 1); //const18
        writeBlock(tex, br0, 262144, 6656, 2048, 512); //const19
        writeBlock(tex, br0, 512, 6256, 3584, 1); //const20
        writeBlock(tex, br0, 262144, 5632, 2048, 512); //const21
        writeBlock(tex, br0, 512, 6255, 3584, 1); //const22
        writeBlock(tex, br0, 262144, 5120, 2048, 512); //const23
        writeBlock(tex, br0, 512, 6254, 3584, 1); //const24
        writeBlock(tex, br0, 524288, 6156, 512, 1024); //const25
        writeBlock(tex, br0, 1024, 6151, 0, 1); //const26
        writeBlock(tex, br0, 524288, 1024, 0, 512); //const27
        writeBlock(tex, br0, 512, 6252, 3584, 1); //const28
        writeBlock(tex, br0, 512, 6250, 3584, 1); //const29
        writeBlock(tex, br0, 512, 6248, 3584, 1); //const30
        writeBlock(tex, br0, 512, 6246, 3584, 1); //const31
        writeBlock(tex, br0, 512, 6244, 3584, 1); //const32
        writeBlock(tex, br0, 262144, 5120, 1536, 512); //const33
        writeBlock(tex, br0, 512, 6242, 3584, 1); //const34
        writeBlock(tex, br0, 262144, 4096, 1536, 512); //const35
        writeBlock(tex, br0, 512, 6240, 3584, 1); //const36
        writeBlock(tex, br0, 262144, 2560, 1536, 512); //const37
        writeBlock(tex, br0, 512, 6238, 3584, 1); //const38
        writeBlock(tex, br0, 262144, 3584, 1536, 512); //const39
        writeBlock(tex, br0, 512, 6230, 3584, 1); //const40
        writeBlock(tex, br0, 524288, 0, 1536, 1024); //const41
        writeBlock(tex, br0, 1024, 6146, 0, 1); //const42
        writeBlock(tex, br0, 524288, 512, 0, 512); //const43
        writeBlock(tex, br0, 512, 6229, 3584, 1); //const44
        writeBlock(tex, br0, 512, 6228, 3584, 1); //const45
        writeBlock(tex, br0, 512, 6226, 3584, 1); //const46
        writeBlock(tex, br0, 512, 6224, 3584, 1); //const47
        writeBlock(tex, br0, 512, 6222, 3584, 1); //const48
        writeBlock(tex, br0, 262144, 512, 2048, 512); //const49
        writeBlock(tex, br0, 512, 6220, 3584, 1); //const50
        writeBlock(tex, br0, 262144, 2560, 3584, 512); //const51
        writeBlock(tex, br0, 512, 6218, 3584, 1); //const52
        writeBlock(tex, br0, 262144, 2560, 2048, 512); //const53
        writeBlock(tex, br0, 512, 6216, 3584, 1); //const54
        writeBlock(tex, br0, 262144, 3584, 2048, 512); //const55
        writeBlock(tex, br0, 512, 6214, 3584, 1); //const56
        writeBlock(tex, br0, 524288, 2048, 1024, 1024); //const57
        writeBlock(tex, br0, 1024, 6155, 0, 1); //const58
        writeBlock(tex, br0, 524288, 2048, 0, 512); //const59
        writeBlock(tex, br0, 512, 6212, 3584, 1); //const60
        writeBlock(tex, br0, 512, 6204, 3584, 1); //const61
        writeBlock(tex, br0, 512, 6203, 3584, 1); //const62
        writeBlock(tex, br0, 512, 6202, 3584, 1); //const63
        writeBlock(tex, br0, 512, 6200, 3584, 1); //const64
        writeBlock(tex, br0, 262144, 512, 2560, 512); //const65
        writeBlock(tex, br0, 512, 6198, 3584, 1); //const66
        writeBlock(tex, br0, 262144, 1536, 2560, 512); //const67
        writeBlock(tex, br0, 512, 6196, 3584, 1); //const68
        writeBlock(tex, br0, 262144, 2560, 2560, 512); //const69
        writeBlock(tex, br0, 512, 6194, 3584, 1); //const70
        writeBlock(tex, br0, 262144, 3584, 2560, 512); //const71
        writeBlock(tex, br0, 512, 6192, 3584, 1); //const72
        writeBlock(tex, br0, 524288, 6144, 1024, 1024); //const73
        writeBlock(tex, br0, 1024, 6147, 0, 1); //const74
        writeBlock(tex, br0, 524288, 4608, 0, 512); //const75
        writeBlock(tex, br0, 512, 6190, 3584, 1); //const76
        writeBlock(tex, br0, 512, 6188, 3584, 1); //const77
        writeBlock(tex, br0, 512, 6186, 3584, 1); //const78
        writeBlock(tex, br0, 512, 6178, 3584, 1); //const79
        writeBlock(tex, br0, 512, 6177, 3584, 1); //const80
        writeBlock(tex, br0, 262144, 512, 3072, 512); //const81
        writeBlock(tex, br0, 512, 6176, 3584, 1); //const82
        writeBlock(tex, br0, 262144, 1536, 3072, 512); //const83
        writeBlock(tex, br0, 512, 6174, 3584, 1); //const84
        writeBlock(tex, br0, 262144, 2560, 3072, 512); //const85
        writeBlock(tex, br0, 512, 6172, 3584, 1); //const86
        writeBlock(tex, br0, 262144, 3584, 3072, 512); //const87
        writeBlock(tex, br0, 512, 6170, 3584, 1); //const88
        writeBlock(tex, br0, 524288, 0, 1024, 1024); //const89
        writeBlock(tex, br0, 1024, 6152, 0, 1); //const90
        writeBlock(tex, br0, 524288, 2560, 0, 512); //const91
        writeBlock(tex, br0, 512, 6168, 3584, 1); //const92
        writeBlock(tex, br0, 512, 6166, 3584, 1); //const93
        writeBlock(tex, br0, 512, 6162, 3584, 1); //const94
        writeBlock(tex, br0, 512, 6160, 3584, 1); //const95
        writeBlock(tex, br0, 512, 6159, 3584, 1); //const96
        // Second texture
        //writeBlock(tex2, br0, 22708224, 0, 0, 8192); //const1
        for (int i = 0; i < 44337; i++)
        {
            int x = (i % 16) * 512;
            int y = i / 16;
            writeBlock(tex2, br0, 512, x, y, 512); //const1
        }
        // Back to first texture
        writeBlock(tex, br0, 262144, 1024, 3584, 512); //const98
        writeBlock(tex, br0, 512, 6151, 3584, 1); //const99
        writeBlock(tex, br0, 262144, 2048, 3584, 512); //const100
        writeBlock(tex, br0, 512, 6150, 3584, 1); //const101
        writeBlock(tex, br0, 262144, 3072, 3584, 512); //const102
        writeBlock(tex, br0, 512, 6148, 3584, 1); //const103
        writeBlock(tex, br0, 262144, 4096, 3584, 512); //const104
        writeBlock(tex, br0, 512, 6146, 3584, 1); //const105
        writeBlock(tex, br0, 262144, 5120, 3584, 512); //const106
        writeBlock(tex, br0, 512, 6144, 3584, 1); //const107
        writeBlock(tex, br0, 262144, 5632, 3584, 512); //const108
        writeBlock(tex, br0, 512, 6145, 3584, 1); //const109
        writeBlock(tex, br0, 262144, 4608, 3584, 512); //const110
        writeBlock(tex, br0, 512, 6147, 3584, 1); //const111
        writeBlock(tex, br0, 262144, 3584, 3584, 512); //const112
        writeBlock(tex, br0, 512, 6149, 3584, 1); //const113
        writeBlock(tex, br0, 524288, 3072, 1024, 1024); //const114
        writeBlock(tex, br0, 1024, 6148, 0, 1); //const115
        writeBlock(tex, br0, 524288, 1536, 0, 512); //const116
        writeBlock(tex, br0, 512, 6153, 3584, 1); //const117
        writeBlock(tex, br0, 512, 6154, 3584, 1); //const118
        writeBlock(tex, br0, 512, 6155, 3584, 1); //const119
        writeBlock(tex, br0, 512, 6156, 3584, 1); //const120
        writeBlock(tex, br0, 512, 6157, 3584, 1); //const121
        writeBlock(tex, br0, 512, 6158, 3584, 1); //const122
        writeBlock(tex, br0, 512, 6282, 3584, 1); //const123
        writeBlock(tex, br0, 262144, 7680, 3072, 512); //const124
        writeBlock(tex, br0, 512, 6161, 3584, 1); //const125
        writeBlock(tex, br0, 262144, 7168, 3072, 512); //const126
        writeBlock(tex, br0, 512, 6163, 3584, 1); //const127
        writeBlock(tex, br0, 262144, 0, 3584, 512); //const128
        writeBlock(tex, br0, 512, 6165, 3584, 1); //const129
        writeBlock(tex, br0, 262144, 6656, 3072, 512); //const130
        writeBlock(tex, br0, 512, 6167, 3584, 1); //const131
        writeBlock(tex, br0, 262144, 6144, 3072, 512); //const132
        writeBlock(tex, br0, 512, 6169, 3584, 1); //const133
        writeBlock(tex, br0, 262144, 4096, 3072, 512); //const134
        writeBlock(tex, br0, 512, 6171, 3584, 1); //const135
        writeBlock(tex, br0, 262144, 3072, 3072, 512); //const136
        writeBlock(tex, br0, 512, 6173, 3584, 1); //const137
        writeBlock(tex, br0, 262144, 2048, 3072, 512); //const138
        writeBlock(tex, br0, 512, 6175, 3584, 1); //const139
        writeBlock(tex, br0, 524288, 1024, 1024, 1024); //const140
        writeBlock(tex, br0, 1024, 6144, 0, 1); //const141
        writeBlock(tex, br0, 524288, 5120, 0, 512); //const142
        writeBlock(tex, br0, 512, 6179, 3584, 1); //const143
        writeBlock(tex, br0, 512, 6180, 3584, 1); //const144
        writeBlock(tex, br0, 512, 6181, 3584, 1); //const145
        writeBlock(tex, br0, 512, 6182, 3584, 1); //const146
        writeBlock(tex, br0, 512, 6183, 3584, 1); //const147
        writeBlock(tex, br0, 512, 6184, 3584, 1); //const148
        writeBlock(tex, br0, 512, 6185, 3584, 1); //const149
        writeBlock(tex, br0, 262144, 7168, 2560, 512); //const150
        writeBlock(tex, br0, 512, 6187, 3584, 1); //const151
        writeBlock(tex, br0, 262144, 6656, 2560, 512); //const152
        writeBlock(tex, br0, 512, 6189, 3584, 1); //const153
        writeBlock(tex, br0, 262144, 6144, 2560, 512); //const154
        writeBlock(tex, br0, 512, 6191, 3584, 1); //const155
        writeBlock(tex, br0, 262144, 4096, 2560, 512); //const156
        writeBlock(tex, br0, 512, 6193, 3584, 1); //const157
        writeBlock(tex, br0, 262144, 3072, 2560, 512); //const158
        writeBlock(tex, br0, 512, 6195, 3584, 1); //const159
        writeBlock(tex, br0, 262144, 2048, 2560, 512); //const160
        writeBlock(tex, br0, 512, 6197, 3584, 1); //const161
        writeBlock(tex, br0, 262144, 1024, 2560, 512); //const162
        writeBlock(tex, br0, 512, 6199, 3584, 1); //const163
        writeBlock(tex, br0, 262144, 0, 2560, 512); //const164
        writeBlock(tex, br0, 512, 6201, 3584, 1); //const165
        writeBlock(tex, br0, 524288, 5120, 1024, 1024); //const166
        writeBlock(tex, br0, 1024, 6153, 0, 1); //const167
        writeBlock(tex, br0, 524288, 3584, 0, 512); //const168
        writeBlock(tex, br0, 512, 6205, 3584, 1); //const169
        writeBlock(tex, br0, 512, 6206, 3584, 1); //const170
        writeBlock(tex, br0, 512, 6207, 3584, 1); //const171
        writeBlock(tex, br0, 512, 6208, 3584, 1); //const172
        writeBlock(tex, br0, 512, 6209, 3584, 1); //const173
        writeBlock(tex, br0, 512, 6210, 3584, 1); //const174
        writeBlock(tex, br0, 512, 6211, 3584, 1); //const175
        writeBlock(tex, br0, 262144, 6144, 2048, 512); //const176
        writeBlock(tex, br0, 512, 6213, 3584, 1); //const177
        writeBlock(tex, br0, 262144, 4096, 2048, 512); //const178
        writeBlock(tex, br0, 512, 6215, 3584, 1); //const179
        writeBlock(tex, br0, 262144, 3072, 2048, 512); //const180
        writeBlock(tex, br0, 512, 6217, 3584, 1); //const181
        writeBlock(tex, br0, 262144, 2048, 2048, 512); //const182
        writeBlock(tex, br0, 512, 6219, 3584, 1); //const183
        writeBlock(tex, br0, 262144, 1024, 2048, 512); //const184
        writeBlock(tex, br0, 512, 6221, 3584, 1); //const185
        writeBlock(tex, br0, 262144, 0, 2048, 512); //const186
        writeBlock(tex, br0, 512, 6223, 3584, 1); //const187
        writeBlock(tex, br0, 262144, 7680, 1536, 512); //const188
        writeBlock(tex, br0, 512, 6225, 3584, 1); //const189
        writeBlock(tex, br0, 262144, 7168, 1536, 512); //const190
        writeBlock(tex, br0, 512, 6227, 3584, 1); //const191
        writeBlock(tex, br0, 524288, 4096, 1024, 1024); //const192
        writeBlock(tex, br0, 1024, 6149, 0, 1); //const193
        writeBlock(tex, br0, 524288, 4096, 0, 512); //const194
        writeBlock(tex, br0, 512, 6231, 3584, 1); //const195
        writeBlock(tex, br0, 512, 6232, 3584, 1); //const196
        writeBlock(tex, br0, 512, 6233, 3584, 1); //const197
        writeBlock(tex, br0, 512, 6234, 3584, 1); //const198
        writeBlock(tex, br0, 512, 6235, 3584, 1); //const199
        writeBlock(tex, br0, 512, 6236, 3584, 1); //const200
        writeBlock(tex, br0, 512, 6237, 3584, 1); //const201
        writeBlock(tex, br0, 262144, 3072, 1536, 512); //const202
        writeBlock(tex, br0, 512, 6239, 3584, 1); //const203
        writeBlock(tex, br0, 262144, 2048, 1536, 512); //const204
        writeBlock(tex, br0, 512, 6241, 3584, 1); //const205
        writeBlock(tex, br0, 262144, 4608, 1536, 512); //const206
        writeBlock(tex, br0, 512, 6243, 3584, 1); //const207
        writeBlock(tex, br0, 262144, 5632, 1536, 512); //const208
        writeBlock(tex, br0, 512, 6245, 3584, 1); //const209
        writeBlock(tex, br0, 262144, 6144, 1536, 512); //const210
        writeBlock(tex, br0, 512, 6247, 3584, 1); //const211
        writeBlock(tex, br0, 262144, 6656, 1536, 512); //const212
        writeBlock(tex, br0, 512, 6249, 3584, 1); //const213
        writeBlock(tex, br0, 262144, 1536, 2048, 512); //const214
        writeBlock(tex, br0, 512, 6251, 3584, 1); //const215
        writeBlock(tex, br0, 262144, 4608, 2048, 512); //const216
        writeBlock(tex, br0, 512, 6253, 3584, 1); //const217
        writeBlock(tex, br0, 524288, 1024, 1536, 1024); //const218
        writeBlock(tex, br0, 1024, 6154, 0, 1); //const219
        writeBlock(tex, br0, 524288, 3072, 0, 512); //const220
        writeBlock(tex, br0, 512, 6257, 3584, 1); //const221
        writeBlock(tex, br0, 512, 6258, 3584, 1); //const222
        writeBlock(tex, br0, 512, 6259, 3584, 1); //const223
        writeBlock(tex, br0, 512, 6260, 3584, 1); //const224
        writeBlock(tex, br0, 512, 6261, 3584, 1); //const225
        writeBlock(tex, br0, 512, 6262, 3584, 1); //const226
        writeBlock(tex, br0, 512, 6263, 3584, 1); //const227
        writeBlock(tex, br0, 262144, 7168, 2048, 512); //const228
        writeBlock(tex, br0, 512, 6265, 3584, 1); //const229
        writeBlock(tex, br0, 262144, 4608, 2560, 512); //const230
        writeBlock(tex, br0, 512, 6267, 3584, 1); //const231
        writeBlock(tex, br0, 262144, 5120, 2560, 512); //const232
        writeBlock(tex, br0, 512, 6269, 3584, 1); //const233
        writeBlock(tex, br0, 262144, 5632, 2560, 512); //const234
        writeBlock(tex, br0, 512, 6271, 3584, 1); //const235
        writeBlock(tex, br0, 262144, 7680, 2560, 512); //const236
        writeBlock(tex, br0, 512, 6273, 3584, 1); //const237
        writeBlock(tex, br0, 262144, 0, 3072, 512); //const238
        writeBlock(tex, br0, 512, 6275, 3584, 1); //const239
        writeBlock(tex, br0, 262144, 1024, 3072, 512); //const240
        writeBlock(tex, br0, 512, 6277, 3584, 1); //const241
        writeBlock(tex, br0, 262144, 5120, 3072, 512); //const242
        writeBlock(tex, br0, 512, 6279, 3584, 1); //const243
        writeBlock(tex, br0, 524288, 6156, 0, 1024); //const244
        writeBlock(tex, br0, 1024, 6150, 0, 1); //const245
        writeBlock(tex, br0, 524288, 0, 0, 512); //const246
        writeBlock(tex, br0, 512, 6283, 3584, 1); //const247
        writeBlock(tex, br0, 512, 6284, 3584, 1); //const248
        writeBlock(tex, br0, 512, 6285, 3584, 1); //const249
        writeBlock(tex, br0, 512, 6286, 3584, 1); //const250
        writeBlock(tex, br0, 512, 6164, 3584, 1); //const251
        writeBlock(tex, br0, 512, 6152, 3584, 1); //const252
        writeBlock(tex, br0, 512, 6287, 3584, 1); //const253
        // Second texture
        //writeBlock(tex2, br0, 22708224, 0, 2772, 8192); //const2
        for (int i = 0; i < 44337; i++)
        {
            int x = (i % 16) * 512;
            int y = 2772 + i / 16;
            writeBlock(tex2, br0, 512, x, y, 512); //const2
        }
        writeBlock(tex2, br0, 44337, 0, 5746, 8192); //const3
    }
}

#endif