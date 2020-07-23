import 'dart:collection';
import 'package:tuple/tuple.dart';

/*
  QUESTIONS:
  Would it be better to keep track of # of possible #s per square too?
  Should one possible left check if 0 are possible? - Yes?
 */

class Generator {
  List<List<int>> board; // need to create size
  Set<int> unknowns;
  Set<int> knowns;
  HashMap<int, HashSet<int>> possible;

  Generator(){
    this.board = List<List<int>>.filled(9, List<int>.filled(9, null));
    this.unknowns = Set<int>();
    this.knowns = Set<int>();
    this.possible = HashMap<int, HashSet<int>>();
  }

  static void makeBoard() {
    print("hi");
  }

  List<List<int>> solver() {
    // map key will be 2 digit #: first represents cell's row index, second is col index
    for (var i = 0; i < 9; i++) {
      for (var j = 0; j < 9; j++) {
        var key = i * 10 + j;
        if (this.board[i][j].isNaN) {
          var value = HashSet<int>.from([1, 2, 3, 4, 5, 6, 7, 8, 9]);
          this.possible[key] = value;
          this.unknowns.add(key);
        } // if not NA
        else {
          this.knowns.add(key);
        } // else is NA
      } // for j
    } // for i
    return this.board; // will update but was error when included????
  } // solver()

  /*
    Check for errors and set the values of the new known squares

    @param newKnowns  List of new known squares and their values
    @return bool      false if problem in the board, true otherwise
   */
  bool setNewKnowns(List<Tuple2<int, int>> newKnowns){
    var isError = isNewKnownError(newKnowns);
    if(isError){
      return false;
    }
    newKnowns.forEach((known) {
      var square = known.item1;
      int row = square ~/ 10;
      int col = square % 10;
      var value = known.item2;
      this.unknowns.remove(square);
      this.knowns.add(square);
      this.board[row][col] = value;
      this.possible[square] = null;
    });
    return true;
  }

  /*
   Update possible values of the squares in the same row, column, and block
   of the recently found square.

   @param possible  map of possible values for all of the squares
   @param key       key of the recently found square (row*10 + column)
   @param value     known value of the recently found square
   */
   void updatePossible(int key, int value) {
      int rowNum = key ~/ 10;
      int colNum = key % 10;
      // update row and column
      for (var i = 0; i < 9; i++){
        var rowKey = rowNum * 10 + i;
        var colKey = i * 10 + colNum;
        if (this.possible[rowKey] != null) {
          this.possible[rowKey].remove(value);
        }
        if (this.possible[colKey] != null){
          this.possible[colKey].remove(value);
        }
      }
      // update block of 9
      // find beginning of block based on relative position
      int rowIndex = rowNum % 3;
      int colIndex = colNum % 3;
      int firstRow = rowNum - rowIndex;
      int firstCol = colNum - colIndex;
      for (var r = firstRow; r <= firstRow + 2; r++) {
        for (var c = firstCol; c <= firstCol + 2; c++) {
          var blockKey = r * 10 + c;
          if (this.possible[blockKey] != null){
            this.possible[blockKey].remove(value);
          }
        }
      }
  } // updatePossible()

  /*
    Iterates through the unknown squares to check if there is only 1 possible left

    @param possible   map of possible values for each square
    @param unknowns   set of squares where the correct value is unknown
    @return           list of tuples of squares and their only possible value
   */
   List<Tuple2<int, int>> onePossibleLeft(){
      List<Tuple2<int, int>> newKnowns = new List<Tuple2<int, int>>();
      this.unknowns.forEach((square){
        if(this.possible[square].isEmpty){
          // not possible to solve
          List<Tuple2<int, int>> error = [Tuple2<int, int>(99, 99)];
          return error;
        }
        else if(this.possible[square].length == 1){
          // must be that square's value
          newKnowns.add(Tuple2<int, int>(square, this.possible[square].first));
        }
      });
      return newKnowns;
  } // onePossibleLeft()

  List<Tuple2<int, int>> oneLeftRowColBox(){
     List<Tuple2<int, int>> newKnowns = new List<Tuple2<int, int>>();
     // rows
     for(var r = 0; r < 9; r++){
       Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0};
       var onlyOne = HashSet<int>();
       for(var c = 0; c < 9; c++){
         int key = r * 10 + c;
         this.possible[key].forEach((possible) { 
           counts[possible]++;
           if (counts[possible] == 1){
             onlyOne.add(possible);
           }
           else if(onlyOne.contains(possible)){
             onlyOne.remove(possible);
           }
         });
       } // for col
       //only one square can have a certain value for this row
       if (onlyOne.isNotEmpty){
         for (var c = 0; c < 9; c++){
           int key = r * 10 + c;
           this.possible[key].forEach((possible) {
             if (onlyOne.contains(possible)){
               newKnowns.add(Tuple2<int, int>(key, possible));
             }
           });
         } // for col
       } // if onlyOne not empty
     } //for row

     // columns
     for(var c = 0; c < 9; c++){
       Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0};
       var onlyOne = HashSet<int>();
       for(var r = 0; r < 9; r++){
         int key = r * 10 + c;
         this.possible[key].forEach((possible) {
           counts[possible]++;
           if (counts[possible] == 1){
             onlyOne.add(possible);
           }
           else if(onlyOne.contains(possible)){
             onlyOne.remove(possible);
           }
         });
       } // for row
       //only one square can have a certain value for this row
       if (onlyOne.isNotEmpty){
         for (var r = 0; r < 9; r++){
           int key = r * 10 + c;
           this.possible[key].forEach((possible) {
             if (onlyOne.contains(possible)){
               newKnowns.add(Tuple2<int, int>(key, possible));
             }
           });
         } // for row
       } // if onlyOne not empty
     } //for column

     // for box of 9
     // boxes are numbered from 0 in row-major order
     // first 2 for loops iterate through the rows/columns of groups of 9
     // inner 2 for loops iterate through the rows/columns of that group of 9
     for (var rIndex = 0; rIndex < 3; rIndex ++){
       for (var cIndex = 0; cIndex < 3; cIndex ++) {
         // can now identify a box of 9
         Map<int, int> counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0, 8: 0, 9: 0};
         var onlyOne = HashSet<int>();
         for (var r = 0; r < 3; r++){
           for (var c = 0; c < 3; c++){
             var row = rIndex * 3 + r;
             var col = cIndex * 3 + c;
             var key = row * 10 + col;
             this.possible[key].forEach((possible) {
               counts[possible]++;
               if (counts[possible] == 1){
                 onlyOne.add(possible);
               }
               else if(onlyOne.contains(possible)){
                 onlyOne.remove(possible);
               }
             });
           } // for c
         } // for r
         if (onlyOne.isNotEmpty){
           for (var r = 0; r < 3; r++){
             for (var c = 0; c < 3; c++) {
               var row = rIndex * 3 + r;
               var col = cIndex * 3 + c;
               int key = row * 10 + col;
               this.possible[key].forEach((possible) {
                 if (onlyOne.contains(possible)) {
                   newKnowns.add(Tuple2<int, int>(key, possible));
                 }
               });
             } // for c
           } // for r
         } // if onlyOne not empty
       } // for cIndex
     } // for rIndex

     return newKnowns;
  }

  /*
    Checks if any of these new values are duplicate values in the same
    row, column, or block of 9 squares

    @param newKnowns  List of new known squares and their values
    @return           true if duplicate, false otherwise
   */
   bool isNewKnownError(List<Tuple2<int, int>> newKnowns){
    if (newKnowns.length < 2){
      return false;
    }
    // list is probably small enough that it is faster to loop through
    // repeatedly as opposed to checking each row, col, and box of 9
    for(var i = 0; i < (newKnowns.length - 1); i++){
      var square = newKnowns[i].item1;
      int row = square ~/ 10;
      int col = square % 10;
      // boxes are numbered starting with 0 in row-major order
      int box = (row ~/ 3) * 3 + (col ~/ 3);
      var value = newKnowns[i].item2;
      for(var j = i; j < newKnowns.length; j++){
        if(newKnowns[j].item2 == value){
          var square2 = newKnowns[j].item1;
          int row2 = square2 ~/ 10;
          int col2 = square2 % 10;
          int box2 = (row2 ~/ 3) * 3 + (col2 ~/ 3);
          if ((row == row2) || (col == col2) || (box == box2)){
            return true;
          } // if duplicate values in row/col/group
        } // if duplicate values
      } // for j
    } // for i
   return false;
  } // isNewKnownError()

  /*
    Checks if there is a duplicate in a row/column/square of 9
    Would likely only possibly use for the starting board and
    maybe as a last check at end?

    @param board  current state of the board
    @return       true if duplicate, false otherwise
   */
   bool isError(){
    // row
    for (var r = 0; r < 9; r++){
      var rowSet = HashSet<int>();
      for (var c = 0; c < 9; c++){
        var boardValue = this.board[r][c];
        if(boardValue != null){
          if(rowSet.contains(boardValue)){
            return true;
          }
          else{
            rowSet.add(boardValue);
          }
        } // if not null
      } // for col
    } // for row

    // column
    for (var c = 0; c < 9; c++){
      var columnSet = HashSet<int>();
      for (var r = 0; r < 9; r++){
        var boardValue = this.board[r][c];
        if(boardValue != null){
          if(columnSet.contains(boardValue)){
            return true;
          }
          else{
            columnSet.add(boardValue);
          }
        } // if not null
      } // for row
    } // for col

    // square of 9
    for(var rindex = 0; rindex < 3; rindex++){
      for(var cindex = 0; cindex < 3; cindex++){
        var groupSet = HashSet<int>();
        for(var r = 0; r < 3; r++){
          for(var c = 0; c < 3; c++){
            var row = rindex * 3 + r;
            var column = cindex * 3 + c;
            var boardValue = this.board[row][column];
            if(boardValue != null) {
              if (groupSet.contains(boardValue)) {
                return true;
              }
              else {
                groupSet.add(boardValue);
              }
            } // if not null
          } // for c
        } // for r
      } // for cindex
    } // for rindex

    return false;
  } // isError()

}