

import UIKit

class MovesCell: UITableViewCell {
    
    @IBOutlet weak var moveNameLbl: UILabel!
    @IBOutlet weak var moveAttackLbl: UILabel!
    @IBOutlet weak var moveAccLbl: UILabel!
    @IBOutlet weak var moveDescLbl: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5.0
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGrayColor().CGColor
    }
    
    func configureCell(move: PokemonMove) {
        moveNameLbl.text = move.name
        moveAttackLbl.text = move.attack
        moveAccLbl.text = move.accuracy
        moveDescLbl.text = move.description
    }
}
