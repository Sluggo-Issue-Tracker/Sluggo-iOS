//
//  TicketListViewModel.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 6/14/22.
//

import Foundation
import SwiftUI


extension TicketListView {
    
    class ViewModel: ObservableObject {
        var identity: AppIdentity?
        var alertContext: AlertContext?
        @Published var ticketsList: [TicketRecord] = []
        @Published var filterParams: TicketFilterParameters = TicketFilterParameters()
        @Published var selectedFilters: Set<String> = Set<String>()
        @Published var showFilter: Bool = false
        @Published var searchKey = ""
        
        var searchedTickets: [TicketRecord] {
            if searchKey.isEmpty {
                return self.ticketsList
            } else {
                return self.ticketsList.filter { $0.title.contains(searchKey) }
            }
        }
        
        func handleTicketsList(page: Int) async {
            let ticketManager = TicketManager(identity: self.identity!)
            let ticketsResult = await ticketManager.listTeamTickets(page: page, queryParams: self.filterParams)
            switch ticketsResult {
            case .success(let tickets):
                // Need to also check for invalid saved team
                await MainActor.run {
                    self.updateTickets(newTickets: tickets)
                }
            case .failure(let error):
                print(error)
                alertContext?.presentError(error: error)
            }
        }
        
        private func updateTickets(newTickets: PaginatedList<TicketRecord>) {
            var ticketsListCopy = Array(self.ticketsList)
            
            for entry in newTickets.results {
                if !self.ticketsList.contains(entry) {
                    ticketsListCopy.append(entry)
                }
                
            }
            self.ticketsList = ticketsListCopy
        }
        
        func setup(identity: AppIdentity, alertContext: AlertContext) {
            self.identity = identity
            self.alertContext = alertContext
        }
    }
}
