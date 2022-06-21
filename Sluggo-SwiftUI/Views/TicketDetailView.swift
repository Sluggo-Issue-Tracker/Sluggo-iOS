//
//  TicketDetailView.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 6/20/22.
//

import Foundation
import SwiftUI

struct TicketDetail: View {
    
    @Environment(\.editMode) private var editMode
    
    @State var selectedIndex: Int = 0
    @State var teamMembers: [MemberRecord] = []
    @State var ticket: TicketRecord
    @State var pickerVisible: Bool = false
    
    
    var body: some View {

        List {
            Section(header: Text("Title")) {
                if editMode?.wrappedValue.isEditing == true {
                    TextField("Required", text: $ticket.title)
                } else {
                    Text(ticket.title)
                }
            }
            Section(header: Text("Assigned User")) {
                if editMode?.wrappedValue.isEditing == true {
                    Picker("\(ticket.assignedUser?.getTitle() ?? "")", selection: $ticket.assignedUser, content: {
                        ForEach(teamMembers) { member in
                            Text(member.owner.username)
                        }
                    })
                } else {
                    Text("\(ticket.assignedUser?.getTitle() ?? "")")
                }
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
                if editMode?.wrappedValue.isEditing == true {
                    TextEditor(text: $ticket.description ?? "")
                        .frame(minHeight: 100, alignment: .topLeading)
                } else {
                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(ticket.description ?? "")")
                            .frame(minHeight: 100, alignment: .topLeading)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: EditButton())
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct TicketEditDetail: View {
    
    @State var ticket: TicketRecord
    @Binding var showModalView: Bool
    
    var body: some View {
        NavigationView {
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
            .navigationBarItems(
                leading: Button("Cancel") {
                    self.showModalView.toggle()
                    
                }, trailing: Button("Done") {
                    
                })
        }
        
    }
}
