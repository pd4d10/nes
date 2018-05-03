class PPU {
  // Registers
  int ppuctrl;
  int ppumask;
  int ppustatus;
  int oamaddr;
  int oamdata;
  int ppuscroll;
  int ppuaddr;
  int ppudata;

  readRegisters(int address) {
    return [
      ppuctrl,
      ppumask,
      ppustatus,
      oamaddr,
      oamdata,
      ppuscroll,
      ppuaddr,
      ppudata
    ][address % 8];
  }
}
