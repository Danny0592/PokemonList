//
//  PokemonListViewModel.swift
//  kemonList
//

import Combine
import Foundation

@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published var pokemonList: [PokemonListItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://pokeapi.co/api/v2/pokemon"

    /// Obtiene la lista de Pokémon desde la API.
    func fetchList(limit: Int = 1000, offset: Int = 0) async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)?limit=\(limit)&offset=\(offset)") else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Error al cargar la lista"
                isLoading = false
                return
            }

            let listResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            pokemonList = listResponse.results.map { PokemonListItem(name: $0.name, url: $0.url) }
        } catch {
            errorMessage = error.localizedDescription
            pokemonList = []
        }

        isLoading = false
    }
}
