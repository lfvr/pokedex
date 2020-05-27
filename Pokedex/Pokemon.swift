import Foundation

struct PokemonListResults: Codable {
    let results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let species: Species
    let sprites: Sprite
    let types: [PokemonTypeEntry]
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct Species: Codable {
    let name: String
    let url: String
}

struct SpeciesEntry: Codable {
    let flavor_text_entries: [FlavorTextEntry]
}

struct FlavorTextEntry: Codable {
    let flavor_text: String
    let language: FlavorLanguage
}

struct FlavorLanguage: Codable {
    let name: String
    let url: String
}

struct Sprite: Codable {
    let front_default: String
}
