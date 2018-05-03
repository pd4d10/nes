import 'memory.dart';

// https://wiki.nesdev.com/w/index.php/Stack
// Descending, empty
class CpuStack {
  final _offset = 0x100; // $0100-$01ff
  Memory _mem;
  int point;

  CpuStack(this._mem);

  reset() => point = 0xff;

  push(int value) {
    if (point < 0) {
      throw 'Stack overflow';
    }
    _mem.write(point + _offset, value);
    point--;
  }

  push16(int value) {
    push(value >> 8 & 0xff);
    push(value & 0xff);
  }

  pop() {
    if (point >= 0xff) {
      throw 'Stack underflow';
    }
    point++;
    return _mem.read(point + _offset);
  }

  pop16() {
    var low = pop();
    var high = pop();
    return low | high << 8;
  }
}
