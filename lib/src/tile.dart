import 'ppu_register.dart';
import 'utils.dart';
import 'ppu.dart';
// import 'ppu_oam.dart';
import 'ppu_memory.dart';

class Tile {
  var _data = matrix<int>(8, 8);
  final int _tileX;
  final int _tileY;
  PpuRegister _reg;
  PpuMemory _mem;
  // PPU _ppu;

  Tile(this._tileX, this._tileY, this._mem, this._reg) {}

  // getPatternTable(int index, int tileX, int tileY, int x, int y) {
  //   return _mem.read(index << 12 | tileX << 7 | 1);
  // }

  // https://wiki.nesdev.com/w/index.php/PPU_pattern_tables
  renderBackground() {
    var tileIndex = _tileY << 4 | _tileX;

    for (var y = 0; y < 8; y++) {
      var offset = _reg.bgPatternTableAddr | tileIndex << 4 | y;
      var low = _mem.read(offset);
      var high = _mem.read(offset | 8);

      var attrAddr = 0x3c0 | _tileY >> 2 << 3 | _tileX >> 2;
      var attr = _mem.read(attrAddr);
      if (getBitBool(_tileX, 1)) attr >>= 2;
      if (getBitBool(_tileY, 1)) attr >>= 4;
      attr &= 3;

      for (var x = 0; x < 8; x++) {
        _data[y][x] = attr << 2 | getBit(high, x) << 1 | getBit(low, x);
      }
    }
  }
}
