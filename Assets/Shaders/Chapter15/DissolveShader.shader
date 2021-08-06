Shader "Unlit/Chapter15/DissolveShader"
{
    // 用来实现物体消融效果的着色器
    /*
    实现原理： 噪声纹理 + 透明度测试 + 烧焦边缘

    镂空效果的实现：通过从噪声纹理中采样，与给定阈值比较，如果小于阈值则不渲染

    烧焦边缘的实现：两种颜色混合，经过pow函数乘幂，然后与源颜色混合
    */
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 控制消融程度的阈值。为0时正常渲染，为1时，物体完全消融
        _BurnAmount ("Burn Amount", Range(0.0, 1.0)) = 0.0
        // 烧焦边缘线的宽度
        _LineWidth ("Burn Line Width", Range(0.0, 2.0)) = 1.0
        // 法线纹理贴图
        _BumpMap ("Bump Map", 2D) = "white" {}
        // 两种混合颜色（用于控制烧焦边缘线的颜色）
        _BurnFirstColor ("Burn First Color", Color) = (1, 1, 1, 1)
        _BurnSecondColor ("Burn Second Color", Color) = (1, 1, 1, 1)
        // 噪声图
        _BurnMap ("Burn Map", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            // 关闭背面剔除，因为镂空处可以看到背面
            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uvMainTex : TEXCOORD0;
                float4 pos : SV_POSITION;
                float2 uvBumpMap : TEXCOORD1;
                float2 uvBurnMap : TEXCOORD2;
                // 切线空间下的光源方向
                float3 lightDir : TEXCOORD3;
                float3 worldPos : TEXCOORD4;
                SHADOW_COORDS(5)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _BurnAmount;
            float _LineWidth;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;

            float4 _BurnFirstColor;
            float4 _BurnSecondColor;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvMainTex = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvBumpMap = TRANSFORM_TEX(v.uv, _BumpMap);
                o.uvBurnMap = TRANSFORM_TEX(v.uv, _BurnMap);

                // 将光源方向转换到切线空间下
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样噪声纹理，小于阈值的不渲染
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                clip(burn.r - _BurnAmount);

                // 切线空间下的光源方向
                fixed3 tagentLightDir = normalize(i.lightDir);
                // 切线空间下的法向量
                fixed3 tagentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

                // sample the texture
                fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                // 漫反射
                float halfLambert = 0.5 * dot(tagentLightDir, tagentNormal) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                // 计算烧焦颜色
                fixed t = 1.0 - smoothstep(0.0, _LineWidth, burn.r - _BurnAmount);
                fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
                burnColor = pow(burnColor, 5);

                // 光照衰减
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                // 源颜色和烧焦颜色混合
                fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t * step(0.0001, _BurnAmount));

                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }

        // 处理阴影的pass
        Pass {
            Tags { "LightMode" = "ShadowCaster" }
            
            Cull off

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"
            
            fixed _BurnAmount;
            sampler2D _BurnMap;
            float4 _BurnMap_ST;
            
            struct v2f {
                V2F_SHADOW_CASTER;
                float2 uvBurnMap : TEXCOORD1;
            };
            
            v2f vert(appdata_base v) {
                v2f o;
                
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                
                o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                fixed3 burn = tex2D(_BurnMap, i.uvBurnMap).rgb;
                
                clip(burn.r - _BurnAmount);
                
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
