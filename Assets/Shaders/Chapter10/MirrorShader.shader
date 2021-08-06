Shader "Unlit/Chapter10/MirrorShader"
{
    Properties
    {
        _MirrorTex ("Camera Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            sampler2D _MirrorTex;
            float4 _MirrorTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MirrorTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 reverseU = float2(1.0 - i.uv.x, i.uv.y);
                fixed4 col = tex2D(_MirrorTex, reverseU);
                return col;
            }
            ENDCG
        }
    }
}
