import 'ppu.dart';

class Memory {
  PPU ppu;
  // Memory(this.ppu);

  List<int> internalRAM = new List(0x800);
  List<int> saveRAM = new List(0x2000);

  read(int address) {
    address &= 0xff;
    if (address < 0x2000) {
      return internalRAM[address % 0x800];
    }
    if (address < 0x4000) {
      return ppu.readRegisters(address);
    }

    // IO Registers
    if (address < 0x6000) {}

    if (address < 0x8000) {
      return saveRAM[address - 0x6000];
    }

    throw 'Address error';
  }

  read16(int address) {
    return read(address) | read(address + 1) >> 8;
  }

  write(int address, int value) {
    address &= 0xff;
  }

  write16(int address, int value) {
    write(address, value & 0xff);
    write(address + 1, value >> 8 & 0xff);
  }
}
