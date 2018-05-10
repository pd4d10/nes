import 'utils.dart';

// https://wiki.nesdev.com/w/index.php/PPU_memory_map
class PpuMemory {
  var patternTables = matrix(2, 0x1000);
  var nameTables = matrix(4, 0x3c0);
  var attrTables = matrix(4, 0x40);
  
  List<int> _tables = new List(0x3000);
  List<int> _palette = new List(0x20);
  // PpuMemory() {}

  read(int addr) {
    if (addr < 0x3000) {
      return _tables[addr];
    }
    if (0x3000 <= addr && addr < 0x3f00) {
      return _tables[addr - 0x1000];
    }
    if (0x3f00 <= addr && addr < 0x4000) {
      return _palette[addr % 0x20 + 0x3f00];
    }
    throw 'Address error';
  }

  write(int addr, int value) {
    if (addr < 0x3000) {
      _tables[addr] = value;
    }
    if (0x3000 <= addr && addr < 0x3f00) {
      _tables[addr - 0x1000] = value;
    }
    if (0x3f00 <= addr && addr < 0x4000) {
      _palette[addr % 0x20 + 0x3f00] = value;
    }
    throw 'Address error';
  }
}
