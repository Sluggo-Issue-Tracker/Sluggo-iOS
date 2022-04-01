//
//  TicketListView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 1/2/22.
//

import SwiftUI

struct TicketListView: View {
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    
    @State var ticketsList: [TicketRecord] = []
    var filterParams: TicketFilterParameters = TicketFilterParameters()
    
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
            .task {
                await handleTicketsList(page: 1)
            }
            .refreshable {
                await handleTicketsList(page: 1)
            }
        }
    }
    
    var searchedTickets: [TicketRecord] {
        if searchKey.isEmpty {
            return ticketsList
        } else {
            return ticketsList.filter { $0.title.contains(searchKey) }
        }
    }
    
    private func handleTicketsList(page: Int) async {
        let ticketManager = TicketManager(identity: self.identity)
        let ticketsResult = await ticketManager.listTeamTickets(page: page, queryParams: self.filterParams)
        switch ticketsResult {
            case .success(let tickets):
                // Need to also check for invalid saved team
                var ticketsListCopy = Array(self.ticketsList)
            
                for entry in tickets.results {
                    ticketsListCopy.append(entry)
                
                }
                ticketsList = ticketsListCopy
            case .failure(let error):
                print(error)
                alertContext.presentError(error: error)
        }
    }
}

struct TicketListView_Previews: PreviewProvider {
    static var previews: some View {
        TicketListView()
    }
}
