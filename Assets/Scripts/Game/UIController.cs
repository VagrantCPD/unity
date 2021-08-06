using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;
using UnityEngine;

public class UIController : MonoBehaviour {

    public Text stageText;
    public Text scoreText;
    public Text lengthText;
    public Text modeText;

    public Text gameOverText;
    public Text replayText;
    public Text pauseText;
    private int dots = 0;

    public Button controlPlay;
    public Button controlSound;
    public Sprite pauseSprite;
    public Sprite playSprite;
    public Sprite replaySprite;
    public Sprite muteSprite;
    public Sprite demuteSprite;

    private void Start()
    {
        scoreText.text = "得 分:\n0";
        lengthText.text = "长 度:\n0";
        stageText.text = "阶 段\n1";

        if(BeginController.mode == 0)
        {
            modeText.text = "边 界 模 式";
            modeText.color = new Color32(230, 92, 59, 255);
        }
        else if(BeginController.mode == 1)
        {
            modeText.text = "自 由 模 式";
            modeText.color = new Color32(116, 169, 43, 255);
        }
    }
    
	public void UpdateScoreText(int score)
    {
        scoreText.text = "得 分:\n" + score.ToString();
    }

    public void UpdateLengthText(int length)
    {
        lengthText.text = "长 度:\n" + length.ToString();
    }

    public void UpdateStageText(int stage)
    {
        if (stage == GameController.maxStage)
        {
            stageText.text = "阶 段\n MAX";
        }
        else
        {
            stageText.text = "阶 段\n" + stage.ToString();
        }
    }
    public void UpdateControlButton(bool paused)
    {
        if(paused)
        {
            controlPlay.GetComponent<Image>().sprite = playSprite;
        }
        else
        {
            controlPlay.GetComponent<Image>().sprite = pauseSprite;
        }
    }
    public void UpdateSoundControlButton()
    {
        int mute = PlayerPrefs.GetInt("mute", 0);
        if (mute == 1)
        {
            controlSound.GetComponent<Image>().sprite = muteSprite;
        }
        else if(mute == 0)
        {
            controlSound.GetComponent<Image>().sprite = demuteSprite;
        }
    }
    public void SetReplayButton()
    {
        controlPlay.GetComponent<Image>().sprite = replaySprite;
    }
    public void ShowGameOverText()
    {
        gameOverText.text = "Game Over!";
        replayText.text = "按‘R’重新开始";
    }
    public void SetPauseText(bool pause)
    {
        if (pause)
        {
            InvokeRepeating("UpdateDot", 0.0f, 0.5f);
        }
        else
        {
            CancelInvoke("UpdateDot");
            pauseText.text = "";
            dots = 0;
        }
    }
    private void UpdateDot()
    {
        string text = "暂 停 中\n";
        for(int i=0;i<dots %4;i++)
        {
            text += "。";
        }
        pauseText.text = text;
        dots++;
    }
}
