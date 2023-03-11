//
//  TicketDetailView.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 6/20/22.
//

import Foundation
import SwiftUI

struct TicketDetail: View {
    
    @Binding var ticket: TicketRecord
    @State var showView = false
    
    var body: some View {

        List {
            Section(header: Text("Title")) {
                Text("\(ticket.title)")
            }
            Section(header: Text("Assigned User")) {
                NilContext(item: ticket.assignedUser) {
                    Text("\(ticket.assignedUser?.getTitle() ?? "")")
                }
            }
            Section(header: Text("Status")) {
                NilContext(item: ticket.status) {
                    Text("\(ticket.status?.getTitle() ?? "")")
                }
            }
            Section(header: Text("Tags")) {
                NilContext(item: ticket.tagList) {
                    ForEach(ticket.tagList) { tag in
                        Text(tag.getTitle())
                    }
                }
            }
            Section(header: Text("Date Due")) {
                NilContext(item: ticket.dueDate) {
                    Text(ticket.dueDate ?? Date(), style: .date)
                }
            }
            Section(header: Text("Description")) {
                NilContext(item: ticket.description) {
                    Text("\(ticket.description ?? "")")
                }
                .frame(minHeight: 100, alignment: .topLeading)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit"){
            self.showView.toggle()
        })
        .sheet(isPresented: $showView) {
            TicketEditDetail(ticket: $ticket, showView: self.$showView)
                
        }
    }
}
