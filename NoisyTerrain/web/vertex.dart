part of noisyterrain;

class Vertex {
  
  // The number of Float32 objects in a vertex
  static final int size = 9;
  
  Vector3 position;
  Vector3 color;
  Vector3 normal;
  
  Vertex(pos, color, norm) {
    position = pos;
    color = color;
    normal = norm;
  }
  
  Vertex.zero() {
    position = new Vector3.zero();
    color = new Vector3.zero();
    normal = new Vector3.zero();
  }
  
  Float32List get data {
    Float32List floatList = new Float32List(9);
    
    for (int i = 0; i < 3; i++) {
      floatList[i] = position.storage[i];
      floatList[i+3] = color.storage[i];
      floatList[i+6] = normal.storage[i];
    }
    
    return floatList;
  }
}