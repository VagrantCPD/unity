Shader "Unlit/Chapter13/MotionBlurWithDepthTexture"
{
    // 利用深度纹理实现动态模糊效果
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Szie", Float) = 0.5
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
            float2 uv_depth : TEXCOORD1;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;

        sampler2D _CameraDepthTexture;

        // 上一帧相机的视角*投影矩阵
        float4x4 _PreviousViewProjectionMatrix;
        // 当前帧相机的视角*投影矩阵的逆矩阵
        float4x4 _currentViewProjectionInverseMatrix;

        float _BlurSize;


        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            o.uv_depth = TRANSFORM_TEX(v.uv, _MainTex);

            // 当处理多张纹理时，在DirectX平台上，图像的y轴朝向可能不同，因此需要统一平台差异
            

            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // 获取当前像素对应的深度值
            float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            // 通过uv坐标以及depth构建NDC坐标
            float4 ndc = float4(2 * i.uv.x - 1, 2 * i.uv.y - 1, 2 * depth - 1, 1);
            // 通过当前相机的视角*投影矩阵的逆矩阵将NDC坐标变换到世界空间
            float4 worldPos = mul(_currentViewProjectionInverseMatrix, ndc);
            worldPos /= worldPos.w;

            // 当前帧的ndc
            float4 currentPos = ndc;
            // 计算上一帧的ndc
            float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
            previousPos /= previousPos.w;

            // 速度向量
            float2 velocity = float2(currentPos.xy - previousPos.xy) / 2.0;

            // 第一次采样
            float2 uv = i.uv;
            float4 color = tex2D(_MainTex, uv);
            
            // 沿速度方向对相邻像素多次采样
            for(int it = 1; it < 4; ++it)
            {
                // uv坐标沿速度方向偏移
                uv += float2(velocity.x * _BlurSize, velocity.y * _BlurSize);
                color += tex2D(_MainTex, uv);
            }

            // 取采样平均值
            return color / 4;
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
