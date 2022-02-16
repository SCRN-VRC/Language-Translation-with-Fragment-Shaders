#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEngine.UI;

[ExecuteInEditMode]
public class JPHandwrite : EditorWindow
{
    public TextAsset source0;
    string SavePath;

    [MenuItem("Tools/SCRN/Bake JPHandwrite Weights")]
    static void Init()
    {
        var window = GetWindowWithRect<JPHandwrite>(new Rect(0, 0, 400, 250));
        window.Show();
    }
    
    void OnGUI()
    {
        GUILayout.Label("Bake JPHandwrite", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        source0 = (TextAsset) EditorGUILayout.ObjectField("Bake JPHandwrite Weights (.bytes):", source0, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!") && source0 != null) {
            string path = AssetDatabase.GetAssetPath(source0);
            int fileDir = path.LastIndexOf("/");
            SavePath = path.Substring(0, fileDir) + "/baked-JPHandwrite.asset";
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        const int width = 1024;
        const int height = 657;

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

        writeBlock(tex, br0, 576, 633, 563, 144); //const0
        writeBlock(tex, br0, 144, 576, 581, 144); //const1
        writeBlock(tex, br0, 144, 576, 579, 144); //const2
        writeBlock(tex, br0, 144, 576, 577, 144); //const3
        writeBlock(tex, br0, 144, 576, 575, 144); //const4
        writeBlock(tex, br0, 144, 576, 573, 144); //const5
        writeBlock(tex, br0, 3600, 777, 538, 144); //const6
        writeBlock(tex, br0, 144, 720, 572, 144); //const7
        writeBlock(tex, br0, 144, 576, 571, 144); //const8
        writeBlock(tex, br0, 144, 777, 568, 144); //const9
        writeBlock(tex, br0, 144, 777, 564, 144); //const10
        writeBlock(tex, br0, 144, 777, 563, 144); //const11
        writeBlock(tex, br0, 20736, 432, 513, 144); //const12
        writeBlock(tex, br0, 144, 777, 565, 144); //const13
        writeBlock(tex, br0, 144, 777, 566, 144); //const14
        writeBlock(tex, br0, 144, 633, 567, 144); //const15
        writeBlock(tex, br0, 144, 777, 567, 144); //const16
        writeBlock(tex, br0, 144, 633, 568, 144); //const17
        writeBlock(tex, br0, 3600, 633, 538, 144); //const18
        writeBlock(tex, br0, 144, 633, 569, 144); //const19
        writeBlock(tex, br0, 144, 777, 569, 144); //const20
        writeBlock(tex, br0, 144, 576, 570, 144); //const21
        writeBlock(tex, br0, 144, 720, 570, 144); //const22
        writeBlock(tex, br0, 144, 864, 570, 144); //const23
        writeBlock(tex, br0, 20736, 144, 513, 144); //const24
        writeBlock(tex, br0, 144, 720, 571, 144); //const25
        writeBlock(tex, br0, 144, 864, 571, 144); //const26
        writeBlock(tex, br0, 144, 576, 572, 144); //const27
        writeBlock(tex, br0, 144, 720, 581, 144); //const28
        writeBlock(tex, br0, 144, 864, 572, 144); //const29
        writeBlock(tex, br0, 3600, 633, 513, 144); //const30
        writeBlock(tex, br0, 144, 720, 573, 144); //const31
        writeBlock(tex, br0, 144, 864, 573, 144); //const32
        writeBlock(tex, br0, 144, 576, 574, 144); //const33
        writeBlock(tex, br0, 144, 720, 574, 144); //const34
        writeBlock(tex, br0, 144, 864, 574, 144); //const35
        writeBlock(tex, br0, 20736, 288, 513, 144); //const36
        writeBlock(tex, br0, 144, 720, 575, 144); //const37
        writeBlock(tex, br0, 144, 864, 575, 144); //const38
        writeBlock(tex, br0, 144, 576, 576, 144); //const39
        writeBlock(tex, br0, 144, 720, 576, 144); //const40
        writeBlock(tex, br0, 144, 864, 576, 144); //const41
        writeBlock(tex, br0, 3600, 777, 513, 144); //const42
        writeBlock(tex, br0, 144, 720, 577, 144); //const43
        writeBlock(tex, br0, 144, 864, 577, 144); //const44
        writeBlock(tex, br0, 144, 576, 578, 144); //const45
        writeBlock(tex, br0, 144, 720, 578, 144); //const46
        writeBlock(tex, br0, 144, 864, 578, 144); //const47
        writeBlock(tex, br0, 20736, 0, 513, 144); //const48
        writeBlock(tex, br0, 144, 720, 579, 144); //const49
        writeBlock(tex, br0, 144, 864, 579, 144); //const50
        writeBlock(tex, br0, 144, 576, 580, 144); //const51
        writeBlock(tex, br0, 144, 720, 580, 144); //const52
        writeBlock(tex, br0, 144, 864, 580, 144); //const53

        //writeBlock(tex, br0, 497097, 0, 0, 969); //const54
        for (int i = 0; i < 144; i++)
        {
            int x = (i % 17) * 57;
            int y = (i / 17) * 57;
            writeBlock(tex, br0, 3225, x, y, 57);
        }

        writeBlock(tex, br0, 3225, 576, 513, 57); //const55

    }
}

#endif