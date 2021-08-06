using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 用于调整画面亮度、饱和度和对比度，继承屏幕后处理基类
public class BrightnessAndContrast : PostEffectsBase
{
    // 着色器
    public Shader brightAndContrastShader;

    // 材质
    private Material brightAndContrastmaterial;
    public Material material
    {
        get
        {
            brightAndContrastmaterial = CheckShaderAndCreateMaterial(brightAndContrastShader, brightAndContrastmaterial);
            return brightAndContrastmaterial;
        }
    }

    // 亮度
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;

    // 饱和度
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;

    // 对比度
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    // 进行屏幕后处理的函数，src为摄像机捕捉到的当前帧，dest为处理后的输出帧
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            // 设置材质的参数
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);

            // 使用material上的shader对src进行处理，处理结果输出到dest
            Graphics.Blit(src, dest, material);
        }
        else
            // 如果材质不可用，则不作任何处理
            Graphics.Blit(src, dest);
    }
}
