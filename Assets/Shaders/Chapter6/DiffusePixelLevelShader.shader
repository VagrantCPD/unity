// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// 逐像素漫反射光照
Shader "Unlit/Chapter6/DiffusePixelLevelShader"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            fixed3 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)(unity_WorldToObject)));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                //光源方向
                fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);

                //漫反射光
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLightDirection));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                fixed3 light = ambient + diffuse;
                return fixed4(light, 1.0);
            }
            ENDCG
        }
    }
}
