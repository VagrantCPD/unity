Shader "Unlit/Chapter14/ToonShader"
{
    // 用来实现简单卡通渲染的着色器
    /*
    实现原理：轮廓描边 + 漫反射纹理采样 + 纯色高光

    描边：首先用轮廓线颜色纯色渲染模型背面，渲染时顶点沿法向量做一定延伸
    然后正常渲染正面即可（这一步可以和纯色高光部分一起进行）
    
    漫反射纹理采样：使用半兰伯特光照模型计算出diffuse值，然后使用(diffuse, diffuse)为uv坐标
    去渐变纹理中采样获得漫反射颜色

    纯色高光：在计算高光时，判断法向量和半向量（光源方向 + 视角方向）的乘机是否大于高光阈值
    如果大于，则高光系数为1，否则为0（实际实现中，需要考虑在边界处采用缓和手段）
    */
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        // 用于控制漫反射色调的渐变纹理
        _Ramp ("Ramp Texture", 2D) = "white" {}
        // 控制轮廓线宽度
        _Outline ("Out line", Range(0, 1)) = 0.1
        // 轮廓线颜色
        _OutlineColor ("Outline Color", Color) = (0, 0 , 0, 0)
        // 高光颜色
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        // 高光阈值（超过该阈值被认为是高光区域）
        _SpecularTreshold ("Specular Threshold", Range(0, 1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        LOD 100


        CGINCLUDE

        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"
        #include "UnityShaderVariables.cginc"

        struct appdataOutline
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
        };

        struct v2fOutline
        {
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;

        float4 _Color;

        sampler2D _Ramp;

        float _Outline;
        float4 _OutlineColor;

        float4 _SpecularColor;
        float _SpecularTreshold;

        // 渲染背面的顶点着色器
        v2fOutline vertOultine (appdataOutline v)
        {
            v2fOutline o;

            // 将顶点坐标和法向量均转换到视角空间下
            float4 viewPos = mul(UNITY_MATRIX_MV, v.vertex);
            float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);

            // 减少凹面模型背面扩张后遮挡正面的可能性
            viewNormal.z = -0.5;
            // 沿法线方向偏移
            viewPos += float4(normalize(viewNormal), 0.0) * _Outline;

            o.vertex = mul(UNITY_MATRIX_P, viewPos);

            return o;
        }

        // 渲染背面的片段着色器
        fixed4 fragOutline (v2fOutline i) : SV_Target
        {
            return fixed4(_OutlineColor.rgb, 1.0);
        }

        struct appdataSpecular
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
        };

        struct v2fSpecular
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 worldNormal : TEXCOORD1;
            float3 worldPos : TEXCOORD2;
            SHADOW_COORDS(3)
        };

        // 渲染高光的顶点着色器
        v2fSpecular vertSpecular (appdataSpecular v)
        {
            v2fSpecular o;

            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            o.worldNormal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

            TRANSFER_SHADOW(o);

            return o;
        }

        // 渲染高光的片段着色器
        fixed4 fragSpecular (v2fSpecular i) : SV_Target
        {
            fixed3 worldNormal = normalize(i.worldNormal);
            fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
            fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
            fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);

            fixed4 col = tex2D(_MainTex, i.uv);
            fixed3 albedo = col.rgb * _Color.rgb;

            // 环境光
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

            // 光照衰减
            UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

            // 漫反射光，使用漫反射系数从渐变纹理中采样
            fixed halfLambert = (0.5 * dot(worldNormal, worldLightDir) + 0.5) * atten;
            fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(halfLambert, halfLambert)).rgb;

            // 高光
            fixed spec = dot(worldNormal, worldHalfDir);
            // 边界抗锯齿处理，fwidth返回邻域像素高光系数变化的近似导数值
            fixed w = fwidth(spec) * 2.0;
            // [-w, w]代表高光区域的边界，使用smoothstep函数在边界处对高光系数进行插值来避免锯齿
            // step(0.0001, _SpecularTreshold)用于在阈值为0时，完全消除高光
            // smoothstep(a, b, x)：当x < a时，返回0；当x > b时，返回1；当x在两者之间时，返回（x - a）/（b - a）
            fixed3 specular = _SpecularColor.rgb * smoothstep(-w, w, spec - _SpecularTreshold) * step(0.0001, _SpecularTreshold);

            return fixed4(ambient + diffuse + specular, 1.0);
        }

        ENDCG


        // 渲染背面的pass
        Pass
        {
            NAME "OUTLINE"

            Cull front

            CGPROGRAM

            #pragma vertex vertOultine
            #pragma fragment fragOutline

            ENDCG
        }

        // 渲染高光的pass
        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            Cull back

            CGPROGRAM

            #pragma vertex vertSpecular
            #pragma fragment fragSpecular

            #pragma multi_compile_fwdbase

            ENDCG
        }
    }

    Fallback "Diffuse"
}
