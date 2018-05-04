import 'utils.dart';
import 'memory.dart';
import 'cpu_register.dart';
import 'cpu_addressing.dart';
import 'cpu_stack.dart';

/// 6502 instructions
// https://wiki.nesdev.com/w/index.php/6502_instructions
// http://obelisk.me.uk/6502/reference.html
// http://www.6502.org/tutorials/6502opcodes.html
class CpuInstruction {
  int opAddr;
  Map<int, List> mapper;
  CpuRegister _reg;
  CpuStack _stack;
  Memory _mem;
  CpuAddressing _am;
  CpuInstruction(this._reg, this._stack, this._mem) {
    _am = new CpuAddressing(_reg, _mem);
    // Operation code: [Addressing mode, instruction, size, cycles]
    mapper = {
      0x69: [_am.immediate, adc, 2, 2],
      0x65: [_am.zeroPage, adc, 2, 3],
      0x75: [_am.zeroPageX, adc, 2, 4],
      0x6d: [_am.absolute, adc, 3, 4],
      0x7d: [_am.absoluteX, adc, 3, 4],
      0x79: [_am.absoluteY, adc, 3, 4],
      0x61: [_am.indirectX, adc, 2, 6],
      0x71: [_am.indirectY, adc, 2, 5],
      0x29: [_am.immediate, and, 2, 2],
      0x25: [_am.zeroPage, and, 2, 3],
      0x35: [_am.zeroPageX, and, 2, 4],
      0x2d: [_am.absolute, and, 3, 4],
      0x3d: [_am.absoluteX, and, 3, 4],
      0x39: [_am.absoluteY, and, 3, 4],
      0x21: [_am.indirectX, and, 2, 6],
      0x31: [_am.indirectY, and, 2, 5],
      0x0a: [_am.accumulator, asl, 1, 2],
      0x06: [_am.zeroPage, asl, 2, 5],
      0x16: [_am.zeroPageX, asl, 2, 6],
      0x0e: [_am.absolute, asl, 3, 6],
      0x1e: [_am.absoluteX, asl, 3, 7],
      0x24: [_am.zeroPage, bit, 2, 3],
      0x2c: [_am.absolute, bit, 3, 4],
      0x10: [_am.relative, bpl, 2, 2],
      0x30: [_am.relative, bmi, 2, 2],
      0x50: [_am.relative, bvc, 2, 2],
      0x70: [_am.relative, bvs, 2, 2],
      0x90: [_am.relative, bcc, 2, 2],
      0xb0: [_am.relative, bcs, 2, 2],
      0xd0: [_am.relative, bne, 2, 2],
      0xf0: [_am.relative, beq, 2, 2],
      0x00: [_am.implicit, brk, 1, 7],
      0xc9: [_am.immediate, cmp, 2, 2],
      0xc5: [_am.zeroPage, cmp, 2, 3],
      0xd5: [_am.zeroPageX, cmp, 2, 4],
      0xcd: [_am.absolute, cmp, 3, 4],
      0xdd: [_am.absoluteX, cmp, 3, 4],
      0xd9: [_am.absoluteY, cmp, 3, 4],
      0xc1: [_am.indirectX, cmp, 2, 6],
      0xd1: [_am.indirectY, cmp, 2, 5],
      0xe0: [_am.immediate, cpx, 2, 2],
      0xe4: [_am.zeroPage, cpx, 2, 3],
      0xec: [_am.absolute, cpx, 3, 4],
      0xc0: [_am.immediate, cpy, 2, 2],
      0xc4: [_am.zeroPage, cpy, 2, 3],
      0xcc: [_am.absolute, cpy, 3, 4],
      0xc6: [_am.zeroPage, dec, 2, 5],
      0xd6: [_am.zeroPageX, dec, 2, 6],
      0xce: [_am.absolute, dec, 3, 6],
      0xde: [_am.absoluteX, dec, 3, 7],
      0x49: [_am.immediate, eor, 2, 2],
      0x45: [_am.zeroPage, eor, 2, 3],
      0x55: [_am.zeroPageX, eor, 2, 4],
      0x4d: [_am.absolute, eor, 3, 4],
      0x5d: [_am.absoluteX, eor, 3, 4],
      0x59: [_am.absoluteY, eor, 3, 4],
      0x41: [_am.indirectX, eor, 2, 6],
      0x51: [_am.indirectY, eor, 2, 5],
      0x18: [_am.implicit, clc, 1, 2],
      0x38: [_am.implicit, sec, 1, 2],
      0x58: [_am.implicit, cli, 1, 2],
      0x78: [_am.implicit, sei, 1, 2],
      0xb8: [_am.implicit, clv, 1, 2],
      0xd8: [_am.implicit, cld, 1, 2],
      0xf8: [_am.implicit, sed, 1, 2],
      0xe6: [_am.zeroPage, inc, 2, 5],
      0xf6: [_am.zeroPageX, inc, 2, 6],
      0xee: [_am.absolute, inc, 3, 6],
      0xfe: [_am.absoluteX, inc, 3, 7],
      0x4c: [_am.absolute, jmp, 3, 3],
      0x6c: [_am.indirect, jmp, 3, 5],
      0x20: [_am.absolute, jsr, 3, 6],
      0xa9: [_am.immediate, lda, 2, 2],
      0xa5: [_am.zeroPage, lda, 2, 3],
      0xb5: [_am.zeroPageX, lda, 2, 4],
      0xad: [_am.absolute, lda, 3, 4],
      0xbd: [_am.absoluteX, lda, 3, 4],
      0xb9: [_am.absoluteY, lda, 3, 4],
      0xa1: [_am.indirectX, lda, 2, 6],
      0xb1: [_am.indirectY, lda, 2, 5],
      0xa2: [_am.immediate, ldx, 2, 2],
      0xa6: [_am.zeroPage, ldx, 2, 3],
      0xb6: [_am.zeroPageY, ldx, 2, 4],
      0xae: [_am.absolute, ldx, 3, 4],
      0xbe: [_am.absoluteY, ldx, 3, 4],
      0xa0: [_am.immediate, ldy, 2, 2],
      0xa4: [_am.zeroPage, ldy, 2, 3],
      0xb4: [_am.zeroPageX, ldy, 2, 4],
      0xac: [_am.absolute, ldy, 3, 4],
      0xbc: [_am.absoluteX, ldy, 3, 4],
      0x4a: [_am.accumulator, lsr, 1, 2],
      0x46: [_am.zeroPage, lsr, 2, 5],
      0x56: [_am.zeroPageX, lsr, 2, 6],
      0x4e: [_am.absolute, lsr, 3, 6],
      0x5e: [_am.absoluteX, lsr, 3, 7],
      0xea: [_am.implicit, nop, 1, 2],
      0x09: [_am.immediate, ora, 2, 2],
      0x05: [_am.zeroPage, ora, 2, 3],
      0x15: [_am.zeroPageX, ora, 2, 4],
      0x0d: [_am.absolute, ora, 3, 4],
      0x1d: [_am.absoluteX, ora, 3, 4],
      0x19: [_am.absoluteY, ora, 3, 4],
      0x01: [_am.indirectX, ora, 2, 6],
      0x11: [_am.indirectY, ora, 2, 5],
      0xaa: [_am.implicit, tax, 1, 2],
      0x8a: [_am.implicit, txa, 1, 2],
      0xca: [_am.implicit, dex, 1, 2],
      0xe8: [_am.implicit, inx, 1, 2],
      0xa8: [_am.implicit, tay, 1, 2],
      0x98: [_am.implicit, tya, 1, 2],
      0x88: [_am.implicit, dey, 1, 2],
      0xc8: [_am.implicit, iny, 1, 2],
      0x2a: [_am.accumulator, rol, 1, 2],
      0x26: [_am.zeroPage, rol, 2, 5],
      0x36: [_am.zeroPageX, rol, 2, 6],
      0x2e: [_am.absolute, rol, 3, 6],
      0x3e: [_am.absoluteX, rol, 3, 7],
      0x6a: [_am.accumulator, ror, 1, 2],
      0x66: [_am.zeroPage, ror, 2, 5],
      0x76: [_am.zeroPageX, ror, 2, 6],
      0x6e: [_am.absolute, ror, 3, 6],
      0x7e: [_am.absoluteX, ror, 3, 7],
      0x40: [_am.implicit, rti, 1, 6],
      0x60: [_am.implicit, rts, 1, 6],
      0xe9: [_am.immediate, sbc, 2, 2],
      0xe5: [_am.zeroPage, sbc, 2, 3],
      0xf5: [_am.zeroPageX, sbc, 2, 4],
      0xed: [_am.absolute, sbc, 3, 4],
      0xfd: [_am.absoluteX, sbc, 3, 4],
      0xf9: [_am.absoluteY, sbc, 3, 4],
      0xe1: [_am.indirectX, sbc, 2, 6],
      0xf1: [_am.indirectY, sbc, 2, 5],
      0x85: [_am.zeroPage, sta, 2, 3],
      0x95: [_am.zeroPageX, sta, 2, 4],
      0x8d: [_am.absolute, sta, 3, 4],
      0x9d: [_am.absoluteX, sta, 3, 5],
      0x99: [_am.absoluteY, sta, 3, 5],
      0x81: [_am.indirectX, sta, 2, 6],
      0x91: [_am.indirectY, sta, 2, 6],
      0x9a: [_am.implicit, txs, 1, 2],
      0xba: [_am.implicit, tsx, 1, 2],
      0x48: [_am.implicit, pha, 1, 3],
      0x68: [_am.implicit, pla, 1, 4],
      0x08: [_am.implicit, php, 1, 3],
      0x28: [_am.implicit, plp, 1, 4],
      0x86: [_am.zeroPage, stx, 2, 3],
      0x96: [_am.zeroPageY, stx, 2, 4],
      0x8e: [_am.absolute, stx, 3, 4],
      0x84: [_am.zeroPage, sty, 2, 3],
      0x94: [_am.zeroPageX, sty, 2, 4],
      0x8c: [_am.absolute, sty, 3, 4]
    };
  }

  adc() {
    var tmp = _reg.a + _reg.carry + _mem.read(opAddr);
    _reg.carry = tmp > 0xff;
    // TODO: status.overflow =
    _reg.setZN(_reg.a = tmp);
  }

  sbc() {}

  and() => _reg.setZN(_reg.a &= _mem.read(opAddr));
  eor() => _reg.setZN(_reg.a ^= _mem.read(opAddr));
  ora() => _reg.setZN(_reg.a |= _mem.read(opAddr));

  asl() {}
  lsr() {}
  rol() {}
  ror() {}

  ifFlagSetPC(int flag, int value) {
    if (flag == value) {
      _reg.pc = opAddr;
    }
  }

  bcs() => ifFlagSetPC(_reg.carry, 1);
  bcc() => ifFlagSetPC(_reg.carry, 0);
  beq() => ifFlagSetPC(_reg.zero, 1);
  bne() => ifFlagSetPC(_reg.zero, 0);
  bvs() => ifFlagSetPC(_reg.overflow, 1);
  bvc() => ifFlagSetPC(_reg.overflow, 0);
  bmi() => ifFlagSetPC(_reg.negative, 1);
  bpl() => ifFlagSetPC(_reg.negative, 0);

  bit() {
    var tmp = _mem.read(opAddr);
    _reg.zero = tmp & _reg.a == 0;
    _reg.overflow = getBit(tmp, 6);
    _reg.negative = getBit(tmp, 7);
  }

  brk() {
    _stack.push16(_reg.pc);
    _stack.push(_reg.p);
    _reg.pc = _mem.read16(0xfffe);
    _reg.breakCommand = 1;
  }

  clc() => _reg.carry = 0;
  cli() => _reg.interrupt = 0;
  cld() => _reg.decimal = 0;
  clv() => _reg.overflow = 0;
  sec() => _reg.carry = 1;
  sei() => _reg.interrupt = 1;
  sed() => _reg.decimal = 1;

  cmp() {
    var tmp = _reg.a - _mem.read(opAddr);
    _reg.carry = tmp >= 0 ? 1 : 0;
    _reg.setZN(tmp);
  }

  cpx() {
    var tmp = _reg.x - _mem.read(opAddr);
    _reg.carry = tmp >= 0 ? 1 : 0;
    _reg.setZN(tmp);
  }

  cpy() {
    var tmp = _reg.y - _mem.read(opAddr);
    _reg.carry = tmp >= 0 ? 1 : 0;
    _reg.setZN(tmp);
  }

  inc() {
    var tmp = _mem.read(opAddr) + 1;
    _mem.write(opAddr, tmp);
    _reg.setZN(tmp);
  }

  dec() {
    var tmp = _mem.read(opAddr) - 1;
    _mem.write(opAddr, tmp);
    _reg.setZN(tmp);
  }

  inx() => _reg.setZN(++_reg.x);
  iny() => _reg.setZN(++_reg.y);
  dex() => _reg.setZN(--_reg.x);
  dey() => _reg.setZN(--_reg.y);

  jmp() => _reg.pc = opAddr;
  jsr() {
    _stack.push(_reg.pc);
    _reg.pc = opAddr;
  }

  lda() => _reg.setZN(_reg.a = _mem.read(opAddr));
  ldx() => _reg.setZN(_reg.x = _mem.read(opAddr));
  ldy() => _reg.setZN(_reg.y = _mem.read(opAddr));

  nop() {}

  pha() => _stack.push(_reg.a);
  php() => _stack.push(_reg.p);
  pla() => _reg.setZN(_reg.a = _stack.pop());
  plp() => _reg.p = _stack.pop();

  rts() => _reg.pc = _stack.pop() + 1;
  rti() {
    _reg.p = _stack.pop();
    _reg.pc = _stack.pop16();
  }

  sta() => _mem.write(opAddr, _reg.a);
  stx() => _mem.write(opAddr, _reg.x);
  sty() => _mem.write(opAddr, _reg.y);

  tax() => _reg.setZN(_reg.x = _reg.a);
  tay() => _reg.setZN(_reg.y = _reg.a);
  txa() => _reg.setZN(_reg.a = _reg.x);
  tya() => _reg.setZN(_reg.a = _reg.y);

  tsx() => _reg.setZN(_reg.x = _stack.point);
  txs() => _stack.point = _reg.x;
}
