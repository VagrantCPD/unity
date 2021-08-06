// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// 逐顶点漫反射光照
Shader "Unlit/Chapter6/DiffuseVertexLevel"
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
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
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
                fixed3 color : COLOR;
            };

            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //模型空间的法向量——>世界坐标系下的法向量
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)(unity_WorldToObject)));

                //获取光源方向
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                //计算漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse * saturate(dot(worldNormal, worldLight));

                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color.rgb, 1.0);
            }
            ENDCG
        }

    }

}
