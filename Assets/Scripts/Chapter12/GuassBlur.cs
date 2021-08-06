using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 高斯模糊后处理，将二维卷积核分为两个竖直、水平两个一维卷积核，减少计算量
public class GuassBlur : PostEffectsBase
{
    public Shader guassShader;

    private Material m_material = null;
    public Material material
    {
        get
        {
            m_material = CheckShaderAndCreateMaterial(guassShader, m_material);
            return m_material;
        }
    }

    // 高斯模糊次数
    [Range(0, 10)]
    public int iterations = 3;

    // 每次迭代卷积核增加的范围（卷积核维数不变，改变相邻像素之间的跨度）
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    // 降采样率，越大代表要处理的像素数越少
    [Range(1, 8)]
    public int downSample = 2;


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            // 降采样
            int rtW = src.width / downSample;
            int rtH = src.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(src, buffer0);

            // 开始迭代
            for (int i = 0; i < iterations; ++i)
            {
                // 卷积核范围随迭代次数增加而增大
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // 竖直方向模糊（使用pass 0）
                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // 水平方向模糊（使用pass 1）
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // buffer0中存储最终的模糊结果
            Graphics.Blit(buffer0, dest);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
            Graphics.Blit(src, dest);
    }
}
