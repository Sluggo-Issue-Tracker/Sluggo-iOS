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
    
    var body: some View {

        List {
            Section(header: Text("Title")) {
                    Text(ticket.title)
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
        .navigationBarItems(trailing: Button("Edit") {})
    }
}