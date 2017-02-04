/**
 *
 */

class Shark extends Kinematics
{
  color c;
  boolean exists;
  float maxSpeed = 2;
  float maxRot = .005;
  
  float maxAccel = .5;
  float maxAngularAccel = 0.01;
  
  float radiusOfSat = 20;
  float radiusOfDecel = 120;
  float radiusOfSat_rot = PI/32;
  float radiusOfDecel_rot = PI/4;
  
  PVector linear_acceleration;
  float angular_acceleration;
  
  float timeToTargetVelocity = 10;
  float timeToTargetRot = 10;
  
  Kinematics goal;
  
  long last_update;
  
  Shark(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(88, 0, 0);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);
    
    goal = new Kinematics(width, int(random(height)));
    last_update = millis();
    exists = true;
  }
  
  // Update pos, vel, or
  boolean update() 
  {
    /**has traveled off the screen, delete it
    if(pos.x > width || pos.x < 0 || pos.y > height || pos.y < 0) 
    {
      exists = false;
      return false;
    }*/
    
    if(pos.x > width) 
    {
      pos.x = 0;
    }
    if(pos.x < 0) 
    {
      pos.x = width;
    }
    if(pos.y > height) 
    {
      pos.y = 0;
    }
    if(pos.y < 0) 
    {
      pos.y = height;
    }
    
    wander();
    
    float speed = scale(vel.mag(), maxSpeed);
    vel.normalize();
    vel.mult(speed);
    
    pos.add(vel);
    or = vel.heading();
    last_update = millis();
    
    return true;
  }

  void wander() 
  {
    long dtime = millis() - last_update;
    goal.or += maxRot * (random(1) - random(1)) * dtime * 3;       
    
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
    vel.x = cos(or);
    vel.y = sin(or);
    
    seekGoal();
    vel.normalize();
    vel.mult(maxSpeed);
  }
  
  void seekGoal() 
  {
    PVector tar_pos = goal.pos;
    long dtime = millis() - last_update;
    
    PVector direction = new PVector(tar_pos.x - pos.x, tar_pos.y - pos.y);
    //float distance = dist(tar_pos.x, tar_pos.y, pos.x, pos.y);
    
    float goalSpeed;
    goalSpeed = maxSpeed;
    
    goal.vel = direction;
    goal.vel.normalize();
    goal.vel.mult(goalSpeed);
    linear_acceleration.x = goal.vel.x - vel.x;
    linear_acceleration.y = goal.vel.y - vel.y;
    linear_acceleration.div(timeToTargetVelocity);
    
    vel.add(linear_acceleration);
    vel.normalize();
    vel.mult(goalSpeed);
    
    goal.or = vel.heading();
    
    if(abs(or - goal.or)%(2*PI) < radiusOfSat_rot) 
    {
      or = goal.or;
      return;
    }
       
    float goalRot;
    if(abs(or - goal.or) < radiusOfDecel_rot) 
    {
      goalRot = maxRot*(abs(or-goal.or)/radiusOfDecel_rot) * dtime;
    } 
    else 
    {
      goalRot = maxRot * dtime;
    }
    
    if(abs(goal.or - or)%(2*PI) < PI) 
    {
      angular_acceleration = goal.or - or;
    } 
    else 
    {
      angular_acceleration = or - goal.or;
    }
    
    angular_acceleration /= timeToTargetRot;
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    rot += angular_acceleration;
    rot = scale(rot, goalRot);
    or += rot;
  }
  
  float scale(float a, float b) 
  {
    boolean is_neg = a < 0;
    a = min(abs(a), b);
    if(is_neg) a *= -1;
    return a;
  }
  
  boolean lives()
  {
    return exists;
  }
  
  void revive()
  {
    exists = true;
    pos = new PVector(0, int(random(height)));
  }
  
  void display() 
  {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 60, 60); //og: 0, 0, 20, 20
    triangle(9, -30, 60, 0, 9, 30); //og: 3, -10, 20, 0, 3, 10
    popMatrix();
  }
}