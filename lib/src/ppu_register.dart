import 'utils.dart';

// https://wiki.nesdev.com/w/index.php/PPU_registers
class PpuRegister {
  List<int> _data = new List(8);

  get ppuctrl => _data[0];
  get ppumask => _data[1];
  get ppustatus => _data[2];
  get oamaddr => _data[3];
  get oamdata => _data[4];
  get ppuscroll => _data[5];
  get ppuaddr => _data[6];
  get ppudata => _data[7];

  read(int addr) => _data[addr % 8];

  write(int addr, int value) {
    _data[addr % 8] = value & 0xff;
  }

  /// Base nametable address
  ///
  /// (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
  get nameTableAddr => 0x2000 + (ppuctrl & 3) * 0x400;

  /// VRAM address increment per CPU read/write of PPUDATA
  ///
  /// (0: add 1, going across; 1: add 32, going down)
  get vramAddrInc => getBitBool(ppuctrl, 2) ? 32 : 1;

  /// Sprite pattern table address for 8x8 sprites
  ///
  /// (0: $0000; 1: $1000; ignored in 8x16 mode)
  get spritePatternTableAddr => getBitBool(ppuctrl, 3) ? 0x1000 : 0;

  /// Background pattern table address (0: $0000; 1: $1000)
  get bgPatternTableAddr => getBitBool(ppuctrl, 4) ? 0x1000 : 0;

  /// Sprite size (0: 8x8; 1: 8x16)
  get spriteHeight => getBitBool(ppuctrl, 5) ? 16 : 8;

  /// PPU master/slave select
  ///
  /// (0: read backdrop from EXT pins; 1: output color on EXT pins)
  bool get masterSlaveSelect => getBitBool(ppuctrl, 6);

  /// Generate an NMI at the start of the vertical blanking interval
  get nmi => getBitBool(ppuctrl, 7);

  /// Greyscale (0: normal color, 1: produce a greyscale display)
  get greyscale => getBitBool(ppumask, 0);

  /// Show background in leftmost 8 pixels of screen
  get showLeftBg => getBitBool(ppumask, 1);

  /// Show sprites in leftmost 8 pixels of screen
  get showLeftSprite => getBitBool(ppumask, 2);

  /// Show background
  get showBg => getBitBool(ppumask, 3);

  /// Show sprites
  get showSprite => getBitBool(ppumask, 4);

  /// Emphasize red
  get emphasizeRed => getBitBool(ppumask, 5);

  /// Emphasize green
  get emphasizeGreen => getBitBool(ppumask, 6);

  /// Emphasize blue
  get emphasizeBlue => getBitBool(ppumask, 7);

  /// Sprite overflow. The intent was for this flag to be set
  /// whenever more than eight sprites appear on a scanline, but a
  /// hardware bug causes the actual behavior to be more complicated
  /// and generate false positives as well as false negatives; see
  /// PPU sprite evaluation. This flag is set during sprite
  /// evaluation and cleared at dot 1 (the second dot) of the
  /// pre-render line.
  get spriteOverflow => getBitBool(ppustatus, 5);

  /// Sprite 0 Hit. Set when a nonzero pixel of sprite 0 overlaps
  /// a nonzero background pixel; cleared at dot 1 of the pre-render
  /// line. Used for raster timing.
  get sprite0Hit => getBitBool(ppustatus, 6);

  /// Vertical blank has started (0: not in vblank; 1: in vblank).
  /// Set at dot 1 of line 241 (the line *after* the post-render
  /// line); cleared after reading $2002 and at dot 1 of the
  /// pre-render line.
  get vblankStarted => getBitBool(ppustatus, 7);
  set vblankStarted(v) => setBit(ppustatus, 7, v);
}
