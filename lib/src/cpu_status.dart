import 'utils.dart';

// CPU Status
// http://wiki.nesdev.com/w/index.php/CPU_status_flag_behavior
class CpuStatus {
  // Capitalized acronyms naming:
  // https://www.dartlang.org/guides/language/effective-dart/style#do-capitalize-acronyms-and-abbreviations-longer-than-two-letters-like-words
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
