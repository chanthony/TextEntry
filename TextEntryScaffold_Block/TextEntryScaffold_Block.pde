import java.util.Arrays;
import java.util.Collections;

// Haptic Feedback
import android.app.Activity;
import android.content.Context;
import android.os.Vibrator;
import android.os.VibrationEffect;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 456; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

// The left edge of the input area
float leftEdge;

// Where the keys start
float topOfKeys;

// The Qwerty keyboard setup
String[] chars = split("q w e r t y u i o p a s d f g h j k l  z x c v _ _ b n m  "," ");

// The left block characters
String[] leftKeys = split("q w e r t a s d f g z x c v _", " ");

// The right block characters
String[] rightKeys = split("y u i o p h j k l  _ b n m  ", " ");

// The current number of consecutive clicks in the same square
int curClicks = 0;

// The last index clicked
int lastIndex = -1;

//Variables for my silly implementation. You can delete this:
String currentLetter = "a";

// Which screen they have selected
// 0 = show both blocks
// 1 = focus on left block
// 2 = focus on right block
int selected = 0;

// Haptic feedback event
Activity act;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(PORTRAIT); //can also be PORTRAIT -- sets orientation on android device
  size(1300, 2300); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("arial.ttf", 36)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  leftEdge = width/2-sizeOfInputArea/2 - 100;
  topOfKeys = height/2 - sizeOfInputArea/2 + sizeOfInputArea/3;

  // Haptic feedback stuff
  act = this.getActivity();
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background

  drawWatch();
  fill(105);
  rect(width/2-sizeOfInputArea/2 - 100, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 550); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(0);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 550); //draw the trial count
    fill(0);
    text("Target:   " + currentPhrase, 70, 600); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 640); //draw what the user has entered thus far 
    
    //draw very basic next button
    fill(0, 255, 0);
    rect(800, 350, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 850, 450); //draw next label

    //my draw code
    // Black outlines
    textAlign(CENTER);

    //Left Block
    fill(238, 169, 153);
    rect(leftEdge,topOfKeys, 228,304);

    // Right block
    fill(156, 227, 233);
    rect(leftEdge + 228, topOfKeys, 232, 304);

    stroke(255);
    fill(105);

    // If unfocused
    if(selected == 0){
      for(int row = 0; row < 3; row = row + 1){
        for(int col = 0; col < 10; col = col + 1){
          // Don't draw the blank squares
          if((row * 10 + col)%10 == 9 && row >= 1){
          }
          // If in the right half shift to the right ever so slightly
          else if((row * 10 + col)%10 >= 5){
            fill(105);
            // The +10 here is to create gaps between the keys
            rect(leftEdge + col*45 + 10, topOfKeys + row*101 + 10, 35, 81);
            fill(255);
            text(chars[row * 10 + col], leftEdge + col*45 + 27, topOfKeys + row * 101 + 57);
          }
          else{
            fill(105);
            rect(leftEdge + col*45 + 5, topOfKeys + row*101 + 10, 35, 81);
            fill(255);
            text(chars[row * 10 + col], leftEdge + col*45 + 22, topOfKeys + row * 101 + 57);
          }
        }
      }

      // stroke(255,0,0);
      // strokeWeight(4);

      // noFill();

      // // Outline blocks in thick red lines
      // // Left block
      // rect(leftEdge,topOfKeys, 228,304);

      // stroke(0,0,255);
      // // Right block
      // rect(leftEdge + 228, topOfKeys, 228, 304);
    }

    // If focused on left block
    else if(selected == 1){
      for(int row = 0; row < 3; row = row + 1){
        for(int col = 0; col < 5; col = col + 1){
          fill(105);
          rect(leftEdge + col*91.2, topOfKeys + row*101, 91, 101);
          fill(255);
          text(leftKeys[row * 5 + col], leftEdge + col*91 + 46, topOfKeys + row * 101 + 57);
        }
      }
    }
    
    // If focused on right block
    else if(selected == 2){
      for(int row = 0; row < 3; row = row + 1){
        for(int col = 0; col < 5; col = col + 1){
          fill(105);
          rect(leftEdge + col*91.2, topOfKeys + row*101, 91, 101);
          fill(255);
          text(rightKeys[row * 5 + col], leftEdge + col*91 + 46, topOfKeys + row * 101 + 57);
        }
      }
    }

    stroke(0);
    strokeWeight(1);

    // fill(0, 255, 0); //green button
    // rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    fill(255);
    text("" + currentLetter, width/2 - 100, height/2-sizeOfInputArea/4); //draw current letter
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{

  Vibrator vibrer = (Vibrator)   act.getSystemService(Context.VIBRATOR_SERVICE);
  VibrationEffect effect = VibrationEffect.createOneShot(25,2);
  vibrer.vibrate(effect);

  // If not focused and user clicks the left block focus on it
  if(selected == 0 && didMouseClick(leftEdge, topOfKeys, sizeOfInputArea/2,sizeOfInputArea)){
    selected = 1;
  }
  else if(selected == 0 && didMouseClick(leftEdge + sizeOfInputArea/2, topOfKeys, sizeOfInputArea/2, sizeOfInputArea)){
    selected = 2;
  }
  // If they click on the blank space unfocus
  else if(didMouseClick(leftEdge, topOfKeys - 101, sizeOfInputArea, 101)){
    selected = 0;
  }  
  else if(selected == 1 && didMouseClick(leftEdge, topOfKeys, sizeOfInputArea, 304)){
    // If we're focused on the left block and we clicked inside the block
    int clickedRow = floor((mouseY - topOfKeys)/101);
    int clickedCol = floor((mouseX - leftEdge)/91.2);
    int clickedIndex = clickedRow * 5 + clickedCol;

    // If they hit the space button
    if(clickedIndex == 14){
      currentTyped += " ";
      currentLetter = "_";
    }
    else{
      currentTyped += leftKeys[clickedIndex];
      currentLetter = leftKeys[clickedIndex];
    }
  }
  else if(selected == 2  && didMouseClick(leftEdge, topOfKeys, sizeOfInputArea, 304)){
    // If we're focused on the left block and we clicked inside the block
    int clickedRow = floor((mouseY - topOfKeys)/101);
    int clickedCol = floor((mouseX - leftEdge)/91.2);
    int clickedIndex = clickedRow * 5 + clickedCol;

    // If they hit the space button
    if(clickedIndex == 9 || clickedIndex == 14){
      return;
    }
    if(clickedIndex == 10){
      currentTyped += " ";
      currentLetter = "_";
    }
    else{
      currentTyped += rightKeys[clickedIndex];
      currentLetter = rightKeys[clickedIndex];
    }
  }

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 400, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());

    lastIndex = -1;
    curClicks = 0;
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    System.out.println("Raw WPM: " + wpm); //output

    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars

    System.out.println("Freebie errors: " + freebieErrors); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2 - 100,height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch,0,0);
  popMatrix();
}

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
