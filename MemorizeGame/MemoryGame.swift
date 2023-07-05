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
            let chosenTime = Date()
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
                cards[chosenIndex].chosenTime = chosenTime
                IndexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
            cards[chosenIndex].isFaceUp = true
            cards[chosenIndex].click += 1
        }
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
    
    struct Card: Identifiable {
        var isFaceUp = false
        var isMatched = false
        var isAlreadySeen = false
        var click:Int = 0
        let content: CardContent
        var chosenTime: Date?
        let id: Int
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
    


