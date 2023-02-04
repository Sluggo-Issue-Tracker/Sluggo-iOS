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
    @State var showModalView = false
    
    var body: some View {

        List {
            Section(header: Text("Title")) {
                Text("\(ticket.title)")
            }
            Section(header: Text("Assigned User")) {
                if(ticket.assignedUser == nil) {
                    Text("None").foregroundColor(.gray)
                }
                else {
                    Text("\(ticket.assignedUser?.getTitle() ?? "")")
                }
            }
            Section(header: Text("Status")) {
                
                Text("\(ticket.status?.getTitle() ?? "")")
            }
            Section(header: Text("Tags")) {
                if(ticket.tagList.isEmpty) {
                    Text("None").foregroundColor(.gray)
                }
                else {
                    ForEach(ticket.tagList) { tag in
                        Text(tag.title)
                    }
                }
            }
            Section(header: Text("Date Due")) {
                if(ticket.dueDate == nil) {
                    Text("None").foregroundColor(.gray)
                }
                else {
                    Text(ticket.dueDate ?? Date(), style: .date)
                }
            }
            Section(header: Text("Description")) {
                if(ticket.description == nil) {
                    Text("None").foregroundColor(.gray)
                }
                else {
                    VStack(spacing: 0) {
                        Spacer()
                        Text("\(ticket.description ?? "")")
                            .frame(minHeight: 100, alignment: .topLeading)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit"){
            self.showModalView.toggle()
        })
        .fullScreenCover(isPresented: $showModalView) {
            TicketEditDetail(ticket: $ticket, showModalView: self.$showModalView)
                
        }
        .transition(.opacity) //Doesn't work
        
    }
}
