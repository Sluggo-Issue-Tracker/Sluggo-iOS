//
//  TicketListViewModel.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 6/14/22.
//

import Foundation
import SwiftUI


extension TicketListView {
    
    class ViewModel: LoadableObject {
        
        @Published private(set) var loadState = LoadState.loading
        
        var identity: AppIdentity?
        var alertContext: AlertContext?
        private var ticketsList: [TicketRecord] = []
        @Published var searchedTickets: [TicketRecord] = []
        @Published var filterParams: TicketFilterParameters = TicketFilterParameters()
        @Published var selectedFilters: Set<String> = Set<String>()
        @Published var showFilter: Bool = false
        @Published var searchKey = ""
        @Published var showMessage = true
        @Published private var nextPageStr: String?
        
        var hasMore: Bool {
            return self.nextPageStr != nil
        }
        
        var nextPage: Int {
            guard let page = self.nextPageStr else {return 1 }
            
            // Create A Regular Expresion from 5.7
            let capturePattern = /[\?&]page=(?<page>\d+)/
            guard let match = try? capturePattern.firstMatch(in: page) else {
                return 1
            }
            let num = match.page
            return Int(num) ?? 1
        }
        
        @MainActor func load() async {
            await self.handleTicketsList(page: 1)
        }
        
        @MainActor func handleTicketsList(page: Int) async {
            
            let ticketManager = TicketManager(identity: self.identity!)
            let ticketsResult = await ticketManager.listTeamTickets(page: page, queryParams: self.filterParams)
            switch ticketsResult {
            case .success(let tickets):
                // Need to also check for invalid saved team
                self.nextPageStr = tickets.next
                self.updateTickets(newTickets: tickets, page: page)
                self.loadState = .success
            case .failure(let error):
                print(error)
                var message: String = ""
                self.alertContext?.presentError(error: error)
                if let exceptionError = error as? Exception {
                    switch exceptionError {
                    case .runtimeError(let errMsg):
                        message = errMsg
                    }
                }
                if message != "cancelled" {
                    self.loadState = .failed
                }
            }
        }
        
        @MainActor private func updateTickets(newTickets: PaginatedList<TicketRecord>, page: Int) {
            var ticketsCopy = Array(self.ticketsList)
            let pageOffset = (page - 1) * self.identity!.pageSize
            if pageOffset < self.ticketsList.count {
                ticketsCopy.removeSubrange(pageOffset...self.ticketsList.count-1)
            }
            
            for entry in newTickets.results {
                ticketsCopy.append(entry)
            }
            self.ticketsList = ticketsCopy
            self.searchedTickets = self.ticketsList
        }
        
        func setup(identity: AppIdentity, alertContext: AlertContext) {
            self.identity = identity
            self.alertContext = alertContext
        }
        
        
        func onFilter() {
            if self.filterParams.didChange {
                self.loadState = .loading
                self.showMessage = true
                Task {
                    try await Task.sleep(nanoseconds: 500_000_000)
                    await self.handleTicketsList(page: 1)
                }
                self.filterParams.didChange = false
            }
        }
        
        func setDismissTimer() {
            let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                withAnimation(.easeInOut(duration: 2)) {
                    self.showMessage = false
                }
                timer.invalidate()
            }
            RunLoop.current.add(timer, forMode:RunLoop.Mode.default)
        }
        
        func updateSearch(searchKey: String) -> Void {
            if searchKey.isEmpty {
                self.searchedTickets = self.ticketsList
            } else {
                self.searchedTickets = self.ticketsList.filter { $0.title.localizedCaseInsensitiveContains(searchKey) }
            }
        }
    }
}
