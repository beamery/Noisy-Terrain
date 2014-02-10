part of noisyterrain;

List<bool> curKeys;
List<bool> pressedKeys;

void initKeyboard() {
  // Initialize keypresses to false.
  curKeys = new List<bool>(256);
  pressedKeys = new List<bool>(256);
  for (int i = 0; i < curKeys.length; i++) {
    curKeys[i] = false;
    pressedKeys[i] = false;
  }
  
  // Set up input handlers
  window.onKeyDown.listen((KeyboardEvent e) {
    curKeys[e.keyCode] = true;
  });
  window.onKeyUp.listen((KeyboardEvent e) {
    curKeys[e.keyCode] = false;
  });
  window.onKeyPress.listen((KeyboardEvent e) {
    KeyEvent ke = new KeyEvent.wrap(e);
    world.player.pressKey(ke);
  });
}

bool keyDown(keyCode) {
  return curKeys[keyCode];
}