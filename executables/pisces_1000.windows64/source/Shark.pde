/**
 * Shark.pde
 * 
 * @author: Brian Clee
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
  //long life_time;
  
  Shark(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(155, 0, 0);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);

    goal = new Kinematics(width, int(random(500,(height-400))));
    last_update = millis();
    //life_time = millis();
    exists = true;
  }
  
  // Update pos, vel, or
  boolean update() 
  {
    if(dolphins[0].exists)
    {
      if(pos.x > width || pos.x < canvas_x || pos.y > height || pos.y < canvas_y) 
      {
        exists = false;
        //life_time = millis();
        return false;
      }
      seekGoal();
      
      float speed = scale(vel.mag(), maxSpeed);
      vel.normalize();
      vel.mult(speed);
      
      pos.add(vel);
      or = vel.heading();
      last_update = millis();
      return true;
    }
    
    if(pos.x > width) 
    {
      pos.x = canvas_x;
    }
    if(pos.x < canvas_x) 
    {
      pos.x = width;
    }
    if(pos.y > height) 
    {
      pos.y = canvas_y;
    }
    if(pos.y < canvas_y) 
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
  
  void revive()
  {
    exists = true;
    //life_time = millis();
    pos = new PVector(0, int(random(height)));
    goal = new Kinematics(width, int(random(420,height-400)));
  }
  
  boolean lives()
  {
    return exists;
  }
  
  void display() 
  {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 40*modifier, 40*modifier); //og: 0, 0, 20, 20
    triangle(6*modifier, -20*modifier, 40*modifier, 0, 6*modifier, 20*modifier); //og: 3, -10, 20, 0, 3, 10
    popMatrix();
  }
}