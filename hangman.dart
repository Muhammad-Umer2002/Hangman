import 'dart:async';

class HangmanGame {
  static const int hanged = 7; // number of wrong guesses before the player's demise

  final List<String> wordList; // list of possible words to guess
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

  HangmanGame(List<String> words) : wordList = List<String>.from(words) {
    newGame();
  }

  void newGame() {
    // shuffle the word list into a random order
    wordList.shuffle();

    // break the first word from the shuffled list into a list of letters
    _wordToGuess = wordList.first.split('');

    // reset the wrong guess count
    _wrongGuesses = 0;

    // clear the set of guessed letters
    lettersGuessed.clear();

    // declare the change (new word)
    _onChange.add(wordForDisplay);
  }

  void guessLetter(String letter) {
    // store guessed letter
    lettersGuessed.add(letter);

    // if the guessed letter is present in the word, check for a win
    // otherwise, check for player death
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

  String get wordForDisplay =>
      wordToGuess.map((String letter) => lettersGuessed.contains(letter) ? letter : '_').join();

  // check to see if every letter in the word has been guessed
  bool get isWordComplete {
    for (final String letter in _wordToGuess) {
      if (!lettersGuessed.contains(letter)) {
        return false;
      }
    }

    return true;
  }
}
