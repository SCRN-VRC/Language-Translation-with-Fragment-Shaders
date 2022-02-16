#if UNITY_EDITOR

using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Globalization;
using UnityEngine.Experimental.Rendering;

[ExecuteInEditMode]
public class BakeWordToChar : EditorWindow
{
    public TextAsset charList;
    public TextAsset wordMapping;
    string SavePath;

    [MenuItem("Tools/SCRN/Bake Eng WordToChar")]
    static void Init()
    {
        var window = GetWindowWithRect<BakeWordToChar>(new Rect(0, 0, 400, 250));
        window.Show();
    }

    void OnGUI()
    {
        GUILayout.Label("Bake WordToChar", EditorStyles.boldLabel);
        EditorGUILayout.BeginVertical();
        charList = (TextAsset) EditorGUILayout.ObjectField("English Character List (.txt):", charList, typeof(TextAsset), false);
        wordMapping = (TextAsset) EditorGUILayout.ObjectField("English Char2Word Mapping (.txt):", wordMapping, typeof(TextAsset), false);
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("Bake!") && charList != null && wordMapping != null) {
            string path = AssetDatabase.GetAssetPath(wordMapping);
            int fileDir = path.LastIndexOf("/");
            SavePath = path.Substring(0, fileDir) + "/baked-word2Char.asset";
            OnGenerateTexture();
        }
    }

    void OnGenerateTexture()
    {
        const int width = 211 * 2;
        const int height = 211 * 2;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RGBAFloat, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        tex.anisoLevel = 1;
        
        Dictionary<char, int> charSet = new Dictionary<char, int>();
        var arrayString = charList.text.Split('\n');
        int i = 0;
        foreach (var line in arrayString)
        {
            if (line.Length < 1) continue;
            charSet.Add(line[0], i);
            i++;
        }

        int[] bitField = new int[20];
        arrayString = wordMapping.text.Split('\n');

        i = 0;
        // char oldChar = 'A';
        foreach (var line in arrayString)
        {
            //if (line.Length < 1) continue;
            for (int j = 0; j < 20; j++)
            {
                bitField[j] = 0;
            }

            var tokens = line.Split('\t');

            int k = 0;
            foreach (char c in tokens[0])
            {
                int val;
                if (charSet.TryGetValue(c, out val))
                {
                    bitField[k] = charSet[c];
                }
                else
                {
                    Debug.Log(string.Format("Key {0} was not found on index {1}", c, i));
                }
                k++;
            }

            uint rChan = 0;
            uint gChan = 0;
            uint bChan = 0;
            uint aChan = 0;
        
            int x = (i % 211) * 2;
            int y = (i / 211) * 2;

            rChan = (uint) (bitField[0] << 6 | bitField[1]);
            gChan = (uint) (bitField[2] << 6 | bitField[3]);
            bChan = (uint) (bitField[4] << 6 | bitField[5]);
            aChan = (uint) (bitField[6] << 6 | bitField[7]);
            tex.SetPixel(x, y, new Color(rChan, gChan, bChan, aChan));

            rChan = (uint) (bitField[8] << 6 | bitField[9]);
            gChan = (uint) (bitField[10] << 6 | bitField[11]);
            bChan = (uint) (bitField[12] << 6 | bitField[13]);
            aChan = (uint) (bitField[14] << 6 | bitField[15]);
            tex.SetPixel(x + 1, y, new Color(rChan, gChan, bChan, aChan));

            rChan = (uint) (bitField[16] << 6 | bitField[17]);
            gChan = (uint) (bitField[18] << 6 | bitField[19]);
            tex.SetPixel(x, y + 1, new Color(rChan, gChan, 0, 0));

            tex.SetPixel(x + 1, y + 1, new Color(tokens[0].Length, 0, 0, 0));

            i++;
        }

        AssetDatabase.CreateAsset(tex, SavePath);
        AssetDatabase.SaveAssets();

        ShowNotification(new GUIContent("Done"));
    }
}

#endif