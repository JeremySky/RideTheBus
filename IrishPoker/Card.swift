//
//  Card.swift
//  IrishPoker
//
//  Created by Jeremy Manlangit on 11/11/23.
//

import SwiftUI

//MARK: -- CARD
struct Card: View {
    typealias Action = () -> Void
    
    let value: PlayingCard
    @Binding var tappable: Bool
    
    
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
//    @State var backDegree = 90.0
//    @State var frontDegree = 0.0
    @State var isFlipped = false
    
    
    var disableButtonsAction: Action
    
    
    
    var width: CGFloat = 300
    var height: CGFloat = 470
    var cornerRadius: CGFloat = 16
    let durationAndDelay: CGFloat = 0.3
    
    //MARK: -- FLIP FUNCTION
    func flipCard() {
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90.0
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                frontDegree = 0.0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)) {
                backDegree = 0.0
            }
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90.0
            }
        }
    }
    
    
    //MARK: -- body
    var body: some View {
        ZStack {
            CardFront(card: value, width: width, degree: $frontDegree)
            CardBack(width: width, degree: $backDegree)
        }
        .onTapGesture {
            if tappable {
                flipCard()
                tappable = false
                disableButtonsAction()
            }
        }
    }
}




//MARK: -- FRONT
struct CardFront: View {
    let card: PlayingCard
    
    var width: CGFloat = 320
    var height: CGFloat = 470
    var fontSize: CGFloat = 50
    var iconSize: CGFloat = 45
    var cornerRadius: CGFloat = 15
    var padding: CGFloat = 16
    
    @Binding var degree: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(Color.white)
                .frame(width: width, height: height)
                .shadow(radius: 10)
            Group {
                ZStack {
                    HStack {
                        VStack {
                            Text(card.value.string)
                                .font(.system(size: fontSize))
                                .fontWeight(.semibold)
                            Image(systemName: card.suit.icon)
                                .font(.system(size: iconSize))
                            Spacer()
                        }
                        .frame(height: height)
                        .padding(.leading, padding)
                        
                        Spacer()
                        
                        VStack {
                            Text(card.value.string)
                                .font(.system(size: fontSize))
                                .fontWeight(.semibold)
                            Image(systemName: card.suit.icon)
                                .font(.system(size: iconSize))
                            Spacer()
                        }
                        .frame(height: height)
                        .padding(.leading, padding)
                        .rotationEffect(.degrees(180))
                    }
                    .frame(width: width, height: height)
                    
                    CardBody(card: card)
                }
            }
            .foregroundColor(card.color)
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0.0, y: 1.0, z: 0.0) )
    }
}




//MARK: -- BODY
struct CardBody: View {
    let card: PlayingCard
    var bodyWidth: CGFloat = 150
    var bodyHeight: CGFloat = 290
    var bodyIconSize: CGFloat = 37
    var bodyBorderWidth: CGFloat = 3
    var bodyCrownSize: CGFloat = 82
    var bodyLargeIconSize: CGFloat = 140
    var bodyLargeLetterSize: CGFloat = 82
    var padding: CGFloat = 16
    
    var body: some View {
        Group {
            switch card.value {
            case .two, .three, .four, .five, .six, .seven, .eight, .nine, .ten:
                HStack {
                    if card.value != .two && card.value != .three {
                        VStack {
                            Image(systemName: card.suit.icon)
                            Spacer()
                            Image(systemName: card.suit.icon)
                                .foregroundColor(card.value == .four || card.value == .five ? Color.clear : card.color)
                            Spacer()
                            Image(systemName: card.suit.icon)
                            if card.value == .nine || card.value == .ten {
                                Spacer()
                                Image(systemName: card.suit.icon)
                            }
                        }
                    }
                    Spacer()
                    
                    if card.value != .four && card.value != .six {
                        if card.isCentered {
                            VStack {
                                Image(systemName: card.suit.icon)
                                    .foregroundColor(card.value == .five || card.value == .nine ? Color.clear : card.color)
                                Spacer()
                                Image(systemName: card.suit.icon)
                                    .foregroundColor(card.value == .two ? Color.clear : card.color)
                                Spacer()
                                Image(systemName: card.suit.icon)
                                    .foregroundColor(card.value == .five || card.value == .nine ? Color.clear : card.color)
                            }
                        } else {
                            VStack {
                                Spacer()
                                Image(systemName: card.suit.icon)
                                Spacer()
                                Image(systemName: card.suit.icon)
                                    .foregroundStyle(card.value == .seven ? Color.clear : card.color)
                                Spacer()
                            }
                        }
                    }
                    
                    
                    Spacer()
                    if card.value != .two && card.value != .three {
                        VStack {
                            Image(systemName: card.suit.icon)
                            Spacer()
                            Image(systemName: card.suit.icon)
                                .foregroundColor(card.value == .four || card.value == .five ? Color.clear : card.color)
                            Spacer()
                            Image(systemName: card.suit.icon)
                            if card.value == .nine || card.value == .ten {
                                Spacer()
                                Image(systemName: card.suit.icon)
                            }
                        }
                    }
                }
                .font(.system(size: bodyIconSize))
                
                
            case .jack, .queen, .king:
                VStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: bodyCrownSize))
                    ZStack {
                        Image(systemName: card.suit.icon)
                            .font(.system(size: bodyLargeIconSize))
                        Text(card.value.string)
                            .foregroundStyle(Color.white)
                            .font(.system(size: bodyLargeLetterSize))
                            .fontWeight(.semibold)
                    }
                }
                
            case .ace:
                ZStack {
                    Image(systemName: card.suit.icon)
                        .font(.system(size: bodyLargeIconSize))
                    Text(card.value.string)
                        .foregroundStyle(Color.white)
                        .font(.system(size: bodyLargeLetterSize))
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundColor(card.color)
        .padding(.all, padding)
        .frame(width: bodyWidth, height: bodyHeight)
        .border(Color.blue.opacity(0.3), width: bodyBorderWidth)
    }
}




//MARK: -- BACK
struct CardBack: View {
    var width: CGFloat = 320
    var height: CGFloat = 470
    var cornerRadius: CGFloat = 16
    var bodyWidth: CGFloat = 275
    var bodyHeight: CGFloat = 425
    var bodyCornerRadius: CGFloat = 10
    @Binding var degree: Double
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundStyle(Color.white)
                .frame(width: width, height: height)
                .shadow(radius: 10)
            RoundedRectangle(cornerRadius: bodyCornerRadius)
                .foregroundStyle(Color.red)
                .frame(width: bodyWidth, height: bodyHeight)
            RoundedRectangle(cornerRadius: bodyCornerRadius)
                .foregroundStyle(Color.black.opacity(0.5))
                .frame(width: bodyWidth, height: bodyHeight)
            Image("card.back")
                .resizable()
//                .opacity(0.8)
                .clipShape(RoundedRectangle(cornerRadius: bodyCornerRadius - 5))
                .frame(width: bodyWidth * 0.95, height: bodyHeight * 0.96)
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0.0, y: 1.0, z: 0.0) )
    }
}





//MARK: -- PREVIEWS
#Preview {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()
        Card(value: PlayingCard(value: .ten, suit: .diamonds), tappable: .constant(true), disableButtonsAction: {return})
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()
        CardFront(card: PlayingCard(value: .two, suit: .hearts), degree: .constant(0))
    }
}

//#Preview {
//    CardBody(card: PlayingCard(value: .nine, suit: .hearts))
//}

#Preview {
    ZStack {
        Color.gray.opacity(0.4).ignoresSafeArea()
        CardBack(degree: .constant(0))
    }
}
