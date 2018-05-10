import 'memory.dart';
import 'cpu_register.dart';
import 'cpu_stack.dart';
import 'cpu_instruction.dart';

class CPU {
  int opAddr;
  int extraCycle;

  CpuRegister reg = new CpuRegister();
  Memory mem = new Memory();
  CpuStack stack;
  CpuInstruction ins;

  CPU() {
    stack = new CpuStack(this.mem);
    ins = new CpuInstruction(reg, stack, mem);
  }

  //
  emulate() {
    var opcode = mem.read(reg.pc);
    var operators = ins.mapper[opcode];
    if (operators == null) {
      throw 'Opcode invalid: $opcode';
    }
    Function() getAddress = operators[0];
    Function() executeInstruction = operators[1];
    int size = operators[2];
    int cycle = operators[3];

    var addr = getAddress();
    if (addr != null) {
      ins.addr = addr;
    }

    executeInstruction();
    extraCycle = 0;
    reg.pc += size;
  }
}
