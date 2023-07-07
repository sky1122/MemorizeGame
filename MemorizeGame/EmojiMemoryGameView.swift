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
            title
            Text("score: \(game.score)")
            // create a view and let them fit in the screen without scrolldown
            AspectVGrid(items: game.cards, aspectRatio: 2/3, content: { card in
                cardView(for: card)
            })
            
            .padding(.horizontal)
            .foregroundColor(game.chosenColor)
            Button {
                game.startNewGame()
            } label: {
                Text("New Game").font(.largeTitle)
            }
        }
    }
    
    var title: some View {
        Text("Memorize \(game.chosenTheme.name)!").font(.largeTitle).foregroundColor(.black)
    }
    
    @ViewBuilder
    private func cardView(for card: EmojiMemoryGame.Card) -> some View {
        if card.isMatched && !card.isFaceUp {
            Rectangle().opacity(0)
        } else {
            CardView(card)
                .padding(4)
                .onTapGesture {
                    game.choose(card)
                }
        }
    }
}



struct CardView: View {
    private let card: MemoryGame<String>.Card
    
    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack {
                    Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: 110-90))
                    .padding(5).opacity(0.5)
                    Text(card.content).font(font(in: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        })
    }
    
    private func font(in size:CGSize) -> Font {
        Font.system(size:min(size.width, size.height) * DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 15
        static let lineWidth: CGFloat = 3
        static let fontScale: CGFloat = 0.6
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
