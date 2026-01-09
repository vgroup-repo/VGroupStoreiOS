//
//  SearchView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//


import SwiftUI
import CoreData

struct SearchView: View {
    @Environment(\.managedObjectContext) private var context
    
    @State private var searchText: String = ""
    @State private var results: [CDProduct] = []
    @State private var showResults: Bool = false
    
    let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]
    
    var body: some View {
        VStack {
            SearchBar(searchText: $searchText, onSearch: {
                print("$searchText>>>>>",searchText)
                performSearch()
            })
            .padding(.bottom, 15)
            
            
            
            if showResults {
                if results.isEmpty {
                    Text("No results found")
                        .font(.montserrate(.bold, size: 18))
                        .foregroundColor(.buttonColor)
                        .padding(.leading)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(results, id: \.objectID) { cdProduct in
                                if let domain = cdProduct.domainProductss {
                                    ProductCard(product: domain)
                                }
                            }
                        }
                        .padding()
                    }
                }
            } else {
                Text("Type a query and press Search")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        
        .background(Color(UIColor.white))
        .safeAreaInset(edge: .top) {
            LogoHeader()
                .padding(.bottom, 10)
        }
    }
    
    // MARK: - Search action
    private func performSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        guard !query.isEmpty else {
            results = []
            showResults = false
            return
        }
        let productFatch: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        productFatch.predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        productFatch.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        productFatch.fetchLimit = 200
        
        do {
            let fetched = try context.fetch(productFatch)
            results = fetched
            showResults = true
        } catch {
            print("CoreData fetch error:", error)
            results = []
            showResults = true
        }
    }
}
