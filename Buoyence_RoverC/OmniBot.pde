//Important for robot targeting sends the message to the robot

public class OmniBot
{
  private PVector position;
  private PVector velocity;
  private float yaw;
  private PVector target;
  private float baseSpeed = 1.5;
  public boolean targetSet;
  private float size; // omnibot size for ROV
  
  //PID control parameter
  private float Kp = 0.6; // 0.3
  private float Ki = 0.001;
  private float Kd = 2.0;
  private float previousError;
  private float integral;
  
  //RVO parameters
  private float acceleration = 550;
  private float avoidanceTendency = 550;
  float pidWeight = 0.2;  // Less weight for pidVelocity
  float rvoWeight = 0.8;  // More weight for rvoVelocity
  private float preferred;
  private boolean check_initial;
  
  // send rate
  int sendRate = 10;
  int sendInterval = 1000 / sendRate;
  int lastSendTime = 0;
  
  //constructor
  public OmniBot(){
    this.position = new PVector(0, 0);
    this.velocity = new PVector(0, 0);
    //this.angle = new PVector(0.0,0.0);
    this.yaw = 0;
    this.size = 40*mmToToio;
    this.target = new PVector(0,0);
    this.targetSet = false;
    this.integral = 0;
    this.previousError = 0;
    this.check_initial = true;
    this.preferred = 0;
  }
  
  //setter
  public void setPosition(PVector position){this.position = position;}
  public void setVelocity(PVector velocity) {this.velocity = velocity;}
  public void setAngle(float yaw){this.yaw = yaw;}
  public void setTargetPosition(PVector target){this.target = target;}
  public void setTargetSet(boolean targetSet){this.targetSet = targetSet;}
  
  //getter
  public PVector getPosition(){return position;}
  
  
  /* -------------------------------------------------------------------------- */
  /*          RVO（Reciprocal Velocity Obstacles (Direction)）             */
  /* -------------------------------------------------------------------------- */
  float getDirection(){
    PVector preferredVelocity = PVector.sub(new PVector(this.target.x, this.target.y), new PVector(this.position.x, this.position.y));
    float l = preferredVelocity.mag();
    
    if(this.check_initial){
      this.check_initial = false;
      this.preferred = atan2(preferredVelocity.y, preferredVelocity.x);
    }
    
    float direction = this.preferred;
    
    for (OmniBot bot : omnibots) {
      if (this == bot) continue;
      PVector d = new PVector(bot.position.x - this.position.x, bot.position.y - this.position.y);
      float s = this.size + bot.size + 10;
      if(d.dot(d) - s * s < 200000){
        float k = atan2(d.y, d.x);
        float k_t = k + PI / 2;
        k_t = (k_t + PI) % (2 * PI) - PI;
        if(abs(k - this.preferred) > 0.01){
          direction = k_t;
        }
      }
    }
    for (int i = 0; i < nObstacles; i++) {
      PVector d = new PVector(obstacles[i].position.x - this.position.x, obstacles[i].position.y - this.position.y);
      float s = this.size + obstacles[i].size + 10;
      if(d.dot(d) - s * s < 250000){
        float k = atan2(d.y, d.x);
        float k_t = k + PI / 2;
        k_t = (k_t + PI) % (2 * PI) - PI;
        if(abs(k - this.preferred) > 0.01){
          direction = k_t;
        } 
      }
    }
    
    return direction;
  }
  
  
  /* -------------------------------------------------------------------------- */
  /*          RVO（Reciprocal Velocity Obstacles (Collisition Time)）             */
  /* -------------------------------------------------------------------------- */
  float len(float x, float y) {
    return sqrt(x * x + y * y);
  }
  
  PVector getRvoVelocity() {
    float accel = acceleration;
    float w = avoidanceTendency;
  
    PVector preferredVelocity = PVector.sub(new PVector(this.target.x, this.target.y), new PVector(this.position.x, this.position.y));
    float l = preferredVelocity.mag();
    if (l > 1) {
      preferredVelocity.mult(this.baseSpeed / l);
    }
  
    PVector rvoVelocity = preferredVelocity.copy();
    float minPenalty = Float.MAX_VALUE;
    
    if(getCollisionTime(preferredVelocity) == Float.MAX_VALUE){
      return preferredVelocity;
    }
  
    for (int i = 0; i < 300; i++) {
      float vx = this.velocity.x + accel * random(1);
      float vy = this.velocity.y + accel * random(1);
      //float vx = this.velocity.x + accel * (0.01 * i);
      //float vy = this.velocity.y;
      float collisionTime = getCollisionTime(new PVector(vx, vy));
      float penalty = w / collisionTime + len(vx - preferredVelocity.x, vy - preferredVelocity.y);
      if (penalty < minPenalty) {
        rvoVelocity = new PVector(vx, vy);
        minPenalty = penalty;
      }
    }
    for (int i = 0; i < 300; i++) {
      float vx = this.velocity.x + accel * random(1);
      float vy = this.velocity.y - accel * random(1);
      //float vx = this.velocity.x - accel * (0.01 * i);
      //float vy = this.velocity.y;
      float collisionTime = getCollisionTime(new PVector(vx, vy));
      float penalty = w / collisionTime + len(vx - preferredVelocity.x, vy - preferredVelocity.y);
      if (penalty < minPenalty) {
        rvoVelocity = new PVector(vx, vy);
        minPenalty = penalty;
      }
    }
    for (int i = 0; i < 300; i++) {
      float vx = this.velocity.x - accel * random(1);
      float vy = this.velocity.y + accel * random(1);
      //float vx = this.velocity.x;
      //float vy = this.velocity.y + accel * (0.01 * i);
      float collisionTime = getCollisionTime(new PVector(vx, vy));
      float penalty = w / collisionTime + len(vx - preferredVelocity.x, vy - preferredVelocity.y);
      if (penalty < minPenalty) {
        rvoVelocity = new PVector(vx, vy);
        minPenalty = penalty;
      }
    }
    for (int i = 0; i < 300; i++) {
      float vx = this.velocity.x - accel * random(1);
      float vy = this.velocity.y - accel * random(1);
      //float vx = this.velocity.x;
      //float vy = this.velocity.y - accel * (0.01 * i);
      float collisionTime = getCollisionTime(new PVector(vx, vy));
      float penalty = w / collisionTime + len(vx - preferredVelocity.x, vy - preferredVelocity.y);
      if (penalty < minPenalty) {
        rvoVelocity = new PVector(vx, vy);
        minPenalty = penalty;
      }
    }
    
    return rvoVelocity;
  }

  float getCollisionTime(PVector velocity) {
    float tmin = Float.MAX_VALUE;
  
    for (OmniBot bot : omnibots) {
      if (this == bot) continue;
  
      //PVector u = PVector.sub(PVector.add(velocity, velocity), new PVector(this.velocity.x + bot.velocity.x, this.velocity.y + bot.velocity.y));
      //PVector u = PVector.sub(PVector.add(this.velocity, velocity).div(2), bot.velocity);
      PVector u = PVector.sub(velocity, bot.velocity);
      PVector d = new PVector(bot.position.x - this.position.x, bot.position.y - this.position.y);
      float s = this.size + bot.size + 10;
      
      float c2 = u.dot(u);
      float c1 = -2 * u.dot(d);
      float c0 = d.dot(d) - s * s;
  
      float t = Float.MAX_VALUE;
      if (c2 == 0) {
          tmin = -c0 / c1;
      } else {
          float discriminant = c1 * c1 - 4 * c2 * c0;
          if (discriminant >= 0) {
            float sq = sqrt(discriminant);
            float t1 = (-c1 - sq) / (2 * c2);
            float t2 = (-c1 + sq) / (2 * c2);
            if (c0 < 0) {
              tmin = 0;  // Already collided!
            } else if (t1 > 0 && t1 < tmin) {
              tmin = t1;
            } else if (t2 > 0 && t2 < tmin) {
              tmin = t2;
            }
          }
       }
    }
    
    for (int i = 0; i < nObstacles; i++) {
      //PVector u = PVector.sub(PVector.add(velocity, velocity), new PVector(this.velocity.x + obstacles[i].velocity.x, this.velocity.y + obstacles[i].velocity.y));
      //PVector u = PVector.sub(PVector.add(this.velocity, velocity).div(2), obstacles[i].velocity);
      PVector u = PVector.sub(velocity, obstacles[i].velocity);
      PVector d = new PVector(obstacles[i].position.x - this.position.x, obstacles[i].position.y - this.position.y);
      float s = this.size + obstacles[i].size + 10;
      
      float c2 = u.dot(u);
      float c1 = -2 * u.dot(d);
      float c0 = d.dot(d) - s * s;

      float t = Float.MAX_VALUE;
      if (c2 == 0) {
          tmin = -c0 / c1;
      } else {
          float discriminant = c1 * c1 - 4 * c2 * c0;
          if (discriminant >= 0) {
            float sq = sqrt(discriminant);
            float t1 = (-c1 - sq) / (2 * c2);
            float t2 = (-c1 + sq) / (2 * c2);
            if (c0 < 0) {
              tmin = 0;  // Already collided!
            } else if (t1 > 0 && t1 < tmin) {
              tmin = t1;
            } else if (t2 > 0 && t2 < tmin) {
              tmin = t2;
            }
          }
       }
    }

    return tmin;
  }

  
  /* -------------------------------------------------------------------------- */
  /*                               PID Control                                  */
  /* -------------------------------------------------------------------------- */
  public void initPID(){
    //this.integral = 0;
    this.previousError = PVector.dist(new PVector(target.x, target.y), new PVector(position.x, position.y));
  }
  
  public void moveToTargetSimulator(){
    baseSpeed = 0.05;
    //calculate the direction for the target
    PVector direction = PVector.sub(new PVector(target.x, target.y), new PVector(position.x, position.y));
    float distance = direction.mag();
    direction.normalize();
    
    if(atan2(direction.y, direction.x) != this.preferred){
      this.preferred = atan2(direction.y, direction.x);
    }
    
    //PID control
    float error = distance;
    integral += error;
    float derivative = error - previousError;
    float control = Kp*error + Ki*integral + Kd*derivative;
    previousError = error;
    
    float speed = baseSpeed;
    //if(distance < 30){
    //  speed = map(distance,0,30,0,baseSpeed);
    //}
    
    //PVector velocity = direction.mult(control*speed);
    PVector pidVelocity = direction.mult(control*speed);
    
    //RVO
    //PVector rvoVelocity = getRvoVelocity();
    //print("vel: " + pidVelocity.x + " " + pidVelocity.y + "\n");
    //print("rvovel: " + rvoVelocity.x + " " + rvoVelocity.y + "\n");  
    //PVector finalVelocity = PVector.add(pidVelocity, rvoVelocity).div(2); // average of pidVeclocity and rvoVelocity  
    //PVector weightedPidVelocity = PVector.mult(pidVelocity, pidWeight);
    //PVector weightedRvoVelocity = PVector.mult(rvoVelocity, rvoWeight);
    //PVector finalVelocity = PVector.add(weightedPidVelocity, weightedRvoVelocity);
    
    //RVO with Direction
    float angle = getDirection();  
    float magnitude = pidVelocity.mag();
    float newX = magnitude * cos(angle);
    float newY = magnitude * sin(angle);
    PVector finalVelocity = new PVector(newX, newY);
    
    //No RVO (only PID control)
    //PVector finalVelocity = pidVelocity;
    
    this.setVelocity(finalVelocity);
    position.add(finalVelocity);
    
    if(distance < 4){
      position.set(target);
      this.setVelocity(new PVector(0,0));
      targetSet = false;
      integral = 0;
      this.check_initial = true;
      this.preferred = 0;
    }
  }
  
  public void moveToTarget(Client client){
    
    //calculate the direction for the target
    PVector direction = PVector.sub(new PVector(target.x, target.y), new PVector(position.x, position.y));
    float distance = direction.mag();
    direction.normalize();
    
    if(atan2(direction.y, direction.x) != this.preferred){
      this.preferred = atan2(direction.y, direction.x);
    }
    
    //PID control
    float error = distance;
    integral += error;
    float derivative = error - previousError;
    float control = Kp*error + Ki*integral + Kd*derivative;
    previousError = error;
    
    float speed = baseSpeed * ((xySpeed.getValue() / 100));

    PVector velocity = direction.mult(control*speed);
    
    //RVO with Direction
    /*float angle = getDirection();
    float magnitude = velocity.mag();
    float newX = magnitude * cos(angle);
    float newY = magnitude * sin(angle);
    velocity = new PVector(newX, newY);*/
    
    velocity  = new PVector(velocity.x, -velocity.y);
    velocity = velocity.rotate(yaw);
    
    /*
    PVector rvoVelocity = getRvoVelocity();
    velocity = PVector.add(velocity, rvoVelocity).div(2);*/
    
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
    
    if(distance < 50*mmToToio){
      targetSet = false;
      integral = 0;
      this.check_initial = true;
      this.preferred = 0;
    }
    int currentTime = millis();
    if(currentTime - lastSendTime >= sendInterval){
      // send command and data
      if(targetSet == false){
        client.write('s');
        //println("reach");
      }else{
        sendSpeedVector(client,velocity);
        //println(velocity);
      }
      lastSendTime = currentTime;
    }
    
  }
  
  void sendSpeedVector(Client client, PVector speed){
    byte[] data = new byte[8+1];
    //byte[] data = new byte[2+1];
    
    data[0] = (byte)'p';
  
    ByteBuffer bb = ByteBuffer.allocate(8).order(ByteOrder.LITTLE_ENDIAN);;
    bb.putFloat(speed.x);
    bb.putFloat(speed.y);
    
    byte[] speedBytes = bb.array();
    
    System.arraycopy(speedBytes, 0, data, 1, speedBytes.length);
    
    //ByteBuffer bb = ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN);;
    //bb.put((byte)constrain((int)speed.x, -128, 127));
    //bb.put((byte)constrain((int)speed.y, -128, 127));
    ////println("float x:"+speed.x+"float y:"+speed.y+"byte x:"+(byte)constrain((int)speed.x, -128, 127)+"byte y:"+(byte)constrain((int)speed.y, -128, 127));
    
    //byte[] speedBytes = bb.array();
    //System.arraycopy(speedBytes, 0, data, 1, speedBytes.length);
    
    client.write(data);
  }
}
