//
//  EmojiMemoryGameView.swift
//  MemorizeGame
//
//  Created by JingweiWang on 7/2/23.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    // then something change, rebuild the entire body.
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        VStack {
            Text("score: \(game.score)")
            ScrollView{
                title
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(game.cards) {card in
                        CardView(card)
                            .aspectRatio(2.5/3, contentMode: .fill)
                            .onTapGesture {
                                game.choose(card)
                            }
                            .padding(.all)
                        
                    }
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(game.chosenColor)
        Button {
            game.startNewGame()
        } label: {
            Text("New Game").font(.largeTitle)
        }
    }
    
    var title: some View {
        Text("Memorize \(game.chosenTheme.name)!").font(.largeTitle).foregroundColor(.black)
    }
}





struct CardView: View {
    private let card: MemoryGame<String>.Card
    
    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 20)
            if card.isFaceUp {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: 1)
                Text(card.content).font(.largeTitle)
            } else if card.isMatched {
                shape.opacity(0)
            } else {
                shape.fill()
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
//        EmojiMemoryGameView(viewModel: game)
//            .preferredColorScheme(.dark)
        EmojiMemoryGameView(game: game)
            .preferredColorScheme(.light)
    }
}
