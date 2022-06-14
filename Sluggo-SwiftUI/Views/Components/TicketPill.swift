//
//  TicketPill.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 1/2/22.
//

import SwiftUI

extension Color {
    public init?(hex: String?) {
        let r, g, b, a: CGFloat
        guard let hexVal = hex else {
            return nil
        }
        if hexVal.hasPrefix("#") {
            let start = hexVal.index(hexVal.startIndex, offsetBy: 1)
            let hexColor = String(hexVal[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, opacity: a)
                    return
                }
            }
        }

        return nil
    }
}

struct TicketPill: View {
    @State var ticket: TicketRecord
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text("\(ticket.ticketNumber) | \(ticket.title)")
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                Text("\(ticket.assignedUser?.getTitle() ?? "")")
                    .font(.subheadline)
                    .foregroundColor(Color.white)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color.white)
        }
        .padding()
        .background(Color(hex: ticket.status?.color) ?? Color(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)))
        .cornerRadius(5)
    }

}

