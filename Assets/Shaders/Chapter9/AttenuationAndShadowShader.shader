// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Chapter9/AttenuationAndShadowShader"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // 用来渲染平行光的base pass
        Pass
        {
            Tags {"LightMode"="ForwardBase"}

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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                // 阴影坐标
                SHADOW_COORDS(2)
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 halfVector = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfVector, worldNormal)), _Gloss);

                // 使用unity内置函数统一光源衰减和阴影的计算
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }

        // 用来渲染次要光源的add pass
        Pass
        {
            Tags {"LightMode"="ForwardAdd"}

            Blend One One

            CGPROGRAM

            //#pragma multi_compile_fwdadd
            #pragma multi_compile_fwdadd_fullshadows

            #pragma vertex vert
            #pragma fragment frag

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
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                // 阴影坐标
                SHADOW_COORDS(2)
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 计算阴影坐标(即光源坐标系下的坐标)
                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 halfVector = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfVector, worldNormal)), _Gloss);


                // 使用unity内置函数统一光源衰减和阴影的计算
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4((diffuse + specular) * atten, 1.0);
            }

            ENDCG
        }
    }

    FallBack "Specular"
}
