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

import controlP5.*;

ControlP5 cp5;

Range rangeW;
Range rangeH;

void setup() {
  size(640, 520);
  
  cp5 = new ControlP5(this);
  rangeW = cp5.addRange("rangeW")
               .setPosition(20,20)
               .setSize(200,20)
               .setRange(0,width)
               .setRangeValues(65,593)
               ;
  rangeH = cp5.addRange("rangeH")
               .setPosition(20,40)
               .setSize(200,20)
               .setRange(0,width)
               .setRangeValues(96,440)
               ;
  
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  
  oscP5 = new OscP5(this,12000);
  myBroadcastLocation = new NetAddress("127.0.0.1",32000);
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
  
  OscMessage myOscMessage = new OscMessage("/kinect_pos");
  
  /* add a value (an integer) to the OscMessage */
  myOscMessage.add(new float[]{v2.x / width, v2.y / height});
  
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
