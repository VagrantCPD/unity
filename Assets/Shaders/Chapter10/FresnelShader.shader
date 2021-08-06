Shader "Unlit/Chapter10/FresnelShader"
{
    //模拟菲涅尔反射
    //近似公式：F = F0 + （1 - F0）（1 - v * n）^ 5
    //其中F0为反射系数，v为视角方向，n为物体表面法向量
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        //反射颜色
        _ReflectColor ("Reflect Color", Color) = (1, 1, 1, 1)
        //反射系数
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 0.5
        //用来采样的cube纹理
        _Cubemap ("Cube Map", Cube) = "_Skybox" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldReflect : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            fixed4 _Color;

            fixed4 _ReflectColor;
            float _FresnelScale;

            samplerCUBE _Cubemap;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldViewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = i.worldNormal;
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = i.worldViewDir;

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //漫反射
                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * halfLambert;

                //反射光
                fixed3 reflectColor = texCUBE(_Cubemap, i.worldReflect).rgb * _ReflectColor.rgb;

                //光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                //根据近似菲涅尔公式计算混合因子
                float fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal),5);
                fixed3 color = ambient + lerp(diffuse, reflectColor, fresnel) * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
