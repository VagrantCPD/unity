Shader "Unlit/Chapter13/EdgeDetectRobertShader"
{
    // 使用Robert算子和深度法线纹理实现边缘检测
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 0.0
        _EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)
        _EdgeScale ("Edge Scale", Float) = 1.0
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
        _SensitiveDepth ("Sensitive Depth", Float) = 1.0
        _SensitiveNormals ("Sensitive Normals", Float) = 1.0 
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
            float2 uv[5] : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;

        float _EdgeOnly;
        float4 _EdgeColor;
        float _EdgeScale;

        float4 _BackgroundColor;

        float _SensitiveDepth;
        float _SensitiveNormals;

        sampler2D _CameraDepthNormalsTexture;


        /*
        Robert 算子

        gx  -1  0
        0   1

        gy  0   -1
        1   0 
        */

        // 若存在边界，返回1；否则返回0
        //  参数为（法线，深度）
        half CheckEdge(half4 frag1, half4 frag2)
        {
            half2 frag1Normal = frag1.xy;
            half2 frag1Depth = DecodeFloatRG(frag1.zw);
            half2 frag2Normal = frag2.xy;
            half2 frag2Depth = DecodeFloatRG(frag2.zw);

            // 法线差
            half2 normalDifference = abs(frag1Normal - frag2Normal) * _SensitiveNormals;
            int isSameNormal = (normalDifference.x + normalDifference.y) < 0.1;

            // 深度差
            half depthDifference = abs(frag1Depth - frag2Depth) * _SensitiveDepth;
            int isSameDepth = depthDifference < 0.1 * frag1Depth;

            return isSameDepth * isSameNormal ? 1.0 : 0.0;
        }

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv[0] = TRANSFORM_TEX(v.uv, _MainTex);

            // 获取以当前像素为中心的相邻四个像素的uv坐标
            o.uv[1] = o.uv[0] + _MainTex_TexelSize.xy * half2(1, 1) * _EdgeScale;
            o.uv[2] = o.uv[0] + _MainTex_TexelSize.xy * half2(-1, -1) * _EdgeScale;
            o.uv[3] = o.uv[0] + _MainTex_TexelSize.xy * half2(-1, 1) * _EdgeScale;
            o.uv[4] = o.uv[0] + _MainTex_TexelSize.xy * half2(1, -1) * _EdgeScale;

            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv[0]);

            // 右上角
            half4 frag1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
            // 左下角
            half4 frag2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
            // 左上角
            half4 frag3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
            // 右下角
            half4 frag4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

            half edge = 1.0;

            // 检查右上——左下、左上——右下是否存在边界
            edge *= CheckEdge(frag1, frag2);
            edge *= CheckEdge(frag3, frag4);

            // 计算背景为原图时的颜色值
            col = lerp(_EdgeColor, col, edge);
            // 计算背景为纯色时的颜色值
            fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

            return lerp(col, onlyEdgeColor, _EdgeOnly);
        }
        ENDCG

        Pass
        {
            ZTest Always
            Cull off
            ZWrite off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            ENDCG
        }
    }
}
