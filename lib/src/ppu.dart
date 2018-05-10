import 'utils.dart';
import 'ppu_register.dart';
import 'ppu_oam.dart';
import 'ppu_memory.dart';
import 'ppu_tile.dart';

// https://wiki.nesdev.com/w/index.php/PPU_registers
class PPU {
  static final _tileSize = 8;
  static final tileCountX = 32;
  static final tileCountY = 30;
  static final pixelCountX = 256;
  static final pixelCountY = 240;

  PpuRegister reg = new PpuRegister();
  PpuMemory mem;
  PpuOam _oam = new PpuOam();
  var _tiles = matrix<PpuTile>(tileCountX, tileCountY);
  var pixels = matrix<int>(pixelCountX, pixelCountY);
  int _scanline = 0;

  get _tileY => _scanline >> 3;

  PPU() {
    for (var j = 0; j < tileCountY; j++) {
      for (var i = 0; i < tileCountX; i++) {
        _tiles[i][j] = new PpuTile(i, j, this);
      }
    }
  }

  /// Base nametable address
  ///
  /// (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
  readNameTable(int addr) {
    return mem.read(0x2000 | (reg.ppuctrl & 3) << 10 | addr);
  }

  /// Sprite pattern table address for 8x8 sprites
  ///
  /// (0: $0000; 1: $1000; ignored in 8x16 mode)
  readSpritePatternTable(int addr) {
    return mem.read(getBit(reg.ppuctrl, 3) << 12 | addr);
  }

  readBackgroundPatternTable(int addr) {
    return mem.read(getBit(reg.ppuctrl, 4) << 12 | addr);
  }

  renderBackground() {}

  renderLine() {
    for (var _tileX = 0; _tileX < tileCountX; _tileX++) {
      var tileIndex = _tileY << 4 | _tileX;

      var offset = reg.bgPatternTableAddr | tileIndex << 4 | _scanline;
      var low = mem.read(offset);
      var high = mem.read(offset | 8);

      var attrAddr = 0x3c0 | _tileY >> 2 << 3 | _tileX >> 2;
      var attr = mem.read(attrAddr);
      if (getBitBool(_tileX, 1)) attr >>= 2;
      if (getBitBool(_tileY, 1)) attr >>= 4;
      attr &= 3;

      for (var j = 0; j < _tileSize; j++) {
        pixels[_tileY << 3 | _scanline][_tileX << 3 | j] =
            attr << 2 | getBit(high, j) << 1 | getBit(low, j);
      }
    }
    _scanline++;
  }

  render() {
    // _reg.vblankStarted;
    for (var j = 0; j < tileCountY; j++) {
      for (var i = 0; i < tileCountX; i++) {
        _tiles[i][j].renderBackground();
      }
    }

    renderSprite();
  }

  // getSpritePattern(int index) {
  //   var addr = getBit(_reg.ppuctrl, 3) << 12 | index << 2;
  // }

  renderSprite() {
    for (var i = 0; i < PpuOam.spriteCount; i++) {
      var info = _oam.getSpriteInfo(i);

      if (!info.front) return;

      for (var y = 0; y < 8; y++) {
        var offset = reg.spritePatternTableAddr | info.tileIndex << 4 | y;
        var low = mem.read(offset);
        var high = mem.read(offset | 8);

        var attrAddr = xxx | _tileY >> 2 << 3 | _tileX >> 2;
        var attr = mem.read(0x3c0 + 1);
        if (getBitBool(_tileX, 1)) attr >>= 2;
        if (getBitBool(_tileY, 1)) attr >>= 4;
        attr &= 3;

        for (var x = 0; x < 8; x++) {
          this._pixels[info.x + x][info.y + y] = 1;
        }
      }
    }
  }
}
