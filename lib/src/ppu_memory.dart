import 'utils.dart';

class _AccessHelper {
  List<int> list;
  int index;
  _AccessHelper(this.list, this.index);

  read() {
    return this.list[this.index];
  }

  write(int value) {
    this.list[this.index] = value;
  }
}

// https://wiki.nesdev.com/w/index.php/PPU_memory_map
class PpuMemory {
  var patternTables = matrix(2, 0x1000);
  var nameTables = matrix(4, 0x3c0);
  var attrTables = matrix(4, 0x40);
  var palette = new List.filled(0x20, 0);

  _AccessHelper getDataAndIndex(int addr) {
    if (addr < 0x2000) {
      return new _AccessHelper(patternTables[addr >> 12 & 1], addr % 0x1000);
    } else if (addr < 0x3f00) {
      var count = addr >> 10 & 0x11;
      var index = addr % 0x400;
      if (index < 0x3c0) {
        return new _AccessHelper(nameTables[count], index);
      } else {
        return new _AccessHelper(attrTables[count], index);
      }
    } else if (addr < 0x4000) {
      return new _AccessHelper(palette, addr % 0x20);
    } else {
      throw addr;
    }
  }

  read(int addr) {
    return getDataAndIndex(addr).read();
  }

  write(int addr, int value) {
    // print('PPU memory write: $addr, $value');
    getDataAndIndex(addr).write(value);
  }
}
