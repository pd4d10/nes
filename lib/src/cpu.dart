import 'utils.dart';
import 'memory.dart';

// http://wiki.nesdev.com/w/index.php/CPU_status_flag_behavior
class ProcessorStatus {
  int data;

  read() => data;
  write(int value) => data = value & 0xff;

  _setDataByBit(int n, int value) => data = setBit(data, n, value);

  get carry => getBit(data, 0);
  set carry(int value) => _setDataByBit(0, value);
  get zero => getBit(data, 1);
  set zero(int value) => _setDataByBit(1, value);
  get interrupt => getBit(data, 2);
  set interrupt(int value) => _setDataByBit(2, value);
  get decimal => getBit(data, 3);
  set decimal(int value) => _setDataByBit(3, value);
  get overflow => getBit(data, 6);
  set overflow(int value) => _setDataByBit(6, value);
  get negative => getBit(data, 7);
  set negative(int value) => _setDataByBit(7, value);

  setZeroAndNegative(int value) {
    zero = value == 0 ? 1 : 0;
    negative = value >> 7 & 1;
  }
}

class CPU {
  int regA;
  int regX;
  int regY;
  int regPC;
  var flags = new ProcessorStatus();
  int regSP;

  int opAddr;
  int opValue;
  int opCode;

  Map<int, List> mapper = {};

  var mem = new Memory();

  CPU() {
    mapper = {
      // Operation code: [Addressing mode, instruction, size, cycles]
      0x69: [immediate, adc, 2, 2],
      0x65: [zeroPage, adc, 2, 3],
      0x75: [zeroPageX, adc, 2, 4],
      0x6d: [absolute, adc, 3, 4],
      0x7d: [absoluteX, adc, 3, 4],
      0x79: [absoluteY, adc, 3, 4],
      0x61: [indirectX, adc, 2, 6],
      0x71: [indirectY, adc, 2, 5],
      0x29: [immediate, and, 2, 2],
      0x25: [zeroPage, and, 2, 3],
      0x35: [zeroPageX, and, 2, 4],
      0x2d: [absolute, and, 3, 4],
      0x3d: [absoluteX, and, 3, 4],
      0x39: [absoluteY, and, 3, 4],
      0x21: [indirectX, and, 2, 6],
      0x31: [indirectY, and, 2, 5],
      0x0a: [accumulator, asl, 1, 2],
      0x06: [zeroPage, asl, 2, 5],
      0x16: [zeroPageX, asl, 2, 6],
      0x0e: [absolute, asl, 3, 6],
      0x1e: [absoluteX, asl, 3, 7],
      0x24: [zeroPage, bit, 2, 3],
      0x2c: [absolute, bit, 3, 4],
      0x10: [relative, bpl, 2, 2],
      0x30: [relative, bmi, 2, 2],
      0x50: [relative, bvc, 2, 2],
      0x70: [relative, bvs, 2, 2],
      0x90: [relative, bcc, 2, 2],
      0xb0: [relative, bcs, 2, 2],
      0xd0: [relative, bne, 2, 2],
      0xf0: [relative, beq, 2, 2],
      0x00: [implicit, brk, 1, 7],
      0xc9: [immediate, cmp, 2, 2],
      0xc5: [zeroPage, cmp, 2, 3],
      0xd5: [zeroPageX, cmp, 2, 4],
      0xcd: [absolute, cmp, 3, 4],
      0xdd: [absoluteX, cmp, 3, 4],
      0xd9: [absoluteY, cmp, 3, 4],
      0xc1: [indirectX, cmp, 2, 6],
      0xd1: [indirectY, cmp, 2, 5],
      0xe0: [immediate, cpx, 2, 2],
      0xe4: [zeroPage, cpx, 2, 3],
      0xec: [absolute, cpx, 3, 4],
      0xc0: [immediate, cpy, 2, 2],
      0xc4: [zeroPage, cpy, 2, 3],
      0xcc: [absolute, cpy, 3, 4],
      0xc6: [zeroPage, dec, 2, 5],
      0xd6: [zeroPageX, dec, 2, 6],
      0xce: [absolute, dec, 3, 6],
      0xde: [absoluteX, dec, 3, 7],
      0x49: [immediate, eor, 2, 2],
      0x45: [zeroPage, eor, 2, 3],
      0x55: [zeroPageX, eor, 2, 4],
      0x4d: [absolute, eor, 3, 4],
      0x5d: [absoluteX, eor, 3, 4],
      0x59: [absoluteY, eor, 3, 4],
      0x41: [indirectX, eor, 2, 6],
      0x51: [indirectY, eor, 2, 5],
      0x18: [implicit, clc, 1, 2],
      0x38: [implicit, sec, 1, 2],
      0x58: [implicit, cli, 1, 2],
      0x78: [implicit, sei, 1, 2],
      0xb8: [implicit, clv, 1, 2],
      0xd8: [implicit, cld, 1, 2],
      0xf8: [implicit, sed, 1, 2],
      0xe6: [zeroPage, inc, 2, 5],
      0xf6: [zeroPageX, inc, 2, 6],
      0xee: [absolute, inc, 3, 6],
      0xfe: [absoluteX, inc, 3, 7],
      0x4c: [absolute, jmp, 3, 3],
      0x6c: [indirect, jmp, 3, 5],
      0x20: [absolute, jsr, 3, 6],
      0xa9: [immediate, lda, 2, 2],
      0xa5: [zeroPage, lda, 2, 3],
      0xb5: [zeroPageX, lda, 2, 4],
      0xad: [absolute, lda, 3, 4],
      0xbd: [absoluteX, lda, 3, 4],
      0xb9: [absoluteY, lda, 3, 4],
      0xa1: [indirectX, lda, 2, 6],
      0xb1: [indirectY, lda, 2, 5],
      0xa2: [immediate, ldx, 2, 2],
      0xa6: [zeroPage, ldx, 2, 3],
      0xb6: [zeroPageY, ldx, 2, 4],
      0xae: [absolute, ldx, 3, 4],
      0xbe: [absoluteY, ldx, 3, 4],
      0xa0: [immediate, ldy, 2, 2],
      0xa4: [zeroPage, ldy, 2, 3],
      0xb4: [zeroPageX, ldy, 2, 4],
      0xac: [absolute, ldy, 3, 4],
      0xbc: [absoluteX, ldy, 3, 4],
      0x4a: [accumulator, lsr, 1, 2],
      0x46: [zeroPage, lsr, 2, 5],
      0x56: [zeroPageX, lsr, 2, 6],
      0x4e: [absolute, lsr, 3, 6],
      0x5e: [absoluteX, lsr, 3, 7],
      0xea: [implicit, nop, 1, 2],
      0x09: [immediate, ora, 2, 2],
      0x05: [zeroPage, ora, 2, 3],
      0x15: [zeroPageX, ora, 2, 4],
      0x0d: [absolute, ora, 3, 4],
      0x1d: [absoluteX, ora, 3, 4],
      0x19: [absoluteY, ora, 3, 4],
      0x01: [indirectX, ora, 2, 6],
      0x11: [indirectY, ora, 2, 5],
      0xaa: [implicit, tax, 1, 2],
      0x8a: [implicit, txa, 1, 2],
      0xca: [implicit, dex, 1, 2],
      0xe8: [implicit, inx, 1, 2],
      0xa8: [implicit, tay, 1, 2],
      0x98: [implicit, tya, 1, 2],
      0x88: [implicit, dey, 1, 2],
      0xc8: [implicit, iny, 1, 2],
      0x2a: [accumulator, rol, 1, 2],
      0x26: [zeroPage, rol, 2, 5],
      0x36: [zeroPageX, rol, 2, 6],
      0x2e: [absolute, rol, 3, 6],
      0x3e: [absoluteX, rol, 3, 7],
      0x6a: [accumulator, ror, 1, 2],
      0x66: [zeroPage, ror, 2, 5],
      0x76: [zeroPageX, ror, 2, 6],
      0x6e: [absolute, ror, 3, 6],
      0x7e: [absoluteX, ror, 3, 7],
      0x40: [implicit, rti, 1, 6],
      0x60: [implicit, rts, 1, 6],
      0xe9: [immediate, sbc, 2, 2],
      0xe5: [zeroPage, sbc, 2, 3],
      0xf5: [zeroPageX, sbc, 2, 4],
      0xed: [absolute, sbc, 3, 4],
      0xfd: [absoluteX, sbc, 3, 4],
      0xf9: [absoluteY, sbc, 3, 4],
      0xe1: [indirectX, sbc, 2, 6],
      0xf1: [indirectY, sbc, 2, 5],
      0x85: [zeroPage, sta, 2, 3],
      0x95: [zeroPageX, sta, 2, 4],
      0x8d: [absolute, sta, 3, 4],
      0x9d: [absoluteX, sta, 3, 5],
      0x99: [absoluteY, sta, 3, 5],
      0x81: [indirectX, sta, 2, 6],
      0x91: [indirectY, sta, 2, 6],
      0x9a: [implicit, txs, 1, 2],
      0xba: [implicit, tsx, 1, 2],
      0x48: [implicit, pha, 1, 3],
      0x68: [implicit, pla, 1, 4],
      0x08: [implicit, php, 1, 3],
      0x28: [implicit, plp, 1, 4],
      0x86: [zeroPage, stx, 2, 3],
      0x96: [zeroPageY, stx, 2, 4],
      0x8e: [absolute, stx, 3, 4],
      0x84: [zeroPage, sty, 2, 3],
      0x94: [zeroPageX, sty, 2, 4],
      0x8c: [absolute, sty, 3, 4]
    };
  }

  // Addressing mode
  // http://wiki.nesdev.com/w/index.php/CPU_addressing_modes
  // http://obelisk.me.uk/6502/addressing.html
  implicit() {}
  accumulator() => opAddr = regA;
  immediate() => opAddr = regPC + 1;
  zeroPage() => opAddr = mem.read(regPC + 1);
  zeroPageX() => opAddr = mem.read(regPC + 1) + regX & 0xff;
  zeroPageY() => opAddr = mem.read(regPC + 1) + regY & 0xff;
  absolute() => opAddr = mem.read16(regPC + 1);
  absoluteX() => opAddr = mem.read16(regPC + 1) + regX & 0xffff;
  absoluteY() => opAddr = mem.read16(regPC + 1) + regY & 0xffff;
  indirect() => opAddr = mem.read16(mem.read16(regPC + 1));
  indirectX() => opAddr = mem.read16(mem.read(regPC + 1) + regX);
  indirectY() => opAddr = mem.read16(mem.read(regPC + 1)) + regY & 0xffff;
  relative() {
    opAddr = mem.read(regPC + 1);
    if (opAddr >= 0x80) {
      opAddr -= 0x100;
    }
    opAddr += regPC;
  }

  // Instructions
  // http://nesdev.com/6502.txt
  // http://obelisk.me.uk/6502/reference.html
  // http://www.6502.org/tutorials/6502opcodes.html
  adc() {}

  ifFlagSetPC(int flag, int value) {
    if (flag == value) {
      regPC = opAddr;
    }
  }

  bcs() => ifFlagSetPC(flags.carry, 1);
  bcc() => ifFlagSetPC(flags.carry, 0);
  beq() => ifFlagSetPC(flags.zero, 1);
  bne() => ifFlagSetPC(flags.zero, 0);
  bvs() => ifFlagSetPC(flags.overflow, 1);
  bvc() => ifFlagSetPC(flags.overflow, 0);
  bmi() => ifFlagSetPC(flags.negative, 1);
  bpl() => ifFlagSetPC(flags.negative, 0);

  cmp() {
    var tmp = regA - opValue;
    flags.carry = tmp >= 0 ? 1 : 0;
    flags.setZeroAndNegative(tmp);
  }

  cpx() {
    var tmp = regX - opValue;
    flags.carry = tmp >= 0 ? 1 : 0;
    flags.setZeroAndNegative(tmp);
  }

  cpy() {
    var tmp = regY - opValue;
    flags.carry = tmp >= 0 ? 1 : 0;
    flags.setZeroAndNegative(tmp);
  }

  inc() {
    mem.write(opAddr, ++opValue);
    flags.setZeroAndNegative(opValue);
  }

  dec() {
    mem.write(opAddr, --opValue);
    flags.setZeroAndNegative(opValue);
  }

  inx() => flags.setZeroAndNegative(++regX);
  iny() => flags.setZeroAndNegative(++regY);
  dex() => flags.setZeroAndNegative(--regX);
  dey() => flags.setZeroAndNegative(--regY);

  lda() => flags.setZeroAndNegative(regA = opValue);
  ldx() => flags.setZeroAndNegative(regX = opValue);
  ldy() => flags.setZeroAndNegative(regY = opValue);

  sta() => mem.write(opAddr, regA);
  stx() => mem.write(opAddr, regX);
  sty() => mem.write(opAddr, regY);

  tax() => flags.setZeroAndNegative(regX = regA);
  tay() => flags.setZeroAndNegative(regY = regA);
  txa() => flags.setZeroAndNegative(regA = regX);
  tya() => flags.setZeroAndNegative(regA = regY);

  tsx() => flags.setZeroAndNegative(regX = regSP);
  txs() => regSP = regX;

  //
  emulate() {
    opCode = mem.read(opAddr);
    var operators = mapper[opCode];
    if (operators == null) {
      throw 'No such operators: $opCode';
    }

    operators[0]();
    operators[1]();
    regPC += operators[2];
  }
}
