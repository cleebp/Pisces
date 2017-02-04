/**
 *
 */

class Fish extends Kinematics
{
  color c;
  float maxSpeed = 3;
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
  Kinematics[] targets;
  
  boolean leader = false;
  boolean wander = false;
  
  long last_update;
  
  Fish(int x, int y) 
  {
    super(x, y);
    pos = new PVector(x, y);
    c = color(0, 0, 0);
    or = 0;
    vel = new PVector(maxSpeed, 0);
    linear_acceleration = new PVector(0, 0);
    
    goal = new Kinematics(0, 0);
    last_update = millis();
  }
  
  // Update pos, vel, or
  void update() 
  {
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
    
    Kinematics c = getClosest((Kinematics)this, targets);
    if(inBruceRadius()) 
    {
      avoid(bruce.pos);
    }
    else if(!leader && inRadius(c.pos)) 
    {
      avoid(c.pos);
    } 
    else if(leader || wander) 
    {
      wander();
    } 
    else 
    {
      seek(getClosest((Kinematics)this, new Kinematics[] {targets[0], targets[1]}));
      seek(getClosest((Kinematics)this, targets));
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
  
  void seek(Kinematics k) 
  {
    PVector tar_pos = k.pos;
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
  
  private boolean inBruceRadius() 
  {
    return dist(pos.x, pos.y, bruce.pos.x, bruce.pos.y) < 150;
  }
  
  // Draw the fishy on the screen
  void display() {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x,pos.y);
    rotate(or);
    ellipse(0, 0, 20, 20);
    triangle(3, -10, 20, 0, 3, 10);
    popMatrix();
  }
}