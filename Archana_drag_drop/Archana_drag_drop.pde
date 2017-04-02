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
float xOffset = 0;
float yOffset = 0;

int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean overBox = false;
boolean locked = false;
boolean dragged = false;
boolean translated = false;
boolean rotated = false;

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
  size(800,800); 

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

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }
  
  Target t = targets.get(trialIndex);
  
  bx = width/2 + t.x + screenTransX;
  bs = t.z/2;
  by = height/2 + t.y + screenTransY;
  if (mouseX > bx-bs && mouseX < bx+bs && 
      mouseY > by-bs && mouseY < by+bs) {
    overBox = true;  
    if(!locked) { 
      strokeWeight(2);
      stroke(255); 
      fill(153);
    } 
  } else {
    strokeWeight(2);
    stroke(153);
    fill(153);
    overBox = false;
  }

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
    translate(bx, by);
    float a = atan2(t.x + screenTransX, t.y - screenTransY);
    rotate(a);
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    popMatrix();
  }
  newScaffoldControlLogic(); //you are going to want to replace this!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}


  //===========MODIFIED SCAFFOLD DESIGN=================

void newScaffoldControlLogic()
{
  
  textSize(32);
  fill(255, 255, 0);
  //tranlate
  text("1. move the square to center", width / 2, inchesToPixels(1.5f));
  text("left", width / 2 - inchesToPixels(1.5f), inchesToPixels(2.75f));
  text("right", width / 2 + inchesToPixels(1.5f), inchesToPixels(2.75f));
  text("up", width/2, inchesToPixels(2f));
  text("down", width/2, inchesToPixels(3.5f));
  if (checkForLocation() == true) {
    translated = true;
    strokeWeight(5);
    line(width / 2 - 300, inchesToPixels(1.4f), width / 2 + 300, inchesToPixels(1.4f));
  }
  else{
    translated = false;
  }
  //rotate
  text("2. rotate the square", width / 2 - 200, inchesToPixels(6.5f));
    //text("CCW", width / 2 + inchesToPixels(2f), inchesToPixels(1.8f));
  text("CW", width / 2, inchesToPixels(6.5f));
  if (!rotated){
    text(degreeDif(), width / 2 + inchesToPixels(3f), inchesToPixels(6.5f));
  }
  
  if (checkForRotation() == true) {
    rotated = true;
    strokeWeight(5);
    line(width / 2 - 400, inchesToPixels(6.4f), width / 2 + 400, inchesToPixels(6.4f));
  }
  else{
    rotated = false;
  }
  //rescale
  text("3. rescale the square", width / 2 - 200, inchesToPixels(8.0f));
  text("-", width / 2, inchesToPixels(8.0f));
  text("+", width / 2 + 80, inchesToPixels(8.0f));
  text(sizeDif(), width / 2 + inchesToPixels(3f), inchesToPixels(8.0f));
  if (checkForSize() == true) {
    strokeWeight(5);
    line(width / 2 - 400, inchesToPixels(7.9f), width / 2 + 400, inchesToPixels(7.9f));
  }
  
  
  //upper left corner, rotate counterclockwise
  //text("CCW", width / 2 + inchesToPixels(2f), inchesToPixels(1.8f));
  //if (mousePressed && dist(width / 2 + inchesToPixels(2f), inchesToPixels(1.8f), mouseX, mouseY)<inchesToPixels(.5f))
    //screenRotation--;

  //upper right corner, rotate clockwise
  //text("CW", width / 2 + inchesToPixels(2.5f), inchesToPixels(1.8f));
  if (mousePressed && dist( width / 2, inchesToPixels(6.5f), mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation++;

  //lower left corner, decrease Z
  //text("-", width / 2 + inchesToPixels(2f), inchesToPixels(2.8f));
  if (mousePressed && dist(width / 2, inchesToPixels(8.0f), mouseX, mouseY)<inchesToPixels(.5f))
    screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  //text("+", width / 2 + inchesToPixels(2.5f), inchesToPixels(2.8f));
  if (mousePressed && dist(width / 2 + 80, inchesToPixels(8.0f), mouseX, mouseY)<inchesToPixels(.5f))
    screenZ+=inchesToPixels(.02f);

  //left middle, move left
  //text("left", inchesToPixels(.2f), height/2);
  if (mousePressed && dist(width / 2 - inchesToPixels(1.5f), inchesToPixels(2.75f), mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX-=inchesToPixels(.01f);

  //text("right", width-inchesToPixels(.2f), height/2);
  if (mousePressed && dist(width / 2 + inchesToPixels(1.5f), inchesToPixels(2.75f), mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX+=inchesToPixels(.01f);
  
  //text("up", width/2, inchesToPixels(.2f));
  if (mousePressed && dist(width/2, inchesToPixels(2f), mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY-=inchesToPixels(.01f);
  
  //text("down", width/2, height-inchesToPixels(.2f));
  if (mousePressed && dist(width/2, inchesToPixels(3.5f), mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY+=inchesToPixels(.01f);
}

//my example design
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
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
    if(overBox) { 
    locked = true; 
    fill(255, 255, 255);
    } else {
      locked = false;
    }
    xOffset = mouseX - bx; 
    yOffset = mouseY - by; 
    
    
}

void mouseDragged() {
  Target t = targets.get(trialIndex);
  
  if(locked) {
    dragged = true;
    bx = mouseX-xOffset; 
    by = mouseY-yOffset;
    screenTransX = bx - (width/2 + t.x);
    screenTransY = by - (height/2 + t.y);
  }
}


void mouseReleased()
{
  
  //check to see if user clicked middle of screen
  if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(.5f) && !dragged)
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;

    screenTransX = 0;
    screenTransY = 0;

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  
  if (dragged){
    dragged = false;
    locked = false;
  }
  
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