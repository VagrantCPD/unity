using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class FoodMaker : MonoBehaviour {

    public GameObject[] foods;

    public GameObject bonus;

    public Boundary foodBoundary;
    public Boundary bonusBoundary;

    // Use this for initialization
    void Start () {
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    public void MakeFood()
    {
        GameObject backGround = GameObject.FindGameObjectWithTag("Background");
        int index = (int)Random.Range(0.0f, foods.Length);
        GameObject food = Instantiate(foods[index]);
        food.transform.SetParent(backGround.transform);

        int randomX = (int)Random.Range(foodBoundary.minX, foodBoundary.maxX);
        randomX = (int)(randomX / SnakeMove.step) * (int)(SnakeMove.step);

        int randomY = (int)Random.Range(foodBoundary.minY, foodBoundary.maxY);
        randomY = (int)(randomY / SnakeMove.step) * (int)(SnakeMove.step);

        food.transform.localPosition = new Vector3(randomX, randomY, 0.0f);
        
    }

    public void MakeBonus()
    {
        GameObject backGround = GameObject.FindGameObjectWithTag("Background");
        
        GameObject bonusObject = Instantiate(bonus);
        bonusObject.transform.SetParent(backGround.transform);

        int randomX = (int)Random.Range(bonusBoundary.minX + 5.0f, bonusBoundary.maxX - 5.0f);
        randomX = (int)(randomX / SnakeMove.step) * (int)(SnakeMove.step);

        int randomY = (int)Random.Range(bonusBoundary.minY + 5.0f, bonusBoundary.maxY - 5.0f);
        randomY = (int)(randomY / SnakeMove.step) * (int)(SnakeMove.step);

        bonusObject.transform.localPosition = new Vector3(randomX, randomY, 0.0f);
    }
}
