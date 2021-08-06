using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 动态模糊后处理
public class MotionBlur : PostEffectsBase
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

    // 控制模糊程度
    [Range(0.0f, 1.0f)]
    public float blurScale = 0.5f;

    // 存储上一帧的rt
    private RenderTexture accumulationRenderTexture;

    // 组件不作用时立即销毁临时rt，确保下次渲染重新开始积累
    private void OnDisable()
    {
        DestroyImmediate(accumulationRenderTexture);
    }

    /*
        动态模糊实现原理：将上一帧的渲染图象保存到一个render target中
        然后在本次渲染中将rt中的结果和当前帧按透明度混合
    */
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            // 创建临时rt存储上一帧的渲染结果
            if (accumulationRenderTexture == null
                || accumulationRenderTexture.width != src.width
                || accumulationRenderTexture.height != src.height)
            {
                DestroyImmediate(accumulationRenderTexture);
                accumulationRenderTexture = new RenderTexture(src.width, src.height, 0);
                accumulationRenderTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(src, accumulationRenderTexture);
            }

            material.SetFloat("_BlurScale", 1.0f - blurScale);

            // 将当前帧和上一帧混合
            Graphics.Blit(src, accumulationRenderTexture, material);
            // 输出混合结果到屏幕
            Graphics.Blit(accumulationRenderTexture, dest);
        }
        else
            Graphics.Blit(src, dest);
    }
}
