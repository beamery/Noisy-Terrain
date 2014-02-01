part of noisyterrain;

// Initialize modelview and projection matrices and operations
Matrix4 mv;
Matrix4 proj;
List<Matrix4> mvStack = new List<Matrix4>();

void mvPush() {
  mvStack.add(new Matrix4.copy(mv));
}
void mvPop() {
  mv = mvStack.removeLast();
}