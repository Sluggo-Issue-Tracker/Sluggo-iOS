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
            TicketEditDetail(ticket: ticket, showModalView: self.$showModalView)
                .transition(.opacity) //Doesn't work
        }
        
    }
}

struct TicketEditDetail: View {
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    
    @State var ticket: TicketRecord
    @Binding var showModalView: Bool

    @State var ticketTitle: String = ""
    @State var ticketUser: MemberRecord?
    @State var ticketStatus: StatusRecord?
    @State var ticketTags: [TagRecord] = []
    @State var ticketDueDate: Date?
    @State var ticketDescription: String?

    @State var teamMembers: [MemberRecord] = []
    @State var ticketStatuses: [StatusRecord] = []
    @State var ticketAllTags: [TagRecord] = []
    
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
                    
                })
            .task(doLoad)
        }
    }
    
    @Sendable func doLoad() async{
//        let ticketManager = TicketManager(identity: self.identity)
//
//        let ticketResult = await ticketManager.updateTicket(ticket: ticket)
//
//        switch ticketResult {
//            case .success(let ticket):
//                self.ticket = ticket
//            case .failure(let error):
//                print(error)
//                self.alertContext.presentError(error: error)
//        }
        
        self.ticketTitle = ticket.title
        self.ticketUser = ticket.assignedUser
        self.ticketStatus = ticket.status
        self.ticketTags = ticket.tagList
        self.ticketDescription = ticket.description
        
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
