part of util;

class Grid2D<E> {
  List<List<E>> _items;
  int get rows => _items.length;
  int get cols => _items[0].length;
  
  
  Grid2D(rows, cols, [initList=null]) {
    // Make sure the dimensions of a passed-in list match the
    // rows and cols passed in
    if (initList != null && initList.length != rows * cols) {
      throw new Exception('List dimensions do not match');
    }
    
    _items = new List<List<E>>(rows);
    for (int i = 0; i < rows; i++) {
      _items[i] = new List<E>(cols);
    }
    
    if (initList != null) {
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          _items[i][j] = initList[i*cols + j];
        }
      }
    }
  }
  
  List<E> flatten() {
    List<E> flatList = new List<E>(rows * cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        flatList[i*cols + j] = _items[i][j];
      }
    }
    return flatList;
  }
  
  int flatIndex(int i, int j) {
    if (i < 0 || i >= rows || j < 0 || j >= cols) {
      throw new Exception('List index out of bounds');
    }
    return i*cols + j;
  }
  
  operator [](int index) => _items[index];
  operator []=(int index, List<E> list) => _items[index] = list;
}