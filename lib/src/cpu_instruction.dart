import 'utils.dart';
import 'cpu.dart';

/// 6502 instructions
// https://wiki.nesdev.com/w/index.php/6502_instructions
// http://obelisk.me.uk/6502/reference.html
// http://www.6502.org/tutorials/6502opcodes.html
class CpuInstruction {
  CPU _cpu;
  CpuInstruction(this._cpu);

  get _reg => _cpu.reg;
  get _stack => _cpu.stack;
  get _mem => _cpu.mem;
  get _addr => _cpu.opAddr;

  adc() {
    var value = _mem.read(_addr);
    var tmp = _reg.a + _reg.carry + value;
    _reg.carry = tmp > 0xff;
    _reg.overflow = (value ^ tmp) & (_reg.a ^ tmp) & 0x80;
    _reg.setZN(_reg.a = tmp);
  }

  sbc() {
    var value = _mem.read(_addr);
    var tmp = _reg.a + _reg.carry - value - 1;
    _reg.carry = tmp <= 0xff;
    _reg.overflow = (_reg.a ^ tmp) & (_reg.a ^ value) & 0x80;
    _reg.setZN(_reg.a = tmp);
  }

  and() => _reg.setZN(_reg.a &= _mem.read(_addr));
  eor() => _reg.setZN(_reg.a ^= _mem.read(_addr));
  ora() => _reg.setZN(_reg.a |= _mem.read(_addr));

  asl() {
    var value = _mem.read(_addr);
    _reg.carry = value > 7 & 1;
    value <<= 1;
    _reg.setZN(value);
    _mem.write(_addr, value);
  }

  lsr() {
    var value = _mem.read(_addr);
    _reg.carry = value & 1;
    value >>= 1;
    _reg.setZN(value);
    _mem.write(_addr, value);
  }

  rol() {
    var value = _mem.read(_addr);
    var tmp = _reg.p & _reg.carry;
    _reg.carry = value & 0x80;
    value <<= 1;
    if (tmp > 0) {
      value |= 1;
    }
    _mem.write(_addr, value);
    _reg.setZN(value);
  }

  ror() {
    var value = _mem.read(_addr);
    var tmp = _reg.p & _reg.carry;
    _reg.carry = value & 1;
    value >>= 1;
    if (tmp > 0) {
      value |= 0x80;
    }
    _mem.write(_addr, value);
    _reg.setZN(value);
  }

  ifFlagSetPC(int flag, int value) {
    if (flag == value) {
      _reg.pc = _addr;
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
    var tmp = _mem.read(_addr);
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
    var tmp = _reg.a - _mem.read(_addr);
    _reg.carry = tmp >= 0 ? 1 : 0;
    _reg.setZN(tmp);
  }

  cpx() {
    var tmp = _reg.x - _mem.read(_addr);
    _reg.carry = tmp >= 0 ? 1 : 0;
    _reg.setZN(tmp);
  }

  cpy() {
    var tmp = _reg.y - _mem.read(_addr);
    _reg.carry = tmp >= 0 ? 1 : 0;
    _reg.setZN(tmp);
  }

  inc() {
    var tmp = _mem.read(_addr) + 1;
    _mem.write(_addr, tmp);
    _reg.setZN(tmp);
  }

  dec() {
    var tmp = _mem.read(_addr) - 1;
    _mem.write(_addr, tmp);
    _reg.setZN(tmp);
  }

  inx() => _reg.setZN(++_reg.x);
  iny() => _reg.setZN(++_reg.y);
  dex() => _reg.setZN(--_reg.x);
  dey() => _reg.setZN(--_reg.y);

  jmp() => _reg.pc = _addr;
  jsr() {
    _stack.push(_reg.pc);
    _reg.pc = _addr;
  }

  lda() => _reg.setZN(_reg.a = _mem.read(_addr));
  ldx() => _reg.setZN(_reg.x = _mem.read(_addr));
  ldy() => _reg.setZN(_reg.y = _mem.read(_addr));

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

  sta() => _mem.write(_addr, _reg.a);
  stx() => _mem.write(_addr, _reg.x);
  sty() => _mem.write(_addr, _reg.y);

  tax() => _reg.setZN(_reg.x = _reg.a);
  tay() => _reg.setZN(_reg.y = _reg.a);
  txa() => _reg.setZN(_reg.a = _reg.x);
  tya() => _reg.setZN(_reg.a = _reg.y);

  tsx() => _reg.setZN(_reg.x = _stack.point);
  txs() => _stack.point = _reg.x;
}
