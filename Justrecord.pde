
void setupRecord() {
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  initAudioFout();
  font = createFont("Arial",fontSize);
  textFont(font,fontSize);
  //initKinect();
  //displayImg = createImage(sW,sH,RGB);
  sayText="READY  " + fileName + shot;
  println(sayText);
}

//---

void drawRecord() {
  if(modeRec) {
    if(!fout.isRecording()){
    xmlInit();
    fout.beginRecord();
    }
    timestamp=millis();
    sayText = fileName + shot + "_frame" + counter + "." + fileType;
    saveFrame(filePath + "_folder" + "/" + fileName + shot + "/" + sayText);
    xmlAdd();
    sayText="REC " + sayText;
    println(sayText);
    counter++;
  }
}

//-----------------------------------------

void recDot() {
  fill(200);
  text(sayText,80,35);
  text(int(frameRate) + " fps", sW-60,35);
  noFill();
  if(record&&(counter%2!=0)) {
    stroke(255,0,0);
  } 
  else {
    stroke(35,0,0);
  }
  strokeWeight(20);
  point(20,30);
  stroke(200);
  strokeWeight(1);
  rectMode(CORNER);
  rect(3,59,633,360);
  line((sW/2)-10,(sH/2),(sW/2)+10,(sH/2));
  line((sW/2),(sH/2)-10,(sW/2),(sH/2)+10);
}

//---

void keyPressed() {
  if(key==' ') {
doSaveWrapup();
  }
}

//---
void doSaveWrapup(){
      if (needsSaving) {
      needsSaving=false;
      if(fout.isRecording()){
      fout.endRecord();
      fout.save();
      initAudioFout();
      }
      println("saved " + fileName+shot+"."+audioFileType);
      xmlSaveToDisk();
      println("saved " + "timestamps_" + fileName + shot + ".xml");
      shot++;
      sayText="READY  shot" + shot;
      println(sayText);
      counter=1;
    }
}
//---

/*
void imageProcess() {
  for(int i=0;i<depthArray.length;i++) {
    float q = map(depthArray[i],minDepthValue,maxDepthValue,255,0);
    depthArray[i] = color(q);
  }
  displayImg.pixels = depthArray;
  displayImg.updatePixels();
  //displayImg.filter(GRAY);
  //displayImg.filter(INVERT);
}
*/

//---

void initKinect() {
  context = new SimpleOpenNI(this);
  context.setMirror(mirror);
  if(depthSwitch){
    context.enableDepth();
  }
  if(rgbSwitch){
    context.enableRGB();
  }
}

//---

void initAudioFout(){
  fout = minim.createRecorder(in,filePath + "/" + fileName + shot + "." + audioFileType,true);
}

//---

void stop() {
  in.close();
  minim.stop();
  //kinect.quit();
  super.stop();
  exit();
}

/* saves the XML list to disk */
void xmlSaveToDisk() {
  xmlIO.saveElement(xmlFile, xmlFileName);
}  

void xmlAdd() {
  proxml.XMLElement frame = new proxml.XMLElement("frame");
  xmlFile.addChild(frame);
  frame.addAttribute("index",counter);
  frame.addAttribute("timestamp",timestamp);
}

void xmlInit() {
  xmlIO = new XMLInOut(this);
  xmlFileName = fileName + shot + ".xml";
  xmlFile = new proxml.XMLElement("timestamps");
  xmlFile.addAttribute("shot",shot);
}

//---   END   ---
