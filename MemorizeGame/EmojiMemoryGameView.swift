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
    @State private var dealt = Set<Int>()
    @State private var cardID = UUID()
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndeal(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    var body: some View {
        VStack {
            title
            Text("score: \(game.score)")
            // create a view and let them fit in the screen without scrolldown
            AspectVGrid(items: game.cards, aspectRatio: 2/3, content: { card in
                cardView(for: card)
                .id(cardID)
            })
            .onAppear {
                // "deal" cards
                withAnimation{
                    for card in game.cards {
                        deal(card)
                    }
                }
            }
            
            .padding(.horizontal)
            .foregroundColor(game.chosenColor)
            HStack{
                newGame
                Spacer()
                shuffle
            }
        }
    }
    
    var title: some View {
        Text("Memorize \(game.chosenTheme.name)!").font(.largeTitle).foregroundColor(.black)
    }
    var newGame: some View {
        Button("New Game") {
            dealt = Set<Int>()
            cardID = UUID()
            game.startNewGame()
            print(game.cards)
            withAnimation{
                for card in game.cards {
                    deal(card)
                }
            }
            
        }.font(.largeTitle).foregroundColor(.gray).padding(10)
    }

    
    var shuffle: some View {
        Button("Shuffle") {
            // use implecte anamation for intent functions
            withAnimation{
                game.shuffle()
            }
        }.font(.largeTitle).padding(10)
    }
    
    @ViewBuilder
    private func cardView(for card: EmojiMemoryGame.Card) -> some View {
        if isUndeal(card) || (card.isMatched && !card.isFaceUp) {
            Color.clear
        } else {
            CardView(card)
                .padding(4)
                .transition(AnyTransition.asymmetric(insertion: .scale, removal: .opacity).animation(.easeInOut(duration: 1)))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 1)){
                        game.choose(card)
                    }
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
                
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false))
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
//            .id(UUID())
        })
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.6
        static let fontSize: CGFloat = 32
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
