import 'cpu_memory.dart';
import 'cpu_register.dart';
import 'cpu_stack.dart';
import 'cpu_instruction.dart';
import 'cpu_addressing.dart';
import 'cpu_table.dart';
import '../nes.dart';

class SomeClass {
  int value;
  get triple => value * 3;
}

class CPU {
  int opAddr;

  CpuRegister reg;
  CpuMemory mem;
  CpuStack stack;
  CpuInstruction instruction;
  CpuAddressing addressing;
  CpuTable table;

  int _extraCycle;

  setExtraCycle() {
    _extraCycle = 1;
  }

  CPU(NES nes) {
    reg = new CpuRegister();
    addressing = new CpuAddressing(this);
    mem = new CpuMemory(nes.ppu.reg, nes.rom);
    stack = new CpuStack(mem);
    instruction = new CpuInstruction(this);
    table = new CpuTable(this);
  }

  reset() {
    reg.reset();
    mem.reset();
    stack.reset();
    reg.pc = mem.read16(0xfffc);
  }

  //
  emulate() {
    _extraCycle = 0;

    var code = mem.read(reg.pc);

    // print('Program count: ${reg.pc.toRadixString(16)}');
    print('Code: ${code.toRadixString(16)}');
    print('Status: ${reg.p.toRadixString(2)}');

    var operators = table.getOperationsbyCode(code);
    Function() getAddress = operators[0];
    Function() executeInstruction = operators[1];
    int size = operators[2];
    int cycle = operators[3];

    getAddress();
    executeInstruction();
    reg.pc += size;

    return _extraCycle + cycle;
  }
}
