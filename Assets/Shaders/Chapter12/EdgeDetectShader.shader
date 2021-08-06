Shader "Unlit/Chapter12/EdgeDetectShader"
{
    // 用于画面边缘检测的屏幕后处理shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 0.5
        _EdgeScale ("Edge Scale", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (0, 0, 0, 0)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Always
            Cull off
            ZWrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _MainTex_TexelSize;


            float _EdgeOnly;
            float _EdgeScale;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;

            // 计算给定九宫格像素的sobel卷积值
            /*
            sobel算子

            -1  -2  -1
            gx  0   0   0
            1   2   1

            -1  0   1
            gy  -2  0   2
            -1  0   1

            sobel = 1 - |gx| - |gy|
            */

            half sobel(v2f i)
            {
                const half gx[9] = {-1, -2, -1,
                    0,  0,  0,
                1,  2,  1};
                
                const half gy[9] = {-1, 0,  1,
                    -2, 0,  2,
                -1, 0,  1};
                
                half sobelX = 0;
                half sobelY = 0;

                for(int it= 0; it < 9; ++it)
                {
                    sobelX += Luminance(tex2D(_MainTex, i.uv[it])) * gx[it];
                    sobelY += Luminance(tex2D(_MainTex, i.uv[it])) * gy[it];
                }

                return 1 - abs(sobelX) - abs(sobelY);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                half2 uv = v.uv;

                _MainTex_TexelSize.xy *= _EdgeScale;

                // 获取以当前像素为中心的九宫格像素的uv坐标
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv[4]);

                // 计算当前像素点的梯度值，梯度值越小，说明该点越可能是边缘点
                half edge = sobel(i);
                // 计算背景为原图时的颜色值
                col = lerp(_EdgeColor, col, edge);
                // 计算背景为纯色时的颜色值
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

                return lerp(col, onlyEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
}
