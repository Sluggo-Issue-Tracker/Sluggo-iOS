//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class AppIdentity: Codable, ObservableObject {

    @Published private var _authenticatedLogin: LoginRecord?
    @Published private var _team: TeamRecord?
    @Published private var _pageSize = 10
    @Published private var _baseAddress: String = Constants.Config.URL_BASE
    @Published private var persist: Bool = false
    
    

    // MARK: Computed Properties
    
    var authenticatedLogin: LoginRecord? {
        get {
            return _authenticatedLogin
        }
        set(newUser) {
            _authenticatedLogin = newUser
            enqueueSave()
        }
    }
    
    var authenticatedUser: AuthRecord? {
        get {
            return _authenticatedLogin?.user
        }
        set(newUser) {
            _authenticatedLogin?.user = newUser
            enqueueSave()
        }
    }
    var team: TeamRecord? {
        get {
            return _team
        }
        set(newTeam) {
            _team = newTeam
            enqueueSave()
        }
    }
    var token: String? {
        get {
            return _authenticatedLogin?.accessToken
        }
        set (newToken) {
            DispatchQueue.main.async {
                self.persist = true
                self._authenticatedLogin?.accessToken = newToken
                self.enqueueSave()
            }
        }
    }
    var refreshToken: String? {
        get {
            return _authenticatedLogin?.refreshToken
        }
        set (newToken) {
            DispatchQueue.main.async {
                self.persist = true
                self._authenticatedLogin?.refreshToken = newToken
                self.enqueueSave()
            }
        }
    }
    var pageSize: Int {
        get {
            return _pageSize
        }
        set(newPageSize) {
            _pageSize = newPageSize
            enqueueSave()
        }
    }
    var baseAddress: String {
        get {
            return _baseAddress
        }
        set(newBaseAddress) {
            _baseAddress = newBaseAddress
            enqueueSave()
        }
    }

    private static var persistencePath: URL {
        let path = URL(fileURLWithPath: NSHomeDirectory().appending("/Library/appdata.json"))
        return path
    }

    public func setPersistData(persist: Bool) {
        self.persist = persist
        if persist {
            enqueueSave()
        } else {
            _ = AppIdentity.deletePersistenceFile()
        }
    }

    private func enqueueSave() {
        if self.persist {
            DispatchQueue.global().async {
                _ = self.saveToDisk()
            }
        }
    }
    
    public func clear() {
        self._authenticatedLogin = nil
        self._team = nil
    }

    static func loadFromDisk() -> AppIdentity? {
        guard let persistenceFileContents = try? String(contentsOf: persistencePath) else {
            return nil
        }

        guard let persistenceFileData = persistenceFileContents.data(using: .utf8) else {
            // File exists but was corrupted, so clean it up
            _ = deletePersistenceFile()
            return nil
        }

        let appIdentity: AppIdentity? = BaseLoader.decode(data: persistenceFileData)
        if appIdentity == nil {
            // File exists, but failed to deserialize, so clean it up
            _ = deletePersistenceFile()
        }

        return appIdentity
    }

    func saveToDisk() -> Bool {
        guard let appIdentityData = BaseLoader.encode(object: self) else {
            track("Failed to encode app identity with JSON, could not persist")
            return false
        }

        guard let appIdentityContents = String(data: appIdentityData, encoding: .utf8) else {
            track("Failed to encode app identity encoded data as string, could not persist")
            return false
        }

        do {
            try appIdentityContents.write(to: AppIdentity.persistencePath, atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch {
            track("Could not write persistence file to disk, could not persist")
            return false
        }
    }

    static func deletePersistenceFile() -> Bool {
        // Succeed if the persistence file doesn't exist. This allows us to clean up a bad file.
        track("in delete")
        if !(FileManager.default.fileExists(atPath: self.persistencePath.path)) {
            track("Attempted to delete persistence file when it doesn't exist, returning")
            return true
        }

        do {
            try FileManager.default.removeItem(at: self.persistencePath)
            track("Cleaned up persistance item")
            return true
        } catch {
            track("FAILED TO CLEAN UP PERSISTENCE FILE")
            return false
        }
    }
    
    enum CodingKeys: CodingKey {
        case authenticatedLogin
        case authenticatedUser
        case team
        case token
        case refreshToken
        case pageSize
        case baseAddress
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        authenticatedLogin = try container.decode(LoginRecord.self, forKey: .authenticatedLogin)
        authenticatedUser = try container.decode(AuthRecord.self, forKey: .authenticatedUser)
        team = try container.decode(TeamRecord.self, forKey: .team)
        token = try container.decode(String.self, forKey: .token)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        pageSize = try container.decode(Int.self, forKey: .pageSize)
        baseAddress = try container.decode(String.self, forKey: .baseAddress)
    }
    
    required init() {
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authenticatedLogin, forKey: .authenticatedLogin)
        try container.encode(authenticatedUser, forKey: .authenticatedUser)
        try container.encode(team, forKey: .team)
        try container.encode(token, forKey: .token)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(pageSize, forKey: .pageSize)
        try container.encode(baseAddress, forKey: .baseAddress)
    }
}
