using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PostEffectsBase : MonoBehaviour
{
    // 用来实现屏幕后处理的基类

    // 检查着色器、材质等资源的合法性
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null)
            return null;

        if (shader.isSupported && material && material.shader == shader)
            return material;

        if (!shader.isSupported)
            return null;

        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;
        return material;
    }
}
