// import 'ppu_register.dart';
import 'utils.dart';
import 'ppu.dart';
// import 'ppu_oam.dart';
// import 'ppu_memory.dart';

class PpuTile {
  static final _tileSize = 8;
  // var _data = matrix<int>(_tileSize, _tileSize);

  final int _tileX;
  final int _tileY;
  // PpuRegister _reg;
  // PpuMemory _mem;
  PPU _ppu;

  PpuTile(this._tileX, this._tileY, this._ppu) {}

  // getPatternTable(int index, int tileX, int tileY, int x, int y) {
  //   return _mem.read(index << 12 | tileX << 7 | 1);
  // }

  // https://wiki.nesdev.com/w/index.php/PPU_pattern_tables
  renderBackground() {
    var tileIndex = _tileY << 4 | _tileX;

    for (var y = 0; y < _tileSize; y++) {
      var offset = _ppu.reg.bgPatternTableAddr | tileIndex << 4 | y;
      var low = _ppu.mem.read(offset);
      var high = _ppu.mem.read(offset | 8);

      var attrAddr = 0x3c0 | _tileY >> 2 << 3 | _tileX >> 2;
      var attr = _ppu.mem.read(attrAddr);
      if (getBitBool(_tileX, 1)) attr >>= 2;
      if (getBitBool(_tileY, 1)) attr >>= 4;
      attr &= 3;

      for (var x = 0; x < _tileSize; x++) {
        _ppu.pixels[_tileY << 3 | y][_tileX << 3 | x] =
            attr << 2 | getBit(high, x) << 1 | getBit(low, x);
      }
    }
  }
}
