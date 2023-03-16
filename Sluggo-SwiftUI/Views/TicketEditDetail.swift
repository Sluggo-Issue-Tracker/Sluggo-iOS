//
//  TicketEditDetail.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 2/4/23.
//

import Foundation
import SwiftUI

struct TicketEditDetail: View {
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    
    @Binding var ticket: TicketRecord
    @Binding var showView: Bool

    @State private var ticketTitle: String = ""
    @State private var ticketUser: MemberRecord?
    @State private var ticketStatus: StatusRecord?
    @State private var ticketTags: [TagRecord] = []
    @State private var ticketDueDate = Date()
    @State private var dateToggle = false
    @State private var ticketDescription: String = ""

    @State private var teamMembers: [MemberRecord] = []
    @State private var ticketStatuses: [StatusRecord] = []
    @State private var ticketAllTags: [TagRecord] = []
    
    @State private var showAlert = false
    
    init(ticket: Binding<TicketRecord>, showView: Binding<Bool>) {
        
        self._ticket = ticket
        self._showView = showView

        self._ticketTitle = State(initialValue: self.ticket.title)
        self._ticketUser = State(initialValue: self.ticket.assignedUser)
        self._ticketStatus = State(initialValue: self.ticket.status)
        self._ticketTags = State(initialValue: self.ticket.tagList)
        self._dateToggle = State(initialValue: {self.ticket.dueDate != nil}())
        self._ticketDueDate = State(initialValue: {self.ticket.dueDate ?? Date()}())
        self._ticketDescription = State(initialValue: {self.ticket.description ?? ""}())

    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title (Required)", text: $ticketTitle)
                }
                Section {
                    ExtendedPicker(title: "Assigned User", items: $teamMembers, selected: $ticketUser)
                }
                Section {
                    ExtendedPicker(title: "Statuses", items: $ticketStatuses, selected: $ticketStatus)
                }
                Section {
                    ZStack{
                        HStack {
                            NilContext(item: ticketTags) {
                                Text((ticketTags.map({$0.getTitle()})).joined(separator: ", "))
                            } nilContent: {
                                Text("Tags")
                            }
                            .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Image(systemName: "plus.square")
                                .foregroundColor(.blue)
                            }
                        NavigationLink("Tags") {
                            MultiSelectionList(items: $ticketAllTags, selected: $ticketTags)
                                .navigationBarTitle("Tags")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .opacity(0)
                    }
                }
                Section {
                    Toggle("Due Date", isOn: $dateToggle.animation())
                    if dateToggle {
                        DatePicker("Date", selection: $ticketDueDate).labelsHidden()
                        // Toggle throwing strange warning
                    }
                }
                Section() {
                    TextField("Description", text: $ticketDescription, axis: .vertical)
                        .frame(minHeight: 100, alignment: .topLeading)
                }
            }
            .navigationBarTitle("Edit Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.showView.toggle()
                    
                }, trailing: Button("Done") {
                    if ticketTitle.isEmpty {
                        showAlert = true
                    } else {
                        Task.init(priority: .userInitiated) {
                            await self.doUpdate()
                        }
                        self.showView.toggle()
                    }
                })
            .task(doLoad)
            .alert("Title Required", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert(context: alertContext)
        }
    }
    
    @Sendable func doUpdate() async {
        let ticketManager = TicketManager(identity: self.identity)
        
        let tempTicket = TicketRecord(id: self.ticket.id,
                            ticketNumber: self.ticket.ticketNumber,
                                 tagList: self.ticketTags,
                              objectUuid: self.ticket.objectUuid,
                            assignedUser: self.ticketUser,
                                  status: self.ticketStatus,
                                   title: self.ticketTitle,
                             description: { self.ticketDescription.isEmpty ? nil : self.ticketDescription}(),
                                 dueDate: { dateToggle ? self.ticketDueDate : nil }(),
                                 created: self.ticket.created,
                               activated: self.ticket.activated,
                             deactivated: self.ticket.deactivated)

        let ticketResult = await ticketManager.updateTicket(ticket: tempTicket)

        switch ticketResult {
            case .success(let ticket):
                self.ticket = ticket
            case .failure(let error):
                print(error)
                self.alertContext.presentError(error: error)
        }
    }
    
    @Sendable func doLoad() async {
        
        let memberManager = MemberManager(identity: self.identity)
        let statusManager = StatusManager(identity: self.identity)
        let tagManager = TagManager(identity: self.identity)
        
        unwindPagination(manager: memberManager,
                         startingPage: 1,
                         onSuccess: { members in
            self.teamMembers = members
        },
                         onFailure:  nil,
                         after: nil)
        
        let tagsResult = await tagManager.listFromTeams()
        switch tagsResult {
        case .success(let tags):
            self.ticketAllTags = tags
        case .failure(let error):
            print(error)
            self.alertContext.presentError(error: error)
        }
        
        let statusResult = await statusManager.listFromTeams()
        switch statusResult {
        case .success(let statuses):
            self.ticketStatuses = statuses
        case .failure(let error):
            print(error)
            self.alertContext.presentError(error: error)
        }
    }
}
