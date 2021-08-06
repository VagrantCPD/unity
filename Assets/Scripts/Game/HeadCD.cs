using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeadCD : MonoBehaviour {

    private GameObject gameController;

    private void Start()
    {
        gameController = GameObject.FindGameObjectWithTag("GameController");
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Food"))
        {
            Destroy(collision.gameObject);
            gameController.GetComponent<GameController>().OnEatFood();
        }
        else if(collision.gameObject.CompareTag("Boundary"))
        {
            if (BeginController.mode == 0)
            {
                gameController.GetComponent<GameController>().GameOver();
            }
            else if(BeginController.mode == 1)
            {
                gameController.GetComponent<GameController>().CrossBoundary();
            }
        }
        else if(collision.gameObject.CompareTag("Body"))
        {
            gameController.GetComponent<GameController>().GameOver();
        }
        else if(collision.gameObject.CompareTag("Bonus"))
        {
            Destroy(collision.gameObject);
            gameController.GetComponent<GameController>().OnEatBonus();
        }
    }

    
}
