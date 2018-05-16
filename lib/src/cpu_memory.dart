import 'ppu_register.dart';
import 'rom.dart';
import 'apu.dart';

class CpuMemory {
  PpuRegister _reg;
  ROM _rom;
  APU _apu;

  List<int> internal;
  List<int> saveRAM;

  CpuMemory(this._reg, this._rom) {
    reset();
  }

  reset() {
    internal = new List.filled(0x800, 0);
    saveRAM = new List.filled(0x2000, 0);
  }

  read(int addr) {
    int value;
    addr &= 0xffff;

    if (addr < 0x2000) {
      value = internal[addr % 0x800];
    } else if (addr < 0x4000) {
      value = _reg.read(addr);
    } else if (addr < 0x6000) {
      if (addr == 0x4014) {} else {}
      value = _apu.read(addr);
    } else if (addr < 0x8000) {
      value = saveRAM[addr - 0x6000];
    } else {
      var tmp = addr - 0x8000;
      value = _rom.roms[tmp > 0x4000 ? 1 : 0][tmp % 0x4000];
    }
    // print(addr.toRadixString(16));

    // try {
    print('Memory read: ${addr.toRadixString(16)}, ${value.toRadixString(16)}');
    // } catch (err) {
    // print(err);
    // }
    return value;
  }

  read16(int address) {
    return read(address) | read(address + 1) << 8;
  }

  write(int addr, int value) {
    print(
        'Memory write: ${addr.toRadixString(16)}, ${value.toRadixString(16)}');
    addr &= 0xffff;

    if (addr < 0x2000) {
      internal[addr % 0x800] = value;
    } else if (addr < 0x4000) {
      _reg.write(addr, value);
    } else if (addr < 0x6000) {
      if (addr == 0x4014) {} else {}
      _apu.write(addr, value);
    } else if (addr < 0x8000) {
      saveRAM[addr - 0x6000] = value;
    } else {
      print('Should not be herer');
      // var tmp = addr - 0x8000;
      // value = _rom.roms[tmp > 0x4000 ? 1 : 0][tmp % 0x4000];
    }
    // print(addr.toRadixString(16));

    // try {
    // } catch (err) {
    // print(err);
    // }
    // return value;
  }

  write16(int address, int value) {
    write(address, value & 0xff);
    write(address + 1, value >> 8 & 0xff);
  }
}
