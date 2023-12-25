import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Time "mo:base/Time";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Int "mo:base/Int";

actor {
  public shared (msg) func whoami() : async Principal {
    msg.caller;
  };

  public type GuessRecord = {
    time : Time.Time;
    playerID : Principal;
    guessNumber : Nat;
  };

  stable var playersList : List.List<Principal> = List.nil<Principal>();

  stable var playersGuesses : List.List<GuessRecord> = List.nil<GuessRecord>();

  stable var gameRound : Nat = 1;

  stable var endTime : Nat = 0;

  public shared (msg) func makeOneGuess(num : Nat) : async () {
    let principalID : Principal = msg.caller;

    func containsPlayer(players : List.List<Principal>, player : Principal) : Bool {
      var isFound = false;
      let playersArr = List.toArray<Principal>(players);
      let len = Array.size(playersArr);
      var i = 0;
      while (i < len) {
        if (playersArr[i] == player) {
          isFound := true;
        };
        i += 1;
      };
      return isFound;
    };

    if (Principal.toText(principalID) != "2vxsx-fae") {
      let isPlayed : Bool = containsPlayer(playersList, principalID);

      if (isPlayed == false) {
        let guessRecord : GuessRecord = {
          time = Time.now();
          playerID = principalID;
          guessNumber = num;
        };

        let playersAmount: Nat = List.size(playersList);
        if (playersAmount == 0) {
          await startTimer(600);
        };

        playersList := List.push<Principal>(principalID, playersList);
        playersGuesses := List.push<GuessRecord>(guessRecord, playersGuesses);
      };
    };
  };

  public shared func getPlayersAmount() : async Nat {
    return List.size(playersList);
  };

  public shared func getCurrentRound() : async Nat {
    return gameRound;
  };

  public shared func calculateAverage(arr : [Nat]) : async Nat {
    var sum = 0;
    let len = Array.size(arr);
    var i = 0;
    while (i < len) {
      sum += arr[i];
      i += 1;
    };
    return sum / len;
  };

  public shared func startTimer(durationInSeconds : Nat) : async () {
    let nanoSecondsNow : Nat = Int.abs(Time.now());
    endTime := nanoSecondsNow + (durationInSeconds * 1_000_000_000);
  };

  public shared func isCurrentRoundEnd(endTime: Nat) : async Bool {
    Int.abs(Time.now()) > endTime;
  };
};
