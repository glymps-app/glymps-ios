//
//  DeckService.swift
//  GlympsApp
//
//  Created by Luckhardt, Charles on 10/3/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import Foundation

struct DeckItem {
    let user: User
    let distance: CGFloat
}

class DeckService {

    let authAPI: AuthAPI

    init(authAPI: AuthAPI) {
        self.authAPI = authAPI
    }

    func observeDeck(_ onUpdate: @escaping ([DeckItem]) -> Void) -> Connection {
        return authAPI.feed.observe(.value) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let uidDistanceMap):
                strongSelf.updateDeckCache(withMap: uidDistanceMap) {
                    let deck = strongSelf.deckCache.values.sorted(by: { $0.distance < $1.distance })
                    onUpdate(deck)
                }
            case .failure:
                onUpdate([])
            }
        }
    }

    private var deckCache: [String: DeckItem] = [:]

    private func updateDeckCache(withMap uidDistanceMap: [String: CGFloat], completion: @escaping () -> Void) {

        let dispatchGroup = DispatchGroup()

        var newCache = [String: DeckItem]()
        for (uid, distance) in uidDistanceMap {
            if let deckItem = deckCache[uid] {
                // If user already exists in cached deck just update distance value
                newCache[uid] = DeckItem(user: deckItem.user, distance: distance)
                continue
            }

            dispatchGroup.enter()
            API.User.getUser(withId: uid) { result in
                if case .success(let user) = result {
                    newCache[uid] = DeckItem(user: user, distance: distance)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.deckCache = newCache
            completion()
        }
    }

    private func userMatchesPreferences(_ user: User) {
        let currentUser
    }
}
