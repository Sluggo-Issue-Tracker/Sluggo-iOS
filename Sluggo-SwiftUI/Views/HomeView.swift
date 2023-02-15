//
//  HomeView.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 9/29/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var identity: AppIdentity
    @StateObject var alertContext = AlertContext()
    var body: some View {
        TabView {
            
//            Text("Welcome Home \(identity.authenticatedUser!.username)" )
            TestView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            TicketListView()
                .tabItem {
                    Image(systemName: "ticket.fill")
                    Text("Tickets")
                }
            Text("Member List and Settings Here")
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Members")
                }
        }
    }
}


/*
 All display styles:
 case `class`
 case collection
 case dictionary
 case `enum`
 case optional
 case set
 case `struct`
 case tuple
 */

struct TestView: View {
    
    // CLASS
    
    
    // COLLECTION
    @State var arr = [1, 2, 3, 4]
    @State var arr_empty: [Int] = []
    @State var arr_opt: [Int]?
    @State var arr_opt_empty: [Int]? = []
    @State var arr_opt_full: [Int]? = [1,2,3]
    
    
    // DICTIONARY
    
    
    // ENUM
    
    
    // Optional
    @State var opt: String?
    @State var opt_empty: String? = ""
    @State var opt_full: String? = "1,2,3,4"
    @State var not_opt: String = "Normal String"
    
    
    // SET
    
    
    // STRUCT
    @State var struct_ = ErrorMessage(detail: "Detail", code: "Code")
    
    // TUPLE
    
    var body: some View {
        Text("HI")
//        VStack {
//            Group {
//                Text("ARRAYS")
//                NilContext(item: arr) {
//                    Text("arr: \(arr.description)")
//                }
//                NilContext(item: arr_empty) {
//                    Text("arr_empty: \(arr_empty.description)")
//                }
//                NilContext(item: arr_opt) {
//                    Text("arr_opt: \(arr_opt?.description ?? "Nil")")
//                }
//                NilContext(item: arr_opt_empty) {
//                    Text("arr_opt_empty: \(arr_opt_empty?.description ?? "Nil")")
//                }
//                NilContext(item: arr_opt_full) {
//                    Text("arr_opt_full: \(arr_opt_full?.description ?? "Nil")")
//                }
//            }
//            Spacer()
//            Group {
//                Text("OPTIONALS")
//                NilContext(item: opt) {
//                    Text("opt: \(opt ?? "")")
//                }
//                NilContext(item: opt_empty) {
//                    Text("opt_empty: \(opt_empty ?? "")")
//                }
//                NilContext(item: opt_full) {
//                    Text("opt_full: \(opt_full ?? "")")
//                }
//                NilContext(item: not_opt) {
//                    Text("not_opt: \(not_opt)")
//                }
//            }
//            Spacer()
//            Group {
//                Text("STRUCT")
//                NilContext(item: struct_) {
//                    Text("struct_: \(struct_)")
//                }
//                NilContext(item: opt_empty) {
//                    Text("opt_empty: \(opt_empty ?? "")")
//                }
//                NilContext(item: opt_full) {
//                    Text("opt_full: \(opt_full ?? "")")
//                }
//                NilContext(item: not_opt) {
//                    Text("not_opt: \(not_opt)")
//                }
//            }
//
//        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
