class Controller {
  static int BUTTON_A = 0;
  static int BUTTON_B = 1;
  static int BUTTON_SELECT = 2;
  static int BUTTON_START = 3;
  static int BUTTON_UP = 4;
  static int BUTTON_DOWN = 5;
  static int BUTTON_LEFT = 6;
  static int BUTTON_RIGHT = 7;

  List<int> state;

  Controller() {
    this.state = new List(8);
    for (var i = 0; i < this.state.length; i++) {
      this.state[i] = 0x40;
    }
  }

  buttonDown(key) {
    this.state[key] = 0x41;
  }

  buttonUp(key) {
    this.state[key] = 0x40;
  }
}
