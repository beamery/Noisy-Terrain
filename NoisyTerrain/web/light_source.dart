part of noisyterrain;

class LightSource {
  Material properties;
  Vector4 position;
  
  LightSource(properties, position) {
    this.properties = properties;
    this.position = position;
  }
}