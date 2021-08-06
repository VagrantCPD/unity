// alpha测试，关闭背面剔除
Shader "Unlit/Chapter8/AlphaTestCullOff"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _CutOff ("Alpha CutOff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="TransparentCutOut" 
                "IgnoreProjector"="true"
                "Queue"="AlphaTest"}
        LOD 100

        Pass
        {
            // 关闭背面剔除
            Cull off
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
            fixed _CutOff;

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

                // 当透明度小于指定阈值时，直接丢弃该片元的渲染
                clip(texColor.a - _CutOff);

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                
                float halfLambert = 0.5 * dot(worldNormal, lightDir) + 0.5;
                fixed3 diffuse = _LightColor0.rgb * albedo * halfLambert;

                return fixed4(ambient + diffuse, 1.0);
            }
            ENDCG
        }
    }
}
