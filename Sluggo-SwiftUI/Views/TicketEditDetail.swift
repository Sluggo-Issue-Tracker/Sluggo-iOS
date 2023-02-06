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
    @State private var ticketDueDate: Date?
    @State private var ticketDescription: String?

    @State private var teamMembers: [MemberRecord] = []
    @State private var ticketStatuses: [StatusRecord] = []
    @State private var ticketAllTags: [TagRecord] = []
    
    init(ticket: Binding<TicketRecord>, showView: Binding<Bool>) {
        
        self._ticket = ticket
        self._showView = showView

        self._ticketTitle = State(initialValue: self.ticket.title)
        self._ticketUser = State(initialValue: self.ticket.assignedUser)
        self._ticketStatus = State(initialValue: self.ticket.status)
        self._ticketTags = State(initialValue: self.ticket.tagList)
        self._ticketDueDate = State(initialValue: self.ticket.dueDate)
        self._ticketDescription = State(initialValue: self.ticket.description)

    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Title")) {
                    TextField("Required", text: $ticketTitle)
                }
                Section(header: Text("Assigned User")) {
                    Picker("Assigned User", selection: $ticketUser) {
                        Text("None").tag(nil as MemberRecord?)
                        ForEach(teamMembers, id: \.self) { member in
                            Text(member.owner.username).tag(member as MemberRecord?)
                        }
                            
                    }
                    .pickerStyle(.menu)
                }
                Section(header: Text("Status")) {
                    Text("\(ticketStatus?.getTitle() ?? "")")
                }
                Section(header: Text("Tags")) {
                    if(self.ticketTags.isEmpty) {
                        Text("")
                    }
                    else {
                        ForEach(ticketTags) { tag in
                            Text(tag.title)
                        }
                    }
                }
                Section(header: Text("Date Due")) {
                    Text(ticketDueDate ?? Date(), style: .date)
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $ticketDescription ?? "")
                        .frame(minHeight: 100, alignment: .topLeading)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.showView.toggle()
                    
                }, trailing: Button("Done") {
                    Task.init(priority: .userInitiated) {
                        await self.doUpdate()
                    }
                    self.showView.toggle()
                }
                )
            .task(doLoad)
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
                             description: self.ticketDescription,
                                 dueDate: self.ticketDueDate,
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

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
