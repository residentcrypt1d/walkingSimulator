using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadBuilding_03 : MonoBehaviour
    {
        private void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.CompareTag("SceneChange"))
            {
                SceneManager.LoadScene("Scenes/building_03");
            }
        }
    }
