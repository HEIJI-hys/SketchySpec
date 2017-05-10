//Libraries  //<>//
import g4p_controls.*;
import static javax.swing.JOptionPane.*;
import processing.serial.*;
import java.awt.Font;

//Declarations
Serial myPort;
GButton btnConnect, btnDisconnect, btnScan, btnClear, btnRunBlank, btnFindMax, btnSetPosition, btnRead;
GDropList lstSerial;
GTextField txtPosition, txtGraphLower, txtGraphUpper;
GLabel lblTo, lblRead;

String[] ports;
final int BAUD_RATE = 9600; //Usually not necessary to change, can be made modifiable later
Font font = new Font("Arial", Font.PLAIN, 20); //GUI font, not the drawing font
boolean newDataScan = false; //flag for receiving (meaningful) data in the serial, in the scan() process, such that draw() doesn't go crazy and cause problems
boolean blankRun = false; //flag, to see whether to pass the current values into the blank array
boolean singleRead =false;//flag to know if it's only a single read so it doesn't mess with the rest od SerialEvent()
int graphWidth = 950;
int graphHeight = 720;
int graphX = 40;
int graphY = 70;
int posLower = 20; //boundaries of the angle values from the servo, can be made modifiable later
int posUpper = 130;
int valLower = 0; //Arbitrary values bracketing the value from the sensor to make the graph more readable. To be implemented auto-changes on this later.
int valUpper = 200;
int i;
int[] scanPos = new int[112]; //stores position value in Scan()
float[] scanVal= new float[112]; //Stores analog value in Scan()
float[] scanValDraw= new float[112]; //Mapped values
float[] scanPosDraw= new float[112]; //Mapped values
float[] blank = new float[112]; //storing da blank values
PFont labelFont;

void setup() {
  labelFont = createFont("Arial", 16, true);
  drawGrid();
  i=1;
  size(1200, 820); 
  ports = Serial.list();
  printArray(ports);
  scanPos[0]=0;
  scanVal[0]=0;
  scanValDraw[0]=graphY;
  scanPosDraw[0]=graphX;

  //This part should be in the if statement later!!!!!!!!
  btnClear = new GButton(this, 800, 10, 100, 30, "Clear");
  btnClear.setFont(font);
  //btnClear.setEnabled(false);
  txtGraphLower = new GTextField(this, 920, 10, 70, 30);
  txtGraphLower.setText(str(valLower));
  txtGraphLower.setFont(font);
  lblTo = new GLabel(this, 995, 10, 50, 30, "to");
  lblTo.setFont(font);
  txtGraphUpper = new GTextField(this, 1020, 10, 70, 30);
  txtGraphUpper.setText(str(valUpper));
  txtGraphUpper.setFont(font);
  btnRunBlank = new GButton(this, 1000, 70, 160, 50, "Run Blank");
  btnRunBlank.setFont(font);
  btnRunBlank.setEnabled(false);
  btnFindMax = new GButton(this, 1000, 140, 160, 50, "Find Max");
  btnFindMax.setFont(font);
  btnFindMax.setEnabled(false);  
  txtPosition = new GTextField(this, 1000, 210, 160, 50);
  txtPosition.setFont(font);
  btnSetPosition = new GButton(this, 1000, 270, 160, 50, "Set Pos");
  btnSetPosition.setFont(font);
  btnSetPosition.setEnabled(false);
  btnRead = new GButton(this, 1000, 340, 160, 50, "Read");
  btnRead.setFont(font);
  btnRead.setEnabled(false);
  lblRead = new GLabel(this, 1000, 410, 160, 150);
  lblRead.setFont(font);


  //Check if a serial port is available, if so, draw stuffs, otherwise exit the application
  if (ports.length >0) {  
    lstSerial = new GDropList(this, 10, 10, 200, 150); //honestly the buttons sure can be an array to make life easier. But lazy me decide to go with copy and paste for now ¯\_(ツ)_/¯
    lstSerial.setItems(ports, 0);
    lstSerial.setFont(font);
    btnConnect = new GButton(this, 220, 10, 100, 30, "Connect");
    btnConnect.setFont(font);
    btnDisconnect = new GButton(this, 340, 10, 140, 30, "Disconnect");
    btnDisconnect.setFont(font);
    btnScan = new GButton(this, 500, 10, 90, 30, "Scan");
    btnScan.setFont(font);
    btnScan.setEnabled(false);
  } else {
    showMessageDialog(null, "Nothing is plugged in!", "Alert", ERROR_MESSAGE);
    exit();
  }
}

void draw() {
  colorMode(HSB, 360, 100, 100);
  if (newDataScan) {
    strokeWeight(2);
    stroke(map(scanPos[i], posLower, posUpper, 0, 270), 100,100);
    line(scanPosDraw[i-1], height-scanValDraw[i-1], scanPosDraw[i], height-scanValDraw[i]);
    newDataScan=false;
    i++;
  }
}

void drawGrid() {
  colorMode(RGB,255);
  noStroke();
  fill(210);
  rect(graphX-50, graphY-20, graphWidth+100, graphHeight+50);
  fill(255);
  stroke(0);
  strokeWeight(3);
  rect(graphX, graphY, graphWidth, graphHeight);
  stroke(0, 0, 0, 80);
  strokeWeight(1);
  for (int i=0; i<11; i++) {
    line(graphX+i*(graphWidth/10), graphY, graphX+i*(graphWidth/10), graphY+graphHeight); //vertical lines
    line(graphX, graphY+i*(graphHeight/10), graphX+graphWidth, graphY+i*(graphHeight/10)); //horizontal lines
    String posText = str(int(map(i, 0, 10, posLower, posUpper))); //map: range of angle values --> graphing area width
    String valText = str(int(map(i, 0, 10, valUpper, valLower)));
    textFont(labelFont, 20);
    fill(0);
    textAlign(CENTER);
    text(posText, graphX+i*(graphWidth/10), graphY+graphHeight+20);
    textAlign(RIGHT);
    text(valText, graphX-5, graphY+i*(graphHeight/10)+5);
  }
}

void handleButtonEvents(GButton button, GEvent event) {
  if (button == btnConnect && event == GEvent.CLICKED) {
    // handles clicked even for connect button
    myPort = new Serial(this, Serial.list()[lstSerial.getSelectedIndex()], BAUD_RATE);
    btnDisconnect.setEnabled(true);
    btnScan.setEnabled(true);
    btnClear.setEnabled(true);
    btnRunBlank.setEnabled(true);
    btnSetPosition.setEnabled(true);
    btnFindMax.setEnabled(true);
    btnRead.setEnabled(true);
    print(myPort);
  } else if (button == btnDisconnect && event == GEvent.CLICKED) {
    myPort.clear();
    myPort.stop();
    btnDisconnect.setEnabled(false);
    btnScan.setEnabled(false);
    printArray(blank);
  } else if (button == btnScan && event == GEvent.CLICKED) {
    myPort.write('s');
    println("scanning...");
    i=1;
  } else if (button == btnClear && event == GEvent.CLICKED) {
    drawGrid();
  } else if (button == btnRunBlank && event == GEvent.CLICKED) {
    myPort.write('s');
    i=1;
    blankRun = true;
  } else if (button == btnFindMax && event == GEvent.CLICKED) {
    for (int i =0; i<111; i++) {
      if (scanVal[i] == max(scanVal)) {
        txtPosition.setText(str(scanPos[i]));
      }
    }
  } else if (button == btnSetPosition && event == GEvent.CLICKED) {
    myPort.write('l');
    int writePos = int(txtPosition.getText());
    if (writePos == 0) {
      showMessageDialog(null, "Number not valid", "Alert", ERROR_MESSAGE);
    } else {
      myPort.write(writePos);
    }
  } else if (button == btnRead && event == GEvent.CLICKED) {
    fill(205);
    rect(1000,410,160,150);
    myPort.write('r');
    singleRead = true;
  }
}


public void handleTextEvents(GEditableTextControl textcontrol, GEvent event) { 
  if (textcontrol == txtGraphLower && event == GEvent.CHANGED) {
    valLower = int(txtGraphLower.getText());
  } else if (textcontrol == txtGraphUpper && event == GEvent.CHANGED) {
    valUpper = int(txtGraphUpper.getText());
  }
}

void serialEvent (Serial myPort) {
  String inString = myPort.readStringUntil('\n'); //Read a line until linebreak, returns null if unavailable
  println(inString);
  if (inString != null) {
    if (singleRead) {
      int read = int(inString);
      float absorbance = 1.1;
      String absorbanceText = "Absorbance was not obtained(somehow)";
      int position = int(txtPosition.getText());
      for (int i =0; i<111; i++) {
        if (position == scanPos[i]) {
          absorbance = log(read/blank[i])/log(10);
        }
      }
      if (absorbance != 1.1) { 
        absorbanceText = str(absorbance);
      }
      lblRead.setText("For Pos: " + txtPosition.getText() + " \nValue: " + trim(inString) + " \nAbs: " + absorbanceText);
      singleRead=false;
    } else {
      String j[] = split(inString, ','); //data from Arduino format: pos,val
      scanPos[i] = int(j[0]);
      scanVal[i] = float(j[1]);
      //println(scanPos[i], scanVal[i]);
      scanValDraw[i] = map(scanVal[i], valLower, valUpper, graphY, graphHeight); //maps it to the screen height
      scanPosDraw[i] = map(scanPos[i], posLower, posUpper, graphX, graphWidth); //maps it to the screen width
      //println(scanPosDraw[i]);
      newDataScan = true;
      if (i == 110 && blankRun == true) {
       arrayCopy(scanVal, blank);
       blankRun = false;
     }
    }
  }
}