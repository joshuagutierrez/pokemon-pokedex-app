

import Foundation

class PokemonMove {
    private var _name: String!
    private var _attack: String!
    private var _accuracy: String!
    private var _level: String! // Unused
    private var _description: String!
    
    var name: String {
        return _name
    }
    
    var attack: String {
        return _attack
    }
    
    var accuracy: String {
        return _accuracy
    }
    
    var level: String {
        return _level
    }
    
    var description: String {
        return _description
    }
    
    init(name: String, attack: String, accuracy: String, description: String) {
        self._name = name.capitalizedString
        self._attack = attack
        self._accuracy = accuracy
        self._description = description
    }
}