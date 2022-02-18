Shader "HandwriteClassify/MSDF JP"
{
    Properties
    {
        _LayersTex ("Translator Output", 2D) = "white" {}
        [HDR]_Color("Text Color", Color) = (1, 1, 1, 1)
        [HDR]_BGColor("BG Color", Color) = (0, 0, 0, 1)
        [NoScaleOffset]_MSDFTex("MSDF Texture", 2D) = "black" {}
        _CharWidth ("MSDF Character Width", Int) = 71
        _Size ("MSDF Column Size", Int) = 57
        _MaxLen ("Sentence Max Length", Int) = 20
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
            #include "./ConvMixer/ConvMixerModel.cginc"

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

            Texture2D<float> _LayersTex;
            float4 _Color;
            float4 _BGColor;
            sampler2D _MSDFTex; float4 _MSDFTex_TexelSize;
            float _PixelRange;
            uint _CharWidth;
            uint _Size;
            uint _MaxLen;
            uint _Index;

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
                clip(unity_OrthoParams.w ? -1 : 1);
                float2 borderUV = i.uv;
                // highlight selected
                uint horzState = floor(_LayersTex[txHBtnState]);
                float horzSel = _LayersTex[txHBtnSel] *
                    ((horzState == HAND_DOWN) ? 1.0 : 0) - 1.0;
                float red = abs(i.uv.x - 0.1 * (1.0 + 2.0 * horzSel)) < 0.1 ? 1.0 : 0.0;
                _BGColor.rgb = lerp(_BGColor.rgb, float3(red, 0, 0), red.x);
                
                i.uv /= _Size;
                i.uv.x *= _MaxLen;
                float2 actualSize = _Size * _CharWidth;
                i.uv = i.uv * actualSize / _MSDFTex_TexelSize.zw;
                uint offx = floor(i.uv.x * _Size);
                uint word = round(_LayersTex[txTop1.xy + uint2(offx, 0)]);
                i.uv.x = mod(i.uv.x, 1.0 / _Size);
                float border = all(abs(float2(i.uv.x * _Size, borderUV.y) - 0.5) < 0.47) ? 1.0 : 0.0;
                i.uv.x += ((word % _Size) * _CharWidth) / _MSDFTex_TexelSize.z;
                i.uv.y += ((_Size - (word / _Size) - 1) * _CharWidth) / _MSDFTex_TexelSize.w;

                float2 msdfUnit = _PixelRange / actualSize;
                float4 sampleCol = tex2D(_MSDFTex, i.uv);
                float sigDist = median(sampleCol.r, sampleCol.g, sampleCol.b) - 0.5;
                sigDist *= max(dot(msdfUnit, 0.5/fwidth(i.uv)), 1); // Max to handle fading out to quads in the distance
                float opacity = clamp(sigDist + 0.5, 0.0, 1.0);
                float4 color = lerp(_BGColor, i.color, opacity);
                color.rgb *= border;

                color.a = word < 3 ? 0.0 : color.a;
                clip(color.a - 0.005);

                return color;
            }
            ENDCG
        }
    }
}
