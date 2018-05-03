getBit(int data, int n) {
  return data >> n & 1;
}

setBit(int data, int n, int value) {
  n = 2 << n;
  if (value != 0) {
    return data | n;
  } else {
    return data & ~n;
  }
}
