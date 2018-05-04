import 'memory.dart';
import 'cpu_register.dart';

/// Addressing mode
// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
// http://obelisk.me.uk/6502/addressing.html
class CpuAddressing {
  int extraCycle = 0;
  Memory _mem;
  CpuRegister _reg;
  CpuAddressing(this._reg, this._mem);

  implicit() {}
  accumulator() => _reg.a;
  immediate() => _reg.pc + 1;
  zeroPage() => _mem.read(_reg.pc + 1);
  zeroPageX() => _mem.read(_reg.pc + 1) + _reg.x & 0xff;
  zeroPageY() => _mem.read(_reg.pc + 1) + _reg.y & 0xff;
  absolute() => _mem.read16(_reg.pc + 1);
  absoluteX() {
    var addr = _mem.read16(_reg.pc + 1) + _reg.x & 0xffff;
    if (true) {
      extraCycle = 1;
    }
    return addr;
  }

  absoluteY() {
    var addr = _mem.read16(_reg.pc + 1) + _reg.y & 0xffff;
    if (true) {
      extraCycle = 1;
    }
    return addr;
  }

  indirect() => _mem.read16(_mem.read16(_reg.pc + 1));
  indirectX() => _mem.read16(_mem.read(_reg.pc + 1) + _reg.x);
  indirectY() {
    var addr = _mem.read16(_mem.read(_reg.pc + 1)) + _reg.y & 0xffff;
    if (true) {
      extraCycle = 1;
    }
    return addr;
  }

  relative() {
    var addr = _mem.read(_reg.pc + 1);
    if (addr >= 0x80) {
      addr -= 0x100;
    }
    if (true) {
      extraCycle = 1;
    }
    return addr + _reg.pc;
  }
}
