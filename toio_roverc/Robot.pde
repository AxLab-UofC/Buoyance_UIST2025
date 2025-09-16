public class Robot
{
  private int id;
  private PVector position;
  //private PVector angle;
  private float yaw;
  private PVector target;
  private boolean isActive;
  
  //PID control parameter
  private float Kp = 1.0;
  private float Ki = 0.001;
  private float Kd = 9.0;
  private float previousError;
  private float integral;
  
  public float baseSpeed = 0.3;
  public boolean targetSet;

  public Robot(int i, boolean isActive)
  {
    this.id = i;
    this.position = new PVector(0, 0);
    //this.angle = new PVector(0.0,0.0);
    this.yaw = 0;
    this.target = new PVector(0,0);
    this.targetSet = false;
    this.integral = 0;
    this.previousError = 0;
    this.isActive = isActive;
  }
  
  public void setPosition(PVector position){
    this.position = position;
  }
  
  public void setAngle(float yaw){
    this.yaw = yaw;
  }
  
  public void setTargetPosition(PVector target){
    this.target = target;
  }
  
  public void setTargetSet(boolean targetSet){
    this.targetSet = targetSet;
  }
  
  public PVector getPosition(){
    return position;
  }
  public void drawRobot(float matSize){
    pushMatrix();
    translate(width/2 + position.x/matSize, height/2 + position.y/matSize);
    fill(0);
    textSize(20);
    text(id, 0, -80/matSize);
    noFill();
    //rotate(yaw * PI / 180);
    rotate(yaw);
    rect(-40/matSize, -40/matSize, 80/matSize, 80/matSize);
    line(0, 0, 0, -80/matSize);
    popMatrix();
  }
  
  public void initPID(){
    this.integral = 0;
    this.previousError = PVector.dist(position,target);
  }
  
  public void moveToTargetSimulator(){
    
    //calculate the direction for the target
    PVector direction = PVector.sub(target, position);
    float distance = direction.mag();
    direction.normalize();
    float targetYaw = atan2(direction.y, direction.x);
    
    //draw target
    pushMatrix();
    translate(width/2 + target.x, height/2 + target.y);
    fill(0);
    noFill();
    //rotate(yaw * PI / 180);
    rotate(targetYaw);
    ellipse(0, 0, 20, 20);
    line(0, 0, 20, 0);
    popMatrix();
    
    //PID control
    //float error = targetYaw - yaw;
    float error = distance;
    integral += error;
    float derivative = error - previousError;
    float control = Kp*error + Ki*integral + Kd*derivative;
    previousError = error;
    
    float speed = baseSpeed;
    if(distance < 30){
      speed = map(distance,0,30,0,baseSpeed);
    }
    // for target
    //yaw += control;
    
    //PVector velocity = PVector.fromAngle(yaw).mult(speed);
    PVector velocity = direction.mult(control*speed);
    position.add(velocity);
    
    if(distance < 1){
      position.set(target);
      targetSet = false;
      integral = 0;
    }
  }
  
  public void moveToTarget(Client client){
    
    //calculate the direction for the target
    PVector direction = PVector.sub(new PVector(target.x*matSize, target.y*matSize), position);
    float distance = direction.mag();
    direction.normalize();
    float targetYaw = atan2(direction.y, direction.x);
    
    //draw target
    pushMatrix();
    translate(width/2 + target.x, height/2 + target.y);
    fill(0);
    noFill();
    //rotate(yaw * PI / 180);
    rotate(targetYaw);
    ellipse(0, 0, 20, 20);
    line(0, 0, 20, 0);
    popMatrix();
    
    //PID control
    //float error = targetYaw - yaw;
    float error = distance;
    integral += error;
    float derivative = error - previousError;
    float control = Kp*error + Ki*integral + Kd*derivative;
    previousError = error;
    
    float speed = baseSpeed;
    //if(distance < 30){
    //  speed = map(distance,0,30,0,baseSpeed);
    //}
    // for target
    //yaw += control;
    
    //PVector velocity = PVector.fromAngle(yaw).mult(speed);
    PVector velocity = direction.mult(control*speed);
    //position.add(velocity);
    
    velocity = new PVector(velocity.x, -velocity.y);
    velocity = velocity.rotate(yaw);
    
    float ratio = velocity.y/velocity.x;
    if(velocity.x < -128 || velocity.x > 127 || velocity.y < -128 || velocity.y > 127){
      if(abs(velocity.x) > abs(velocity.y)){
        velocity.x = (velocity.x > 0) ? 127 : -128;
        velocity.y = velocity.x * ratio;
      }else{
        velocity.y = (velocity.y > 0) ? 127 : -128;
        velocity.x = velocity.y / ratio;
      }
    }
    
    // draw velocity
    pushMatrix();
    translate(width/2 + position.x/matSize, height/2 + position.y/matSize);
    rotate(yaw);
    stroke(255,0,0);
    strokeWeight(3);
    line(0,0,velocity.x,-velocity.y);
    stroke(0,0,0);
    strokeWeight(1);
    popMatrix();
    
    if(distance < 30/matSize){
      //position.set(target);
      targetSet = false;
      integral = 0;
      client.write('s');
    }else if(position.x/matSize <= -width/2 || position.x/matSize >= width/2 || position.y/matSize <= -height/2 || position.y/matSize >= height/2){
      client.write('s');
    }else{
      sendSpeedVector(client,velocity);
      println(velocity);
    }
  }
  
  void sendSpeedVector(Client client, PVector speed){
    byte[] data = new byte[8+1];
    
    data[0] = (byte)'p';
  
    ByteBuffer bb = ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN);;
    bb.putFloat(speed.x);
    bb.putFloat(speed.y);
    
    byte[] speedBytes = bb.array();
    System.arraycopy(speedBytes, 0, data, 1, speedBytes.length);
    
    client.write(data);
  }
}
