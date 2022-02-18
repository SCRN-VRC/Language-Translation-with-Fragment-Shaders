Shader "HandwriteClassify/VertBtns"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _Test ("Test", Vector) = (0, 0, 0 ,0)
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
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "ConvMixer/ConvMixerModel.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Digit data by P_Malin (https://www.shadertoy.com/view/4sf3RN)
            static const int font[10] = {0x75557, 0x22222, 0x74717, 0x74747, 0x11574, 0x71747, 0x71757, 0x74444, 0x75757, 0x75747};
            static const uint powers[5] = {1, 10, 100, 1000, 10000};
            float PrintInt( in float2 uv, in uint value, in int maxDigits )
            {
                if( abs(uv.y-0.5)<0.5 )
                {
                    int iu = int(floor(uv.x));
                    if( iu>=0 && iu<maxDigits )
                    {
                        uint n = (value/powers[maxDigits-iu-1]) % 10;
                        uv.x = frac(uv.x);//(uv.x-float(iu)); 
                        int2 p = int2(floor(uv*float2(4.0,5.0)));
                        return float(round((font[n] / pow(2, p.x+p.y*5 - p.y)) % 1));
                    }
                    else return 0.0;
                } else return 0.0;
            }

            //RWStructuredBuffer<float4> buffer : register(u1);
            sampler2D _MainTex;
            float4 _MainTex_ST;
            Texture2D<float> _LayersTex;
            float4 _Test;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                clip(unity_OrthoParams.w ? -1 : 1);
                uint btnState = floor(_LayersTex[txVBtnState]);
                float btnSel = _LayersTex[txVBtnSel];
                float selected = btnSel * (btnState == HAND_DOWN ? 1.0 : 0.0) - 1.0;
                // color the selection red
                float red = abs(i.uv.y - 0.1667 * (1.0 + 2.0 * selected)) < 0.1667 ? 1.0 : 0.0;
                float4 col = tex2D(_MainTex, i.uv);
                
                // float2 uv = i.uv * _Test.zw;
                // col = lerp(col, float4(0, 0, 0, 1), PrintInt((uv + _Test.xy), floor(btnSel), 2));
                // col = lerp(col, float4(0, 0, 0, 1), PrintInt((uv + _Test.xy + float2(0, 1.1)), floor(btnState), 2));
                
                col = lerp(float4(red, 0..xx, red), col, col.a);

                clip(col.a - 0.0001);
                return col;
            }
            ENDCG
        }
    }
}
