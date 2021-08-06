// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// 凹凸映射（使用法线纹理，纹理中存储切线空间下的法向量），在世界空间中进行光照计算

Shader "Unlit/Chapter7/NormalMapWorldShader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

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
                float4 vertex : SV_POSITION;
                // 切线空间到世界空间变换矩阵的三行，每个向量的w分量依次存储顶点在世界坐标系下的xyz
                float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
				float4 TtoW1 : TEXCOORD2;  
				float4 TtoW2 : TEXCOORD3; 
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


                // 构造从切线空间转换到世界空间的矩阵(????)
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));  
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 

                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                // 对法线纹理采样
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

                // 将切线空间下的法向量转换到世界空间下
                bump = normalize(half3(dot(i.TtoW0.xyz, bump),
                                        dot(i.TtoW1.xyz, bump),
                                        dot(i.TtoW2.xyz, bump)));

                // 在世界空间下计算光照
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float halfLambert = 0.5 * dot(bump, lightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                fixed3 halfVector = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfVector)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }

    }
}
