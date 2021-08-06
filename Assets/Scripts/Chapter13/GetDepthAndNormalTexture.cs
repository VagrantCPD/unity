using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 获取深度和发现纹理，并绘制
public class GetDepthAndNormalTexture : PostEffectsBase
{
    private Camera myCamera;

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

    public enum TYPE { DEPTH, NORMAL };

    public TYPE type;

    // Start is called before the first frame update
    void Start()
    {
        myCamera = GetComponent<Camera>();
        // 设置相机渲染深度/深度+发现纹理
        // 在着色器中，可以通过_CameraDepthTexture访问深度纹理，通过_CameraDepthNormalsTexture访问深度法线纹理
        myCamera.depthTextureMode |= DepthTextureMode.Depth | DepthTextureMode.DepthNormals;
    }

    // 绘制深度/深度法线纹理
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null && myCamera != null)
        {
            Graphics.Blit(src, dest, material, (int)(type));
        }
        else
            Graphics.Blit(src, dest);
    }
}
