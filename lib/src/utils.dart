int getBit(int data, int n) {
  return data >> n & 1;
}

bool getBitBool(int data, int n) {
  return getBit(data, n) == 1;
}

int setBit(int data, int n, int value) {
  n = 1 << n;
  if (value != 0) {
    return data | n;
  } else {
    return data & ~n;
  }
}

int setBitBool(int data, int n, bool b) {
  return setBit(data, n, b ? 1 : 0);
}

class LinearMemory {
  List<int> _data;
  LinearMemory(int length) {
    _data = new List.filled(length, 0);
  }
  read(int addr) {
    return _data[addr];
  }

  write(int addr, int value) {
    _data[addr] = value;
  }
}

read(List<int> list, int index) {
  return list[index];
}

List<List<int>> matrix(int x, int y) {
  return new List.generate(x, (i) => new List.filled(y, 0));
}
