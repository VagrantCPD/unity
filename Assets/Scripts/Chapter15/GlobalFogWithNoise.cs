using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 用来实现全局高度雾效的后处理脚本
// 加入噪声纹理，实现不均匀雾、雾的移动
public class GlobalFogWithNoise : PostEffectsBase
{
    public Shader shader;

    private Material m_material;

    public Material material
    {
        get
        {
            m_material = CheckShaderAndCreateMaterial(shader, m_material);
            return m_material;
        }
    }

    private Camera myCamera;

    // 雾的浓度
    [Range(0.0f, 3.0f)]
    public float fogDensity = 1.0f;

    // 雾的颜色
    public Color fogColor = Color.white;

    // 雾的起始、终止高度
    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    // 噪声纹理
    public Texture noiseTexture;

    // 雾的移动速度
    [Range(-0.5f, 0.5f)]
    public float fogXSpeed = 0.1f;

    [Range(-0.5f, 0.5f)]
    public float fogYSpeed = 0.1f;

    // 雾的不均匀程度
    [Range(0.0f, 3.0f)]
    public float noiseAmount = 1.0f;

    // 是否启用雾效
    private bool IS_FOG = true;

    // Start is called before the first frame update
    void Start()
    {
        myCamera = GetComponent<Camera>();
        // 开启深度纹理
        myCamera.depthTextureMode |= DepthTextureMode.Depth;
    }


    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.F))
            IS_FOG = !IS_FOG;
    }

    /*
        实现原理：利用深度纹理 + 摄像机世界空间位置 + 像素在世界空间下相对摄像机的偏移，在片段着色器中重构像素的世界空间位置
        关键在于计算像素在世界空间下相对摄像机的偏移，

        在顶点着色器中，通过摄像机的前向量、以近平面中心为原点的上向量、右向量 + 像素的uv坐标，可以计算出顶点相对于相机偏移的方向向量
        然后在片段着色器中对深度纹理采样获取深度值，乘以偏移方向的方向向量即可得到偏移量
    */
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null && IS_FOG)
        {
            // 视角（度数）
            float fov = myCamera.fieldOfView;
            // 近平面距离
            float near = myCamera.nearClipPlane;
            // 近平面宽高比
            float aspect = myCamera.aspect;

            // 前向量
            Vector3 forward = myCamera.transform.forward * near;
            // 计算以近平面中心为原点的右向量和上向量
            float halfHeight = near * Mathf.Tan(0.5f * fov * Mathf.Deg2Rad);
            Vector3 up = myCamera.transform.up * halfHeight;
            Vector3 right = myCamera.transform.right * halfHeight * aspect;

            material.SetMatrix("_ViewProjectionInverseMatrix",
                    (myCamera.projectionMatrix * myCamera.worldToCameraMatrix).inverse);
            material.SetVector("_CameraForward", forward);
            material.SetVector("_CameraUp", up);
            material.SetVector("_CameraRight", right);
            material.SetFloat("_CameraNear", near);

            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            material.SetTexture("_NoiseTexture", noiseTexture);
            material.SetFloat("_FogXSpeed", fogXSpeed);
            material.SetFloat("_FogYSpeed", fogYSpeed);
            material.SetFloat("_NoiseAmount", noiseAmount);

            Graphics.Blit(src, dest, material);
        }
        else
            Graphics.Blit(src, dest);
    }
}
