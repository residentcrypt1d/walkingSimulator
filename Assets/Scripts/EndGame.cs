using UnityEngine;
using UnityEngine.SceneManagement;

public class EndGame : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("SceneChange"))
        {
            SceneManager.LoadScene("Scenes/EndGame");
        }
    }
}
