import java.util.ArrayList;
import java.util.Collections;

int index = 0;

//your input code should modify these!!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;
float bx = 0;
float by = 0;
float bs = 0;
float xOffsetTrans = 0;
float yOffsetTrans = 0;
float xOffsetResize = 0;
float yOffsetResize = 0;
float radius = inchesToPixels(.15f);
float cnt =0;

int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean overBoxTrans = false;
boolean overBoxResize = false;
boolean locked = false;
boolean dragged = false;
boolean translated = false;
boolean rotated = false;
boolean resized = false;

final int screenPPI = 72; //what is the DPI of the screen you are using 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(600,600); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();
  textSize(15);
  
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }
  
  Target t = targets.get(trialIndex);
  
  
   //boolean onCircle = dist(bx,by,mouseX,mouseY)>=inchesToPixels((sqrt(2)*(t.z/2))-radius);
  
   boolean onCircle = (sqrt(2)*(t.z/2))-radius <= dist(bx,by,mouseX,mouseY) && dist(bx,by,mouseX,mouseY) <= (sqrt(2)*(t.z/2))+radius;  
  
  //dist(bx,by,mouseX,mouseY)>=inchesToPixels((sqrt(2)*(t.z/2))-radius) && 
  //dist(bx,by,mouseX,mouseY)<=inchesToPixels((sqrt(2)*(t.z/2))+radius)
  bx = width/2 + t.x + screenTransX;
  bs = t.z/2;
  by = height/2 + t.y + screenTransY;
  if (mouseX > bx-bs && mouseX < bx+bs && 
      mouseY > by-bs && mouseY < by+bs) {
    overBoxTrans = true;  
    if(!locked) { 
      strokeWeight(3);
      stroke(255); 
      fill(153);
    } 
  } 
  else{
    overBoxTrans = false;
  }
  if (onCircle) {
    overBoxResize = true;  
    if(!locked) { 
      strokeWeight(3);
      stroke(255); 
      fill(153);
    } 
  }
  else{
    overBoxResize = false;
  }
  
  if (!overBoxResize && !overBoxTrans){
    strokeWeight(2);
    stroke(153);
    fill(153);
    overBoxResize = false;
    overBoxTrans = false;
  }
  
  //println("overBoxResize: "+overBoxResize);
  //println("testCnt"+cnt);
  //cnt++;
  //println("mouseX: "+mouseX+" mouseY: "+mouseY);

  
  
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  

  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen

  rotate(radians(t.rotation));

  fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t.z, t.z);
  float radius = inchesToPixels(.15f);
  fill(255,255,0);
  ellipse(0, 0, radius, radius);
  noFill();
  if (locked){
    strokeWeight(3);
  }
  ellipse(0, 0, sqrt(2)*(t.z), sqrt(2)*(t.z));
  popMatrix();

  //===========DRAW TARGETTING SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(screenRotation));
  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  fill(255, 128); //set color to semi translucent
  rect(0, 0, screenZ, screenZ);
  fill(255,255,0);
  ellipse(0, 0, radius, radius);
  popMatrix();


  
  if (!translated){
    //make a line btw the target and targetting
    stroke(0, 255, 0);
    line(bx, by, width/2, height/2);
    
    // draw a triangle at (x2, y2)
    pushMatrix();
    translate(width/2, height/2);
    float a = atan2(bx- (width/2), (height/2) - by);
    rotate(a);
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    popMatrix();
  }
  newScaffoldControlLogic(); 
  
  fill(255,255,0);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}


  //===========MODIFIED SCAFFOLD DESIGN=================

void newScaffoldControlLogic()
{
  
  textSize(20);
  
  //tranlate
  fill(124, 252, 0);
  text("move the square", width / 2 - 200, inchesToPixels(1.0f));
  if (checkForLocation() == false) {
    translated = false;
  } else {
    translated = true;
    strokeWeight(5);
    stroke(124, 252, 0);
    line(width / 2 - 280, inchesToPixels(0.9f), width / 2 - 100, inchesToPixels(0.9f));
  }
  //rotate
  fill(124, 252, 0);
  text("rotate", width / 2 - 250, inchesToPixels(1.5f));
  if (checkForRotation() == false) {
    rotated = false;
    fill(255, 255, 0);
    text(degreeDif(), width / 2 - 100, inchesToPixels(1.5f));
  } else {
    rotated = true;
    strokeWeight(5);
    stroke(124, 252, 0);
    line(width / 2 - 280, inchesToPixels(1.4f), width / 2 - 100, inchesToPixels(1.4f));
  }
  fill(255, 255, 0);
  text("CW", width / 2 + 200, inchesToPixels(1.5f));
  fill(255, 255, 0);
  text("CCW", width / 2 + 100, inchesToPixels(1.5f));
  //resize
  fill(124, 252, 0);
  text("rescale by drag", width / 2 - 210, inchesToPixels(2.0f));
  if (checkForSize() == false) {
    resized = false;
    
    fill(255, 255, 0);
    text(sizeDif(), width / 2 - 100, inchesToPixels(2.0f));
  } else {
    resized = true;
    strokeWeight(5);
    stroke(124, 252, 0);
    line(width / 2 - 280, inchesToPixels(1.9f), width / 2 - 100, inchesToPixels(1.9f));
  }
  //text("-", width / 2, inchesToPixels(2.0f));
  //text("+", width / 2 + 80, inchesToPixels(2.0f));
  
  //proceed
  if (translated == true && rotated == true && resized == true) {
    textSize(32);
    fill(255, 0, 0);
    text("next", width / 2 + 200, height / 2);
  }
  
  
  //upper left corner, rotate counterclockwise
  //text("CCW", width / 2 + inchesToPixels(2f), inchesToPixels(1.8f));
  if (mousePressed && dist(width / 2 + 100, inchesToPixels(1.5f), mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation--;

  //upper right corner, rotate clockwise
  //text("CW", width / 2 + inchesToPixels(2.5f), inchesToPixels(1.8f));
  if (mousePressed && dist( width / 2 + 200, inchesToPixels(1.5f), mouseX, mouseY)<inchesToPixels(.5f) && !dragged)
    screenRotation++;

  //lower left corner, decrease Z
  //text("-", width / 2 + inchesToPixels(2f), inchesToPixels(2.8f));
  //if (mousePressed && dist(width / 2, inchesToPixels(2.0f), mouseX, mouseY)<inchesToPixels(.5f) && !dragged)
    //screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  //text("+", width / 2 + inchesToPixels(2.5f), inchesToPixels(2.8f));
  //if (mousePressed && dist(width / 2 + 80, inchesToPixels(2.0f), mouseX, mouseY)<inchesToPixels(.5f) && !dragged)
    //screenZ+=inchesToPixels(.02f);

  // go to the next step
  if (mousePressed && dist(width/2 + 200, height / 2, mouseX, mouseY)<inchesToPixels(.5f) && !dragged)
    {
    if (translated == true && rotated == true && resized == true) {
      if (userDone==false && !checkForSuccess()) {
        errorCount++;
      }
      trialIndex++;
      screenTransX = 0;
      screenTransY = 0;
      translated = false;
      rotated = false;
      resized = false;
      if (trialIndex==trialCount && userDone==false)
      {
        userDone = true;
        finishTime = millis();
      }
    }
    
  }
}

//my example design
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f) )
    screenRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation++;

  //lower left corner, decrease Z
  text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  text("+", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ+=inchesToPixels(.02f);

  //left middle, move left
  text("left", inchesToPixels(.2f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX-=inchesToPixels(.02f);

  text("right", width-inchesToPixels(.2f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX+=inchesToPixels(.02f);
  
  text("up", width/2, inchesToPixels(.2f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY-=inchesToPixels(.02f);
  
  text("down", width/2, height-inchesToPixels(.2f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY+=inchesToPixels(.02f);
}


void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
    if(overBoxTrans) { 
    locked = true; 
    
    fill(255, 255, 255);
    } 
    else if (overBoxResize){
      locked = true;
    }
    else {
      locked = false;
    }
    xOffsetTrans = mouseX - bx; 
    yOffsetTrans = mouseY - by; 
    
    //println("Locked: "+locked);
    //println("overBoxResize: "+overBoxResize);
    //println("overBoxTrans: "+overBoxTrans);
    //if (overBoxResize){
    //  locked = true;
    //}
    //else{
    //}
    
}

void mouseDragged() {
  Target t = null;
  if (trialIndex<trialCount){
    t = targets.get(trialIndex);
  }
  
  if(locked && trialIndex<trialCount && overBoxTrans) {
    dragged = true;
    bx = mouseX-xOffsetTrans; 
    by = mouseY-yOffsetTrans;
    screenTransX = bx - (width/2 + t.x);
    screenTransY = by - (height/2 + t.y);
  }
  
  if(locked && trialIndex<trialCount && overBoxResize) {
    strokeWeight(6);
    dragged = true;
    t.z = (2* (dist(bx, by, mouseX, mouseY)))/sqrt(2);
    
  }
}


void mouseReleased()
{
  
  ////check to see if user clicked middle of screen
  //if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f) && !dragged)
  //{
  //  if (userDone==false && !checkForSuccess())
  //    errorCount++;

  //  //and move on to next trial
  //  trialIndex++;

  //  screenTransX = 0;
  //  screenTransY = 0;

  //  if (trialIndex==trialCount && userDone==false)
  //  {
  //    userDone = true;
  //    finishTime = millis();
  //  }
  //}
  
  dragged = false;
  locked = false;
  
  //println("Locked: "+locked);
}

public boolean checkForLocation()
{
  Target t = targets.get(trialIndex);
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f);
  return closeDist;
}

public boolean checkForRotation()
{
  Target t = targets.get(trialIndex);
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  return closeRotation;
}

public boolean checkForSize()
{
  Target t = targets.get(trialIndex);
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f);
  return closeZ;
}

public float sizeDif() 
{
  Target t = targets.get(trialIndex);
  float tmp = (t.z - screenZ) / inchesToPixels(.02f);
  return tmp;
}  

public float degreeDif() 
{
  Target t = targets.get(trialIndex);
  double tmp = calculateDifferenceBetweenAngles(t.rotation,screenRotation);
  return (float)tmp;
} 


public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);  
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  
  
  println("Close Enough Distance: " + closeDist);
  println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
  println("Close Enough Z: " + closeZ);
  
  return closeDist && closeRotation && closeZ;  
}


double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }