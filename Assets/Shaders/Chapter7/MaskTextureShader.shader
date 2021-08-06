// 使用遮罩纹理控制镜面高光
Shader "Unlit/Chapter7/MaskTexture_Shader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "white" {}
        _BumpScale ("Bump Scale", Range(-1.0, 1.0)) = 0.8
        // 用于控制高光的遮罩纹理
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        // 遮罩纹理的影响系数
        _SpecularScale ("Specular Mask Scale", Range(0.0, 1.0)) = 1.0
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256.0)) = 20.0
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                // uv的xy分量存储_MainTex的UV坐标，zw分量存储_BumpMap的UV坐标
                float2 uv : TEXCOORD0;
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
            float _BumpScale;

            sampler2D _SpecularMask;
            float _SpecularScale;

            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

                float3 binormal = cross(v.normal, v.tangent).xyz * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                o.viewDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)).xyz);
                

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 packedNormal = tex2D(_BumpMap, i.uv);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float halfLambert = 0.5 * dot(tangentNormal, i.lightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                fixed3 halfVector = normalize(i.lightDir + i.viewDir);
                // 使用遮罩纹理控制镜面高光
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(halfVector, tangentNormal)), _Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
