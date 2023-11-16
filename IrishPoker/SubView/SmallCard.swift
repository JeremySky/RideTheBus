//
//  SmallCard.swift
//  IrishPoker
//
//  Created by Jeremy Manlangit on 11/14/23.
//

import SwiftUI


struct SmallCard: View {
    let card: Card
    let playerColor: Color
    let startFaceUp: Bool
    let hide: Bool
    
    var body: some View {
        if hide {
            MiniCardHide(color: playerColor)
        } else {
            CardViewHelper(startFaceUp: startFaceUp) {
                MiniCardFront(card: card, playerColor: playerColor)
            } backView: {
                MiniCardBack(playerColor: playerColor)
            }
        }
    }
}

struct MiniCardFront: View {
    let card: Card
    let playerColor: Color
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 65, height: 70)
                    .foregroundStyle(.white)
                    .shadow(color: playerColor == .black ? .white.opacity(0.5) : .black.opacity(0.75), radius: 5)
                Image(systemName: card.suit.icon)
                    .resizable()
                    .padding(.all, 5)
                    .frame(width: 63, height: 63)
                    .foregroundStyle(card.color)
                Text(card.value.string)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
            }
        }
    }
}

struct MiniCardBack: View {
    let playerColor: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 65, height: 70)
                .foregroundStyle(.white)
                .shadow(color: playerColor == .black ? .white.opacity(0.5) : .black.opacity(0.75), radius: 5)
            Image("card.back")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}

struct MiniCardHide: View {
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(style: StrokeStyle(lineWidth: 5, dash: [10]))
            .frame(width: 65, height: 70)
    }
}

#Preview {
    SmallCard(card: Card.test1, playerColor: Player.test1.color, startFaceUp: true, hide: false)
}

#Preview {
    SmallCard(card: Card.test1, playerColor: Player.test1.color, startFaceUp: false, hide: false)
}
#Preview {
    SmallCard(card: Card.test1, playerColor: Player.test1.color, startFaceUp: true, hide: true)
}
