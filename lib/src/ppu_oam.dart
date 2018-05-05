import 'utils.dart';
// import 'ppu.dart';

/// Object Attribute Memory
// https://wiki.nesdev.com/w/index.php/PPU_OAM
class PpuOam {
  static final spriteCount = 64;
  List<int> data = new List(0x100);

  SpriteInfo getSpriteInfo(int index) {
    return new SpriteInfo.fromMem(data.getRange(index << 2, index + 1 << 2));
  }
}

class SpriteInfo {
  int x;
  int y;
  int tileIndex;
  bool front;
  bool vFlip;
  bool hFlip;
  int palette;

  SpriteInfo.fromMem(data) {
    y = data[0];
    tileIndex = data[1];
    var byte2 = data[2];
    x = data[3];

    palette = byte2 & 3;
    front = getBitBool(byte2, 5);
    hFlip = getBitBool(byte2, 6);
    vFlip = getBitBool(byte2, 7);
  }
}
