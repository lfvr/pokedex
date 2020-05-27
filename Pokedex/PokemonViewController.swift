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
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
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
    
}
