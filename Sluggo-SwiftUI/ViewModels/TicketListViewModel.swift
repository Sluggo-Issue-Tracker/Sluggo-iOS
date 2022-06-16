//
//  TicketListViewModel.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 6/14/22.
//

import Foundation
import SwiftUI


extension TicketListView {
    
    @MainActor class ViewModel: ObservableObject {
        var identity: AppIdentity?
        var alertContext: AlertContext?
        @Published var ticketsList: [TicketRecord] = []
        @Published var filterParams: TicketFilterParameters = TicketFilterParameters()
        @Published var selectedFilters: Set<String> = Set<String>()
        @Published var showFilter: Bool = false
        @Published var searchKey = ""
        @Published var loadState = LoadState.loading
        @Published private var nextPageStr: String?
        
        var hasMore: Bool {
            return self.nextPageStr != nil
        }
        
        var nextPage: Int {
            guard let page = self.nextPageStr else {return 1 }
            let pageRange = NSRange(
                page.startIndex..<page.endIndex,
                in: page
            )

            // Create A NSRegularExpression
            let capturePattern = #"\?page=(\d+)?"#
            let captureRegex = try! NSRegularExpression(
                pattern: capturePattern,
                options: []
            )
            
            let matches = captureRegex.matches(
                in: page,
                options: [],
                range: pageRange
            )
            
            guard let match = matches.first else {
                // Handle exception
                return 1
            }
            
            var names: [String] = []

            // For each matched range, extract the capture group
            for rangeIndex in 0..<match.numberOfRanges {
                let matchRange = match.range(at: rangeIndex)
                
                // Ignore matching the entire username string
                if matchRange == pageRange { continue }
                
                // Extract the substring matching the capture group
                if let substringRange = Range(matchRange, in: page) {
                    let capture = String(page[substringRange])
                    names.append(capture)
                }
            }
            guard let num = names.last else {return 1}

            return Int(num) ?? 1
        }
        
        /// The current state of our ticket download
        enum LoadState {
            /// The download is currently in progress. This is the default.
            case loading
            
            /// The download has finished, and tickets can now be displayed.
            case success
            
            /// The download failed.
            case failed
        }
        
        var searchedTickets: [TicketRecord] {
            if searchKey.isEmpty {
                return self.ticketsList
            } else {
                return self.ticketsList.filter { $0.title.localizedCaseInsensitiveContains(searchKey) }
            }
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
        }
        
        func setup(identity: AppIdentity, alertContext: AlertContext) {
            self.identity = identity
            self.alertContext = alertContext
        }
    }
}
