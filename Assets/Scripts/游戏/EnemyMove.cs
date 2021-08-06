using System.Collections.Generic;
using UnityEngine;

public class EnemyMove : MonoBehaviour {

    public float speed;//调用Move函数的频率
    public float inspectRange;//鬼的监视范围
    private float offset = 1.0f;//每次运动的距离
    private Rigidbody2D rb;//对象刚体
    private int initStep = 0;//鬼出门时先往上走三步
    private float turnRoundChance = 0.02f;//运动过程中回头的概率
    private float turnSideChance = 0.18f;//运动过程中转向侧向的概率
    private float keepChance = 0.8f;//运动过程中保持前进的概率
    private int pulse = 0;
    private int pulseBound = 10;
    private bool free = true;
    private Vector2 shift = Vector2.zero;//上一次pulse开始的位移
    private float shiftBound = 10.0f;
    private GameObject pacman;

    private Vector2 initPos;
    

    //运动方向
    enum DIRECTION { UP = 0, LEFT, DOWN, RIGHT, STOP };
    private DIRECTION direction = DIRECTION.UP;
    private DIRECTION lastDirection = DIRECTION.UP;

    private Dictionary<DIRECTION, Vector2> offsets = new Dictionary<DIRECTION, Vector2>();

    // Use this for initialization
    void Start () {
        
        rb = GetComponent<Rigidbody2D>();

        initPos = rb.position;

        offsets[DIRECTION.UP] = new Vector2(0.0f, offset);
        offsets[DIRECTION.LEFT] = new Vector2(-offset, 0.0f);
        offsets[DIRECTION.DOWN] = new Vector2(0.0f, -offset);
        offsets[DIRECTION.RIGHT] = new Vector2(offset, 0.0f);
        offsets[DIRECTION.STOP] = new Vector2(0.0f, 0.0f);

        pacman = GameObject.FindGameObjectWithTag("Pacman");

        InvokeRepeating("Move", 0.0f, speed);
    }
	
	// Update is called once per frame
	void Update () {
		
	}

    //运动函数
    private void Move()
    {
        if (GameController.gameState != GameController.GAMESTATE.PLAYING) return;
        //此时鬼已经出门，要对其与墙壁的碰撞进行检测
        if (initStep >= 3)
        {
            if (direction == DIRECTION.STOP) return;
            //如果吃豆人在监视范围内，鬼会去追吃豆人
            if (!free && CheckPacman())
            {
                CatchPacmanMove();
                pulse++;
                
                shift += offsets[direction];
                //当pulse达到pulseBound时，检查鬼的位移是否够大，防止鬼卡在角落
                if(pulse == pulseBound)
                {
                    //如果鬼的位移过小，让其暂时进入自由移动模式
                    if(Vector2.Distance(shift,Vector2.zero) <= shiftBound)
                    {
                        free = true;
                    }
                    pulse = 0;
                    shift = Vector2.zero;
                }
            }
            //否则鬼自由移动
            else
            {
                FreeMove();
                pulse++;
                if(pulse == pulseBound)
                {
                    free = false;
                    pulse = 0;
                }
            }
        }

        
        rb.position += offsets[direction];//更新位置
        GetComponent<Animator>().SetInteger("direction", (int)direction);//更新朝向动画
        initStep++;
    }

    //自由移动（即此时吃豆人不在鬼的监视范围内）
    private void FreeMove()
    {
        List<DIRECTION> validDirs = ValidDirection();
        
        if (validDirs.Contains(direction))
        {
            float temp = Random.Range(0.0f, turnRoundChance + turnSideChance + keepChance);
            List<DIRECTION> validSideDirection = GetValidSideDirections(direction);

            if(temp <= turnRoundChance)
            {
                direction = GetOppositeDirection(direction);
            }
            else if(temp <= turnSideChance)
            {
                if (validSideDirection.Count != 0)
                {
                    direction = validSideDirection[RandomInt(validSideDirection.Count)];
                }
            }
            return;
        }
        else
        {
            direction = validDirs[RandomInt(validDirs.Count)];
        }
        
    }

    //追击吃豆人
    private void CatchPacmanMove()
    {
        List<DIRECTION> validDirs = ValidDirection();
        List<float> costs = new List<float>();
        Vector2 pacmanPos = pacman.GetComponent<Rigidbody2D>().position;

        DIRECTION to = DIRECTION.STOP;
        float minDis = Mathf.Infinity;

        foreach (DIRECTION d in validDirs)
        {
            float temp = Vector2.Distance(rb.position + offsets[d], pacmanPos);
            if(temp <= minDis)
            {
                minDis = temp;
                to = d;
            }
        }

        direction = to;
    }

    //生成0到max-1的随机整数
    private int RandomInt(int max)
    {
        return (int)Random.Range(0.0f, max);
    }
    
    //获取合法的侧向方向
    private List<DIRECTION> GetValidSideDirections(DIRECTION direction_)
    {
        List<DIRECTION> results = new List<DIRECTION>();
        List<DIRECTION> temp = new List<DIRECTION>();
        if(direction_ == DIRECTION.UP || direction_ == DIRECTION.DOWN)
        {
            temp.Add(DIRECTION.LEFT);
            temp.Add(DIRECTION.RIGHT);
        }
        else if(direction_ == DIRECTION.LEFT || direction_ == DIRECTION.RIGHT)
        {
            temp.Add(DIRECTION.UP);
            temp.Add(DIRECTION.DOWN);
        }

        foreach(DIRECTION d in temp)
        {
            if (Valid(d)) results.Add(d);
        }

        return results;
    }
    
    //获取反方向
    private DIRECTION GetOppositeDirection(DIRECTION direction_)
    {
        DIRECTION result = DIRECTION.STOP;
        if (direction_ == DIRECTION.UP) result = DIRECTION.DOWN;
        if (direction_ == DIRECTION.DOWN) result =  DIRECTION.UP;
        if (direction_ == DIRECTION.LEFT) result = DIRECTION.RIGHT;
        if (direction_ == DIRECTION.RIGHT) result = DIRECTION.LEFT;
        return result;
    }
    
    //获取此时的合法方向
    private List<DIRECTION> ValidDirection()
    {
        List<DIRECTION> results = new List<DIRECTION>();

        if (Valid(DIRECTION.UP)) results.Add(DIRECTION.UP);
        if (Valid(DIRECTION.LEFT)) results.Add(DIRECTION.LEFT);
        if (Valid(DIRECTION.DOWN)) results.Add(DIRECTION.DOWN);
        if (Valid(DIRECTION.RIGHT)) results.Add(DIRECTION.RIGHT);

        return results;
    }

    //检查方向是否合法
    private bool Valid(DIRECTION direction_)
    {
        Vector2 pos = rb.position;
        RaycastHit2D hit = Physics2D.Linecast(pos + offsets[direction_], pos);
        return (hit.collider.name != "Maze");
    }

    //检查吃豆人是否在鬼的监视范围内
    private bool CheckPacman()
    {
        if (pacman == null) return false;
        Vector2 pacmanPos = pacman.GetComponent<Rigidbody2D>().position;
        float distance = Vector2.Distance(rb.position, pacmanPos);
        return distance <= inspectRange;
    }

    //当吃豆人吃到超级豆子时，鬼被冻结，并且可以被吃掉
    public void OnFreeze()
    {
        lastDirection = direction;
        direction = DIRECTION.STOP;
        SpriteRenderer sr = GetComponent<SpriteRenderer>();
        sr.color = new Color(sr.color.r, sr.color.g, sr.color.b, 0.5f);
        GetComponent<EnemyCD>().freeze = true;
    }

    //解冻
    public void UnFreeze()
    {
        direction = lastDirection;
        SpriteRenderer sr = GetComponent<SpriteRenderer>();
        sr.color = new Color(sr.color.r, sr.color.g, sr.color.b, 1.0f);
        GetComponent<EnemyCD>().freeze = false;
    }

    public void Reload()
    {
        UnFreeze();
        initStep = 0;
        direction = DIRECTION.UP;
        lastDirection = DIRECTION.UP;
        rb.position = initPos;
    }
    
}
