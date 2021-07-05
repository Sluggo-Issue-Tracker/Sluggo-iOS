//
//  TeamListable.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

protocol TeamPaginatedListable {
    associatedtype Record where Record: Codable
    func listFromTeams(page: Int, completionHandler: @escaping(Result<PaginatedList<Record>, Error>) -> Void)
}
