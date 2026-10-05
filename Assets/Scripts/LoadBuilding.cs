using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadBuilding : MonoBehaviour
    {
        private void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.CompareTag("SceneChange"))
            {
                SceneManager.LoadScene("Scenes/building_01");
            }
        }
    }
