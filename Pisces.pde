/**
 * pisces.pde
 * 
 * @author: Brian Clee | bpclee@ncsu.edu
 * @version: 2/3/2017
 */
 
Fish[] fishList;
Shark bruce;

int trails = 20;
int[] leaders;

void setup() 
{
  background(2, 37, 94);
  fullScreen();
  //size(displayWidth, displayHeight);
  //size(1280,800);
  
  //spawn a shark at a random point on the left side of the screen
  bruce = new Shark(0, int(random(height)));
  
  fishList = new Fish[900];
  leaders = new int[fishList.length/100];
  for(int i = 0; i < fishList.length; i++) 
  {
    fishList[i] = new Fish(int(random(width)), int(random(height)));
    fishList[i].targets = fishList;
    fishList[i].maxSpeed = random(1.5) + 2.5;
    fishList[i].c = color(0, 0, int(pow(fishList[i].maxSpeed, 4)));
  }
  
  for(int i = 0; i < leaders.length; i++)
  {
    int index = int(random(fishList.length));
    fishList[index].leader = true;
    fishList[index].c = color(0, 0, 0);
    fishList[index].maxSpeed = 2;
    leaders[i] = index;
  }
}

void draw() 
{
  // draws a semi-transparent rectangle over the window to create fading trails
  fill(2, 37, 94, trails);
  rect(0, 0, width, height);
  int m = millis();
  // stupid fucking jank to get around multiple hits on each second
  if(m%1000 < 35)
    m -= m%1000;
  
  
  if(bruce.lives())
  {
    if(bruce.update())
      bruce.display();
  }
  /** this bit isn't needed if the shark doesn't die
  else if(m%50000 == 0)
  {
    bruce.revive();
    bruce.update();
    bruce.display();
  }*/
  
  // every 20 seconds chose a new leader to follow
  if(m%20000 == 0)
  {
    bruce.goal.pos = fishList[leaders[int(random(leaders.length))]].pos;
    bruce.update();
    bruce.display();
  }
  
  // every 10 seconds shuffle the leaders
  if(m%10000 == 0)
  {
    for(int i = 0; i < leaders.length; i++)
    {
      int index = leaders[i];
      fishList[index].leader = false;
      fishList[index].c = color(0, 0, int(pow(fishList[i].maxSpeed, 4)));
      fishList[index].maxSpeed = random(1.5) + 2.5;
    }
    
    for(int i = 0; i < leaders.length; i++)
    {
      int index = int(random(fishList.length));
      fishList[index].leader = true;
      fishList[index].c = color(0, 0, 0);
      fishList[index].maxSpeed = 2;
      leaders[i] = index;
    }
  }
  
  for(int i = fishList.length-1; i >= 0; i--) 
  {
    fishList[i].update();
    fishList[i].display();
  }
}