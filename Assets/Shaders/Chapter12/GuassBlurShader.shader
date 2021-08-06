Shader "Unlit/Chapter12/GuassBlurShader"
{
    // 高斯模糊着色器，卷积核为5维
    // 使用两个pass渲染，一个pass负责竖直方向的模糊，一个pass负责水平方向的模糊
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", Float) = 1.0
    }
    SubShader
    {
        // 使用cginclude，可以在pass中重复使用frag函数，避免为两个pass编写重复的片段着色器
        // 作用类似于C++ 的 include头文件，提高代码重用率
        CGINCLUDE

        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct v2f
        {
            float2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;

        float _BlurSize;

        // 竖直方向模糊的顶点着色器
        v2f vertBlurVertical (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            
            half2 uv = v.uv;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[2] = uv + float2(0.0, _MainTex_TexelSize.y * -1.0) * _BlurSize;
            o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            o.uv[4] = uv + float2(0.0, _MainTex_TexelSize.y * -2.0) * _BlurSize;

            return o;
        }

        // 水平方向模糊的顶点着色器
        v2f vertBlurHorizontal(appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            
            half2 uv = v.uv;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[2] = uv + float2(_MainTex_TexelSize.x * -1.0, 0.0) * _BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            o.uv[4] = uv + float2(_MainTex_TexelSize.x * -2.0, 0.0) * _BlurSize;

            return o;
        }

        // 两个方向使用相同的片段着色器
        fixed4 frag (v2f i) : SV_Target
        {
            // 权重系数         中心    1格     2格
            float weight[3] = {0.4026, 0.2442, 0.0545};

            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv[0]) * weight[0];

            for(int it = 1; it < 3; ++it)
            {
                col += tex2D(_MainTex, i.uv[it]) * weight[it];
                col += tex2D(_MainTex, i.uv[it + 1]) * weight[it];
            }

            return col;
        }
        ENDCG
        
        ZTest Always
        Cull Off
        ZWrite Off

        // 竖直模糊的pass
        Pass
        {
            // 使用NAME语义，可以在其他着色器中通过usepass来重用该pass
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM

            #pragma vertex vertBlurVertical
            #pragma fragment frag

            ENDCG
        }

        // 水平模糊的pass
        Pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM

            #pragma vertex vertBlurHorizontal
            #pragma fragment frag

            ENDCG
        }
    }

    FallBack "Diffuse"
}
