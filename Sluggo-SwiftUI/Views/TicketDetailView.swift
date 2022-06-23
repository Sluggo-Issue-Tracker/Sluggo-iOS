//
//  TicketDetailView.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 6/20/22.
//

import Foundation
import SwiftUI

struct TicketDetail: View {
    
    @State var ticket: TicketRecord
    @State var showModalView = false
    
    var body: some View {

        List {
            Section(header: Text("Title")) {
                TextField("Required", text: $ticket.title)
            }
            Section(header: Text("Assigned User")) {
                Text("\(ticket.assignedUser?.getTitle() ?? "")")
            }
            Section(header: Text("Status")) {
                Text("\(ticket.status?.getTitle() ?? "")")
            }
            Section(header: Text("Tags")) {
                if(ticket.tagList.isEmpty) {
                    Text("")
                }
                else {
                    ForEach(ticket.tagList) { tag in
                        Text(tag.title)
                    }
                }
            }
            Section(header: Text("Date Due")) {
                if(ticket.dueDate == nil) {
                    Text("")
                }
                else {
                    Text(ticket.dueDate ?? Date(), style: .date)
                }
            }
            Section(header: Text("Description")) {
                VStack(spacing: 0) {
                    Spacer()
                    Text("\(ticket.description ?? "")")
                        .frame(minHeight: 100, alignment: .topLeading)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit"){
            self.showModalView.toggle()
        })
        .fullScreenCover(isPresented: $showModalView) {
            TicketEditDetail(ticket: $ticket, tempTicket: ticket, showModalView: self.$showModalView)
                .transition(.opacity) //Doesn't work
        }
        
    }
}

struct TicketEditDetail: View {
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    
    @Binding var ticket: TicketRecord
    @State var tempTicket: TicketRecord?
    @Binding var showModalView: Bool

    @State private var ticketTitle: String = ""
    @State private var ticketUser: MemberRecord?
    @State private var ticketStatus: StatusRecord?
    @State private var ticketTags: [TagRecord] = []
    @State private var ticketDueDate: Date?
    @State private var ticketDescription: String?

    @State private var teamMembers: [MemberRecord] = []
    @State private var ticketStatuses: [StatusRecord] = []
    @State private var ticketAllTags: [TagRecord] = []
    
//    init(ticket: Binding<TicketRecord>, ticketTemp: TicketRecord, showModalView: Binding<Bool>) {
//        self._ticket = ticket
//        self._showModalView = showModalView
//
//
//        self.ticketTemp = TicketRecord(id: self.ticket.id,
//                             ticketNumber: self.ticket.ticketNumber,
//                                  tagList: self.ticket.tagList,
//                               objectUuid: self.ticket.objectUuid,
//                             assignedUser: self.ticket.assignedUser,
//                                   status: self.ticket.status,
//                                    title: self.ticket.title,
//                              description: self.ticket.description,
//                                  dueDate: self.ticket.dueDate,
//                                  created: self.ticket.created,
//                                activated: self.ticket.activated,
//                              deactivated: self.ticket.deactivated)
//
//        self.ticketTemp = self.ticket
//
//        self.ticketTitle = self.ticket.title
//        self.ticketUser = self.ticket.assignedUser
//        self.ticketStatus = self.ticket.status
//        self.ticketTags = self.ticket.tagList
//        self.ticketDueDate = self.ticket.dueDate
//        self.ticketDescription = self.ticket.description
//
//    }
//
//    init(ticket: Binding<TicketRecord>, showModalView: Binding<Bool>) {
//        let tempTicket = ticket
//
//        self.init(ticket: ticket, ticketTemp: tempTicket, showModalView: showModalView)
//
//    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Title")) {
                    TextField("Required", text: $ticketTitle)
                }
                Section(header: Text("Assigned User")) {
                    Picker("\(ticketUser?.getTitle() ?? "")", selection: $ticketUser, content: {
                        ForEach(teamMembers) { member in
                            Text(member.owner.username)
                        }
                    })
                }
                Section(header: Text("Status")) {
                    Text("\(ticketStatus?.getTitle() ?? "")")
                }
                Section(header: Text("Tags")) {
                    if(ticketTags.isEmpty) {
                        Text("")
                    }
                    else {
                        ForEach(ticketTags) { tag in
                            Text(tag.title)
                        }
                    }
                }
                Section(header: Text("Date Due")) {
                    if(ticket.dueDate == nil) {
                        Text("")
                    }
                    else {
                        Text(ticket.dueDate ?? Date(), style: .date)
                    }
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $ticketDescription ?? "")
                        .frame(minHeight: 100, alignment: .topLeading)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.showModalView.toggle()
                    
                }, trailing: Button("Done") {
                    self.updateTicket()
                    self.showModalView.toggle()
                }
                )
            .task(doLoad)
        }
    }
    
    private func updateTicket() {
        
        // Update locally
        
        Task.init(priority: .userInitiated) {
            await self.doUpdate()
        }
        
    }
    
    @Sendable func doUpdate() async {
        let ticketManager = TicketManager(identity: self.identity)

        let ticketResult = await ticketManager.updateTicket(ticket: ticket)

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
