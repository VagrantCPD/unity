Shader "Unlit/Chapter11/ParallaxShader"
{
    // 用来实现视差滚动的着色器
    Properties
    {
        // 近景
        _NearTex ("Near Texture", 2D) = "white" {}
        // 远景
        _FarTex ("Far Texture", 2D) = "white" {}
        // 近景滚动速度
        _NearSpeed ("Near Speed", Float) = 1.0
        // 远景滚动速度
        _FarSpeed ("Far Speed", Float) = 2.0
        // 控制整体亮度
        _Multiplier ("Layer Multiplier", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _NearTex;
            float4 _NearTex_ST;

            sampler2D _FarTex;
            float4 _FarTex_ST;

            float _NearSpeed;
            float _FarSpeed;

            float _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // 近景、远景纹理采样坐标以不同速度改变
                o.uv.xy = TRANSFORM_TEX(v.uv, _NearTex) + frac(float2(_NearSpeed, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.uv, _FarTex) + frac(float2(_FarSpeed, 0.0) * _Time.y);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样近景
                fixed4 near = tex2D(_NearTex, i.uv.xy);
                // 采样远景
                fixed4 far = tex2D(_FarTex, i.uv.zw);

                // 混合
                fixed4 color = lerp(far, near, near.a);

                // 控制亮度
                color *= _Multiplier;

                return color;
            }
            ENDCG
        }
    }
}
