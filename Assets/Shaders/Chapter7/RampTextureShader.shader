// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// 使用渐变纹理来计算漫反射光照
Shader "Unlit/Chapter7/RampTextureShader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4 _Color;

            sampler2D _RampTex;
            float4 _RampTex_ST;

            float4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _RampTex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 使用半兰伯特值对作为访问渐变纹理的UV坐标
                float halfLambert = 0.5 * dot(worldLightDir, worldNormal) + 0.5;
                fixed3 albedo = tex2D(_RampTex, float2(halfLambert, halfLambert)).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo;

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfVector = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular * pow(max(0, dot(halfVector, worldNormal)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
}
