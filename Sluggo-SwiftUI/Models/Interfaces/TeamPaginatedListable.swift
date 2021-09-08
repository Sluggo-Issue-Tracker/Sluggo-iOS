//
//  TeamListable.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

protocol TeamPaginatedListable {
    associatedtype Record where Record: Codable
    func listFromTeams(page: Int) async -> Result<PaginatedList<Record>, Error>
}
