part of noisyterrain;

class Camera {
  
  static final double MOVE_SPEED = 200.0;
  static final double TURN_SPEED = PI / 2;
  
  Vector3 rotation;
  Vector3 translation;
  Vector3 get position => -translation;
  
  Camera() {
    rotation = new Vector3.zero();
    translation = new Vector3.zero();
    translation.y = -5.0;
  }
  
  void turnRight(double amount) {
    camera.rotation.y -= amount;
  }
  void turnLeft(double amount) {
    camera.rotation.y += amount;
  }
  void turnUp(double amount) {
    camera.rotation.x -= amount;
  }
  void turnDown(double amount) {
    camera.rotation.x += amount;
  }
  
  void moveForward(double distance) {
    Vector3 forwardDirection = getForwardDirection();
    translation += forwardDirection * distance;
  } 
  void moveBackward(double distance) {
    Vector3 forwardDirection = getForwardDirection();
    translation -= forwardDirection * distance;
  }
  void moveLeft(double distance) {
    Vector3 rightDirection = getRightDirection();
    translation += rightDirection * distance;
  }
  void moveRight(double distance) {
    Vector3 rightDirection = getRightDirection();
    translation -= rightDirection * distance;
  }
  void moveUp(double distance) {
    camera.translation.y -= distance;
  }
  void moveDown(double distance) {
    camera.translation.y += distance;
  }
  
  /**
   * Get the world-space direction corresponding to the forward direction
   * in camera space. If pitch is taken into account, when calculating
   * movement direction, then the camera can fly. Otherwise, the camera
   * will remain on the ground.
   */
  Vector3 getForwardDirection() {
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
  Vector3 getRightDirection() {
    Vector3 direction = new Vector3.zero();
    direction.x = cos(rotation.y);
    direction.z = -sin(rotation.y);
    return direction.normalized();
  }
}