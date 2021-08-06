using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SnakeMove : MonoBehaviour {
    public GameObject skinController;

    public Boundary initHeadBoundary;
    public Boundary crossBoundary;
    private GameObject head;
    

    enum DIRECTION { UP=0,LEFT,DOWN,RIGHT};

    DIRECTION direction = DIRECTION.LEFT;

    static public float step = 20.0f;
    public float maxSpeed = 0.1f;
    public float minSpeed = 0.05f;
    private float speed;
    private float delta;

    //头部的上一帧位置
    private Vector3 lastPos;
   
    //运动方向
    private Dictionary<DIRECTION, Vector3> steps = new Dictionary<DIRECTION, Vector3>();
    //头部朝向
    private Dictionary<DIRECTION, Vector3> forwards = new Dictionary<DIRECTION, Vector3>();


 

    private class SnakeBody
    {
        public GameObject body;
        public Vector3 lastPos = new Vector3(0.0f,0.0f,0.0f);

        public SnakeBody(GameObject body)
        {
            this.body = body;
        }
    }

    private List<SnakeBody> bodies = new List<SnakeBody>();

	// Use this for initialization
	void Start () {
        
        steps[DIRECTION.UP] = new Vector3(0.0f, step, 0.0f);
        steps[DIRECTION.LEFT] = new Vector3(-step, 0.0f, 0.0f);
        steps[DIRECTION.DOWN] = new Vector3(0.0f, -step, 0.0f);
        steps[DIRECTION.RIGHT] = new Vector3(step, 0.0f, 0.0f);

        forwards[DIRECTION.UP] = new Vector3(0.0f, 0.0f, 0.0f);
        forwards[DIRECTION.LEFT] = new Vector3(0.0f, 0.0f, 90.0f);
        forwards[DIRECTION.DOWN] = new Vector3(0.0f, 0.0f, 180.0f);
        forwards[DIRECTION.RIGHT] = new Vector3(0.0f, 0.0f, 270.0f);



        MakeHead();

       

        delta = (maxSpeed - minSpeed) / GameController.maxStage;

        speed = maxSpeed;
        InvokeRepeating("Move", 0.0f, speed);
	}
	
	// Update is called once per frame
	void Update () {
        if (GameController.state == GameController.STATE.PLAYING)
        {
            if (Input.GetKeyDown(KeyCode.UpArrow))
            {
                if (direction != DIRECTION.DOWN)
                {
                    direction = DIRECTION.UP;
                }
            }
            else if (Input.GetKeyDown(KeyCode.LeftArrow))
            {
                if (direction != DIRECTION.RIGHT)
                {
                    direction = DIRECTION.LEFT;
                }
            }
            else if (Input.GetKeyDown(KeyCode.DownArrow))
            {
                if (direction != DIRECTION.UP)
                {
                    direction = DIRECTION.DOWN;
                }
            }
            else if (Input.GetKeyDown(KeyCode.RightArrow))
            {
                if (direction != DIRECTION.LEFT)
                {
                    direction = DIRECTION.RIGHT;
                }
            }
        }
    }

    private void MakeHead()
    {
        head = Instantiate(skinController.GetComponent<SkinController>().headStyles[BeginController.skin]) as GameObject;
        head.transform.SetParent(transform);
        head.transform.localScale = new Vector3(75.0f, 75.0f, 75.0f);
        head.transform.localPosition = new Vector3(Random.Range(initHeadBoundary.minX, initHeadBoundary.maxX), Random.Range(initHeadBoundary.minY, initHeadBoundary.maxY), -50.0f);
        head.transform.rotation = Quaternion.Euler(forwards[direction]);
    }

    //更新头部和身体位置
    private void Move()
    {
        lastPos = head.transform.localPosition;
        head.transform.localPosition += steps[direction];
        head.transform.rotation = Quaternion.Euler(forwards[direction]);

        //Debug.Log("Head Pos: " + head.transform.localPosition);


        for (int i=0;i<bodies.Count;i++)
        {
            if(i==0)
            {
                bodies[i].lastPos = bodies[i].body.transform.localPosition;
                bodies[i].body.transform.localPosition = lastPos;
            }
            else
            {
                bodies[i].lastPos = bodies[i].body.transform.localPosition;
                bodies[i].body.transform.localPosition = bodies[i - 1].lastPos;
            }
        }

        
    }

    public void AddBody()
    {
        GameObject newBody = Instantiate(skinController.GetComponent<SkinController>().bodyStyles[BeginController.skin][bodies.Count % 2], new Vector3(2000.0f, 2000.0f, 0.0f), Quaternion.identity);
        newBody.transform.SetParent(gameObject.transform);
        bodies.Add(new SnakeBody(newBody));
    }

    public void StopMove()
    {
        CancelInvoke("Move");
    }
    public Transform GetHeadPos()
    {
        return head.transform;
    }
    public void RecoverMove()
    {
        InvokeRepeating("Move", 0, speed);
    }

    public void SpeedUp()
    {
        speed -= delta;
        CancelInvoke("Move");
        InvokeRepeating("Move", 0, speed);
    }

    public void CrossBoundary()
    {
        switch(direction)
        {
            case DIRECTION.UP:
                head.transform.localPosition = new Vector3(head.transform.localPosition.x, crossBoundary.minY, 0.0f);
                break;
            case DIRECTION.LEFT:
                head.transform.localPosition = new Vector3(crossBoundary.maxX, head.transform.localPosition.y, 0.0f);
                break;
            case DIRECTION.DOWN:
                head.transform.localPosition = new Vector3(head.transform.localPosition.x, crossBoundary.maxY, 0.0f);
                break;
            case DIRECTION.RIGHT:
                head.transform.localPosition = new Vector3(crossBoundary.minX, head.transform.localPosition.y, 0.0f);
                break;
        }
    }
}
