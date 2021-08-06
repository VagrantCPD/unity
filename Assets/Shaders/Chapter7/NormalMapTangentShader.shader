// 凹凸映射（使用法线纹理，纹理中存储切线空间下的法向量），在切线空间中进行光照计算

Shader "Unlit/Chapter7/NormalMapTagnetShader"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        // 法线贴图
        _BumpMap ("Normal Map", 2D) = "white" {}
        // 控制凹凸程度
        _BumpScale ("Bump Scale", Range(-1.0, 1.0)) = 1.0
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 255.0)) = 20.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                // uv的xy分量存储_MainTex的UV坐标，zw分量存储_BumpMap的UV坐标
                float4 uv : TEXCOORD0;
                // 切线空间下的光源方向
                fixed3 lightDir : TEXCOORD1;
                // 切线空间下的观察向量
                fixed3 viewDir : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _BumpMap);

                // 构造模型空间到切线空间的转换矩阵
                // 1，计算副切线(法向量和切线的叉乘，乘以w分量来选择副切线的方向)
                float3 binormal = cross(normalize(v.normal), normalize(v.tangent)).xyz * v.tangent.w;
                
                // 2，构造矩阵
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                // 计算切线空间下的光源方向和观察向量
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                o.viewDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 对法线贴图进行采样，变换获取法向量
                // 从贴图获取的分量值在[0, 1]之间
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                // 将其变换到[-1, 1]之间
                fixed3 tangentNormal;
                // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                // tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 如果对应的法线纹理的type在unity中已经设置为Normal Map，则使用unity内置函数计算切线空间的法向量
                tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // 对主纹理采样计算反射率
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                //漫反射光
                float halfLambert = 0.5 * dot(i.lightDir, tangentNormal) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                // 镜面高光
                fixed3 halfVector = normalize(i.lightDir + i.viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfVector)), _Gloss);
                
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
