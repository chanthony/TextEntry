import java.util.Arrays;
import java.util.Collections;

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

// The character groupings for the cell phone keys
String[] chars = {"a b c", "d e f", "g h i", "j k l" , "m n o", "p q r", "s t u", "v w x","y z", "__", "del", "ent"};

// The current number of consecutive clicks in the same square
int curClicks = 0;

// The last index clicked
int lastIndex = -1;

//Variables for my silly implementation. You can delete this:
String currentLetter = "a";

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(PORTRAIT); //can also be PORTRAIT -- sets orientation on android device
  size(1300, 2300); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24
  noStroke(); //my code doesn't use any strokes.
  
  leftEdge = width/2-sizeOfInputArea/2 - 100;
  topOfKeys = height/2 - sizeOfInputArea/2 + sizeOfInputArea/3;
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background

  drawWatch();
  fill(255);
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
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 
    
    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 400, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 450); //draw next label

    //my draw code
    // Black outlines
    textAlign(CENTER);

    stroke(0);
    fill(255);

    //draw first square
    // rect(leftEdge, topOfKeys, 114, 101);
    // fill(0);
    // text("a b c", leftEdge + 57, topOfKeys + 57);

    for(int row = 0; row < 3; row = row + 1){
      for(int col = 0; col < 4; col = col + 1){
        fill(255);
        rect(leftEdge + col * 114, topOfKeys + row * 101, 114, 101);
        fill(0);
        text(chars[row * 4 + col], leftEdge + col * 114 + 57, topOfKeys + row * 101 + 57);
      }
    }


    // fill(0, 255, 0); //green button
    // rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    fill(0);
    text("" + currentLetter, width/2 - 100, height/2-sizeOfInputArea/4); //draw current letter
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


void mousePressed()
{

  if(didMouseClick(leftEdge, topOfKeys, sizeOfInputArea, sizeOfInputArea)){
    int clickedRow = floor((mouseY - topOfKeys)/101);
    int clickedCol = floor((mouseX - leftEdge)/114);

    int clickedIndex = clickedRow * 4 + clickedCol;

    // If we repeated a click
    if (clickedIndex == lastIndex){
      // If it's one of the letters
      if(clickedIndex < 8){
        curClicks = (curClicks + 1)%3;
      }
      else if (clickedIndex < 9){
        curClicks = (curClicks + 1)%2;
      }
    }
    // If this is a new key
    else {
      // Track the new key
      lastIndex = clickedIndex;
      // Reset count
      curClicks = 0;
    }


    if(lastIndex < 0){
    }
    // If we currently have selected a letter
    else if(lastIndex < 9){
      String[] keyChars = split(chars[lastIndex], " ");

      currentLetter = keyChars[curClicks];
    }
    // Apostrophe
    else if (lastIndex == 9){
      currentLetter = " ";
    }
    // Space character
    else if (lastIndex == 10 && currentTyped != ""){
      currentTyped = currentTyped.substring(0, currentTyped.length() - 1);
    }
    // Backspace
    else if (lastIndex == 11){
      currentTyped+=currentLetter;
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
