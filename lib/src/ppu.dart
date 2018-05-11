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
  int _scanline;

  get _tileY => _scanline >> 3;
  get _yInTile => _scanline & 0x111;

  PPU() {
    for (var j = 0; j < tileCountY; j++) {
      for (var i = 0; i < tileCountX; i++) {
        _tiles[i][j] = new PpuTile(i, j, this);
      }
    }
  }

  render() {
    for (_scanline = 0; _scanline < pixelCountY; _scanline++) {
      if (reg.showBackground) {
        renderBackground();
      }
      if (reg.showSprite) {
        renderSprite();
      }
    }
    // _reg.vblankStarted;
  }

  renderBackground() {
    for (var _tileX = 0; _tileX < tileCountX; _tileX++) {
      var tileIndex = mem.nameTables[reg.nameTableIndex][_tileY << 5 | _tileX];

      var offset = tileIndex << 4 | _yInTile;
      var low = mem.patternTables[reg.bgPatternTableIndex][offset];
      var high = mem.patternTables[reg.bgPatternTableIndex][offset | 8];

      var attr =
          mem.attrTables[reg.nameTableIndex][_tileY >> 2 << 3 | _tileX >> 2];
      if (getBitBool(_tileX, 1)) attr >>= 2;
      if (getBitBool(_tileY, 1)) attr >>= 4;
      attr &= 3;

      for (var x = 0; x < _tileSize; x++) {
        pixels[_tileX << 3 | x][_scanline] =
            attr << 2 | getBit(high, x) << 1 | getBit(low, x);
      }
    }
  }

  renderSprite() {
    var spriteCount = 0;
    for (var i = 0; i < PpuOam.spriteCount; i++) {
      var info = _oam.getSpriteInfo(i);

      if (_scanline < info.y || info.y + reg.spriteHeight < _scanline) {
        continue;
      }

      spriteCount++;
      if (spriteCount > 8) {
        reg.spriteOverflow = true;
      }

      var tmp = _scanline - info.y & 0x111;
      var yInTile = info.vFlip ? 0x111 - tmp : tmp;
      var offset = info.tileIndex << 4 | yInTile;
      var low = mem.patternTables[reg.bgPatternTableIndex][offset];
      var high = mem.patternTables[reg.bgPatternTableIndex][offset | 8];

      // TODO: info.front
      for (var x = info.x; x < _tileSize; x++) {
        var tmp = info.x & 0x111;
        var xInTile = info.hFlip ? 0x111 - tmp : tmp;
        pixels[x][_scanline] =
            info.attr << 2 | getBit(high, xInTile) << 1 | getBit(low, xInTile);
      }
    }
  }
}
