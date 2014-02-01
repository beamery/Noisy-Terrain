library noisyterrain;

import 'dart:html';
import 'dart:web_gl';
import 'dart:math';
import 'dart:typed_data';
import 'dart:async';
import 'package:vector_math/vector_math.dart';

part 'world.dart';
part 'shader_program.dart';
part 'terrain.dart';
part 'mesh.dart';
part 'vertex.dart';
part 'matrix.dart';

CanvasElement canvas = querySelector('#main_canvas');
RenderingContext gl;
Map<String, String> shaders;
World world;

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
  
  // Load program assets
  shaders = new Map<String, String>();
  Future assetsLoadedFuture = loadAssets();
 
  // Initialize and start the simulation
  assetsLoadedFuture.then((_) {
    world = new World();
    
    // Start the render loop
    tick(0);
  });
}

Future loadAssets() {
  // Load our assets
  Future<String> vertFuture = HttpRequest.getString('phong.vert');
  Future<String> fragFuture = HttpRequest.getString('phong.frag');
  
  // Once assets are done loading, add them to our global dictionaries
  Future assetsLoadedFuture = Future.wait([vertFuture, fragFuture])
      .then((shaderStrings) {
        shaders['phong.vert'] = shaderStrings[0];
        shaders['phong.frag'] = shaderStrings[1];
      });
  
  return assetsLoadedFuture;

}

void tick(time) {
  window.requestAnimationFrame(tick);
  
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.clear(COLOR_BUFFER_BIT | DEPTH_BUFFER_BIT);
  gl.enable(DEPTH_TEST);
  gl.disable(BLEND);
 
  world.drawScene(time);
}
