import 'ppu_register.dart';

// https://wiki.nesdev.com/w/index.php/PPU_registers
class PPU {
  PpuRegister reg;

  PPU(this.reg);

  renderBackground() {
    reg.vblankStarted;
  }
}
