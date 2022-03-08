//
//  TicketListView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 1/2/22.
//

import SwiftUI

struct TicketListView: View {
    
    let tickets: [TicketRecord] = [
        TicketRecord(id: 1, ticketNumber: 1, tagList: [], objectUuid: UUID(), title: "Fix The Robot", description: "This is a robot", created: Date()),
        TicketRecord(id: 2, ticketNumber: 2, tagList: [], objectUuid: UUID(), title: "Develop Network Protocol", description: "This is a robot", created: Date()),
        TicketRecord(id: 3, ticketNumber: 3, tagList: [], objectUuid: UUID(), title: "Update Firmware", description: "This is a robot", created: Date()),
        TicketRecord(id: 4, ticketNumber: 4, tagList: [], objectUuid: UUID(), title: "Update The API", description: "This is a robot", created: Date()),
        TicketRecord(id: 5, ticketNumber: 5, tagList: [], objectUuid: UUID(), title: "Rewrite the API Code", description: "This is a robot", created: Date())
        
    ]
    @State private var searchKey = ""
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(searchedTickets, id: \.id) { ticket in
                        NavigationLink(destination: Text("HI")) {
                            TicketPill(ticket: ticket)
                                .padding(.horizontal, 5)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .searchable(text: $searchKey)
            .navigationTitle("Tickets")
        }
    }
    
    var searchedTickets: [TicketRecord] {
        if searchKey.isEmpty {
            return tickets
        } else {
            return tickets.filter { $0.title.contains(searchKey) }
        }
    }
}

struct TicketListView_Previews: PreviewProvider {
    static var previews: some View {
        TicketListView()
    }
}
