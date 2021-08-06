Shader "Unlit/Chapter13/DepthAndNormalsShader"
{
    // 查看深度和法线纹理
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

        sampler2D _CameraDepthTexture;
        sampler2D _CameraDepthNormalsTexture;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        fixed4 fragDepth (v2f i) : SV_Target
        {
            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv);

            // 采样深度纹理
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
            // 线性化深度值
            float linearDepth = Linear01Depth(depth);
            fixed3 depthCol = fixed3(linearDepth, linearDepth, linearDepth);

            return fixed4(depthCol, 1.0);
        }


        fixed4 fragNormal (v2f i) : SV_Target
        {
            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv);

            // 采样深度法线纹理
            fixed3 normal = DecodeViewNormalStereo(tex2D(_CameraDepthNormalsTexture, i.uv));
            // [-1, 1] ——>  [0, 1]
            normal = normal * 0.5 + 0.5;

            return fixed4(normal, 1.0) * col;
        }

        ENDCG


        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragDepth

            ENDCG
        }

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment fragNormal

            ENDCG
        }
    }
}
