library noisyterrain;

import 'dart:html';
import 'dart:web_gl';
import 'dart:math';
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart';

part 'world.dart';
part 'shader_program.dart';
part 'terrain.dart';
part 'mesh.dart';
part 'vertex.dart';

CanvasElement canvas = querySelector('#main_canvas');
RenderingContext gl;
World world;

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

/**
 * This is where initial program setup will be handled. Our rendering loop
 * will be called from this function to perform the actual rendering of our
 * scene.
 */
void main() {
  mv = new Matrix4.identity();
  proj = makePerspectiveMatrix(PI / 4, canvas.width / canvas.height, 1.0, 1000.0);
  
  // Get the rendering context we will be drawing to
  gl = canvas.getContext3d();
  if (gl == null) {
    return;
  }
  gl.clearColor(0.3, 0.3, 0.3, 1.0);
  
  world = new World();
  // Start the rendering loop
  tick(0);
}

void tick(time) {
  window.requestAnimationFrame(tick);
  
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.enable(DEPTH_TEST);
  gl.disable(BLEND);
 
  world.drawScene(time);
}
