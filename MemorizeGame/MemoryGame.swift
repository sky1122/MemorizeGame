//
//  MemoryGame.swift
//  MemorizeGame
//
//  Created by JingweiWang on 7/2/23.
//

import Foundation


struct MemoryGame<CardContent> where CardContent: Equatable {
    private(set) var cards: [Card]
    // make sure only have one faceUpCard
    private var IndexOfTheOneAndOnlyFaceUpCard: Int? {
        get { cards.indices.filter({  cards[$0].isFaceUp}).oneAndOnly }
        set { cards.indices.forEach( { cards[$0].isFaceUp = ($0 == newValue)} )}
    }
    
    private(set) var score = 0
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
           !cards[chosenIndex].isFaceUp,
           !cards[chosenIndex].isMatched
        {
            if let potentialMatchIndex = IndexOfTheOneAndOnlyFaceUpCard {
                
                if cards[chosenIndex].content == cards[potentialMatchIndex].content
                {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    if cards[chosenIndex].isAlreadySeen {
                        score += 1
                    } else {
                        score += 2
                    }
                    
                }
                else {
                    if cards[potentialMatchIndex].isAlreadySeen && cards[potentialMatchIndex].click > 0 {
                        score -= 1
                    }
                    if cards[chosenIndex].isAlreadySeen && cards[chosenIndex].click > 0 {
                        score -= 1
                    }
                }
                cards[chosenIndex].isAlreadySeen = true
                cards[potentialMatchIndex].isAlreadySeen = true
                
            } else {
                for index in cards.indices {
                    cards[index].isFaceUp = false
                }
                
                IndexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
            cards[chosenIndex].isFaceUp = true
            cards[chosenIndex].click += 1
        }
    }
    mutating func shuffle() {
        cards.shuffle()
    }
    
    init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
        cards = []
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = createCardContent(pairIndex)
            cards.append(Card(content: content, id: pairIndex * 2))
            cards.append(Card(content: content, id: pairIndex * 2 + 1))
        }
        cards.shuffle()
    }
    
//    struct Card: Identifiable {
//        var isFaceUp = false
//        var isMatched = false
//        var isAlreadySeen = false
//        var click:Int = 0
//        let content: CardContent
//        let id: Int
//    }
    struct Card: Identifiable {
        var click:Int = 0
        var isAlreadySeen = false
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        let content: CardContent
        let id: Int
            
            // MARK: - Bonus Time
            
            // this could give matching bonus points
            // if the user matches the card
            // before a certain amount of time passes during which the card is face up
            
            // can be zero which means "no bonus available" for this card
            var bonusTimeLimit: TimeInterval = 6
            
            // how long this card has ever been face up
            private var faceUpTime: TimeInterval {
                if let lastFaceUpDate = self.lastFaceUpDate {
                    return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
                } else {
                    return pastFaceUpTime
                }
            }
            // the last time this card was turned face up (and is still face up)
            var lastFaceUpDate: Date?
            // the accumulated time this card has been face up in the past
            // (i.e. not including the current time it's been face up if it is currently so)
            var pastFaceUpTime: TimeInterval = 0
            
            // how much time left before the bonus opportunity runs out
            var bonusTimeRemaining: TimeInterval {
                max(0, bonusTimeLimit - faceUpTime)
            }
            // percentage of the bonus time remaining
            var bonusRemaining: Double {
                (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
            }
            // whether the card was matched during the bonus time period
            var hasEarnedBonus: Bool {
                isMatched && bonusTimeRemaining > 0
            }
            // whether we are currently face up, unmatched and have not yet used up the bonus window
            var isConsumingBonusTime: Bool {
                isFaceUp && !isMatched && bonusTimeRemaining > 0
            }
            
            // called when the card transitions to face up state
            private mutating func startUsingBonusTime() {
                if isConsumingBonusTime, lastFaceUpDate == nil {
                    lastFaceUpDate = Date()
                }
            }
            // called when the card goes back face down (or gets matched)
            private mutating func stopUsingBonusTime() {
                pastFaceUpTime = faceUpTime
                self.lastFaceUpDate = nil
            }
        }
}

struct Theme {
    let name: String
    let emojis: [String]
    var numberOfPairsOfCards: Int
    let cardColor: String // type of color?
}

extension Array {
    var oneAndOnly: Element? {
        if count == 1 {
            return first
        } else {
            return nil
        }
    }
}
    


