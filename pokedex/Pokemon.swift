

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _defense: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLvl: String!
    private var _nextEvolutionTxt: String!
    private var _pokemonUrl: String!
    
    private var _moves: [PokemonMove]!
    
    var moves: [PokemonMove] {
        return _moves
    }
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLvl: String {
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        return _nextEvolutionLvl
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name.capitalizedString
        self._pokedexId = pokedexId
        self._moves = [PokemonMove]()
        _pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
        
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        
        let url = NSURL(string: _pokemonUrl)!
        
        Alamofire.request(.GET, url).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                // Pokemon type
                if let types = dict["types"] as? [Dictionary<String, String>] where types.count > 0 {
                    
                    if let name = types[0]["name"] {
                        self._type = name.capitalizedString
                    }
                    
                    if types.count > 1 {
                        
                        for var x = 1; x < types.count; x++ {
                            if let name = types[x]["name"] {
                                self._type! += " / \(name.capitalizedString)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                
                // Description
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                    if let url = descArr[0]["resource_uri"] {
                        let nsurl = NSURL(string: "\(URL_BASE)\(url)")!
                        
                        // Make another request from the url
                        Alamofire.request(.GET, nsurl).responseJSON { response in
                            
                            let desResult = response.result
                            
                            if let descDict = desResult.value as? Dictionary<String, AnyObject> {

                                if let description = descDict["description"] as? String {
                                    self._description = description
                                }
                            }
                            
                            completed()
                        }
                    }
                } else {
                    self._description = ""
                }
                
                // Evolutions
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>] where evolutions.count > 0 {
                    
                    if let to = evolutions[0]["to"] as? String {
                        // ignore 'mega' evolutions
                        if to.rangeOfString("mega") == nil {
                            
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                
                                let newStr = uri.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                                
                                // Grab pokedexId from uri
                                let num = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                                
                                self._nextEvolutionId = num
                                self._nextEvolutionTxt = to
                                
                                if let lvl = evolutions[0]["level"] as? Int {
                                    self._nextEvolutionLvl = "\(lvl)"
                                }
                            }
                            
                        }
                    }
                    
                }
                
                //Moves
                if let moves = dict["moves"] as? [Dictionary<String, AnyObject>] where moves.count > 0 {
                    var moveAtk = ""
                    var moveAcc = ""
                    var moveDesc = ""
                    var moveName = ""

                    for parsedMove in moves {
                        if let moveUrl = parsedMove["resource_uri"] {
                            let nsurl = NSURL(string: "\(URL_BASE)\(moveUrl)")!
                            Alamofire.request(.GET, nsurl).responseJSON { response in
                                
                                let moveResult = response.result
                                
                                if let moveDict = moveResult.value as? Dictionary<String, AnyObject> {
                                    
                                    if let attack = moveDict["power"] as? Int {
                                        moveAtk = "\(attack)"
                                    }
                                    
                                    if let accuracy = moveDict["accuracy"] as? Int {
                                        moveAcc = "\(accuracy)"
                                    }
                                    
                                    if let name = moveDict["name"] as? String {
                                        moveName = name
                                    }
                                    if let description = moveDict["description"] as? String {
                                        moveDesc = description
                                    }
                                }
                                
                                self._moves.append(PokemonMove(name: moveName, attack: moveAtk, accuracy: moveAcc, description: moveDesc))

                                completed()
                            }
                        }
                    }
                }
            }
        }
    }
}