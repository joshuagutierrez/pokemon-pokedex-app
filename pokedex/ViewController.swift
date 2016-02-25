

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collection: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var pokemon = [Pokemon]()
    var filteredPokemon = [Pokemon]()
    var musicPlayer: AVAudioPlayer!
    
    var inSearchMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        collection.delegate = self
        collection.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.Done
        initAudio()
        parsePokemonCSV()
        
        let image: UIImage = UIImage(named: "search")!
        self.searchBar.setImage(image, forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        
        let searchTextField: UITextField? = searchBar.valueForKey("searchField") as? UITextField
        if searchTextField!.respondsToSelector(Selector("attributedPlaceholder")) {
            let color = UIColor.whiteColor()
            let attributeDict = [NSForegroundColorAttributeName: color]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Search for Pokemon", attributes: attributeDict)
            searchTextField!.textColor = color            
        }
    }
    
    
    
    func initAudio() {
        
        let path = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")!
        
        do {
            musicPlayer = try AVAudioPlayer(contentsOfURL: NSURL(string: path)!)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        } catch let err as NSError {
            print(err)
        }
        
    }
    
    func parsePokemonCSV() {
        let path = NSBundle.mainBundle().pathForResource("pokemon", ofType: "csv")!
        
        do {
            let csv = try CSV(contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows {
                let pokeId = Int(row["id"]!)!
                let name = row["identifier"]!
                let poke = Pokemon(name: name, pokedexId: pokeId)
                
                pokemon.append(poke)
            }
            
        } catch let err as NSError {
            print(err)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PokeCell", forIndexPath: indexPath) as? PokeCell {
            // Configure cell
            
            let poke: Pokemon!
            
            if inSearchMode {
                poke = filteredPokemon[indexPath.row]
            } else {
                poke = pokemon[indexPath.row]
            }
            
            
            cell.configureCell(poke)
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let poke: Pokemon!
        
        if inSearchMode {
            poke = filteredPokemon[indexPath.row]
        } else {
            poke = pokemon[indexPath.row]
        }

        performSegueWithIdentifier("PokemonDetailVC", sender: poke)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if inSearchMode {
            return filteredPokemon.count
        }
        
        return pokemon.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSizeMake(105,105)
    }
    
    @IBAction func musicBtnPressed(sender: UIButton) {
        
        if musicPlayer.playing {
            musicPlayer.stop()
            sender.alpha = 0.2
        } else {
            musicPlayer.play()
            sender.alpha = 1.0
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            view.endEditing(true)
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercaseString

            //$0 = pokemon object
            filteredPokemon = pokemon.filter({$0.name.lowercaseString.rangeOfString(lower) != nil})
            
        }
        collection.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    // Pass pokemon object via segue to the PokemonDetailVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PokemonDetailVC" {
            if let detailsVC = segue.destinationViewController as? PokemonDetailVC {
                if let poke = sender as? Pokemon {
                    detailsVC.pokemon = poke
                }
            }
        }
    }
    
}

