//
//  GameManager.swift
//  RideTheBus
//
//  Created by Jeremy Manlangit on 12/11/23.
//

import Foundation


@MainActor
@dynamicMemberLookup
class GameManager: ObservableObject {
    @Published var game: Game
    @Published var user: User
    @Published var stage: Stage
    private var repository: GameRepository
    
    init(game: Game, user: User, repository: GameRepository, stage: Stage = .waiting) {
        self.game = game
        self.user = user
        self.repository = repository
        self.stage = stage
    }
    
    init(user: User) {
        let randomID = String.randomGameID()
        self.game = Game(user: user, gameID: randomID)
        self.user = user
        self.repository = GameRepository(user: user, gameID: randomID)
        self.stage = .waiting
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Game, T>) -> T {
        get { game[keyPath: keyPath] }
        set { game[keyPath: keyPath] = newValue }
    }
    
    
    
    //MARK: -- CREATING NEW GAME & JOINING GAME & LEAVING GAME
    func createNewGame() {
        resetManagerAndRepo()
        repository.createNewGame(game)
        repository.observeGame { result in
            self.handleGameResult(result)
        }
    }
    //WIP joingGame(_:) needs to throws
    func joinGame(_ gameID: String) {
        //if successful
        repository.updateGameID(to: gameID)
        repository.observeGame { result in
            self.handleGameResult(result)
        }
        repository.joinGame()
        
        //if failed
    }
    func leaveGame() {
        removeSelfFromGame()
        repository.stopObserving()
    }
    
    
    //MARK: -- GAME SETUP $ GAME START
    func setupLobby() -> Lobby {
        var newLobby = game.lobby
        newLobby.shufflePlayerOrder()
        newLobby.setupResultsData()
        newLobby.dealCards { [weak self] updatedDeck in
            self?.repository.updateDeck(to: updatedDeck)
        }
        
        return newLobby
    }
    func startGame() async {
        do {
            try await self.repository.updateLobby(to: setupLobby())
        } catch {
            print("ERROR: cannot start game")
        }
        self.repository.updateHasStarted(to: true)
    }
    func updateUserIndex() {
        let players = game.lobby.players
        for i in players.indices {
            if user.id == players[i].id {
                user.index = i
            }
        }
    }
    
    
    //MARK: -- GENERAL UPDATE GAME
    func flipCard() {
        repository.updatePlayerCardFlipState(playerIndex: user.index, cardIndex: game.question.number - 1)
    }
    func updateGame() {
        switch game.phase {
        case .guessing:
            updateQuestion()
        case .giveTake:
            if checkForGameEnd() {
                endGame()
                return
            } else {
                removeTwoCards()
            }
        }
        updateCurrentPlayer()
    }
    func resetTurnTaken() {
        repository.updateTurnTaken(to: false)
    }
    func updateStage() {
        if user.index == game.currentPlayerIndex {
            self.stage = .guessing
        } else {
            self.stage = .waiting
        }
//        print("\(user.name)")
//        print("\(user.index)")
//        print("\(game.currentPlayerIndex)")
//        if !game.turnTaken && user.index == game.currentPlayerIndex {
//            self.stage = .guessing
//        } else if fetchUsersPlayerReference().pointsToGive > 0 {
//            self.stage = .giving
//        } else if fetchUsersPlayerReference().pointsToTake > 0 {
//            self.stage = .taking
//        } else if !game.lobby.players.map( {
//            $0.pointsToGive == 0 && $0.pointsToTake == 0
//        }).contains(false) && game.turnTaken && user.index == game.currentPlayerIndex {
//            game.turnTaken = false
//            self.removeTwoCards()
//            self.updateCurrentPlayer()
//            self.updateQuestion()
//        }
//        print("_______________________")
//        print(self.user.name)
//        print(self.stage.rawValue)
    }
    func updateCurrentPlayer() {
        var updatedIndex = game.currentPlayerIndex
        if game.currentPlayerIndex == game.lobby.players.count - 1 {
            updatedIndex = 0
        } else {
            updatedIndex += 1
        }
        repository.updateCurrentPlayerIndex(to: updatedIndex)
    }
    
    func checkForGameEnd() -> Bool {
        if game.deck.count < 2 {
            return true
        } else {
            return false
        }
    }
    func endGame() {
        self.stage = .results
    }
    
    
    //MARK: -- GUESSING PHASE
    func setResultsOfGuessing(_ result: Bool, _ points: Int) {
        var updatedPlayer = fetchUsersPlayerReference()
        if result {
            updatedPlayer.pointsToGive = points
        } else {
            updatedPlayer.pointsToTake = points
        }
        updatedPlayer.guesses.append(result)
        self.stage = .waiting
        repository.updatePlayer(at: user.index, to: updatedPlayer)
        repository.updateTurnTaken(to: true)
    }
    func updateQuestion() {
        if game.lobby.players[0].id == game.lobby.players[game.currentPlayerIndex].id {
            switch game.question {
            case .one:
                repository.updateQuestion(to: .two)
            case .two:
                repository.updateQuestion(to: .three)
            case .three:
                repository.updateQuestion(to: .four)
            case .four:
                repository.updatePhase(to: .giveTake)
            }
        }
    }
    
    
    //MARK: -- GIVE/TAKE PHASE
    func setResultsOfGiveTake() {
        repository.updateTurnTaken(to: true)
        self.stage = .waiting
        removeTwoCards()
    }
    func checkForGiveAndTake(_ card: Card, _ firstPick: inout CardValue?, _ secondPick: inout CardValue?) {
        if firstPick == nil {
            checkPlayersHandForGive(matching: card)
            firstPick = card.value
        } else if firstPick == card.value || secondPick != nil {
            //DO NOTHING
        } else {
            checkPlayersHandForTake(matching: card)
            secondPick = card.value
        }
    }
    func checkPlayersHandForGive(matching card: Card) {
        var players = game.lobby.players
        for playerIndex in players.indices {
            var hand = players[playerIndex].hand
            for cardIndex in hand.indices {
                if hand[cardIndex].value == card.value {
                    var updatedPlayer = players[playerIndex]
                    updatedPlayer.pointsToGive += card.value.rawValue
                    updatedPlayer.hand[cardIndex].giveCards.append(card)
                    
                    repository.updatePlayer(at: playerIndex, to: updatedPlayer)
                }
            }
        }
    }
    func checkPlayersHandForTake(matching card: Card) {
        var players = game.lobby.players
        for playerIndex in players.indices {
            var hand = players[playerIndex].hand
            for cardIndex in hand.indices {
                if hand[cardIndex].value == card.value {
                    var updatedPlayer = players[playerIndex]
                    updatedPlayer.pointsToTake += card.value.rawValue
                    updatedPlayer.hand[cardIndex].takeCards.append(card)
                    
                    repository.updatePlayer(at: playerIndex, to: updatedPlayer)
                }
            }
        }
    }
    func removeTwoCards() {
        //WIP updating deck
        //WIP remove last two (Stack as opposed to Queue) save from shifting all nodes
        if game.phase == .giveTake {
            game.deck.removeFirst()
            game.deck.removeFirst()
        }
    }
    
    
    //MARK: -- GIVE STAGE
    func givePointsTo(_ lobby: Lobby) {
        var updatedLobby = lobby
        //subtract from user's pointsToGive
        updatedLobby.players[user.index].pointsToGive = 0
        
        for playerIndex in updatedLobby.players.indices {
            var playerRef = updatedLobby.players[playerIndex]
            
            //update user's givenTo
            updatedLobby.players[user.index].give(points: playerRef.pointsToTake, to: playerRef.id)
            
            //update player's takenFrom
            updatedLobby.players[playerIndex].take(points: playerRef.pointsToTake, from: user.id)
        }
        
        //update player.stage = .wait
        self.stage = .waiting
        
        
        repository.updateLobby(to: updatedLobby)
    }
    
    
    //MARK: -- GIVE STAGE
    func takePoints(_ points: Int, completionHandler: ((Int?) -> Void)) {
        var updatedPlayer = fetchUsersPlayerReference()
        var pointsToTake: Int?
        updatedPlayer.pointsToTake -= points
        
        
        
        if updatedPlayer.pointsToTake > 0 {
            pointsToTake = updatedPlayer.pointsToTake
        } else {
            self.stage = .waiting
            pointsToTake = nil
        }
        
        repository.updatePlayer(at: user.index, to: updatedPlayer)
        completionHandler(pointsToTake)
    }
}













//MARK -- HELPER FUNCTIONS
extension GameManager {
    func fetchUsersPlayerReference() -> Player {
        game.lobby.players[user.index]
    }
    func fetchPlayerCard() -> Card {
        fetchUsersPlayerReference().hand[game.question.number - 1]
    }
    func updateUser(to user: User) {
        self.user = user
        let newGameID = String.randomGameID()
        self.game = Game(user: user, gameID: newGameID)
        self.repository.gameID = newGameID
    }
    
    func handleGameResult(_ result: Result<Game, Error>) {
        switch result {
        case .success(let game):
            self.game = game
        case .failure(let error):
            print("Error observing game: \(error)")
        }
    }
    
    
    func removeSelfFromGame() {
        var newPlayers = game.lobby.players
        newPlayers.removeAll { player in
            return user == player.user
        }
        let newLobby = Lobby(players: newPlayers)
        repository.updateLobby(to: newLobby)
        
        if user == game.host {
            replaceHost(using: newLobby)
        }
    }
    
    func replaceHost(using newLobby: Lobby) {
        guard let newHost = newLobby.players.first?.user else {
            repository.deleteGame()
            return
        }
        game.host = newHost
        repository.updateHost(to: newHost)
    }
    
    func resetManagerAndRepo() {
        let newGameID = String.randomGameID()
        self.game = Game(user: self.user, gameID: newGameID)
        repository.updateGameID(to: newGameID)
    }
}


//MARK: -- PREVIEWS
extension GameManager {
    static var previewSetUp = GameManager(user: User.test1)
    static var previewGameStarted = GameManager(game: Game.previewGameHasStarted, user: User.test1, repository: GameRepository(user: User.test1, gameID: Game.testRoomID))
    static var previewResults = GameManager(game: Game.previewResults, user: User.test1, repository: GameRepository(user: User.test1, gameID: Game.testRoomID))
    static var previewPlayerTakes: GameManager {
        var game = GameManager(game: Game.previewGameHasStarted, user: User.test1, repository: GameRepository(user: User.test1, gameID: Game.testRoomID))
        
        for playerIndex in game.lobby.players.indices {
            if game.user.id == game.lobby.players[playerIndex].id {
                game.lobby.players[playerIndex].pointsToTake = 3
            }
        }
        
        
        return game
    }
}
