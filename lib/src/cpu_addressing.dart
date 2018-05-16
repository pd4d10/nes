import 'cpu.dart';
import 'cpu_memory.dart';
import 'cpu_register.dart';

/// Addressing mode
// http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
// http://obelisk.me.uk/6502/addressing.html
class CpuAddressing {
  CPU _cpu;
  CpuAddressing(this._cpu);

  CpuMemory get _mem => _cpu.mem;
  CpuRegister get _reg => _cpu.reg;

  implicit() {
    _reg.pc++;
  }

  accumulator() {
    _cpu.opAddr = _reg.a;
    _reg.pc++;
  }

  immediate() {
    _cpu.opAddr = ++_reg.pc;
    _reg.pc++;
  }

  zeroPage() {
    _cpu.opAddr = _mem.read(++_reg.pc);
    _reg.pc++;
  }

  zeroPageX() {
    _cpu.opAddr = _mem.read(++_reg.pc) + _reg.x & 0xff;
    _reg.pc++;
  }

  zeroPageY() {
    _cpu.opAddr = _mem.read(++_reg.pc) + _reg.y & 0xff;
    _reg.pc++;
  }

  absolute() {
    _cpu.opAddr = _mem.read16(++_reg.pc);
    _reg.pc += 2;
  }

  absoluteX() {
    var addr = _mem.read16(++_reg.pc) + _reg.x & 0xffff;
    if ((addr >> 8) != (_reg.pc >> 8)) {
      _cpu.setExtraCycle();
    }
    _cpu.opAddr = addr;
  }

  absoluteY() {
    var addr = _mem.read16(++_reg.pc) + _reg.y & 0xffff;
    if ((addr >> 8) != (_reg.pc >> 8)) {
      _cpu.setExtraCycle();
    }
    _cpu.opAddr = addr;
  }

  indirect() {
    _cpu.opAddr = _mem.read16(_mem.read16(++_reg.pc));
    _reg.pc += 2;
  }

  indirectX() {
    _cpu.opAddr = _mem.read16(_mem.read(++_reg.pc) + _reg.x);
  }

  indirectY() {
    var addr = _mem.read16(_mem.read(++_reg.pc)) + _reg.y & 0xffff;
    if ((addr >> 8) != (_reg.pc >> 8)) {
      _cpu.setExtraCycle();
    }
    _cpu.opAddr = addr;
  }

  relative() {
    var addr = _mem.read(++_reg.pc);
    if (addr >= 0x80) {
      addr -= 0x100;
    }
    if ((addr >> 8) != (_reg.pc >> 8)) {
      _cpu.setExtraCycle();
    }
    _cpu.opAddr = addr + _reg.pc;
  }
}
