void detectHandGesture(PVector palm, PVector middle) {
  PVector gesture = PVector.sub(middle, palm);
  float horizontalMag = sqrt(sq(gesture.x) + sq(gesture.z));
  float verticalAngle = atan2(abs(gesture.y), abs(gesture.x));
  float distance = sqrt(sq(gesture.x) + sq(gesture.z) +  sq(gesture.y));
  
  //print("angle: " + verticalAngle + "\n");
  //print("dis: " + distance + "\n");
  if (abs(verticalAngle) > 0.5 && distance < 150) {
    gesture_status = 1; 
  }
  else {
    gesture_status = 0;
  }
}

int detectRobot(PVector hand, int except){
  float distance = -1;
  int select = -1;
  for(int i = 0; i < nBalloons; i++){
    PVector robot = new PVector(balloons[i].objectCenter.x, balloons[i].objectCenter.y);
    PVector dif = PVector.sub(hand, robot);
    if(distance == -1 || distance >= abs(sqrt(sq(dif.x) + sq(dif.y)))){
      if(i != except){
        distance = abs(sqrt(sq(dif.x) + sq(dif.y)));
        select = i;
      }
    }
  }
  return select;
}
