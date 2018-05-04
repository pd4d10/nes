import 'utils.dart';

/// CPU Registers
///
/// https://wiki.nesdev.com/w/index.php/CPU_registers
///
/// https://wiki.nesdev.com/w/index.php/CPU_status_flag_behavior
class CpuRegister {
  int a; // Accumulator
  int x; // Index Register X
  int y; // Index Register Y
  int pc; // Program Counter

  int p; // Processor Status

  _setDataByBit(int n, value) {
    value = (value == 0 || value == false || value == null) ? 0 : 1;
    p = setBit(p, n, value);
  }

  get carry => getBit(p, 0);
  set carry(value) => _setDataByBit(0, value);
  get zero => getBit(p, 1);
  set zero(value) => _setDataByBit(1, value);
  get interrupt => getBit(p, 2);
  set interrupt(value) => _setDataByBit(2, value);
  get decimal => getBit(p, 3);
  set decimal(value) => _setDataByBit(3, value);
  get breakCommand => getBit(p, 4);
  set breakCommand(value) => _setDataByBit(4, value);
  get overflow => getBit(p, 6);
  set overflow(value) => _setDataByBit(6, value);
  get negative => getBit(p, 7);
  set negative(value) => _setDataByBit(7, value);

  /// Set zero and negative flag
  setZN(int value) {
    zero = value == 0;
    negative = value >> 7 & 1;
  }
}
