// 使用两个pass进行渲染
// pass1只写入深度缓冲
// pass2在pass1深度缓冲的基础上进行alpha blend
Shader "Unlit/Chapter8/AlphaBlendZWriteShader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" 
                "IgnoreProjector"="true"
                "Queue"="Transparent"}
        LOD 100

        // wrtie depth Buffer
        Pass
        {
            ZWrite on
            // color mask 为0意味着不写入任何颜色
            ColorMask 0
        }

        // alpha blend
        Pass
        {
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            // 控制透明程度
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                float3 worldPos = i.worldPos;
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                
                float halfLambert = 0.5 * dot(worldNormal, lightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}
