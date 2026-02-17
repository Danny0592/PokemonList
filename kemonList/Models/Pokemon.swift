//
//  Pokemon.swift
//  kemonList
//
//  Modelos para decodificar la respuesta de PokeAPI
//

import Foundation

struct Pokemon: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let baseExperience: Int?
    let types: [PokemonTypeSlot]
    let stats: [PokemonStat]
    let sprites: PokemonSprites
    
    enum CodingKeys: String, CodingKey {
        case id, name, height, weight, types, stats, sprites
        case baseExperience = "base_experience"
    }
}

struct PokemonTypeSlot: Decodable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Decodable {
    let name: String
    let url: String
}

struct PokemonStat: Decodable {
    let baseStat: Int
    let effort: Int
    let stat: PokemonStatInfo
    
    enum CodingKeys: String, CodingKey {
        case effort, stat
        case baseStat = "base_stat"
    }
}

struct PokemonStatInfo: Decodable {
    let name: String
    let url: String
}

struct PokemonSprites: Decodable {
    let frontDefault: String?
    let other: PokemonSpritesOther?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case other
    }
}

struct PokemonSpritesOther: Decodable {
    let officialArtwork: OfficialArtwork?
    
    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct OfficialArtwork: Decodable {
    let frontDefault: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

// MARK: - Listado
/// Respuesta de la API de listado.
struct PokemonListResponse: Decodable {
    let results: [PokemonListResult]
}

/// Ítem crudo del listado (name y url).
struct PokemonListResult: Decodable {
    let name: String
    let url: String
}

/// Ítem de la lista para mostrar (con id, nombre y sprite).
struct PokemonListItem: Identifiable, Hashable {
    let id: Int
    let name: String

    /// Crea el ítem extrayendo el id numérico de la URL.
    init(name: String, url: String) {
        self.name = name
        self.id = Self.idFromURL(url)
    }

    /// Extrae el id de la URL (ej: ".../pokemon/25/" → 25).
    private static func idFromURL(_ url: String) -> Int {
        let numbers = url.split(separator: "/").compactMap { Int($0) }
        return numbers.last ?? 0
    }
    
    /// Nombre con la primera letra en mayúscula.
    var displayName: String {
        name.prefix(1).uppercased() + name.dropFirst()
    }

    /// URL del sprite pequeño para la lista.
    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: PokemonListItem, rhs: PokemonListItem) -> Bool { lhs.id == rhs.id }
}

extension Pokemon {
    /// URL de la imagen (arte oficial o sprite por defecto).
    var imageURL: URL? {
        if let urlString = sprites.other?.officialArtwork?.frontDefault {
            return URL(string: urlString)
        }
        if let urlString = sprites.frontDefault {
            return URL(string: urlString)
        }
        return nil
    }
    
    /// Nombre con la primera letra en mayúscula.
    var displayName: String {
        name.prefix(1).uppercased() + name.dropFirst()
    }

    /// Tipos como texto separado por comas.
    var typesDisplay: String {
        types.map { $0.type.name.capitalized }.joined(separator: ", ")
    }
}
