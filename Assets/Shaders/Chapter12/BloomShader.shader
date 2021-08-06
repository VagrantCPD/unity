Shader "Unlit/Chapter12/BloomShader"
{
    // 用来实现光源bloom的着色器
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
        _Bloom ("Bloom Texture", 2D) = "white" {}
        _LuminanceTreshold ("Luminance Threshold", Float) = 0.6
    }
    SubShader
    {
        CGINCLUDE

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

        struct v2fBloom
        {
            half4 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;

        float _BlurSize;

        sampler2D _Bloom;
        float4 _Bloom_ST;

        float _LuminanceTreshold;

        // 用于根据给定阈值提取较亮区域的顶点着色器
        v2f vertExtractBright(appdata v)
        {
            v2f o;

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);

            return o;
        }

        // 用于根据给定阈值提取较亮区域的片段着色器
        fixed4 fragExtractBright(v2f i) : SV_TARGET
        {
            fixed4 col = tex2D(_MainTex, i.uv);
            fixed val = clamp(Luminance(col.rgb) - _LuminanceTreshold, 0.0, 1.0);

            return col * val;
        }

        // 用于混合模糊后的图像和源图像的顶点着色器
        v2fBloom vertBloom(appdata v)
        {
            v2fBloom o;

            o.vertex = UnityObjectToClipPos(v.vertex);

            // 源图像的纹理坐标
            o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
            // 模糊图像的纹理坐标
            o.uv.zw = TRANSFORM_TEX(v.uv, _Bloom);

            return o;
        }

        // 用于混合模糊后的图像和源图像的片段着色器
        fixed4 fragBloom(v2fBloom i) : SV_TARGET
        {
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
        }

        ENDCG
        
        ZTest Always
        Cull off
        ZWrite off

        // pass 0：提取源图像中较亮的区域
        Pass
        {
            CGPROGRAM

            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright

            ENDCG
        }

        // pass 1：竖直方向高斯模糊
        UsePass "Unlit/Chapter12/GuassBlurShader/GAUSSIAN_BLUR_VERTICAL"

        // pass 2：水平方向高斯模糊
        UsePass "Unlit/Chapter12/GuassBlurShader/GAUSSIAN_BLUR_HORIZONTAL"

        // pass 3：混合源图像和模糊图像
        Pass
        {
            CGPROGRAM

            #pragma vertex vertBloom
            #pragma fragment fragBloom

            ENDCG
        }
    }

    Fallback off
}
