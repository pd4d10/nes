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

List<List<T>> matrix<T>(int count, int size) {
  var list = new List(count);
  for (var i = 0; i < count; i++) {
    list[i] = new List(size);
  }
  return list;
}
