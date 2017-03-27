/**
 * Dolphin.pde
 *
 * @author: Brian Clee
 */

class Dolphin extends Kinematics
{
  color c;
  float maxSpeed = 5;
  float maxRot = .005;
  
  float maxAccel = .5;
  float maxAngularAccel = 0.01;
  
  float radiusOfSat = 100*modifier;
  float radiusOfDecel = 120;
  float radiusOfSat_rot = PI/32;
  float radiusOfDecel_rot = PI/4;
  
  PVector linear_acceleration;
  float angular_acceleration;
  
  float timeToTargetVelocity = 10;
  float timeToTargetRot = 10;
  
  Kinematics goal;
  Kinematics[] targets;
  
  boolean leader = false;
  boolean wander = false;
  
  long last_update;
  boolean exists;
  
  Dolphin(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(70, 0, 155);//(163, 0, 138);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);
    
    goal = new Kinematics(0, 0);
    last_update = millis();
    exists = false; // doesnt start spawned
  }
  
  // Update pos, vel, or
  void update() 
  {
    if(!bruce.lives())
    {
      if(pos.x > width || pos.x < canvas_x || pos.y > height || pos.y < canvas_y) 
      {
        exists = false;
      }
      seekGoal();
      float speed = scale(vel.mag(), maxSpeed);
      vel.normalize();
      vel.mult(speed);
      
      pos.add(vel);
      or = vel.heading();
      last_update = millis();
      return;
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
    
    if(bruce.lives() && inRadius(bruce.pos)) 
    {
      avoid(bruce.pos);
    } 
    else if(!bruce.lives()) 
    {
      wander();
    } 
    else 
    {
      seekBruce();
    }
    
    float speed = scale(vel.mag(), maxSpeed);
    vel.normalize();
    vel.mult(speed);
    
    pos.add(vel);
    or = vel.heading();
    last_update = millis();
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
    
    vel.normalize();
    vel.mult(maxSpeed);
  }
  
  void seekBruce() 
  {
    PVector tar_pos = bruce.pos;
    long dtime = millis() - last_update;
    
    PVector direction = new PVector(tar_pos.x - pos.x, tar_pos.y - pos.y);
    float distance = dist(tar_pos.x, tar_pos.y, pos.x, pos.y);
    
    float goalSpeed;
    if(inRadius(tar_pos)) 
    {
      goalSpeed = maxSpeed * (distance/radiusOfDecel);
    } 
    else 
    {
      goalSpeed = maxSpeed;
    }
    
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
  
  void avoid(PVector k) 
  {
    PVector tar_pos = k;
    linear_acceleration.x = pos.x - tar_pos.x;
    linear_acceleration.y = pos.y - tar_pos.y;
    linear_acceleration.normalize();
    linear_acceleration.mult(maxAccel);
      
    angular_acceleration = vel.heading();
    angular_acceleration = scale(angular_acceleration, maxAngularAccel);
    
    vel.add(linear_acceleration);
  }
  
  float scale(float a, float b) 
  {
    boolean is_neg = a < 0;
    a = min(abs(a), b);
    if(is_neg) a *= -1;
    return a;
  }
  
  Kinematics getClosest(Kinematics given, Kinematics[] targetList) 
  {
    Kinematics closest = targetList[0];
    float closest_dist = dist(closest.pos.x, closest.pos.y, given.pos.x, given.pos.y);
    for(int i=0; i < targetList.length; i++) 
    {
      if(given == targetList[i]) 
        continue;
      float d = dist(targetList[i].pos.x, targetList[i].pos.y, given.pos.x, given.pos.y);
      if(d < closest_dist) 
      {
        closest = targetList[i];
        closest_dist = d;
      }
    }
    
    return closest;
  }

  private boolean inRadius(PVector t) 
  {
    return dist(pos.x, pos.y, t.x, t.y) < radiusOfSat;
  }
  
  boolean lives()
  {
    return exists;
  }
  
  void spawn()
  {
    exists = true;
    pos = new PVector(canvas_y, int(random(canvas_x,height)));
  }
  
  // Draw the fishy on the screen
  void display() {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 30*modifier, 30*modifier);
    triangle(4.5*modifier, -15*modifier, 30*modifier, 0, 4.5*modifier, 15*modifier);
    popMatrix();
  }
}