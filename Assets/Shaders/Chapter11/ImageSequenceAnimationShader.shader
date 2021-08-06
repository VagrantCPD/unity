Shader "Unlit/Chapter11/ImageSequenceAnimationShader"
{
    // 序列帧动画
    // 原理：在每个时刻计算该时刻下应该播放的关键帧，并对关键帧进行纹理采样
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        // 水平方向包含关键帧的个数
        _HorizontalAmount ("Horizontal Amount", Float) = 4
        // 竖直方向包含关键帧的个数
        _VerticalAmount ("Vertical Amount", Float) = 4
        // 动画播放速度
        _Speed ("Speed", Range(1, 100)) = 30
    }

    SubShader
    {
        // 序列帧图像通常包含透明度通道
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
        LOD 100

        Pass
        {
            Tags {"LightMode"="ForwardBase"}

            // 关闭深度写入，开启混合
            ZWrite off
            Blend SrcAlpha OneMinusSrcAlpha

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _Color;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _HorizontalAmount;
            float _VerticalAmount;

            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 计算从场景开始加载经过的时间
                float time = floor(_Time.y * _Speed);

                // 计算行
                float row = floor(time / _HorizontalAmount);
                // 计算列
                float col = time - row * _HorizontalAmount;
                // (row, col)相当于加在原有纹理坐标原点的一个offset

                // 根据计算出来的行与列，计算对应关键帧图像的采样坐标(注意unity uv的y和图像的y反向，因此使用-row)
                float2 uv = i.uv + half2(col, -row);
                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

                fixed4 color = tex2D(_MainTex, uv);
                color.rgb *= _Color.rgb;
                return color;
            }
            ENDCG
        }
    }

    Fallback "Transparent/VertexLit"
}
