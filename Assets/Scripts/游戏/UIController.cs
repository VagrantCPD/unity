using UnityEngine;
using UnityEngine.UI;

public class UIController : MonoBehaviour {

    public Text remainText;
    public Text eatText;
    public Text scoreText;
    public Text messageText;
    public Text restartText;

	
    public void UpdateRemain(int remain)
    {
        remainText.text = "Remain\n\n" + remain.ToString();
    }

    public void UpdateEat(int eat)
    {
        eatText.text = "Eat\n\n" + eat.ToString();
    }

    public void UpdateScore(int score)
    {
        scoreText.text = "Score\n\n" + score.ToString();
    }

    public void UpdateMessage(bool win)
    {
        if(win)
        {
            messageText.text = "You Win!";
        }
        else
        {
            messageText.text = "You Lose!";
        }
        UpdateRestart();
    }

    private void UpdateRestart()
    {
        restartText.text = "Press 'R' to restart";
    }
}
