// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

import oscP5.*;
import netP5.*;

OscP5 oscP5;

/* a NetAddress contains the ip address and port number of a remote location in the network. */
NetAddress myBroadcastLocation; 

float minW, maxW, minH, maxH;
float minKW, maxKW, minKH, maxKH;


import controlP5.*;

ControlP5 cp5;

Range rangeW;
Range rangeH;
Range rangeKW;
Range rangeKH;

void setup() {
  size(640, 520);
  
  cp5 = new ControlP5(this);
  rangeW = cp5.addRange("rangeW")
               .setPosition(20,20)
               .setSize(200,20)
               .setRange(0,width)
               .setRangeValues(96,565)
               ;
  rangeH = cp5.addRange("rangeH")
               .setPosition(20,40)
               .setSize(200,20)
               .setRange(0,width)
               .setRangeValues(138,376)
               ;
  rangeKW = cp5.addRange("rangeKW")
               .setPosition(20,80)
               .setSize(200,20)
               .setRange(0,width)
               .setRangeValues(60,590)
               ;
  rangeKH = cp5.addRange("rangeKH")
               .setPosition(20,100)
               .setSize(200,20)
               .setRange(0,width)
               .setRangeValues(46,398)
               ;
  
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  
  oscP5 = new OscP5(this,12000);
  myBroadcastLocation = new NetAddress("127.0.0.1",32000);
  
  frameRate(30);
}

void draw() {
  background(255);

  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  fill(50, 100, 250, 200);
  noStroke();
  ellipse(v1.x, v1.y, 20, 20);

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);
  
  fill(0, 255, 0, 40);
  rect(minW, minH, maxW - minW, maxH - minH);
  
  stroke(0, 0, 255);
  noFill();
  rect(minKW, minKH, maxKW - minKW, maxKH - minKH);
  
  OscMessage myOscMessage = new OscMessage("/kinect_pos");
  
  float valX = map(v2.x, minW, maxW, 0, 1);
  float valY = map(v2.y, minH, maxH, 0, 1);
  
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(new float[]{valX, valY});
  
  oscP5.send(myOscMessage, myBroadcastLocation);

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
}

void controlEvent(ControlEvent theControlEvent) {
  if(theControlEvent.isFrom("rangeW")) {
    minW = int(theControlEvent.getController().getArrayValue(0));
    maxW = int(theControlEvent.getController().getArrayValue(1));
  }
  if(theControlEvent.isFrom("rangeH")) {
    minH = int(theControlEvent.getController().getArrayValue(0));
    maxH = int(theControlEvent.getController().getArrayValue(1));
  }
  if(theControlEvent.isFrom("rangeKW")) {
    minKW = int(theControlEvent.getController().getArrayValue(0));
    maxKW = int(theControlEvent.getController().getArrayValue(1));
  }
  if(theControlEvent.isFrom("rangeKH")) {
    minKH = int(theControlEvent.getController().getArrayValue(0));
    maxKH = int(theControlEvent.getController().getArrayValue(1));
  }
}

// Adjust the threshold with key presses
void keyPressed() {
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
}
