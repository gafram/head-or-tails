// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract HeadsOrTails {
    enum GameState { Commit, Reveal, Ended}
    struct Game {
        address payable player1; // address of Creator of Game
        address payable player2;
        uint deadline; // deadline of Game
        uint bet;
        bytes32 commit1;
        uint number1;
        bool creatorSide; // creator choosen head (0 - even sum) or tail (1 - odd sum) 
        GameState state;
        uint bank;

        address payable winner;
    }

    uint public numGames;
    mapping (uint => Game) public games;

    function createGame(bytes32 _commit, bool _creatorSide, uint _deadline) public payable returns (uint gameID){
        gameID = numGames++; // gameID is return variable

        Game storage newGame = games[gameID];
        newGame.commit1 = _commit;
        newGame.player1 = payable(msg.sender);
        newGame.creatorSide = _creatorSide;
        newGame.state = GameState.Commit;
        newGame.bet = msg.value;
        newGame.bank = msg.value;
        newGame.deadline = _deadline;
    }

    function participateGame(uint _gameID, uint _number) public payable {
        require(_gameID < numGames, "Game doesn't exists");
        
        Game storage game = games[_gameID];
        require(msg.value == game.bet, "Wrong bet");
        game.bank += msg.value;
        game.player2 = payable(msg.sender);
        game.number1 = _number;
        game.state = GameState.Reveal;
    }

    function reveal(uint _gameID, uint _number, bytes32 _secret) public {
        require(_gameID < numGames, "Game doesn't exists");
        Game storage game = games[_gameID];

        require(game.state == GameState.Reveal, "GameState isn't correct");

        require(game.commit1 == keccak256(abi.encodePacked(_number, _secret, msg.sender)),  "Reveal doesn't match with commit");

        uint adder = game.creatorSide ? 1 : 0;
        if ((_number + game.number1 + adder) % 2 == 0) {
            game.winner = game.player1;
        }else {
            game.winner = game.player2;   
        }
        game.state = GameState.Ended;
    }

    function withdraw(uint _gameID) public {
        require(_gameID < numGames, "Game doesn't exists");

        Game storage game = games[_gameID];

        require(game.bank != 0, "Withdraw already made!");

        if (game.state != GameState.Ended && block.timestamp > game.deadline) {
            if (game.state == GameState.Reveal) {
                game.winner = game.player2;
                game.state = GameState.Ended;
            }else if (game.state == GameState.Commit) {
                game.winner = game.player1;
                game.state = GameState.Ended;
            }
        }
        require(game.state == GameState.Ended, "The game is not over yet");
        require(msg.sender == game.winner, "You aren't the winner");

        game.winner.transfer(game.bank);
        game.bank = 0;
    }   

    // VIEW FUNCTIONS

    // view function to get all games in mapping `games`
    function getGames() public view returns (Game[] memory){
        Game[] memory ret = new Game[](numGames);
        for (uint i = 0; i < numGames; i++) {
            ret[i] = games[i];
        }
        return ret;
    } 


}