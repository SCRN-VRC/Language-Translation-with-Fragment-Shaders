Shader "Translator/Jp2Eng/Masks"
{
    Properties
    {
        _WeightsTex ("Baked Weights", 2D) = "black" {}
        _LayersTex ("Layers Texture", 2D) = "black" {}
        _WeightBiasLoopID ("Weight, Bias, Loop Max, CurID", Vector) = (0, 0, 0, 0)
        _MaxDist ("Max Distance", Float) = 0.02
    }
    SubShader
    {
        Tags { "Queue"="Overlay+1" "ForceNoShadowCasting"="True" "IgnoreProjector"="True" }
        ZWrite Off
        ZTest Always
        Cull Front
        
        Pass
        {
            Lighting Off
            SeparateSpecular Off
            Fog { Mode Off }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "Jp2EngInclude.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _WeightsTex;
            Texture2D<float> _LayersTex;
            float4 _LayersTex_TexelSize;
            float _MaxDist;

            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(uint4, _WeightBiasLoopID)
                UNITY_DEFINE_INSTANCED_PROP(uint4, _PrevID)
            UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
                o.vertex = float4(v.uv * 2 - 1, 0, 1);
                #ifdef UNITY_UV_STARTS_AT_TOP
                v.uv.y = 1-v.uv.y;
                #endif
                o.uv.xy = UnityStereoTransformScreenSpaceTex(v.uv);
                o.uv.z = distance(_WorldSpaceCameraPos,
                   mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz) > _MaxDist ? -1.0 : 1.0;
                o.uv.z = unity_OrthoParams.w ? o.uv.z : -1.0;
                return o;
            }

            float frag (v2f i) : SV_Target
            {
                clip(i.uv.z);

                UNITY_SETUP_INSTANCE_ID(i);
                uint4 WBLID = UNITY_ACCESS_INSTANCED_PROP(Props, _WeightBiasLoopID);

                uint2 px = i.uv.xy * _LayersTex_TexelSize.zw;
                uint4 renderPos = layersPos[WBLID.w];
                bool renderArea = insideArea(renderPos, px);
                clip(renderArea ? 1.0 : -1.0);

                float col = _LayersTex.Load(uint3(px, 0));
                px -= renderPos.xy;

                uint TLState = floor(_LayersTex[txTLState]);

                float s = col;
                // encoder mask
                if (px.x < 22)
                {
                    if (TLState == ST_ENC_EMBED)
                    {
                        s = abs(getWordJp(_LayersTex, px.x)) < 0.00001 ? -1.0e9 : 0.0;
                    }
                }
                // decoder target mask
                else
                {
                    if (TLState == ST_DEC_SEQ)
                    {
                        px.x -= 22;
                        s = abs(getWordEng(_LayersTex, px.x)) < 0.00001 ? -1.0e9 : 0.0;
                        float targetMask = (px.x <= px.y) ? 0.0 : -1.0e9f;
                        s = min(targetMask, s);
                    }
                }
                col = s;

                return col;
            }
            ENDCG
        }
    }
}
