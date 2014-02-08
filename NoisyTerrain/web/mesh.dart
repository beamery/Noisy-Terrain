part of noisyterrain;

class Mesh {
  Float32List vertexData;
  Buffer glVertexBuffer, glIndexBuffer;
  List<int> indices;
  int rows, cols;
  
  // Material properties
  Material material;
  
  Mesh(Grid2D<Vertex> vertices, Material material) {
    
    this.indices = [];
    this.rows = vertices.rows;
    this.cols = vertices.cols;
    this.material = material;
    
    createIndexArray(vertices);
    getNormals(vertices);
    flattenVertices(vertices);
    glSetup();
  }
  
  /**
   * Create an index array which specifies the drawing order of our vertices.
   * We will draw all of our triangles clockwise for consistency.
   */
  void createIndexArray(Grid2D<Vertex> vertices) {
    for (int i = 0; i < vertices.rows - 1; i++) {
      for (int j = 0; j < vertices.cols - 1; j++) {     
        // Top-left triangle
        indices.add(vertices.flatIndex(i, j));
        indices.add(vertices.flatIndex(i, j+1));
        indices.add(vertices.flatIndex(i+1, j));
        
        // bottom-right triangle
        indices.add(vertices.flatIndex(i+1, j));
        indices.add(vertices.flatIndex(i, j+1));
        indices.add(vertices.flatIndex(i+1, j+1));
      }
    }
  }
  
  /**
   * Get the normals for each vertex and store them in the vertices.
   */
  void getNormals(Grid2D<Vertex> vertices) {
    int rows = vertices.rows;
    int cols = vertices.cols;
    
    // Initialize the normal lists as a 2D grid of vertex normal lists.
    Grid2D<List<Vector3>> perVertexNormals = new Grid2D<List<Vector3>>(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        perVertexNormals[i][j] = new List<Vector3>();
      }
    }
    
    // Get a list of normals for each vertex, corresponding to each triangle
    // which contains that vertex.
    for (int i = 0; i < rows - 1; i++) {
      for (int j = 0; j < cols - 1; j++) {
        // Top-left triangle
        Vector3 normalizedNorm = getNormFromTriangle(
            vertices[i][j].position,
            vertices[i][j+1].position,
            vertices[i+1][j].position);
        if ((normalizedNorm.length - 1).abs() > 0.0001) {
          print('ERROR: Length of normal does not equal 1.0');
        }
        perVertexNormals[i][j].add(normalizedNorm.clone());
        perVertexNormals[i][j+1].add(normalizedNorm.clone());
        perVertexNormals[i+1][j].add(normalizedNorm.clone());
        
        // Bottom-right triangle
        normalizedNorm = getNormFromTriangle(
            vertices[i+1][j].position,
            vertices[i][j+1].position,
            vertices[i+1][j+1].position);
        if ((normalizedNorm.length - 1).abs() > 0.0001) {
          print('ERROR: Length of normal does not equal 1.0');
        }
        perVertexNormals[i+1][j].add(normalizedNorm.clone());
        perVertexNormals[i][j+1].add(normalizedNorm.clone());
        perVertexNormals[i+1][j+1].add(normalizedNorm.clone());
        
      }
      
      // Average the calculated normals to get final normals. Store these
      // final numbers in the normal field of the corresponding vertex.
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          Vector3 avgNorm = getAverageNorm(perVertexNormals[i][j]);
          vertices[i][j].normal = avgNorm;
        }
      }
    }
  }
  
  Vector3 getAverageNorm(List<Vector3> norms) {
    Vector3 total = new Vector3.zero();
    for (var n in norms) {
      total += n;
    }
    return total.normalized();
  }
  
  /**
   * Calculate the normal direction, given 3 vertices making up a triangle
   */
  Vector3 getNormFromTriangle(Vector3 v1, Vector3 v2, Vector3 v3) {
    Vector3 v12 = v2 - v1;
    Vector3 v13 = v3 - v1;
    Vector3 norm = v12.cross(v13);
    return norm.normalized();
  }
  
  /**
   * Flatten the vertex array into a 1D array of Float32 objects. This makes
   * our meshes easier for the rendering system to handle.
   */
  void flattenVertices(Grid2D<Vertex> vertices) {
    List<Vertex> flatVerts = vertices.flatten();
    vertexData = new Float32List(flatVerts.length * Vertex.size);
    
    for (int i = 0; i < flatVerts.length; i++) {   
      Float32List vxData = flatVerts[i].data;
      for (int j = 0; j < vxData.length; j++) {
        vertexData[i * Vertex.size + j] = vxData[j];
      }
    }
  }
  
  /**
   * Set up WebGL with a buffer for this mesh
   */
  void glSetup() {
    glVertexBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, vertexData, STATIC_DRAW);
    
    glIndexBuffer = gl.createBuffer();
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, glIndexBuffer);
    gl.bufferDataTyped(ELEMENT_ARRAY_BUFFER, new Int16List.fromList(indices), STATIC_DRAW);
  }
  
  void draw(ShaderProgram program) {
    mvPush();
    gl.useProgram(program.program);
    // Set up array buffer.
    gl.bindBuffer(ARRAY_BUFFER, glVertexBuffer);
    gl.vertexAttribPointer(
        program.attributes['aPosition'], 3, FLOAT, 
        false, Vertex.size * FLOAT_SIZE, 0);
    gl.vertexAttribPointer(
        program.attributes['aNormal'], 3, FLOAT, 
        false, Vertex.size * FLOAT_SIZE, 3 * FLOAT_SIZE);
    
    // Set up index buffer.
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, glIndexBuffer);
    
    // Set uniforms
    mvp = proj * mv;
    Matrix4 normalMat = new Matrix4.identity();
    normalMat.copyInverse(mv);
    normalMat.transpose();
    gl.uniformMatrix4fv(program.uniforms['uNormalMat'], false, normalMat.storage);
    gl.uniformMatrix4fv(program.uniforms['uMV'], false, mv.storage);
    gl.uniformMatrix4fv(program.uniforms['uMVP'], false, mvp.storage);
    gl.uniform3fv(program.uniforms['uKa'], material.ambient.storage);
    gl.uniform3fv(program.uniforms['uKd'], material.diffuse.storage);
    gl.uniform3fv(program.uniforms['uKs'], material.specular.storage);
    gl.uniform1f(program.uniforms['uShine'], material.shine);
    
    // Draw lines for debugging purposes only
    //gl.drawElements(LINES, indices.length, UNSIGNED_SHORT, 0);
    gl.drawElements(TRIANGLES, indices.length, UNSIGNED_SHORT, 0);
    
    mvPop();
  }

}