int getBit(int data, int n) {
  return data >> n & 1;
}

bool getBitBool(int data, int n) {
  return getBit(data, n) == 1;
}

setBit(int data, int n, int value) {
  n = 2 << n;
  if (value != 0) {
    return data | n;
  } else {
    return data & ~n;
  }
}

setBitBool(int data, int n, bool b) {
  setBit(data, n, b ? 1 : 0);
}

List<List<T>> matrix<T>(int x, int y) {
  var list = new List(x);
  for (var i = 0; i < x; i++) {
    list[i] = new List(y);
  }
  return list;
}
