Shader "Unlit/Chapter10/ReflectShader"
{
    //利用cube纹理进行环境反射
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        //反射颜色
        _ReflectColor ("Reflect Color", Color) = (1, 1, 1, 1)
        //反射程度
        _ReflectScale ("Reflect Scale", Range(0, 1)) = 1
        //采样的立方体纹理
        _CubeMap ("Cube Map", Cube) = "_Skybox" {}
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
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                /*
                物体反射到相机中的光线，可以通过光路的可逆原则求得
                即可以通过计算view关于法向量的反射方向来求得入射光线的方向
                */
                float3 worldReflect : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            fixed4 _Color;

            fixed4 _ReflectColor;
            float _ReflectScale;

            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
                o.worldReflect = reflect(-o.worldViewDir, o.worldNormal);

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //漫反射光
                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * halfLambert;

                //使用世界空间下的反射向量从cube map中采样
                fixed3 reflectColor = texCUBE(_CubeMap, i.worldReflect).rgb * _ReflectColor.rgb;

                //光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                //漫反射颜色和反射颜色线性混合
                fixed3 color = ambient + lerp(diffuse, reflectColor, _ReflectScale) * atten;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
