import 'src/cpu.dart';
import 'src/memory.dart';
import 'src/ppu.dart';

main() {
  var ppu = new PPU();
  var mem = new Memory(ppu);
  var cpu = new CPU(mem);
}
