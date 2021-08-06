Shader "Unlit/Chapter12/MotionBlurShader"
{
    // 用于实现动态模糊的着色器
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 模糊程度
        _BlurScale ("Blur Scale", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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

        sampler2D _MainTex;
        float4 _MainTex_ST;

        float _BlurScale;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        fixed4 fragRGB (v2f i) : SV_Target
        {
            return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurScale);
        }

        fixed4 fragA (v2f i) : SV_TARGET
        {
            return fixed4(tex2D(_MainTex, i.uv));
        }

        ENDCG


        ZTest Always
        Cull off
        ZWrite off

        // 只修改rgb通道的pass，通过给定的_BlurScale进行透明度混合
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            ColorMask RGB

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragRGB

            ENDCG
        }

        // 只修改a通道的pass
        // 采用one zero混合模式，保证当前帧和上一帧的混合不影响当前帧的透明度
        Pass
        {
            Blend One Zero

            ColorMask A

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragA

            ENDCG
        }
    }

    Fallback off
}
