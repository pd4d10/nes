import 'utils.dart';

// https://wiki.nesdev.com/w/index.php/INES
// https://wiki.nesdev.com/w/index.php/NES_2.0
class ROM {
  int romCount;
  int vromCount;
  int mirroring;
  int hasSaved;
  int trainer;
  int fourScreen;
  int mapperType;

  List<List<int>> roms;
  List<List<int>> vroms;

  ROM(List<int> data) {
    romCount = data[4];
    vromCount = data[5];

    var flag6 = data[6];
    mirroring = getBit(flag6, 0);
    hasSaved = getBit(flag6, 1);
    trainer = getBit(flag6, 2);
    fourScreen = getBit(flag6, 3);

    var flag7 = data[7];
    mapperType = flag6 >> 4 | flag7 & 0xf0;

    final romSize = 0x4000;
    final vromSize = 0x2000;
    var offset = 16;
    // PRG ROM
    for (var i = 0; i < romCount; i++) {
      roms[i] = data.getRange(offset, offset + romSize);
      offset += romSize;
    }
    // CHR ROM
    for (var i = 0; i < vromCount; i++) {
      vroms[i] = data.getRange(offset, offset + vromSize);
    }
  }
}
