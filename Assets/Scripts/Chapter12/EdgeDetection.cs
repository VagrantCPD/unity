using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 采用sobel算子检测画面边缘，继承屏幕后处理基类
public class EdgeDetection : PostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial;
    public Material material
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    // 边缘线强度（该值越大，原图越淡，边缘线和背景纯色混合的图像越深）
    [Range(0.0f, 1.0f)]
    public float edgeOnly = 0.0f;

    // 边缘线颜色
    public Color edgeColor = Color.black;

    // 边缘线粗度
    [Range(0.0f, 10.0f)]
    public float edgeScale = 1.0f;

    // 背景颜色
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetFloat("_EdgeScale", edgeScale);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(src, dest, material);
        }
        else
            Graphics.Blit(src, dest);
    }
}
