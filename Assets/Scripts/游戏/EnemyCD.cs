using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyCD : MonoBehaviour {

    public bool freeze = false;
    private GameObject gameController;

    private void Start()
    {
        gameController = GameObject.FindGameObjectWithTag("GameController");
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if(freeze)
        {
            GetComponent<EnemyMove>().Reload();
            gameController.GetComponent<GameController>().OnEatEnemy();
        }
        else
        {
            if(collision.gameObject.tag == "Pacman")
            {
                gameController.GetComponent<GameController>().GameOver();
            }
        }
    }
}
