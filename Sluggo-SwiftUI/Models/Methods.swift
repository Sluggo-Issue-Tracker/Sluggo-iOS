//
//  Methods.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

class UnwindState<M: TeamPaginatedListable> {
    let manager: M
    var page: Int
    var maxCount: Int
    var codableArray: [M.Record]
    var onSuccess: (([M.Record]) -> Void)?
    var onFailure: ((Error) -> Void)?
    var after: (() -> Void)?

    init(manager: M,
         page: Int,
         maxCount: Int,
         codableArray: [M.Record],
         onSuccess: (([M.Record]) -> Void)?,
         onFailure: ((Error) -> Void)?,
         after: (() -> Void)?) {

        self.manager = manager
        self.page = page
        self.maxCount = maxCount
        self.codableArray = codableArray
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.after = after
    }
}

func unwindPaginationRecurse<M: TeamPaginatedListable>(state: UnwindState<M>) {

    state.manager.listFromTeams(page: state.page) { (result: Result<PaginatedList<M.Record>, Error>) -> Void in

        switch result {
        case .success(let record):
            state.maxCount = record.count

            for entry in record.results {
                state.codableArray.append(entry)
            }

            if state.codableArray.count < state.maxCount {
                state.page += 1

                // tail recurse to get remaining data
                unwindPaginationRecurse(state: state)
            } else {
                state.onSuccess?(state.codableArray)
                state.after?()
            }
        case .failure(let error):
            print("error occured")
            state.onFailure?(error)
            state.after?()
        }
    }
}

func unwindPagination<M: TeamPaginatedListable>(manager: M,
                                                startingPage: Int,
                                                onSuccess: (([M.Record]) -> Void)?,
                                                onFailure: ((Error) -> Void)?,
                                                after: (() -> Void)?) {

    let state = UnwindState<M>(manager: manager,
                               page: startingPage,
                               maxCount: 0,
                               codableArray: [],
                               onSuccess: onSuccess,
                               onFailure: onFailure,
                               after: after)

    unwindPaginationRecurse(state: state)
}
