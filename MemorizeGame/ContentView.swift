//
//  ContentView.swift
//  MemorizeGame
//
//  Created by JingweiWang on 7/2/23.
//

import SwiftUI

struct ContentView: View {
    // then something change, rebuild the entire body.
    @ObservedObject var viewModel: EmojiMemoryGame
    
    var body: some View {
        VStack {
            Text("score: \(viewModel.score)")
            ScrollView{
                title
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(viewModel.cards) {card in
                        CardView(card: card)
                            .aspectRatio(2.5/3, contentMode: .fill)
                            .onTapGesture {
                                viewModel.choose(card)
                            }
                            .padding(.all)
                        
                    }
                }
            }
        }
        .padding(.horizontal)
        .foregroundColor(viewModel.chosenColor)
        Button {
            viewModel.startNewGame()
        } label: {
            Text("New Game").font(.largeTitle)
        }
    }
    
    var title: some View {
        Text("Memorize \(viewModel.chosenTheme.name)!").font(.largeTitle).foregroundColor(.black)
    }
}





struct CardView: View {
    let card: MemoryGame<String>.Card
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
//        ContentView(viewModel: game)
//            .preferredColorScheme(.dark)
        ContentView(viewModel: game)
            .preferredColorScheme(.light)
    }
}
