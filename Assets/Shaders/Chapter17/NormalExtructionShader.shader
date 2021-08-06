Shader "Custom/Chapter17/NormalExtructionShader"
{
    // 实现模型沿法线膨胀的表面着色器
    // 顶点修改函数、表面函数、光照函数和最后的颜色修改函数均采用自定义函数
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "white" {}
        // 膨胀程度
        _Amount ("Amount", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        
        #pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow exclude_path:deferred exclude_path:prepass nometa

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        float _Amount;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        // 自定义顶点修改函数，在unity为surface shader生成的顶点着色器之前执行
        void myvert (inout appdata_full v)
        {
            v.vertex.xyz += _Amount * v.normal;
        }

        // 自定义表面函数，填充SurfaceOutput中的各种属性，为光照函数做准备
        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
        }

        // 自定义光照函数
        half4 LightingCustomLambert (SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = dot(s.Normal, lightDir);

            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * NdotL * atten;
            c.a = s.Alpha;
            return c;
        }

        // 自定义颜色修改函数，在颜色绘制到屏幕前，最后一次修改颜色
        void mycolor (Input IN, SurfaceOutput o, inout fixed4 color)
        {
            color *= _Color;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
