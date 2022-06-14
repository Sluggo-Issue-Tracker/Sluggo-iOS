//
//  TicketListView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 1/2/22.
//

import SwiftUI

struct TicketListView: View {
    
    @EnvironmentObject var identity: AppIdentity
    @StateObject private var alertContext = AlertContext()
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            TicketList(tickets: viewModel.searchedTickets)
                .searchable(text: $viewModel.searchKey)
                .navigationTitle("Tickets")
                .task {
                    viewModel.setup(identity: identity, alertContext: alertContext)
                    await viewModel.handleTicketsList(page: 1)
                }
                .refreshable {
                    await viewModel.handleTicketsList(page: 1)
                }
                .toolbar {
                    Menu {
                        Button {} label: {Label("Create New", systemImage: "plus")}
                        Button {viewModel.showFilter = true} label: {Label("Filter", systemImage: "folder")}
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                .sheet(isPresented: $viewModel.showFilter) {
                    track("canceled")
                    
                } content: {
                    NavigationView {
                        ListView(filter: $viewModel.filterParams)
                            .navigationTitle("Filter")
                    }
                }
        }
        .navigationViewStyle(.stack)
        .alert(context: alertContext)
    }
}

struct TestData: Identifiable {
    var id = UUID()
    var title: String
    var items: [String]
}

struct ListView : View {
    @Binding var filter: TicketFilterParameters
    let mygroups = [
        TestData(title: "Numbers", items: ["1","2","3"]),
        TestData(title: "Letters", items: ["A","B","C"]),
        TestData(title: "Symbols", items: ["€","%","&"])
    ]
    let returningClass = String.self
    var body: some View {
        List(mygroups) { gp in
            Section(gp.title) {
                SingleSelectionList (items:gp.items, selection:$filter, sectionType: returningClass) { item in
                    HStack{
                        Text(item)
                        Spacer()
                    }
                }
            }
            
        }
        
    }
}

struct SingleSelectionList<Item: Hashable, Content: View>: View {
    
    var items: [Item]
    @Binding var selection: TicketFilterParameters
    var sectionType: Item.Type
    var rowContent: (Item) -> Content
    
    var body: some View {
        ForEach(items, id: \.self) { item in
            rowContent(item)
                .modifier(CheckmarkModifier(checked: self.isChecked(item: item)))
                .contentShape(Rectangle())
                .onTapGesture {
                    self.selection.assignedUser = (item as? MemberRecord)
                }
        }
    }
    
  private func isChecked(item: Item) -> Bool {
        
        return self.selection.assignedUser?.id == (item as? MemberRecord)?.id
    }
}

struct CheckmarkModifier: ViewModifier {
    var checked: Bool = false
    func body(content: Content) -> some View {
        Group {
            if checked {
                ZStack(alignment: .trailing) {
                    content
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            } else {
                content
            }
        }
    }
}


struct TicketListView_Previews: PreviewProvider {
    static var previews: some View {
        TicketListView()
    }
}

struct TicketList: View {
    //    Simple struct to account for all the fancy styling on lists and Zstack
    var tickets: [TicketRecord]
    var body: some View {
        List {
            ForEach(tickets, id: \.id) { ticket in
                ZStack {
                    NavigationLink(destination: Text("HI")) {
//                        Text(ticket.title)
                    }
                    .opacity(0.0)
                    .buttonStyle(.plain)
                    TicketPill(ticket: ticket)
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.none)
//            .listRowBackground(Color.clear)
            
        }
        .listStyle(.plain)
        
    }
}
