part of noisyterrain;

class World {
  ShaderProgram program;
  Buffer triangleVxPosBuf;
  
  // World entities
  Terrain terrain;
  
  World() {
    initGL();
    initEntities();
  }
  
  void initGL() {
    String frag = '''
        precision mediump float;

        void main(void) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        }
      ''';
    String vert = '''
        attribute vec3 aVertexPosition;

        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        }
      ''';
    
    program = new ShaderProgram(vert, frag, ['aVertexPosition'], ['uMVMatrix', 'uPMatrix']);
    
    gl.useProgram(program.program);
    
    // Allocate and build the vertex buffer for our triangle
    triangleVxPosBuf = gl.createBuffer();
    
    gl.bindBuffer(ARRAY_BUFFER, triangleVxPosBuf);
    gl.bufferDataTyped(ARRAY_BUFFER, new Float32List.fromList([
            0.0,  1.0, 0.0,
           -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0
        ]), STATIC_DRAW);
  }
  
  void initEntities() {
    terrain = new Terrain(10, 10);
  }
  
  void drawScene(time) {
    mvPush();
    
    mv.translate(0.0, 0.0, -7.0);
    mv.rotateY((time / 1000) * PI / 2);
    
    // set up triangle buffer
    gl.bindBuffer(ARRAY_BUFFER, triangleVxPosBuf);
    gl.vertexAttribPointer(program.attributes['aVertexPosition'], 3, FLOAT, false, 0, 0);
    
    // set matrix uniforms
    gl.uniformMatrix4fv(program.uniforms['uPMatrix'], false, proj.storage);
    gl.uniformMatrix4fv(program.uniforms['uMVMatrix'], false, mv.storage);
    
    gl.drawArrays(TRIANGLES, 0, 3);
    
    mvPop();
  }
}