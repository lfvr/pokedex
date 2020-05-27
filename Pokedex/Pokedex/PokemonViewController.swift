import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    var caughtPokemon = UserDefaults.standard
    var pokemon: String = ""
    var descriptionUrl: String = ""
    

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchButton: UIButton!
    @IBOutlet var sprite: UIImageView!
    @IBOutlet var descriptionLabel: UITextView!
    @IBAction func toggleCatch() {
        
        if caughtPokemon.bool(forKey: "\(pokemon)") {
            caughtPokemon.set(false, forKey: "\(pokemon)")
            catchButton.setTitle("Catch", for: .normal)
        } else {
            caughtPokemon.set(true, forKey: "\(pokemon)")
            catchButton.setTitle("Release", for: .normal)
        }
    }
    
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        loadPokemon()
    }

    func loadPokemon() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    self.pokemon = result.name
                    self.descriptionUrl = result.species.url
                    
                    if self.descriptionUrl != "" {
                        self.loadDescription()
                    }
                    
                    let x = result.sprites.front_default
                    guard let imgUrl = URL(string: x) else { return }
                    guard let imgData = try? Data(contentsOf: imgUrl) else { return }
                    guard let img = UIImage(data: imgData) else { return }
                    self.sprite.image = img
                    
                    if self.caughtPokemon.bool(forKey: "\(self.pokemon)") {
                        self.catchButton.setTitle("Release", for: .normal)
                    } else {
                        self.catchButton.setTitle("Catch", for: .normal)
                    }

                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                            let color = self.typeColor(type: self.type1Label.text!)
                            self.type1Label.backgroundColor = color
                            self.type1Label.textColor = .white
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                            let color = self.typeColor(type: self.type2Label.text!)
                            self.type2Label.backgroundColor = color
                            self.type2Label.textColor = .white
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func loadDescription() {
        URLSession.shared.dataTask(with: URL(string: self.descriptionUrl)!) { (data, response, error) in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(SpeciesEntry.self, from: data)
                for flavor in result.flavor_text_entries {
                    if flavor.language.name == "en" {
                        let descriptionText = flavor.flavor_text.replacingOccurrences(of: "\n", with: " ")
                        
                        DispatchQueue.main.async {
                            self.descriptionLabel.text = descriptionText
                        }
                    }
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func typeColor(type: String) -> UIColor {
        var color: UIColor
        switch type {
        case "bug": color = UIColor(red: 168/255, green: 184/255, blue: 32/255, alpha: 1)
        case "dark": color = UIColor(red: 112/255, green: 88/255, blue: 72/255, alpha: 1)
        case "dragon": color = UIColor(red: 112/255, green: 56/255, blue: 248/255, alpha: 1)
        case "electric": color = UIColor(red: 248/55, green: 208/255, blue: 48/255, alpha: 1)
        case "fighting": color = UIColor(red: 192/255, green: 48/255, blue: 40/255, alpha: 1)
        case "fire": color = UIColor(red: 240/255, green: 128/255, blue: 48/255, alpha: 1)
        case "flying": color = UIColor(red: 168/255, green: 144/255, blue: 240/255, alpha: 1)
        case "ghost": color = UIColor(red: 112/255, green: 88/255, blue: 152/255, alpha: 1)
        case "grass": color = UIColor(red: 120/255, green: 200/255, blue: 80/255, alpha: 1)
        case "ground": color = UIColor(red: 224/255, green: 192/255, blue: 104/255, alpha: 1)
        case "ice": color = UIColor(red: 152/255, green: 216/255, blue: 216/255, alpha: 1)
        case "normal": color = UIColor(red: 168/255, green: 168/255, blue: 120/255, alpha: 1)
        case "poison": color = UIColor(red: 160/255, green: 64/255, blue: 160/255, alpha: 1)
        case "psychic": color = UIColor(red: 248/255, green: 88/255, blue: 136/255, alpha: 1)
        case "rock": color = UIColor(red: 184/255, green: 160/255, blue: 56/255, alpha: 1)
        case "steel": color = UIColor(red: 184/255, green: 184/255, blue: 208/255, alpha: 1)
        case "water": color = UIColor(red: 104/255, green: 144/255, blue: 240/255, alpha: 1)
        default: color = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        }
        return color
    }
}
