Shader "Custom/Chapter17/BumpedSpecular"
{
    // 简单的表面着色器
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM

        // 编译指令，指明表面着色器使用的表面函数和光照函数

        // 下面这条指令中
        // surf对应下面的surf函数
        // Standard指定使用的光照函数，它将surf函数中设置的表面属性应用到光照模型上
        // fullforwardshadows为额外参数，在前向渲染中支持所有光源类型的阴影
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        fixed4 _Color;

        // 表面函数surf的输入，自定义顶点修改函数的输出
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // SurfaceOutputStandard，表面函数的输出，光照函数的输入，存储各种表面属性
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
