Shader "Unlit/Chapter5/SimpleShader"
{
    Properties
    {
        _Color ("Customized Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass
        {
            CGPROGRAM
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
                float3 color : COLOR0;
            };

            float4 _Color;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.normal * 0.5 + float3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color * _Color.rgb, 1.0f);   
            }
            ENDCG
        }
    }
}
