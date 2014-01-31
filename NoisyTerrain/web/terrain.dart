part of noisyterrain;

class Terrain {
  Mesh mesh;
  
  Terrain(int rows, int cols) {
    // To get an n by n grid, we actually need n+1 by n+1 vertices.
    rows++;
    cols++;
    
    List<Vertex> vertices = new List<Vertex>(rows * cols);
    
    // Initialize the mesh array based on the height map
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        vertices[i*cols + j] = new Vertex.zero();
        vertices[i*cols + j].position = 
            new Vector3(i.toDouble(), 0.0, j.toDouble());
      }
    }
    mesh = new Mesh(vertices, rows, cols);
  }
  
  Terrain.fromHeightMap(heightMap, rows, cols) {
    List<Vertex> vertices = new List<Vertex>(rows * cols);
    
    // Initialize the mesh array based on the height map
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        vertices[i*cols + j] = new Vertex.zero();
        vertices[i*cols + j].position = 
            new Vector3(i.toDouble(), heightMap[i*cols + j], j.toDouble());
      }
    }
    mesh = new Mesh(vertices, rows, cols);
  }
  
  void draw(ShaderProgram program) {
    mesh.draw(program);
  }
}