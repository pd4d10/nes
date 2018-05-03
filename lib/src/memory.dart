class Memory {
  var internalRAM = new List<int>(0x800);
  var sRAM = new List<int>(0x2000);

  read(int address) {
    address &= 0xff;
    if (address < 0x2000) {
      return internalRAM[address % 0x800];
    }
    if (address < 0x4000) {
      // return
    }
  }

  read16(int address) {
    return;
  }

  write(int address, int value) {
    address &= 0xff;
  }

  write16(int address, int value) {}
}
