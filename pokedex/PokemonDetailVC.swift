

import UIKit

class PokemonDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pokemon: Pokemon!
    var state = 0           // 0 = bio, 1 = moves
    
    @IBOutlet weak var movesTableView: UITableView!
    @IBOutlet weak var segCtrl: UISegmentedControl!
    @IBOutlet weak var bioStack: UIStackView!
    @IBOutlet weak var evoStack: UIStackView!
    @IBOutlet weak var evoView: UIView!
    
    // Bio variables
    @IBOutlet weak var pokeLbl: UILabel!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var defenseLbl: UILabel!
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var pokedexIdLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var attackLbl: UILabel!
    @IBOutlet weak var currentEvoImg: UIImageView!
    @IBOutlet weak var nextEvoImg: UIImageView!
    @IBOutlet weak var evoLbl: UILabel!
    @IBOutlet weak var evoArrow: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "\(pokemon.pokedexId)")
        
        pokeLbl.text = pokemon.name
        mainImg.image = img
        currentEvoImg.image = img
        resetUI()
        
        pokemon.downloadPokemonDetails { () -> () in
            // this will be called after download is done
            self.updateUI()
            self.movesTableView.reloadData()
        }
        
        movesTableView.delegate = self
        movesTableView.dataSource = self

        selectSegment(0)
    }
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        selectSegment(sender.selectedSegmentIndex)
    }
    
    func selectSegment(segment: Int) {
        if segment == 0 {
            bioStack.hidden = false
            evoStack.hidden = false
            evoView.hidden = false
            
            movesTableView.hidden = true
        } else if segment == 1 {
            bioStack.hidden = true
            evoStack.hidden = true
            evoView.hidden = true
            
            movesTableView.hidden = false
        }
        state = segment
    }
    
    /****************************************************************
                                Bio
    ****************************************************************/
    @IBAction func backBtnPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func updateUI() {
        descriptionLbl.text = pokemon.description
        typeLbl.text = pokemon.type
        defenseLbl.text = pokemon.defense
        heightLbl.text = pokemon.height
        pokedexIdLbl.text = "\(pokemon.pokedexId)"
        weightLbl.text = pokemon.weight
        attackLbl.text = pokemon.attack
        
        if pokemon.nextEvolutionId == "" {
            evoLbl.text = "No Evolution"
            nextEvoImg.hidden = true
            evoArrow.hidden = true
        } else {
            nextEvoImg.hidden = false
            evoArrow.hidden = false
            nextEvoImg.image = UIImage(named: pokemon.nextEvolutionId)
            
            var str = "Next Evolution: \(pokemon.nextEvolutionTxt)"

            if pokemon.nextEvolutionLvl != "" {
                str += " - LVL \(pokemon.nextEvolutionLvl)"
            }
            evoLbl.text = str
        }
    }
    
    func resetUI() {
        descriptionLbl.text = ""
        typeLbl.text = ""
        defenseLbl.text = ""
        heightLbl.text = ""
        pokedexIdLbl.text = ""
        weightLbl.text = ""
        attackLbl.text = ""
        evoLbl.text = ""
        evoArrow.hidden = true
        nextEvoImg.hidden = true
        
    }
    
    /****************************************************************
                                    Moves
    ****************************************************************/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Spacer cell
        if (indexPath.row % 2 == 0) {
            let spacerCell = UITableViewCell()
            spacerCell.userInteractionEnabled = false
            
            return spacerCell
        }
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("MovesCell", forIndexPath: indexPath) as? MovesCell {
            
            var move = PokemonMove(name: "Tackle", attack: "10", accuracy: "35", description: "This move really hurts!")
            
            if pokemon.moves.count > 0 {
                move = pokemon.moves[indexPath.row/2]
            }
            cell.configureCell(move)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row % 2 != 0) {
            // this is a regular cell
            return 80;
        }
        else {
            // this is a "space" cell
            return 16;
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pokemon.moves.count > 0 {
            return pokemon.moves.count * 2
        }
        return 1
    }
}
