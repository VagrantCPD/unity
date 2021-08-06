using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;

[System.Serializable]
public class Boundary
{
    public float minX, maxX, minY, maxY;
}


public class GameController : MonoBehaviour {

    public GameObject snake;

    public GameObject foodMaker;

    public GameObject gameOverAnime;

    public GameObject audioController;

    public GameObject uiController;

    public static int maxStage = 10;

    

    private bool eatFood = false;

    private int score = 0;
    private int length = 1;
    private int stage = 1;
    private int scorePerStage;
    private int scoreInNowStage = 0;
    private bool bonus = false;

    public int minScorePerFood;
    public int maxScorePerFood;

    public enum STATE {PLAYING=0,PAUSE,GAMEOVER};
    public static STATE state = STATE.PLAYING;
    

	// Use this for initialization
	void Start () {
        scorePerStage = (minScorePerFood + maxScorePerFood) * 5;

        MakeFood();
        uiController.GetComponent<UIController>().UpdateSoundControlButton();
        audioController.GetComponent<AudioController>().InitBgm();
        state = STATE.PLAYING;
    }
	
	// Update is called once per frame
	void Update () {
        if (eatFood)
        {
            if (scoreInNowStage >= scorePerStage && stage < maxStage)
            {
                if (!bonus)
                {
                    bonus = true;
                    MakeBonus();
                }
            }
               
            MakeFood();
            AddBody();
            eatFood = false;
        }
        if(Input.GetKeyDown(KeyCode.Space))
        {
            if (state != STATE.GAMEOVER)
            {
                ControlPlay();
            }
        }
        else if(Input.GetKeyDown(KeyCode.Escape))
        {
            ReturnHome();
        }
        else if(Input.GetKeyDown(KeyCode.R))
        {
            if(state == STATE.GAMEOVER)
            {
                ControlPlay();
            }
        }
        else if(Input.GetKeyDown(KeyCode.S))
        {
            ControlSound();
        }
	}

    private void MakeFood()
    {
        foodMaker.GetComponent<FoodMaker>().MakeFood();
    }

    private void MakeBonus()
    {
        foodMaker.GetComponent<FoodMaker>().MakeBonus();
    }

    private void AddBody()
    {
        snake.GetComponent<SnakeMove>().AddBody();
    }

    public void OnEatFood()
    {
        eatFood = true;
        audioController.GetComponent<AudioController>().OnEat();
        AddScore();
        AddLength();
    }

    public void OnEatBonus()
    {
        audioController.GetComponent<AudioController>().OnEat();
        AddStage();
        snake.GetComponent<SnakeMove>().SpeedUp();
        UpdateScorePerFood();
        bonus = false;
    }

    public void GameOver()
    {
        state = STATE.GAMEOVER;
        StoreGrade();
        snake.GetComponent<SnakeMove>().StopMove();
        audioController.GetComponent<AudioController>().OnGameOver();
        uiController.GetComponent<UIController>().ShowGameOverText();
        uiController.GetComponent<UIController>().SetReplayButton();
        Instantiate(gameOverAnime, snake.GetComponent<SnakeMove>().GetHeadPos());
        Invoke("DestroySnake", 2.0f);
    }

    private void DestroySnake()
    {
        Destroy(snake);
    }

    private void AddLength()
    {
        length++;
        uiController.GetComponent<UIController>().UpdateLengthText(length);
    }

    private void AddScore()
    {
        int delta = (int)Random.Range(minScorePerFood, maxScorePerFood);
        score += delta;
        scoreInNowStage += delta;
        uiController.GetComponent<UIController>().UpdateScoreText(score);
    }

    private void AddStage()
    {
        stage++;
        uiController.GetComponent<UIController>().UpdateStageText(stage);
    }

    private void UpdateScorePerFood()
    {
        minScorePerFood += stage * 20;
        maxScorePerFood += stage * 20;
        scorePerStage = (minScorePerFood + maxScorePerFood) * 5;
        scoreInNowStage = 0;
    }

    public void ControlPlay()
    {
        if (state == STATE.PAUSE)
        {
            state = STATE.PLAYING;
            uiController.GetComponent<UIController>().UpdateControlButton(false);
            uiController.GetComponent<UIController>().SetPauseText(false);
            snake.GetComponent<SnakeMove>().RecoverMove();
        }
        else if(state == STATE.PLAYING)
        {
            state = STATE.PAUSE;
            uiController.GetComponent<UIController>().UpdateControlButton(true);
            uiController.GetComponent<UIController>().SetPauseText(true);
            snake.GetComponent<SnakeMove>().StopMove();
        }
        else if(state == STATE.GAMEOVER)
        {
            SceneManager.LoadSceneAsync("Scenes/Game");
        }
    }

    public void ControlSound()
    {
        int mute = PlayerPrefs.GetInt("mute", 0);
        mute = 1 - mute;
        PlayerPrefs.SetInt("mute", mute);
        uiController.GetComponent<UIController>().UpdateSoundControlButton();
        audioController.GetComponent<AudioController>().ControlBgm();
    }

    public void ReturnHome()
    {
        StoreGrade();
        SceneManager.LoadSceneAsync("Scenes/Begin");
    }
    private void StoreGrade()
    {
        PlayerPrefs.SetInt("lastL", length);
        PlayerPrefs.SetInt("lastS", score);

        int bestLength = PlayerPrefs.GetInt("bestL", 0) > length ? PlayerPrefs.GetInt("bestL") : length;
        int bestScore = PlayerPrefs.GetInt("bestS", 0) > score ? PlayerPrefs.GetInt("bestS") : score;

        PlayerPrefs.SetInt("bestL", bestLength);
        PlayerPrefs.SetInt("bestS", bestScore);
    }
    //自由模式下穿过边界
    public void CrossBoundary()
    {
        snake.GetComponent<SnakeMove>().CrossBoundary();
    }
}
