// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// 多光源前向渲染
Shader "Unlit/Chapter9/ForwardRenderShader"
{
    Properties
    {
        _Diffuse ("Diffuse Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256.0)) = 20.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // 渲染环境光和一个逐像素平行光的pass
        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM

            // 需要该声明来保证如衰减等变量的正确赋值
            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // blinn-phong光照模型
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 halfVector = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular * pow(max(0, dot(halfVector, worldNormal)), _Gloss);

                // base pass中的光源衰减因子为1
                float attenuation = 1.0;

                return fixed4((ambient + diffuse + specular) * attenuation, 1.0);
            }
            ENDCG
        }

        // 渲染其他逐像素光源的pass，在代码中不同的光源类型有不同的光源属性获取方式
        Pass
        {
            Tags {"LightMode"="ForwardAdd"}

            // 需要开启混合模式，将渲染结果叠加到base pass的渲染结果上
            Blend One One

            CGPROGRAM

            // 需要该声明来保证如衰减等变量的正确赋值
            #pragma multi_compile_fwdadd

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
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // blinn-phong光照模型
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

                // 环境光只需要在base pass中计算一次即可
                // fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

                fixed3 halfVector = normalize(worldLightDir + worldViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfVector, worldNormal)), _Gloss);

                // 计算衰减因子
                // 使用平行光，衰减因子为1
                #ifdef USING_DIRECTIONAL_LIGHT
                    fixed attenuation = 1.0;
                #else
                    // 使用点光源
                    #if defined(POINT)
                        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
                        float d2 = dot(lightCoord, lightCoord);
                        fixed attenuation = tex2D(_LightTexture0, float2(d2,d2)).UNITY_ATTEN_CHANNEL;
                        // 使用聚光源
                    #elif defined(SPOT)
                        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
                        fixed attenuation = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
                        // 其他
                    #else
                        fixed attenuation = 1.0;
                    #endif
                #endif



                return fixed4((diffuse + specular) * attenuation, 1.0);
            }


            ENDCG
        }
    }
}
