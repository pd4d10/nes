import 'memory.dart';
import 'cpu_register.dart';
import 'cpu_stack.dart';
import 'cpu_instruction.dart';

class CPU {
  int opAddr;
  int opCode;
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
    opCode = mem.read(reg.pc);
    var operators = ins.mapper[opCode];
    if (operators == null) {
      throw 'No such operators: $opCode';
    }
    Function() addressing = operators[0];
    Function() instruction = operators[1];
    int size = operators[2];
    int cycle = operators[3];

    ins.opAddr = addressing();
    instruction();
    extraCycle = 0;
    reg.pc += size;
  }
}
