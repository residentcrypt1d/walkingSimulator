using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadVoid : MonoBehaviour
    {
        private void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.CompareTag("SceneChange"))
            {
                SceneManager.LoadScene("Scenes/void");
            }
        }
    }
