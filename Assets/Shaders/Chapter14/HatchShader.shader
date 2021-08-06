Shader "Unlit/Chapter14/HatchShader"
{
    // 用来实现素描风格的着色器
    /*
    实现原理：不同素描笔触纹理的混合
    在顶点着色器中计算出漫反射光照系数，根据系数大小决定不同纹理的混合权重
    */
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // 主色
        _Color ("Main Color" , Color) = (1, 1, 1, 1)
        //  底色
        _SubColor ("Sub Color", Color) = (1, 1, 1, 1)
        // 线条密集程度
        _TileFactor ("Tile Factor", Float) = 1
        // 描边粗度
        _Outline ("Outline", Float) = 1
        // 六张素描笔触纹理
        _Hatch0 ("Hatch 0", 2D) = "white" {}
        _Hatch1 ("Hatch 1", 2D) = "white" {}
        _Hatch2 ("Hatch 2", 2D) = "white" {}
        _Hatch3 ("Hatch 3", 2D) = "white" {}
        _Hatch4 ("Hatch 4", 2D) = "white" {}
        _Hatch5 ("Hatch 5", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // 描边shader
        UsePass "Unlit/Chapter14/ToonShader/OUTLINE"

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShaderVariables.cginc"

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
                // 混合权重
                fixed3 weight0 : TEXCOORD1;
                fixed3 weight1 : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            fixed4 _SubColor;

            float _TileFactor;

            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex) * _TileFactor;

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 worldLightDir = normalize(WorldSpaceLightDir(worldPos));
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float diff = max(0, dot(worldLightDir, worldNormal)) * 7.0;
                
                o.weight0 = fixed3(0, 0, 0);
                o.weight1 = fixed3(0, 0, 0);
                
                if (diff > 6.0) {
                } 
                else if (diff > 5.0) {
                    o.weight0.x = diff - 5.0;
                } 
                else if (diff > 4.0) {
                    o.weight0.x = diff - 4.0;
                    o.weight0.y = 1.0 - o.weight0.x;
                } 
                else if (diff > 3.0) {
                    o.weight0.y = diff - 3.0;
                    o.weight0.z = 1.0 - o.weight0.y;
                }
                else if (diff > 2.0) {
                    o.weight0.z = diff - 2.0;
                    o.weight1.x = 1.0 - o.weight0.z;
                }
                else if (diff > 1.0) {
                    o.weight1.x = diff - 1.0;
                    o.weight1.y = 1.0 - o.weight1.x;
                } 
                else {
                    o.weight1.y = diff;
                    o.weight1.z = 1.0 - o.weight1.y;
                }

                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 hatch0 = tex2D(_Hatch0, i.uv) * i.weight0.x;
                fixed4 hatch1 = tex2D(_Hatch1, i.uv) * i.weight0.y;
                fixed4 hatch2 = tex2D(_Hatch2, i.uv) * i.weight0.z;
                fixed4 hatch3 = tex2D(_Hatch3, i.uv) * i.weight1.x;
                fixed4 hatch4 = tex2D(_Hatch4, i.uv) * i.weight1.y;
                fixed4 hatch5 = tex2D(_Hatch5, i.uv) * i.weight1.z;

                // 底色
                fixed4 subColor = _SubColor * (1 - i.weight0.x - i.weight0.y - i.weight0.z
                - i.weight1.x - i.weight1.y - i.weight1.z);

                return _Color * (hatch0 + hatch1 + hatch2 + hatch3 + hatch4 + hatch5 + subColor);
            }
            ENDCG
        }
    }
}
