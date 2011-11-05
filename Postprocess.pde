//This is a utility to post-process and check for drop frames in Kinect recordings.
//Copy the data folder recorded by Kinect_just_record before you start.


void setupRender() {
  reInit();
  if(record3D){
  cam = new PeasyCam(this, sW);
  }
  //smooth();
  stroke(255);
}

void xmlLoad() {
  xmlIO = new XMLInOut(this);
  try {
    xmlIO.loadElement(xmlFileName); //loads the XML
  }
  catch(Exception e) {
    //if loading failed 
    println("Loading Failed");
  }
}

void reInit() {
  readFrameNum = readFrameNumOrig;
  writeFrameNum = readFrameNum;
  addFrameCounter = 0;
  subtractFrameCounter = 0;
  xmlFileName = readFilePath + "/" + readFileName + shotNum + ".xml";
  errorAllow = 0;
  loaded = false;
  countFolder();
  xmlLoad();
}

void xmlEventRead(proxml.XMLElement element) {
  //this function is ccalled by default when an XML object is loaded
  xmlFile = element;
  //parseXML(); //appelle la fonction qui analyse le fichier XML
  loaded = true;
  readTimestamps();
  println("average interval: " + getAverageInterval() + " ms   |   correct interval: " + idealInterval + " ms");
}


void drawRender() {
  background(0);
  if (shotNum<=numberOfFolders) {
    if (loaded) {
      if (readFrameNum<readFrameNumMax) {
        readString = readFilePath + "/" + readFileName + shotNum + "/" + readFileName + shotNum + "_frame" + readFrameNum + "." + readFileType;
        println("-- read: " + readString + "     timestamp: " + timestamps[readFrameNum-1]  + " ms");
        img = loadImage(readString);
        if(record3D){
          objGenerate();
        }else{
          image(img, 0, 0);
        }
        checkTimestamps();
        if (!checkTimeAhead()&&checkTimeBehind()) { //behind and not ahead; add a missing frame
          //********************
          int q = 1;
          if (readFrameNum>readFrameNumOrig) {
            q = timestamps[readFrameNum-1]-timestamps[readFrameNum-2];
          }
          writeFile(int(q/int(idealInterval)));
          //********************
          addFrameCounter+=errorAllow/idealInterval;
          diffReport += "   ADDED FRAMES";
          errorAllow -= idealInterval;
        }
        else if (checkTimeAhead()&&!checkTimeBehind()) {  //ahead and not behind; skip an extra frame
          subtractFrameCounter++;
          diffReport += "   REMOVED FRAMES";
          errorAllow += idealInterval;
        }
        else if (!checkTimeAhead()&&!checkTimeBehind()) {  //not ahead and not behind; do nothing
          diffReport += "   OK";
          writeFile(1);
        }
        println("written: " + writeString + diffReport);
        readFrameNum++;
      } 
      else {
        renderVerdict();
        if (shotNum==numberOfFolders) {
          exit();
        }
        else {
          shotNum++;
          reInit();
        }
      }
    }
  }
  else {
    exit();
  }
  
}

void countFolder() {
  dataFolder = new File(sketchPath, readFilePath + "/" + readFileName + shotNum+"/");
  numFiles = dataFolder.list();
  readFrameNumMax = numFiles.length+1;
}

void writeFile(int reps) {
  for (int i=0;i<reps;i++) {
    writeString = writeFilePath + "/" + writeFileName + shotNum + "/" + writeFileName + shotNum + "_frame"+writeFrameNum+"."+writeFileType;
    
    saveFrame(writeString);

    if(record3D&&reps>1){
      objGenerate();
    }
    //println("written: " + writeString + diffReport);
    writeFrameNum++;
  }
}

void readTimestamps() {
  timestamps = new int[numFiles.length];
  for (int i=0;i<numFiles.length;i++) {
    timestamps[i] = int(xmlFile.getChild(i).getAttribute("timestamp"));
    println(timestamps[i]);
  }
}

void checkTimestamps() {
  if (readFrameNum>readFrameNumOrig) {
    float q = timestamps[readFrameNum-1]-timestamps[readFrameNum-2];
    diffReport = "     diff: " + int(q) + " ms" + "   min: " + int(idealInterval)+ " ms" + "   cumulative error: " + int(errorAllow) + " ms";
    errorAllow += q-idealInterval;
  }
}

boolean checkTimeBehind() {
  if (errorAllow>idealInterval) {
    return true;
  } 
  else {
    return false;
  }
}

boolean checkTimeAhead() {
  if (errorAllow<-1*idealInterval) {
    return true;
  } 
  else {
    return false;
  }
}

void renderVerdict() {


  //int timeDiff = int(30*((timestamps[timestamps.length-1] - timestamps[0])/1000));
  println("SHOT" + shotNum + " COMPLETE");
  /*
   println(int(addFrameCounter) + " dropped frames added");
   println(int(subtractFrameCounter) + " extra frames removed");
   */
}

float getAverageInterval() {
  float q = ((timestamps[3] - timestamps[2]) + (timestamps[1] - timestamps[0]))/2;
  for (int i=4;i<timestamps.length/4;i++) {
    float qq = ((timestamps[i+3] - timestamps[i+2]) + (timestamps[i+1] - timestamps[i]))/2;
    q = (q+qq)/2;
  }
  return q;
}

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
}

void objGenerate(){
  background(0);
  if(record3D){
    objBegin();
  }
  buffer = img;
    for (int y = 0; y < sH; y++) {
    for (int x = 0; x < sW; x++) {
      // FIXME: this loses Z-resolution about tenfold ...
      //       -> should grab the real distance instead...
      color argb = buffer.pixels[y*width+x];
      gray[y][x] = gray(argb);
    }
  }

  // Kyle McDonald's original source used here
  pushMatrix();
  translate(-sW / 2, -sH / 2);  
  int step = 2;
  for (int y = step; y < sH; y += step) {
    float planephase = 0.5 - (y - (sH / 2)) / zskew;
    for (int x = step; x < sW; x += step)
    {
      stroke(gray[y][x]);
      //point(x, y, (gray[y][x] - planephase) * zscale);
      line(x, y, (gray[y][x] - planephase) * zscale, x+1, y, (gray[y][x] - planephase) * zscale);
    }
  }
  popMatrix();
  if(record3D){
    objEnd();
  }
}

void objBegin(){
        beginRaw("superCAD.ObjFile", writeFilePath + "/" + writeFileName + shotNum + "/" + writeFileName + shotNum + "_frame"+writeFrameNum+"."+ "obj"); // Start recording to the file
}

void objEnd(){
      endRaw();
}

//~~~   END   ~~~

