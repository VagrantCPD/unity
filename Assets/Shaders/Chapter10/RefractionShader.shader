Shader "Unlit/Chapter10/RefractionShader"
{
    //利用cube纹理进行环境折射
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        //折射颜色
        _RefractColor ("Reflect Color", Color) = (1, 1, 1, 1)
        //介质透射比
        _RefractRatio ("Refract Ratio", Range(0.1, 1)) = 0.5
        //折射程度
        _RefractScale ("Refract Scale", Range(0, 1)) = 1
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
                fixed3 worldNormal : TEXCOORD1;
                fixed3 worldViewDir : TEXCOORD2;
                fixed3 worldRefract : TEXCOORD3;
                SHADOW_COORDS(4) 
            };

            fixed4 _Color;

            fixed4 _RefractColor;
            float _RefractRatio;
            float _RefractScale;

            samplerCUBE _CubeMap;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldViewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));

                //计算折射向量
                //计算公式：η1 sinθ1 = η2 sin θ2
                //θ1：入射光线；η1：入射光线所在介质的折射率
                //θ2：折射光线；η2：折射光线所在介质的折射率
                //_RefractRatio即为η1和η2的比值
                o.worldRefract = refract(-o.worldViewDir, o.worldNormal, _RefractRatio);

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

                //使用折射向量从cube map中取样
                fixed3 refractionColor = texCUBE(_CubeMap, i.worldRefract).rgb * _RefractColor.rgb;

                //光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                //漫反射颜色和折射颜色线性混合
                fixed3 color = ambient + lerp(diffuse, refractionColor, _RefractScale);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
