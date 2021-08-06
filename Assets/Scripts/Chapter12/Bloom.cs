using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 光照bloom效果
/*
    实现原理：根据给定阈值提取图片中的较亮区域存储到一张RenderTarget中
    然后对RT进行高斯模糊，模拟光照扩散效果
    最后将源图像和模糊后的图像混合
*/
public class Bloom : PostEffectsBase
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

    // 高斯模糊次数
    [Range(0, 10)]
    public int iterations = 3;

    // 每次迭代卷积核增加的范围（卷积核维数不变，改变相邻像素之间的跨度）
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    // 降采样率，越大代表要处理的像素数越少
    [Range(1, 8)]
    public int downSample = 2;

    // 亮度阈值
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;


    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_LuminanceTreshold", luminanceThreshold);

            int rtW = src.width / downSample;
            int rtH = src.height / downSample;

            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            // 首先根据阈值提取源图像中较亮的区域
            Graphics.Blit(src, buffer0, material, 0);

            // 然后对提取出来的图像进行高斯模糊
            for (int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1.0f + blurSpread * i);
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                Graphics.Blit(buffer0, buffer1, material, 2);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // 最后将模糊的图像和源图像进行混合
            material.SetTexture("_Bloom", buffer0);
            Graphics.Blit(src, dest, material, 3);

            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
            Graphics.Blit(src, dest);
    }
}
