library noisyterrain;

import 'dart:html';
import 'dart:web_gl';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:vector_math/vector_math.dart';
import 'util.dart';

part 'tests.dart';
part 'world.dart';
part 'shader_program.dart';
part 'terrain_fragment.dart';
part 'mesh.dart';
part 'vertex.dart';
part 'matrix.dart';
part 'axis.dart';
part 'material.dart';
part 'light_source.dart';
part 'player.dart';
part 'keyboard.dart';

final int FLOAT_SIZE = 4;

CanvasElement canvas = querySelector('#main_canvas');
RenderingContext gl;
Map<String, String> shaders;
Map<String, ShaderProgram> shaderManager;
bool renderWireframe = false;

World world;

/**
 * This is where initial program setup will be handled. Our rendering loop
 * will be called from this function to perform the actual rendering of our
 * scene.
 */
void main() {
  
  // If a smaller canvas is desired (i.e, for screenshotting), just comment
  // out initCanvas()
  initCanvas();
  
  //_testNoise();
 
  mv = new Matrix4.identity();
  
  // Get the rendering context we will be drawing to
  gl = canvas.getContext3d();
  if (gl == null) {
    return;
  }
  gl.clearColor(0.5, 0.6, 1.0, 1.0);
  
  // Initialize keyboard handler
  initKeyboard();
  
  // Load program assets
  shaders = new Map<String, String>();
  Future assetsLoadedFuture = loadAssets();
 
  // Initialize and start the simulation
  assetsLoadedFuture.then((_) {
    world = new World();
    world.init();
    
    // Start the render loop
    tick(0);
  });
}

void initCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  window.onResize.listen((Event e) {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
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
      })
      .catchError((Error e) {
        print('Error: could not load shaders');
      });
  
  return assetsLoadedFuture;

}

void initShaders() {
  shaderManager = new Map<String, ShaderProgram>();
  
  shaderManager['phong'] = new ShaderProgram(
      shaders['phong.vert'], shaders['phong.frag'], 
      ['aPosition', 'aNormal'], 
      ['uMVP', 'uMV', 'uNormalMat', 'uLightPos', 'uKa',
       'uLa', 'uKd', 'uLd', 'uKs', 'uLs', 'uShine']);
  
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
  setPerspectiveMatrix(proj, PI / 4, canvas.width / canvas.height, 1.0, 10000.0);
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.enable(DEPTH_TEST);
  gl.disable(BLEND);
 
  mvPush();
  /*// Handle camera rotation
  mv.rotateX(camera.rotation.x);
  mv.rotateY(camera.rotation.y);
  
  // Handle camera position
  mv.translate(camera.translation);
  */
  // Draw world
  world.update(elapsedTime);
  world.draw(time);
  mvPop();
}

