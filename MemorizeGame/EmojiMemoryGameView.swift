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
    @State private var dealt = Set<UUID>()
    @State private var themeID = UUID()
    @Namespace private var dealingNamespace
    
    private func deal(_ card: EmojiMemoryGame.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: EmojiMemoryGame.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func dealAnimation(for card: EmojiMemoryGame.Card) -> Animation{
        var delay = 0.0
        if let index = game.cards.firstIndex(where: { $0.id == card.id}) {
            delay = Double(index) * (CardConstants.totalDuration / Double(game.cards.count))
        }
        return Animation.easeInOut(duration: CardConstants.dealDuration).delay(delay)
    }
    
    private func zIndex(of card: EmojiMemoryGame.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var body: some View {
        ZStack(alignment: .centerLastTextBaseline) {
            VStack {
                title
                Text("score: \(game.score)")
                gameBody
                
                HStack{
                    newGame
                    Spacer()
                    shuffle
                }
            }
            deckBody
        }
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: CardConstants.aspectRatio) { card in
            if isUndealt(card) || (card.isMatched && !card.isFaceUp) {
                Color.clear
            } else {
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
//                                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
                    
            }
        }
        .foregroundColor(game.chosenColor)
    }
    
    private struct CardConstants {
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDuration: Double = 2
        static let undealHeight: CGFloat = 90
        static let undealWidth: CGFloat = undealHeight * aspectRatio
    }
    
    var deckBody: some View {
        ZStack {
            
            ForEach(game.cards.filter(isUndealt)) { card in
                
                CardView(card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .identity))
                    .zIndex(zIndex(of: card))
                    .id(themeID)
            }
        }
        .frame(width: CardConstants.undealWidth, height: CardConstants.undealHeight)
        .foregroundColor(game.chosenColor)
        .onTapGesture {
            for card in game.cards {
                withAnimation(dealAnimation(for: card)) {
                    deal(card)
                }
            }
        }
    }
    
    var title: some View {
        Text("Memorize \(game.chosenTheme.name)!").font(.largeTitle).foregroundColor(.black)
    }
    
    var newGame: some View {
        
        Button("New Game") {
            UIView.performWithoutAnimation {
//                isAnimating = false
                
                dealt = []
                game.startNewGame()
            }

        }.font(.largeTitle).foregroundColor(.gray).padding(10)
    }

    var shuffle: some View {
        Button("Shuffle") {
            withAnimation{
                game.shuffle()
            }
        }.font(.largeTitle).padding(10)
    }
    
}







struct CardView: View {
    private let card: MemoryGame<String>.Card
    @State private var animatedBonusRemaining: Double = 0
    @State private var isAnimating = false
    
    init(_ card: EmojiMemoryGame.Card) {
        self.card = card
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                    }
                }
                    .padding(5)
                    .opacity(0.5)
                Text(card.content)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                    .padding(5)
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
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
