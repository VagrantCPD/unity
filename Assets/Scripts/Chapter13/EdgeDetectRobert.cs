using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 使用robert算子和深度法线纹理进行边缘检测
// 这样的边缘检测不受光照和纹理的影响，只与模型有关
public class EdgeDetectRobert : PostEffectsBase
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

    // 深度敏感度，值越大，深度差阈值（大于该值认为存在边界）越小
    public float sensitiveDepth = 1.0f;

    // 法线敏感度，值越大，法线差阈值（大于该值认为存在边界）越小
    public float sensitiveNormals = 1.0f;

    private Camera myCamera;

    private bool IS_EDGE_DETECT = true;

    // Start is called before the first frame update
    void Start()
    {
        myCamera = GetComponent<Camera>();
        myCamera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.V))
            IS_EDGE_DETECT = !IS_EDGE_DETECT;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null && myCamera != null && IS_EDGE_DETECT)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetFloat("_EdgeScale", edgeScale);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SensitiveDepth", sensitiveDepth);
            material.SetFloat("_SensitiveNormals", sensitiveNormals);

            Graphics.Blit(src, dest, material);
        }
        else
            Graphics.Blit(src, dest);
    }
}
