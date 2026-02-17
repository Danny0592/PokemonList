//
//  PokemonDetailViewModel.swift
//  kemonList
//

import Combine
import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://pokeapi.co/api/v2/pokemon"

    /// Obtiene el detalle de un Pokémon por nombre o id.
    func fetch(nameOrId: String) async {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)/\(nameOrId.lowercased())") else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Respuesta inválida"
                isLoading = false
                return
            }
            guard httpResponse.statusCode == 200 else {
                errorMessage = "Error \(httpResponse.statusCode): Pokémon no encontrado"
                isLoading = false
                return
            }

            pokemon = try JSONDecoder().decode(Pokemon.self, from: data)
        } catch {
            errorMessage = error.localizedDescription
            pokemon = nil
        }

        isLoading = false
    }
}
