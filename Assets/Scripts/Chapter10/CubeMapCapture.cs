using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//该类可以从指定位置出发渲染cube map到指定的纹理
public class CubeMapCapture : MonoBehaviour
{
    private Transform pos;
    public Cubemap cubemap;
    private Camera _myCamera;

    // Start is called before the first frame update
    void Start()
    {
        //在物体上构建一个临时相机
        gameObject.AddComponent<Camera>();
        _myCamera = GetComponent<Camera>();
        _myCamera.enabled = false;
    }

    // Update is called once per frame
    void Update()
    {
        //通过相机的render to cubemap函数将从物体视角出发的cubemap渲染到指定的纹理上
        _myCamera.RenderToCubemap(cubemap);
    }
}
