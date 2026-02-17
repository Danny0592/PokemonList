//
//  ContentView.swift
//  kemonList
//
//  Created by daniel ortiz millan on 16/02/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @State private var searchText = ""

    /// Lista filtrada por el texto de búsqueda.
    var filteredList: [PokemonListItem] {
        guard !searchText.isEmpty else { return viewModel.pokemonList }
        return viewModel.pokemonList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if viewModel.pokemonList.isEmpty {
                    emptyListView
                } else if filteredList.isEmpty {
                    noResultsView
                } else {
                    pokemonListView
                }
            }
            .navigationTitle("Pokémon List")
            .searchable(text: $searchText, prompt: "Buscar Pokémon")
            .task { await viewModel.fetchList() }
            .refreshable { await viewModel.fetchList() }
        }
    }
    
    /// Indicador de carga mientras se obtiene la lista.
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Cargando lista...")
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
            Button("Reintentar") { Task { await viewModel.fetchList() } }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Vista cuando la lista está vacía.
    private var emptyListView: some View {
        ContentUnavailableView(
            "Sin Pokémon",
            systemImage: "list.bullet",
            description: Text("Arrastra para recargar")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Vista cuando la búsqueda no tiene coincidencias.
    private var noResultsView: some View {
        ContentUnavailableView.search(text: searchText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Lista de Pokémon con navegación al detalle.
    private var pokemonListView: some View {
        List(filteredList) { item in
            NavigationLink(value: item) {
                PokemonListRow(item: item)
            }
        }
        .navigationDestination(for: PokemonListItem.self) { item in
            PokemonDetailView(nameOrId: item.name)
        }
    }
}

// MARK: - Fila de la lista
/// Fila individual de la lista con sprite, nombre y número.
struct PokemonListRow: View {
    let item: PokemonListItem

    var body: some View {
        HStack(spacing: 12) {
            spriteView
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayName)
                    .font(.headline)
                Text("#\(String(format: "%03d", item.id))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    /// Imagen del Pokémon o placeholder si falla.
    @ViewBuilder
    private var spriteView: some View {
        if let url = item.spriteURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ContentView()
}
