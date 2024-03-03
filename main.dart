import 'dart:async';
import 'dart:html';

const List<String> imageList = [
  "https://i.imgur.com/kReMv94.png",
  "https://i.imgur.com/UFP8RM4.png",
  "https://i.imgur.com/9McnEXg.png",
  "https://i.imgur.com/vNAW0pa.png",
  "https://i.imgur.com/8UFWc9q.png",
  "https://i.imgur.com/rHCgIvU.png",
  "https://i.imgur.com/CtvIEMS.png",
  "https://i.imgur.com/Z2mPdX0.png"
];

const String winImage = "https://i.imgur.com/QYKuNwB.png";

const List<String> wordList = [
  "PLENTY", "ACHIEVE", "CLASS", "STARE", "AFFECT", "THICK", "CARRIER", "BILL",
  "SAY", "ARGUE", "OFTEN", "GROW", "VOTING", "SHUT", "PUSH", "FANTASY",
  "PLAN", "LAST", "ATTACK", "COIN", "ONE", "STEM", "SCAN", "ENHANCE", "PILL",
  "OPPOSED", "FLAG", "RACE", "SPEED", "BIAS", "HERSELF", "DOUGH", "RELEASE",
  "SUBJECT", "BRICK", "SURVIVE", "LEADING", "STAKE", "NERVE", "INTENSE",
  "SUSPECT", "WHEN", "LIE", "PLUNGE", "HOLD", "TONGUE", "ROLLING", "STAY",
  "RESPECT", "SAFELY"
];

class HangmanGame {
  static const int hanged = 7;

  final List<String> wordList;
  final Set<String> lettersGuessed = <String>{};

  late List<String> _wordToGuess;
  int _wrongGuesses = 0;

  final StreamController<Null> _onWin = StreamController<Null>.broadcast();
  Stream<Null> get onWin => _onWin.stream;

  final StreamController<Null> _onLose = StreamController<Null>.broadcast();
  Stream<Null> get onLose => _onLose.stream;

  final StreamController<int> _onWrong = StreamController<int>.broadcast();
  Stream<int> get onWrong => _onWrong.stream;

  final StreamController<String> _onRight = StreamController<String>.broadcast();
  Stream<String> get onRight => _onRight.stream;

  final StreamController<String> _onChange = StreamController<String>.broadcast();
  Stream<String> get onChange => _onChange.stream;

  HangmanGame(this.wordList) {
    newGame();
  }

  void newGame() {
    wordList.shuffle();
    _wordToGuess = wordList.first.split('');
    _wrongGuesses = 0;
    lettersGuessed.clear();
    _onChange.add(wordForDisplay);
  }

  void guessLetter(String letter) {
    lettersGuessed.add(letter);
    if (_wordToGuess.contains(letter)) {
      _onRight.add(letter);
      if (isWordComplete) {
        _onChange.add(fullWord);
        _onWin.add(null);
      } else {
        _onChange.add(wordForDisplay);
      }
    } else {
      _wrongGuesses++;
      _onWrong.add(_wrongGuesses);
      if (_wrongGuesses == hanged) {
        _onChange.add(fullWord);
        _onLose.add(null);
      }
    }
  }

  int get wrongGuesses => _wrongGuesses;
  List<String> get wordToGuess => _wordToGuess;
  String get fullWord => wordToGuess.join();
  String get wordForDisplay => wordToGuess.map((String letter) => lettersGuessed.contains(letter) ? letter : '_').join();

  bool get isWordComplete {
    for (final String letter in _wordToGuess) {
      if (!lettersGuessed.contains(letter)) {
        return false;
      }
    }
    return true;
  }
}

late HangmanGame game;

void main() {
  game = HangmanGame(wordList);

  // set up event listeners
  game.onChange.listen(updateWordDisplay);
  game.onWrong.listen(updateGallowsImage);
  game.onWin.listen(win);
  game.onLose.listen(gameOver);

  // put the letter buttons on the screen
  createLetterButtons();

  // start the first game
  newGame();
}

void newGame([_]) {
  game.newGame();
  newGameRef.hidden = true;
  updateGallowsImage(0);
}

void updateWordDisplay(String word) {
  wordRef.text = word;
}

void updateGallowsImage(int wrongGuesses) {
  gallowsRef.src = imageList[wrongGuesses];
}

void win([_]) {
  gallowsRef.src = winImage;
  gameOver();
}

void gameOver([_]) {
  newGameRef.hidden = false;
}

void createLetterButtons() {
  generateAlphabet().forEach((String letter) {
    lettersRef.append(
      ButtonElement()
        ..classes.add('letter-btn')
        ..text = letter
        ..onClick.listen((Event event) {
          final ButtonElement target = event.target as ButtonElement;
          target.disabled = true;
          game.guessLetter(letter);
        }),
    );
  });
}

List<String> generateAlphabet() {
  final int startingCharCode = 'A'.codeUnitAt(0);
  final List<int> charCodes = List<int>.generate(26, (int index) => startingCharCode + index);
  return charCodes.map((int code) => String.fromCharCode(code)).toList();
}

ImageElement get gallowsRef => querySelector("#gallows") as ImageElement;
DivElement get wordRef => querySelector("#word") as DivElement;
DivElement get lettersRef => querySelector("#letters") as DivElement;
ButtonElement get newGameRef => querySelector("#new-game") as ButtonElement;
