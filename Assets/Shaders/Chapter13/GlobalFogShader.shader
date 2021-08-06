Shader "Unlit/Chapter13/GlobalFogShader"
{
    // 实现全局雾效的着色器
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity ("Fog Density", float) = 1.0
        _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
        _FogStart ("Fog Start", float) = 0.0
        _FogEnd ("Fog End", float) = 2.0
        // 相机近平面距离
        _CameraNear ("Camera Near", float) = 0.0
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
            // 偏移方向的方向向量
            float4 ray : TEXCOORD2;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        half4 _MainTex_TexelSize;

        sampler2D _CameraDepthTexture;

        // 当前帧相机视角*投影矩阵的逆矩阵
        float4x4 _ViewProjectionInverseMatrix;
        // 相机前向量
        float4 _CameraForward;
        // 相机上向量（以近平面中心为原点）
        float4 _CameraUp;
        // 相机右向量（以近平面中心为原点）
        float4 _CameraRight;
        // 相机近平民距离
        float _CameraNear;

        float _FogDensity;
        float4 _FogColor;
        float _FogStart;
        float _FogEnd;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            o.uv_depth = TRANSFORM_TEX(v.uv, _MainTex);

            #if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1.0 - o.uv_depth.y;
            #endif

            // 计算偏移方向的方向向量
            float i = 2 * o.uv.x - 1;
            float j = 2 * o.uv.y - 1;

            float3 ray = _CameraForward + i * _CameraRight + j * _CameraUp;
            // 因为从深度纹理采样出的深度值是z值，而非欧氏距离（即两点距离）
            // 因此需要乘以scale来将深度值转换为欧氏距离
            float scale = length(ray) / _CameraNear;
            o.ray = float4(normalize(ray) * scale, 1.0);

            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            // sample the texture
            fixed4 col = tex2D(_MainTex, i.uv);

            // 采样深度纹理
            float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));

            // 重构世界空间坐标
            float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.ray.xyz;

            // 雾色和原色混合
            // 根据世界空间坐标的y值计算对应高度的雾的浓度
            float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
            fogDensity = saturate(fogDensity * _FogDensity);

            return lerp(col, _FogColor, fogDensity);
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
