import 'utils.dart';
import 'ppu_register.dart';
import 'ppu_oam.dart';
import 'ppu_memory.dart';
import 'tile.dart';

// https://wiki.nesdev.com/w/index.php/PPU_registers
class PPU {
  static final tileCountX = 32;
  static final tileCountY = 30;

  PpuRegister _reg;
  PpuMemory _mem;
  PpuOam _oam = new PpuOam();
  var _data = matrix<Tile>(tileCountX, tileCountY);
  int _scanline;

  PPU(this._reg) {
    for (var j = 0; j < tileCountY; j++) {
      for (var i = 0; i < tileCountX; i++) {
        _data[i][j] = new Tile(i, j, _mem, _reg);
      }
    }
  }

  /// Base nametable address
  ///
  /// (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
  readNameTable(int addr) {
    return _mem.read(0x2000 | (_reg.ppuctrl & 3) << 10 | addr);
  }

  /// Sprite pattern table address for 8x8 sprites
  ///
  /// (0: $0000; 1: $1000; ignored in 8x16 mode)
  readSpritePatternTable(int addr) {
    return _mem.read(getBit(_reg.ppuctrl, 3) << 12 | addr);
  }

  readBackgroundPatternTable(int addr) {
    return _mem.read(getBit(_reg.ppuctrl, 4) << 12 | addr);
  }

  render() {
    // _reg.vblankStarted;
    for (var j = 0; j < tileCountY; j++) {
      for (var i = 0; i < tileCountX; i++) {
        _data[i][j].renderBackground();
      }
    }
  }

  renderSprite() {
    for (var i = 0; i < PpuOam.spriteCount; i++) {
      var info = _oam.getSpriteInfo(i);

      var patternAddr = readSpritePatternTable(info.tileIndex);
      var low = _mem.read(patternAddr);
      var high = _mem.read(patternAddr | 8);
    }
  }
}
