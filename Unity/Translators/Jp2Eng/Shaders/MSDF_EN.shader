Shader "Translator/Jp2Eng/MSDF EN"
{
    Properties
    {
        _MainTex ("Translator Input", 2D) = "white" {}
        [HDR]_Color("Text Color", Color) = (1, 1, 1, 1)
        [HDR]_BGColor("BG Color", Color) = (0, 0, 0, 1)
        [NoScaleOffset]_MSDFTex("MSDF Texture", 2D) = "black" {}
        _CharWidth ("MSDF Character Width", Int) = 71
        _Size ("MSDF Column Size", Int) = 57
        _MaxLen ("Sentence Max Length", Int) = 40
        _Offset ("Word Offset", Int) = 0
        _Index ("Index Test", Float) = 0
        [HideIninspector]_PixelRange("Pixel Range", Float) = 4.0
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
        
        ZWrite Off
        //Blend SrcAlpha OneMinusSrcAlpha 
        AlphaToMask On
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "./Transformer/Jp2EngInclude.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            Texture2D<float> _MainTex;
            float4 _Color;
            float4 _BGColor;
            sampler2D _MSDFTex; float4 _MSDFTex_TexelSize;
            float _PixelRange;
            uint _CharWidth;
            uint _Size;
            uint _MaxLen;
            uint _Index;
            uint _Offset;

            float median(float r, float g, float b) 
            {
                return max(min(r, g), min(max(r, g), b));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color * _Color;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                i.uv /= _Size;
                i.uv.x *= _MaxLen;
                float2 actualSize = _Size * _CharWidth;

                uint word = getCharSeq(_MainTex, i.uv.x * _Size + _Offset);
                i.uv.x = mod(i.uv.x, 1.0 / _Size);
                i.uv.x += ((word % _Size) * _CharWidth) / _MSDFTex_TexelSize.z;
                i.uv.y += ((_Size - (word / _Size) - 1) * _CharWidth) / _MSDFTex_TexelSize.w;

                float2 msdfUnit = _PixelRange / _MSDFTex_TexelSize.zw;
                float4 sampleCol = tex2D(_MSDFTex, i.uv);
                float sigDist = median(sampleCol.r, sampleCol.g, sampleCol.b) - 0.5;
                sigDist *= max(dot(msdfUnit, 0.5/fwidth(i.uv)), 1); // Max to handle fading out to quads in the distance
                float opacity = clamp(sigDist + 0.5, 0.0, 1.0);
                float4 color = lerp(_BGColor, i.color, opacity);

                color.a = word < 1 ? 0.0 : color.a;
                clip(color.a - 0.005);

                return color;
            }
            ENDCG
        }
    }
}
