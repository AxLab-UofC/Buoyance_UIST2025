using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OSCController : MonoBehaviour {

    // Use this for initialization
    [SerializeField] Transform robots;
    [SerializeField] Transform gestures;
    [SerializeField] Transform hand;
    [SerializeField] Transform objects;
    //[SerializeField] Transform target;
    void Start () {
        // this line triggers the magic
        OSCHandler.Instance.Init ();
    }

    // Update is called once per frame
    void Update () {
        for(int i = 0; i < robots.childCount; i++){
            Transform robot = robots.GetChild(i);
            List<object> robotTransformData = new List<object> (){
                i,
                robot.position.x,
                robot.position.y,
                robot.position.z,
                robot.localEulerAngles.x,
                robot.localEulerAngles.y,
                robot.localEulerAngles.z
            };
            OSCHandler.Instance.SendMessageToClient ("myRemoteLocation", "/robot", robotTransformData);
        }

        for(int i = 0; i < gestures.childCount; i++){
            Transform gesture = gestures.GetChild(i);
            List<object> gestureTransformData = new List<object> (){
                i,
                gesture.position.x,
                gesture.position.y,
                gesture.position.z,
                gesture.localEulerAngles.x,
                gesture.localEulerAngles.y,
                gesture.localEulerAngles.z
            };
            OSCHandler.Instance.SendMessageToClient ("myRemoteLocation", "/gesture", gestureTransformData);
        }
        
        List<object> handTransformData = new List<object> (){
             hand.position.x,
             hand.position.y,
             hand.position.z,
             hand.localEulerAngles.x,
             hand.localEulerAngles.y,
             hand.localEulerAngles.z
        };
        OSCHandler.Instance.SendMessageToClient("myRemoteLocation", "/hand", handTransformData);

        for(int i = 0; i < objects.childCount; i++){
            Transform ob = objects.GetChild(i);
            List<object> objectTransformData = new List<object> (){
                i,
                ob.position.x,
                ob.position.y,
                ob.position.z,
                ob.localEulerAngles.x,
                ob.localEulerAngles.y,
                ob.localEulerAngles.z
            };
            OSCHandler.Instance.SendMessageToClient ("myRemoteLocation", "/object", objectTransformData);
        }

        // List<object> targetTransformData = new List<object> (){
        //     target.position.x,
        //     target.position.y,
        //     target.position.z,
        //     target.localEulerAngles.x,
        //     target.localEulerAngles.y,
        //     target.localEulerAngles.z
        // };

    }
}