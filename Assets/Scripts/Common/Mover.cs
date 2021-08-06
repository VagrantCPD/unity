using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 控制当前物体移动
public class Mover : MonoBehaviour
{
    // 正常状态下的移动速度
    public float normalSpeed = 10.0f;
    // 奔跑状态下的移动速度
    public float runSpeed = 25.0f;
    private float speed;
    // 最大仰角
    public float MIN_MOUSE_Y = -45.0f;
    // 最大俯角
    public float MAX_MOUSE_Y = 45.0f;
    // 视角转动速度
    public float mouseSpeed = 5.0f;

    float rotationX = 0.0f;
    float rotationY = 0.0f;

    // Start is called before the first frame update
    void Start()
    {
        speed = normalSpeed;
        ChangeCursor();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
            ChangeCursor();

        if (Input.GetKey(KeyCode.LeftShift))
            speed = runSpeed;
        else if (Input.GetKeyUp(KeyCode.LeftShift))
            speed = normalSpeed;

        if (Input.GetKeyDown(KeyCode.Space))
            Time.timeScale = 1.0f - Time.timeScale;

        Move();
    }

    void Move()
    {
        if (Cursor.lockState != CursorLockMode.Locked)
            return;

        float h = Input.GetAxis("Horizontal");
        float v = Input.GetAxis("Vertical");

        Vector3 direction = new Vector3(h, 0, v);

        transform.Translate(direction * Time.deltaTime * speed);

        rotationX += Input.GetAxis("Mouse X") * mouseSpeed;

        rotationY -= Input.GetAxis("Mouse Y") * mouseSpeed;

        rotationY = Mathf.Clamp(rotationY, MIN_MOUSE_Y, MAX_MOUSE_Y);

        transform.eulerAngles = new Vector3(rotationY, rotationX, 0);
    }

    void ChangeCursor()
    {
        Cursor.lockState = Cursor.lockState == CursorLockMode.Locked
                            ? CursorLockMode.None : CursorLockMode.Locked;

        Cursor.visible = Cursor.lockState == CursorLockMode.Locked
                            ? false : true;

    }
}
