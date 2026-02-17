//
//  PokemonDetailView.swift
//  kemonList
//
//  Pantalla de detalle de un Pokémon. Carga los datos por nameOrId.
//

import SwiftUI

struct PokemonDetailView: View {
    let nameOrId: String
    @StateObject private var viewModel = PokemonDetailViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if let pokemon = viewModel.pokemon {
                pokemonDetailContent(pokemon)
            } else {
                ContentUnavailableView("Sin datos", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle(viewModel.pokemon?.displayName ?? nameOrId.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.fetch(nameOrId: nameOrId) }
    }
    
    /// Indicador de carga mientras se obtiene el detalle.
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Cargando Pokémon...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Vista de error con opción de reintentar.
    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Error", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(message)
        } actions: {
            Button("Reintentar") { Task { await viewModel.fetch(nameOrId: nameOrId) } }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Contenido del detalle: imagen, datos y estadísticas.
    private func pokemonDetailContent(_ pokemon: Pokemon) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if let url = pokemon.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 200, height: 200)
                }
                
                VStack(spacing: 4) {
                    Text(pokemon.displayName)
                        .font(.title.bold())
                    Text("#\(String(format: "%03d", pokemon.id))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text(pokemon.typesDisplay)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 32) {
                    labelValue(label: "Altura", value: "\(pokemon.height) dm")
                    labelValue(label: "Peso", value: "\(pokemon.weight) kg")
                }
                
                if let exp = pokemon.baseExperience {
                    labelValue(label: "Exp. base", value: "\(exp)")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estadísticas base")
                        .font(.headline)
                    
                    ForEach(pokemon.stats, id: \.stat.name) { stat in
                        HStack {
                            Text(statName(stat.stat.name))
                                .frame(width: 100, alignment: .leading)
                            ProgressView(value: Double(stat.baseStat), total: 255)
                                .tint(progressColor(for: stat.stat.name))
                            Text("\(stat.baseStat)")
                                .frame(width: 30, alignment: .trailing)
                                .font(.caption.monospacedDigit())
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
    
    /// Etiqueta con su valor (altura, peso, etc.).
    private func labelValue(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }
    
    /// Traduce el nombre de la stat al español.
    private func statName(_ name: String) -> String {
        switch name {
        case "hp": return "PS"
        case "attack": return "Ataque"
        case "defense": return "Defensa"
        case "special-attack": return "At. Esp."
        case "special-defense": return "Def. Esp."
        case "speed": return "Velocidad"
        default: return name.capitalized
        }
    }
    
    /// Color de la barra según el tipo de stat.
    private func progressColor(for stat: String) -> Color {
        switch stat {
        case "hp": return .green
        case "attack": return .red
        case "defense": return .blue
        case "special-attack": return .orange
        case "special-defense": return .purple
        case "speed": return .yellow
        default: return .gray
        }
    }
}
