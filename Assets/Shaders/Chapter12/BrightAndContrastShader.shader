Shader "Unlit/Chapter12/BrightAndContrastShader"
{
    // 用于调整画面亮度、对比度、饱和度的屏幕后处理shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness ("Brightness", Float) = 1
        _Saturation ("Saturation", Float) = 1
        _Contrast ("Contrast", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {

            ZTest Always
            Cull off
            // 关闭深度写入，防止影响到后续物体的渲染
            ZWrite off

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Brightness;
            float _Saturation;
            float _Contrast;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                // 应用亮度
                col.rgb *= _Brightness;

                // 应用饱和度
                fixed3 luminance = Luminance(col.rgb);
                // col.rgb = lerp(col.rgb, luminance, _Saturation);
                col.rgb = lerp(luminance, col.rgb, _Saturation);

                // 应用对比度
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                // col.rgb = lerp(col.rgb, avgColor, _Saturation);
                col.rgb = lerp(avgColor, col.rgb, _Contrast);

                return col;
            }
            ENDCG
        }
    }

    Fallback off
}
