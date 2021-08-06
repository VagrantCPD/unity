// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Chapter11/WaterShader"
{
    // 顶点动画，模拟水流
    Properties
    {
        // 河流纹理
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        // 水流波动幅度
        _Magnitude ("Magnitude", Range(0.01, 0.1)) = 0.06
        // 水流波动频率
        _Frequency ("Frequency", Float) = 1
        // 波长倒数
        _InvWaveLength ("Inverse Wave Length", Float) = 10
        // 水流流动速度
        _Speed ("Speed", Float) = 0.5
    }
    SubShader
    {
        // 透明渲染
        // 同时取消批处理，以在模型各自的模型空间下进行顶点动画
        Tags { "DisableBatching"="True"}

        LOD 100

        Pass
        {

            Tags {"LightMode"="ForwardBase"}

            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;

            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;

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

            v2f vert (appdata v)
            {
                v2f o;
                
                float4 offset = float4(0.0, 0.0, 0.0, 0.0);

                /* 只对顶点的x方向进行偏移(模型空间)
                _Frequency * _Time.y控制顶点x方向移动
                
                v.vertex.x * _InvWaveLength +
                v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength
                用来生成弦
                */
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength +
                v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                o.vertex = UnityObjectToClipPos(v.vertex + offset);

                // 纹理坐标运动
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv += float2(0.0, _Time.y * _Speed);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }

        // 投射阴影的pass
        Pass {
            Tags { "LightMode" = "ShadowCaster" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma multi_compile_shadowcaster
            
            #include "UnityCG.cginc"
            
            float _Magnitude;
            float _Frequency;
            float _InvWaveLength;
            float _Speed;
            
            struct v2f { 
                V2F_SHADOW_CASTER;
            };
            
            v2f vert(appdata_base v) {
                v2f o;
                
                float4 offset;
                offset.yzw = float3(0.0, 0.0, 0.0);
                offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
                v.vertex = v.vertex + offset;

                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

    FallBack "VertexLit"   
}
