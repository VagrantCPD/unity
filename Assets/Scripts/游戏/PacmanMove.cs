using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PacmanMove : MonoBehaviour
{
    public float speed;
    private float offset = 1.0f;
    private Rigidbody2D rb;

    enum DIRECTION { UP=0,LEFT,DOWN,RIGHT,STOP};
    DIRECTION direction = DIRECTION.UP;

    private Dictionary<DIRECTION, Vector2> offsets = new Dictionary<DIRECTION, Vector2>();

    // Use this for initialization
    void Start()
    {
        rb = gameObject.GetComponent<Rigidbody2D>();

        offsets[DIRECTION.UP] = new Vector2(0.0f, offset);
        offsets[DIRECTION.LEFT] = new Vector2(-offset, 0.0f);
        offsets[DIRECTION.DOWN] = new Vector2(0.0f, -offset);
        offsets[DIRECTION.RIGHT] = new Vector2(offset, 0.0f);
        offsets[DIRECTION.STOP] = new Vector2(0.0f, 0.0f);

        InvokeRepeating("Move", 0.0f, speed);
    }

    // Update is called once per frame
    void Update()
    {
        if (GameController.gameState == GameController.GAMESTATE.PLAYING)
        {
            if (Input.GetKey(KeyCode.UpArrow) || Input.GetKey(KeyCode.W))
            {
                direction = DIRECTION.UP;
            }
            else if (Input.GetKey(KeyCode.LeftArrow) || Input.GetKey(KeyCode.A))
            {
                direction = DIRECTION.LEFT;
            }
            else if (Input.GetKey(KeyCode.DownArrow) || Input.GetKey(KeyCode.S))
            {
                direction = DIRECTION.DOWN;
            }
            else if (Input.GetKey(KeyCode.RightArrow) || Input.GetKey(KeyCode.D))
            {
                direction = DIRECTION.RIGHT;
            }
            else
            {
                direction = DIRECTION.STOP;
            }
            UpdateAnimator();
        }
    }

    private void Move()
    {
        if (GameController.gameState != GameController.GAMESTATE.PLAYING) return;
        if (Valid(direction))
        {
            rb.position += offsets[direction];
        }
        
    }

    private void UpdateAnimator()
    {
        if (direction != DIRECTION.STOP)
        {
            GetComponent<Animator>().SetInteger("direction", (int)direction);
        }
    }

    private bool Valid(DIRECTION direction_)
    {
        Vector2 pos = rb.position;
        RaycastHit2D hit = Physics2D.Linecast(pos + offsets[direction_], pos);
        return (hit.collider == gameObject.GetComponent<Collider2D>());
    }

}
