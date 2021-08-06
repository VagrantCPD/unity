using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/*
    利用深度纹理实现动态模糊效果
    实现原理为：利用深度纹理以及当前帧相机的视角*投影矩阵的逆矩阵，可以在片段着色器中重构出世界坐标，进而通过上一帧相机的视角*投影矩阵构造出上一帧的ndc坐标
                当前帧ndc和上一帧ndc坐标之差即为速度方向
                在速度方向上对邻域像素采样，取平均值作为最终输出
*/
public class MotionBlurWithDepthTexture : PostEffectsBase
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

    // 模糊程度
    [Range(0.0f, 1.0f)]
    public float blurSize = 0.0f;

    private Camera myCamera;
    private Camera mCamera
    {
        get
        {
            if (myCamera == null)
                myCamera = GetComponent<Camera>();

            return myCamera;
        }
    }

    // 上一帧摄像机的视角*投影矩阵
    private Matrix4x4 previousViewProjectionMatrix;

    // 是否启用动态模糊
    private bool IS_BLUR = true;

    // Start is called before the first frame update
    void Start()
    {
        // 开启深度纹理
        mCamera.depthTextureMode |= DepthTextureMode.Depth;

        previousViewProjectionMatrix = mCamera.projectionMatrix * mCamera.worldToCameraMatrix;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.B))
            IS_BLUR = !IS_BLUR;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null && IS_BLUR && myCamera != null)
        {
            material.SetFloat("_BlurSize", blurSize);

            // 上一帧相机的视角*投影矩阵
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            // 当前帧的视角*投影矩阵
            Matrix4x4 currentViewProjectionMatrix = mCamera.projectionMatrix * mCamera.worldToCameraMatrix;
            // 上面矩阵的逆矩阵
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_currentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);

            // 更新上一帧相机的视角*投影矩阵
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(src, dest, material);
        }
        else
            Graphics.Blit(src, dest);
    }
}
