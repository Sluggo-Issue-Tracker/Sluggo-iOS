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
            List {
                ForEach(searchedTickets, id: \.id) { ticket in
                    ZStack {
                        NavigationLink(destination: Text("HI")) {
                            EmptyView()
                        }
                        .opacity(0.0)
                        .buttonStyle(.plain)
                        TicketPill(ticket: ticket)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(.none)
                .listRowBackground(Color.clear)
                
            }
            .listStyle(.plain)
            .searchable(text: $searchKey)
            .navigationTitle("Tickets")
            .task {
                await handleTicketsList(page: 1)
            }
            .refreshable {
                await handleTicketsList(page: 1)
            }
        }
        .navigationViewStyle(.stack)
        .alert(context: alertContext)
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
                if !ticketsList.contains(entry) {
                    ticketsListCopy.append(entry)
                }
                
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
