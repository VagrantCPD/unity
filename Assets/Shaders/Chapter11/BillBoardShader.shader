Shader "Unlit/Chapter11/BillBoardShader"
{
    // 用来实现广告牌（即物体始终朝向摄像机）的着色器
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
        
        LOD 100

        Pass
        {

            Tags { "LightMode"="ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;

                // 假设模型的中心为模型空间原点
                float3 center = float3(0.0, 0.0, 0.0);
                // 获取模型空间下相机的位置
                float3 cameraPosInModelSpace = mul(unity_WorldToObject,float4(_WorldSpaceCameraPos, 1));

                // 相机移动时，保持物体朝向相机的法向量不变
                // 获取物体朝向摄像机时的法向量
                float3 normal =  cameraPosInModelSpace - center;
                normal = normalize(normal);
                // 如果法向量朝上，则上向量朝前；其他情况上向量向上
                float3 up = abs(normal.y) > 0.999 ? float3(0.0, 0.0, 1.0) : float3(0.0, 1.0, 0.0);
                // 右向量为上向量和法向量的叉乘
                float3 right = normalize(cross(up, normal));
                // 上向量为法向量和右向量的叉乘
                up = normalize(cross(normal, right));

                // 根据上述计算出来的三个向量计算变换后的模型空间顶点(相对于center)
                float3 centerOff = v.vertex.xyz - center;
                float3 updateCenterOff = right * centerOff.x + up * centerOff.y + normal * centerOff.z;

                o.vertex = UnityObjectToClipPos(float4(center + updateCenterOff, 1.0));
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
    }
}
