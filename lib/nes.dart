import 'cpu.dart';
import 'controller.dart';
import 'ppu.dart';
import 'rom.dart';

class NES {
  dynamic opts;
  CPU cpu;
  PPU ppu;
  dynamic mmap;
  num frameTime;
  dynamic ui;
  dynamic controllers;
  dynamic lastFpsTime;
  ROM rom;

  NES(onFrame, onStatusUpdate) {
    // this.opts = {
    //   onFrame() {},
    //   onStatusUpdate() {},
    //   onBatteryRamWrite() {},

    //   // FIXME: not actually used except for in PAPU

    //   // sampleRate: 44100 // Sound sample rate in hz
    // };
    // if (opts != null) {
    //   var key;
    //   for (key in this.opts) {
    //     if (opts[key] !=null) {
    //       this.opts[key] = opts[key];
    //     }
    //   }
    // }
    this.frameTime = 1000 / 60;

    this.ui = {"writeFrame": onFrame, "updateStatus": onStatusUpdate};
    this.cpu = new CPU(this);
    this.ppu = new PPU(this);
    // this.papu = new PAPU(this);
    this.mmap = null; // set in loadROM()
    this.controllers = {1: new Controller(), 2: new Controller()};

    this.ui["updateStatus"]("Ready to load a ROM.");

    // this.frame = this.frame.bind(this);
    // this.buttonDown = this.buttonDown.bind(this);
    // this.buttonUp = this.buttonUp.bind(this);
    // this.zapperMove = this.zapperMove.bind(this);
    // this.zapperFireDown = this.zapperFireDown.bind(this);
    // this.zapperFireUp = this.zapperFireUp.bind(this);
  }

  var fpsFrameCount = 0;
  var romData = null;

  // Resets the system
  reset() {
    if (this.mmap != null) {
      this.mmap.reset();
    }

    this.cpu.reset();
    this.ppu.reset();
    // this.papu.reset();

    this.lastFpsTime = null;
    this.fpsFrameCount = 0;
  }

  frame() {
    this.ppu.startFrame();
    var cycles = 0;
    // var emulateSound = this.opts.emulateSound;
    var emulateSound = true;
    var cpu = this.cpu;
    var ppu = this.ppu;
    // var papu = this.papu;
    FRAMELOOP:
    for (;;) {
      if (cpu.cyclesToHalt == 0) {
        // Execute a CPU instruction
        cycles = cpu.emulate();
        if (emulateSound) {
          // papu.clockFrameCounter(cycles);
        }
        cycles *= 3;
      } else {
        if (cpu.cyclesToHalt > 8) {
          cycles = 24;
          if (emulateSound) {
            // papu.clockFrameCounter(8);
          }
          cpu.cyclesToHalt -= 8;
        } else {
          cycles = cpu.cyclesToHalt * 3;
          if (emulateSound) {
            // papu.clockFrameCounter(cpu.cyclesToHalt);
          }
          cpu.cyclesToHalt = 0;
        }
      }

      for (; cycles > 0; cycles--) {
        if (ppu.curX == ppu.spr0HitX &&
            ppu.f_spVisibility == 1 &&
            ppu.scanline - 21 == ppu.spr0HitY) {
          // Set sprite 0 hit flag:
          ppu.setStatusFlag(ppu.STATUS_SPRITE0HIT, true);
        }

        if (ppu.requestEndFrame) {
          ppu.nmiCounter--;
          if (ppu.nmiCounter == 0) {
            ppu.requestEndFrame = false;
            ppu.startVBlank();
            break FRAMELOOP;
          }
        }

        ppu.curX++;
        if (ppu.curX == 341) {
          ppu.curX = 0;
          ppu.endScanline();
        }
      }
    }
    this.fpsFrameCount++;
  }

  buttonDown(controller, button) {
    this.controllers[controller].buttonDown(button);
  }

  buttonUp(controller, button) {
    this.controllers[controller].buttonUp(button);
  }

  zapperMove(x, y) {
    if (!this.mmap) return;
    this.mmap.zapperX = x;
    this.mmap.zapperY = y;
  }

  zapperFireDown() {
    if (!this.mmap) return;
    this.mmap.zapperFired = true;
  }

  zapperFireUp() {
    if (!this.mmap) return;
    this.mmap.zapperFired = false;
  }

  getFPS() {
    var now = new DateTime.now().millisecondsSinceEpoch;
    var fps = null;
    if (this.lastFpsTime) {
      fps = this.fpsFrameCount / ((now - this.lastFpsTime) / 1000);
    }
    this.fpsFrameCount = 0;
    this.lastFpsTime = now;
    return fps;
  }

  reloadROM() {
    if (this.romData != null) {
      this.loadROM(this.romData);
    }
  }

  // Loads a ROM file into the CPU and PPU.
  // The ROM file is validated first.
  loadROM(data) {
    // Load ROM file:
    this.rom = new ROM(this);
    this.rom.load(data);

    this.reset();
    this.mmap = this.rom.createMapper();
    this.mmap.loadROM();
    this.ppu.setMirroring(this.rom.getMirroringType());
    this.romData = data;
  }

  setFramerate(rate) {
    this.opts.preferredFrameRate = rate;
    this.frameTime = 1000 / rate;
    // this.papu.setSampleRate(this.opts.sampleRate, false);
  }

  toJSON() {
    return {
      romData: this.romData,
      cpu: this.cpu.toJSON(),
      mmap: this.mmap.toJSON(),
      ppu: this.ppu.toJSON()
    };
  }

  fromJSON(s) {
    this.loadROM(s.romData);
    this.cpu.fromJSON(s.cpu);
    this.mmap.fromJSON(s.mmap);
    this.ppu.fromJSON(s.ppu);
  }
}
