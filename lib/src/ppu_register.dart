import 'utils.dart';
import 'ppu_oam.dart';
import 'ppu_memory.dart';

/// PPU Registers
///
/// https://wiki.nesdev.com/w/index.php/PPU_registers
class PpuRegister {
  PpuOam _oam;
  PpuMemory _mem;

  int ppuctrl;
  int ppumask;
  int ppustatus;
  int oamaddr;
  int oamdata;

  bool ppuscrollXReceived;
  int ppuscrollX;
  int ppuscrollY;

  bool ppuaddrHighReceived;
  int ppuaddr;
  int ppudata;
  int oamdma;

  int latch = 0xff;

  int addrLatch;
  bool dataFirstRead = false;

  PpuRegister(this._oam, this._mem) {
    powerUp();
  }

  // https://wiki.nesdev.com/w/index.php/PPU_power_up_state
  powerUp() {
    ppuctrl = 0;
    ppumask = 0;
    ppustatus = 0xa0;
    oamaddr = 0;
    ppuscrollXReceived = false;
    ppuscrollX = 0;
    ppuscrollY = 0;
    ppuaddrHighReceived = false;
    ppuaddr = 0;
    ppudata = 0;
  }

  reset() {
    ppuctrl = 0;
    ppumask = 0;
    ppuscrollXReceived = false;
    ppuscrollX = 0;
    ppuscrollY = 0;
    ppuaddrHighReceived = false;
    ppudata = 0;
    // 29658
  }

  read(int addr) {
    int value;
    switch (addr & 7) {
      case 2:
        value = ppustatus;
        ppuscrollX = 0;
        ppuaddrHighReceived = false;
        latch = value;
        addrLatch = 0;
        dataFirstRead = true;
        vblankStarted = false;
        sprite0Hit = false;
        break;
      case 4:
        value = _oam.data[oamaddr];
        break;
      case 7:
        value = _mem.read(ppuaddr);
        latch = 0;
        if (dataFirstRead) {
          dataFirstRead = false;
        } else {
          ppuaddr += vramAddrInc;
        }
        break;
      default:
        value = latch;
    }
    latch = value;
    return value;
  }

  write(int addr, int value) {
    latch = value;
    switch (addr & 0x111) {
      case 0:
        ppuctrl = value;
        break;
      case 1:
        ppumask = value;
        break;
      case 3:
        oamaddr = value;
        break;
      case 4:
        _oam.data[oamaddr] = value;
        oamaddr++;
        break;
      case 5:
        if (ppuscrollXReceived) {
          ppuscrollY = value;
        } else {
          ppuscrollX = value;
        }
        ppuscrollXReceived = !ppuscrollXReceived;
        break;
      case 6:
        if (ppuaddrHighReceived) {
          ppuaddr = addrLatch << 8 | value;
        } else {
          addrLatch = value;
        }
        ppuaddrHighReceived = !ppuaddrHighReceived;
        break;
      case 7:
        _mem.write(ppuaddr, value);
        break;
      default:
        print('eher');
    }
  }

  get nameTableIndex => ppuctrl & 3;

  /// VRAM address increment per CPU read/write of PPUDATA
  ///
  /// (0: add 1, going across; 1: add 32, going down)
  get vramAddrInc => getBitBool(ppuctrl, 2) ? 32 : 1;

  /// Sprite pattern table address for 8x8 sprites
  ///
  /// (0: $0000; 1: $1000; ignored in 8x16 mode)
  get spritePatternTableIndex => getBitBool(ppuctrl, 3);

  /// Background pattern table address (0: $0000; 1: $1000)
  // get bgPatternTableOffset => getBitBool(ppuctrl, 4) ? 0x1000 : 0;
  get bgPatternTableIndex => getBit(ppuctrl, 4);

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
  get showBackground => getBitBool(ppumask, 3);

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
  set spriteOverflow(bool b) => ppustatus = setBitBool(ppustatus, 5, b);

  /// Sprite 0 Hit. Set when a nonzero pixel of sprite 0 overlaps
  /// a nonzero background pixel; cleared at dot 1 of the pre-render
  /// line. Used for raster timing.
  get sprite0Hit => getBitBool(ppustatus, 6);
  set sprite0Hit(v) => ppustatus = setBitBool(ppustatus, 6, v);

  /// Vertical blank has started (0: not in vblank; 1: in vblank).
  /// Set at dot 1 of line 241 (the line *after* the post-render
  /// line); cleared after reading $2002 and at dot 1 of the
  /// pre-render line.
  get vblankStarted => getBitBool(ppustatus, 7);
  set vblankStarted(v) => ppustatus = setBitBool(ppustatus, 7, v);
}
