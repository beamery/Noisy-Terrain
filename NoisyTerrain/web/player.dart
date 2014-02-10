part of noisyterrain;

// TODO: Consider changing all the translation usage to position
// in order to make movement easier to understand.
class Player {
  static final double WALKING_SPEED = 5.0;
  static final double RUNNING_SPEED = 10.0;
  static final double FLYING_SPEED = 20.0;
  static final double DEFAULT_TURN_SPEED = PI / 2;
  static final double PLAYER_HEIGHT = 2.0;
  
  double moveSpeed = RUNNING_SPEED;
  double turnSpeed = DEFAULT_TURN_SPEED;
  Vector3 translation;
  Vector3 rotation;
  Vector3 get position => -translation;
  void set position(value) { translation = -value; }
  bool canFly;
  
  Player() {
    // Initialize player in the middle of the world.
    double initX = world.terrain.sizeX / 2.0;
    double initZ = world.terrain.sizeZ / 2.0;
    position = new Vector3(initX, 0.0, initZ);
    
    rotation = new Vector3.zero();
    canFly = false;
    
    // Move forward a tiny amount to calculate initial height.
    moveForward(0.0001);
  }
  
  void update(elapsedTime) {
    handleInput(elapsedTime);
  }
  
  void handleInput(elapsedTime) {

    elapsedTime /= 1000.0; // convert time to seconds
    if (keyDown(KeyCode.UP)) {
      turnUp(elapsedTime * turnSpeed);
    }
    if (keyDown(KeyCode.DOWN)) {
      turnDown(elapsedTime * turnSpeed);
    }
    if (keyDown(KeyCode.LEFT)) {
      turnLeft(elapsedTime * turnSpeed);
    }
    if (keyDown(KeyCode.RIGHT)) {
      turnRight(elapsedTime * turnSpeed);
    }
    if (keyDown(KeyCode.W)) {
      moveForward(elapsedTime * moveSpeed);
    }
    if (keyDown(KeyCode.A)) {
      moveLeft(elapsedTime * moveSpeed);
    }
    if (keyDown(KeyCode.S)) {
      moveBackward(elapsedTime * moveSpeed);
    }
    if (keyDown(KeyCode.D)) {
      moveRight(elapsedTime * moveSpeed);
    }
    if (keyDown(KeyCode.E) && canFly) {
      moveDown(elapsedTime * moveSpeed);
    }
    if (keyDown(KeyCode.Q) && canFly) {
      moveUp(elapsedTime * moveSpeed);
    }
  }
  
  /**
   * Using numbers instead of key codes because the keycodes appear
   * to be broken at the moment.
   */
  void pressKey(KeyEvent e) {
    if (e.keyCode == 45) { // -
      renderWireframe = !renderWireframe;
    }
    else if (e.keyCode == 102) { // F
      canFly = !canFly;
    }
  }
  
  void turnRight(double amount) {
    rotation.y -= amount;
  }
  void turnLeft(double amount) {
    rotation.y += amount;
  }
  void turnUp(double amount) {
    rotation.x -= amount;
  }
  void turnDown(double amount) {
    rotation.x += amount;
  }
  
  /**
   * Move the player to the specified coordinate on the map, making sure 
   * he is always on the ground if he cannot fly.
   * 
   * TODO: Maybe use position here instead of translation to get rid of
   * the large number of negations.
   */
  void moveTo(Vector3 newTrans) {
    // Only move if our new position does not go outside of the world bounds
    if (world.isInWorldBounds(-newTrans) && !canFly) {
      newTrans.y = -(world.getHeightAt(position.x, position.z) + PLAYER_HEIGHT);
      translation = newTrans;
    }
    else if (canFly) {
      translation = newTrans;
    }
    else {
      // Don't move
    }
  }
  
  void moveForward(double distance) {
    Vector3 forwardDirection = _getForwardDirection();
    Vector3 newTrans = translation + forwardDirection * distance;
    moveTo(newTrans);
 
  } 
  void moveBackward(double distance) {
    Vector3 forwardDirection = _getForwardDirection();
    Vector3 newTrans = translation - forwardDirection * distance;
    moveTo(newTrans);
  }
  void moveLeft(double distance) {
    Vector3 rightDirection = _getRightDirection();
    Vector3 newTrans = translation + rightDirection * distance;
    moveTo(newTrans);
  }
  void moveRight(double distance) {
    Vector3 rightDirection = _getRightDirection();
    Vector3 newTrans = translation - rightDirection * distance;
    moveTo(newTrans);
  }
  
  void moveUp(double distance) {
    if (canFly) {
      translation.y -= distance;
    }

  }
  void moveDown(double distance) {
    if (canFly) {
      translation.y += distance;    translation.y += distance;
    }
  }
  
  /**
   * Get the world-space direction corresponding to the forward direction
   * in camera space. If pitch is taken into account, when calculating
   * movement direction, then the camera can fly. Otherwise, the camera
   * will remain on the ground.
   */
  Vector3 _getForwardDirection() {
    Vector3 direction = new Vector3.zero();
    direction.x = sin(rotation.y);
    //direction.y = sin(rotation.x);
    direction.z = cos(rotation.y);
    return direction.normalized();
  }
  
  /**
   * Get the world-space direction corresponding to the right direction in 
   * camera space. We want to ignore the pitch of the camera for this 
   * calculation.
   */
  Vector3 _getRightDirection() {
    Vector3 direction = new Vector3.zero();
    direction.x = cos(rotation.y);
    direction.z = -sin(rotation.y);
    return direction.normalized();
  }
}