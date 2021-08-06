using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
// 使用代码生成纹理，并应用到材质上
public class ProceduralTextureGen : MonoBehaviour
{
    // 使用程序纹理的材质
    public Material material = null;

    // 程序生成的纹理
    private Texture2D proceduralTexture = null;

    // 程序纹理的参数
    [SerializeField, SetProperty("textureWidth")]
    private int m_textureWidth = 512;

    public int textureWidth
    {
        get
        {
            return m_textureWidth;
        }
        set
        {
            m_textureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color m_backgroundColor = Color.white;

    public Color backgroundColor
    {
        get
        {
            return m_backgroundColor;
        }
        set
        {
            m_backgroundColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleColor")]
    private Color m_circleColor = Color.yellow;

    public Color circleColor
    {
        get
        {
            return m_circleColor;
        }
        set
        {
            m_circleColor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("blurFactor")]
    private float m_blurFactor = 2.0f;

    public float blurFactor
    {
        get
        {
            return m_blurFactor;
        }
        set
        {
            m_blurFactor = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("circleCount")]
    private int m_circleCount = 500;

    public int circleCount
    {
        get
        {
            return m_circleCount;
        }
        set
        {
            m_circleCount = value;
            _UpdateMaterial();
        }
    }

    private void Start()
    {
        // 检查是否有可用的材质
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.Log("no material is found!");
                return;
            }

            material = renderer.sharedMaterial;
        }
    }

    // 更新材质使用的纹理
    private void _UpdateMaterial()
    {
        if (material != null)
        {
            proceduralTexture = createProceduralTexture();
            material.SetTexture("_MainTex", proceduralTexture);
        }
    }

    //创建程序纹理
    private Texture2D createProceduralTexture()
    {
        Texture2D result = new Texture2D(m_textureWidth, m_textureWidth);

        Vector2 textureCenter = new Vector2(m_textureWidth / 2.0f, m_textureWidth / 2.0f);
        float maxDistance = m_textureWidth / Mathf.Sqrt(2);

        // 创建纹理的核心算法(逐像素创建)
        for (int i = 0; i < m_circleCount; ++i)
        {
            // 首先将像素颜色初始化为背景颜色
            Color pixel = backgroundColor;

            Vector2 pos = new Vector2(Random.Range(0.0f, m_textureWidth), Random.Range(0.0f, m_textureWidth));

            float distance = Vector2.Distance(pos, textureCenter);

            pixel = Color.Lerp(pixel, m_circleColor, distance / maxDistance);

            result.SetPixel((int)pos.x, (int)pos.y, pixel);
        }

        // 将上述setpixel操作应用到纹理上
        result.Apply();

        return result;
    }
}
