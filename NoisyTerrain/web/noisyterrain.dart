library noisyterrain;

import 'dart:html';
import 'dart:web_gl';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:vector_math/vector_math.dart';

part 'world.dart';
part 'shader_program.dart';
part 'terrain_fragment.dart';
part 'mesh.dart';
part 'vertex.dart';
part 'matrix.dart';
part 'camera.dart';
part 'axis.dart';

final int FLOAT_SIZE = 4;

CanvasElement canvas = querySelector('#main_canvas');
RenderingContext gl;
Map<String, String> shaders;
Map<String, ShaderProgram> shaderManager;
List<bool> curKeys;

World world;
Camera camera;

/**
 * This is where initial program setup will be handled. Our rendering loop
 * will be called from this function to perform the actual rendering of our
 * scene.
 */
void main() {
  mv = new Matrix4.identity();
  
  // Get the rendering context we will be drawing to
  gl = canvas.getContext3d();
  if (gl == null) {
    return;
  }
  gl.clearColor(0.3, 0.3, 0.3, 1.0);
  
  // Initialize keypresses to false
  curKeys = new List<bool>(256);
  for (int i = 0; i < curKeys.length; i++) {
    curKeys[i] = false;
  }
  // Set up input handlers
  window.onKeyDown.listen((KeyboardEvent e) {
    curKeys[e.keyCode] = true;
  });
  window.onKeyUp.listen((KeyboardEvent e) {
    curKeys[e.keyCode] = false;
  });
  
  // Load program assets
  shaders = new Map<String, String>();
  Future assetsLoadedFuture = loadAssets();
 
  // Initialize and start the simulation
  assetsLoadedFuture.then((_) {
    world = new World();
    camera = new Camera();
    
    // Start the render loop
    tick(0);
  });
}

Future loadAssets() {
  // Load our assets
  List<Future<String>> futureList = new List<Future<String>>();
  futureList.add(HttpRequest.getString('shaders/phong.vert'));
  futureList.add(HttpRequest.getString('shaders/phong.frag'));
  futureList.add(HttpRequest.getString('shaders/unlit.vert'));
  futureList.add(HttpRequest.getString('shaders/unlit.frag'));
  
  // Once assets are done loading, add them to our global dictionaries
  Future assetsLoadedFuture = Future.wait(futureList)
      .then((shaderStrings) {
        shaders['phong.vert'] = shaderStrings[0];
        shaders['phong.frag'] = shaderStrings[1];
        shaders['unlit.vert'] = shaderStrings[2];
        shaders['unlit.frag'] = shaderStrings[3];
        initShaders();
      });
  
  return assetsLoadedFuture;

}

void initShaders() {
  shaderManager = new Map<String, ShaderProgram>();
  
  shaderManager['phong'] = new ShaderProgram(
      shaders['phong.vert'], shaders['phong.frag'], 
      ['aPosition', 'aNormal'], ['uMVP']);
  
  shaderManager['unlit'] = new ShaderProgram(
      shaders['unlit.vert'], shaders['unlit.frag'],
      ['aPosition', 'aColor'], ['uMVP']);
}

var lastTime = 0.0;
var frames = 0;
var frameTime = 0.0;
var fpsCounter = querySelector('#fps_counter');
void tick(time) {
  window.requestAnimationFrame(tick);
  
  // Get elapsed time
  var elapsedTime = (time - lastTime);
  lastTime = time;
  
  // Count FPS
  frames++;
  frameTime += elapsedTime;
  if (frameTime >= 1000) {
    fpsCounter.innerHtml = 'FPS: $frames';
    frameTime = 0.0;
    frames = 0;
  }

  // Set up GL stuff
  proj = makePerspectiveMatrix(PI / 4, canvas.width / canvas.height, 1.0, 1000.0);
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.enable(DEPTH_TEST);
  gl.disable(BLEND);
  
  // Handle keyboard input
  handleKeys(elapsedTime);
 
  mvPush();
  // Handle camera position
  mv.translate(0.0, 0.0, -15.0);
  mv.rotateX(camera.rotation.x);
  mv.rotateY(camera.rotation.y);
  
  // Draw world
  world.drawWorld(time);
  mvPop();
}

void handleKeys(time) {
  time /= 1000.0; // convert time to seconds
  if (curKeys[KeyCode.UP]) {
    camera.rotation.x += time * PI / 2;
  }
  if (curKeys[KeyCode.DOWN]) {
    camera.rotation.x -= time * PI / 2;
  }
  if (curKeys[KeyCode.LEFT]) {
    camera.rotation.y -= time * PI / 2;
  }
  if (curKeys[KeyCode.RIGHT]) {
    camera.rotation.y += time * PI / 2;
  }
}
