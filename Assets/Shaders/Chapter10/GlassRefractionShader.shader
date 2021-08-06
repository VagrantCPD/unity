Shader "Unlit/Chapter10/GlassRefractionShader"
{
    //模拟玻璃的反射和折射
    //反射：玻璃反射周围环境
    //折射：透过玻璃看到玻璃后面的物体
    Properties {
        _MainTex ("Main Tex", 2D) = "white" {}
        //玻璃的法线纹理
        _BumpMap ("Normal Map", 2D) = "bump" {}
        //模拟反射的环境纹理
        _Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
        //控制折射时图像的扭曲程度
        _Distortion ("Distortion", Range(0, 10000)) = 10
        //折射颜色和反射颜色的混合因子
        _RefractAmount ("Refract Amount", Range(0.0, 1.0)) = 1.0
    }
    SubShader {
        //确保在透明队列渲染，保证其他的不透明物体已经渲染完毕
        Tags { "Queue"="Transparent" "RenderType"="Opaque" }
        
        // This pass grabs the screen behind the object into a texture.
        // We can access the result in the next pass as _RefractionTex
        // Grab Pass抓取当前屏幕的画面（注意使用该pass的物体尚未渲染）
        GrabPass { "_RefractionTex" }
        
        Pass {		
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            samplerCUBE _Cubemap;
            float _Distortion;
            fixed _RefractAmount;
            sampler2D _RefractionTex;
            float4 _RefractionTex_TexelSize;
            
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT; 
                float2 texcoord: TEXCOORD0;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD0;
                float4 uv : TEXCOORD1;
                float4 TtoW0 : TEXCOORD2;  
                float4 TtoW1 : TEXCOORD3;  
                float4 TtoW2 : TEXCOORD4;
                float3 worldNormal : TEXCOORD5;
            };
            
            v2f vert (a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                //计算采样坐标，采样grab pass所得到的纹理
                o.scrPos = ComputeGrabScreenPos(o.pos);
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
                
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
                
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));

                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target {	
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                
                // Get the normal in tangent space
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

                // Compute the offset in tangent space
                // 计算折射的扭曲程度
                // 相当于使用屏幕后处理(处理grab pass获得的屏幕图像)的方式来模拟折射
                float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
                i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
                fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy/i.scrPos.w).rgb;
                
                // Convert the normal to world space
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                fixed3 reflDir = reflect(-worldViewDir, bump);
                fixed4 texColor = tex2D(_MainTex, i.uv.xy);
                fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;
                
                fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;
                
                return fixed4(finalColor, 1);
            }
            
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
