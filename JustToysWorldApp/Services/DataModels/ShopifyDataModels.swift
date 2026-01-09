//
//  ShopifyDataModels.swift
//  JustToysWorldApp
//
//  Created by Satyam on 01/12/25.
//


import Foundation

// MARK: - Login

struct AuthCredentials: Codable {
    let email: String
    let password: String

}
// MARK: - Signup
struct SignupRequest: Codable {
    let email: String
    let password: String
    let firstname: String
    let lastname: String
}
// MARK: - Customer
struct CustomerRequest: Codable {
    let email: String
    
}

// MARK: - GraphQL Request Structure & Helpers

struct GraphQLPayload: Encodable {
    let query: String
    let variables: [String: Any]?
    
    private enum CodingKeys: String, CodingKey {
        case query, variables
    }
    
    // Custom encoding to handle [String: Any] variables for Alamofire payload
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        
        if let variables = variables {
            // Serialize and re-parse to handle the nested [String: Any] dictionary
            let data = try JSONSerialization.data(withJSONObject: variables, options: [])
            let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            
            var varsContainer = container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .variables)
            if let dict = dict as? [String: Any] {
                try varsContainer.encodeAny(dict)
            }
        }
    }
}


struct DynamicCodingKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int?
    init?(intValue: Int) { self.intValue = intValue; self.stringValue = String(intValue) }
}

extension KeyedEncodingContainer where Key == DynamicCodingKey {
    mutating func encodeAny(_ value: [String: Any]) throws {
        for (key, val) in value {
            let codingKey = DynamicCodingKey(stringValue: key)!
            if let str = val as? String {
                try self.encode(str, forKey: codingKey)
            } else if let int = val as? Int {
                try self.encode(int, forKey: codingKey)
            } else if let bool = val as? Bool {
                try self.encode(bool, forKey: codingKey)
            } else if let dict = val as? [String: Any] {
                // Recursive call for nested dictionaries
                try self.encode(dict, forKey: codingKey)
            } else if let array = val as? [String] {
                // Handle simple array of strings (e.g., tags)
                try self.encode(array, forKey: codingKey)
            } else {
                // Catch-all for unsupported types in the helper
                throw EncodingError.invalidValue(val, EncodingError.Context(codingPath: codingPath, debugDescription: "Unsupported value type in [String: Any] encoder helper."))
            }
        }
    }
    
    mutating func encode(_ value: [String: Any], forKey key: KeyedEncodingContainer<DynamicCodingKey>.Key) throws {
        var nestedContainer = self.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: key)
        try nestedContainer.encodeAny(value)
    }
}


// MARK: - GraphQL Response Container & Error Models

struct GraphQLResponse<T: Decodable>: Decodable {
    let data: T? // The data object returned by the successful query/mutation
    let errors: [GraphQLError]? // Errors specific to the GraphQL engine (e.g., syntax error)
}

/// Standard GraphQL error model.
struct GraphQLError: Decodable {
    let message: String
}

/// User-facing errors returned inside mutation payloads (e.g., invalid password).
struct UserError: Decodable {
    let message: String
    let field: [String]?
}


// MARK: - Specific Mutation Payloads

struct CustomerMutationPayload<T: Decodable>: Decodable {
    let customerAccessTokenCreate: T? // Used for Login
    let customerCreate: T? // Used for Signup
    
    // Use coding keys to determine which field is present
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        customerAccessTokenCreate = try? container.decodeIfPresent(T.self, forKey: DynamicCodingKey(stringValue: "customerAccessTokenCreate")!)
        customerCreate = try? container.decodeIfPresent(T.self, forKey: DynamicCodingKey(stringValue: "customerCreate")!)
    }
}
//MARK: -  --------RESPONSE ------------
//  Login Response (The actual type inside CustomerMutationPayload)
struct LoginResponse: Decodable {
    let customerAccessToken: AccessToken?
    let customerUserErrors: [UserError]?
    
    struct AccessToken: Decodable {
        let accessToken: String
        let expiresAt: String
    }
}

// Signup Response (The actual type inside CustomerMutationPayload)
struct SignupResponse: Decodable {
    let customer: Customer?
    let customerUserErrors: [UserError]?
    
//    struct Customer: Decodable {
//        let id: String
//        let email: String
//    }
}
//MARK: -  Product Response

struct ProductsResponse: Decodable {
    // The key "products" holds an array of ProductDetails objects.
    let products: [ProductDetails]
}

/// Represents a single product object from the REST API payload.
struct ProductDetails: Identifiable, Decodable {
    // Use Int64 for large Shopify IDs, then convert to String for Identifiable
    let id: Int64
    let title: String
    let handle: String
    let body_html: String?
    let vendor: String
    let variants: [ProductVariant]
    let images: [ProductImage]
    // The 'image' field is also present, but 'images' is more reliable.

    // Conforming to Identifiable
    var identifier: String {
        return String(self.id)
    }

    /// Converts the complex network model into the simple domain model.
    var domainProduct: Products {
        // Safely get the first variant's price, convert String to Double
        let priceString = variants.first?.price ?? "0.0"
        let price = Double(priceString) ?? 0.0

        // Safely get the first image URL
        let imageUrl = images.first?.src
        
        return Products(
            id: identifier, // Use the converted String ID
            title: title,
           // handle: handle,
            price: price,
            imageUrl: imageUrl
        )
    }
}
/// Represents the nested image details in the REST response.
struct ProductImage: Decodable {
    let src: String // The actual image URL
    // We don't need the other fields (id, alt, etc.) for display
}

/// Represents the nested variant details in the REST response.
struct ProductVariant: Decodable {
    let id: Int64
    let price: String // Price comes as a String
    let title: String
}

//MARK: -  Customer Details
/// Root response holding customers array
struct CustomersResponse: Decodable {
    /// The key "customers" holds an array of CustomerDetails objects.
    let customers: [CustomerDetails]
}

/// Represents a single customer object from the REST API payload.
struct CustomerDetails: Identifiable, Decodable {

    /// Shopify customer ID (large number)
    let id: Int64
    let first_name: String
    let last_name: String
    let email: String
    let phone: String?
    let state: String
    let verified_email: Bool
    let created_at: String
    let updated_at: String
    let currency: String
    let orders_count: Int
    let total_spent: String
    //let addresses: [CustomerAddress]
    //let email_marketing_consent: EmailMarketingConsent?

    /// Conforming to Identifiable
    var identifier: String {
        return String(id)
    }

    /// Converts API model → App domain model
    var domainCustomer: Customer {
        return Customer(
            id: identifier,
            firstName: first_name,
            lastName: last_name,
            email: email,
            phone: phone,
            isVerified: verified_email,
            currency: currency,
            totalSpent: Double(total_spent) ?? 0.0
        )
    }
}
struct Customer:Identifiable, Decodable{
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let isVerified: Bool
    let currency: String
    let totalSpent: Double
}

//struct SearchProduct: Identifiable, Equatable {
//    let id: String
//    let title: String
//    let handle: String
//    /// Simplified price, converted from the API's String.
//    let price: Double
//    /// Simplified primary image URL.
//    let imageUrl: String?
//}
//
//// MARK: - 2. Minimal Network Models (Matching the GraphQL JSON Structure)
//
///// The root response, skipping the top-level "data" key to access the "products" connection directly.
//struct SearchResponse: Decodable {
//    // Nested structure to handle: data -> products
//    let data: ProductConnectionWrapper
//    
//    // Helper to get the flattened list of domain products
//    var domainProducts: [SearchProduct] {
//        return data.products.edges.map { $0.node.domainProduct }
//    }
//    
//    /// Helper struct to access the nested 'data' key.
//    struct ProductConnectionWrapper: Decodable {
//        let products: ProductsConnection
//    }
//}
//
///// Represents the connection layer (products), containing the list of products (edges) and pagination.
//struct ProductsConnection: Decodable {
//    let edges: [ProductEdge]
//    let pageInfo: PageInfo
//}
//
///// Represents a single item in the `edges` array, which holds the actual product (`node`).
//struct ProductEdge: Decodable {
//    let node: GraphQLProductNode
//}
//
///// Pagination information (kept separate as it's simple and useful).
//struct PageInfo: Decodable {
//    let hasNextPage: Bool
//    let hasPreviousPage: Bool
//}
//
//
//// MARK: - 3. Specialized Data Wrappers (Reducing Boilerplate)
//
///// Handles the nested structure of a product's primary image: images -> edges[0] -> node -> url.
//struct ImageURLWrapper: Decodable {
//    let edges: [ImageNodeWrapper]
//    
//    var firstImageUrl: String? {
//        return edges.first?.node.url
//    }
//    
//    struct ImageNodeWrapper: Decodable {
//        let node: URLContainer
//        
//        struct URLContainer: Decodable {
//            let url: String
//        }
//    }
//}
//
///// Handles the nested structure of the minimum price: priceRange -> minVariantPrice.
//struct PriceWrapper: Decodable {
//    let minVariantPrice: PriceDetails
//    
//    struct PriceDetails: Decodable {
//        // Price amount is kept as String for precision during decoding
//        let amount: String
//        let currencyCode: String
//    }
//}
//
//
//// MARK: - 4. Network Node with Domain Conversion
//
///// Represents the core product data nested under "node" in the GraphQL response.
///// This is the key struct that performs the conversion to the clean Domain Model.
//struct GraphQLProductNode: Decodable {
//    let id: String
//    let title: String
//    let handle: String
//    let vendor: String
//    
//    // Use the specialized wrappers for complex fields
//    let images: ImageURLWrapper
//    let priceRange: PriceWrapper
//    
//    /// Converts the complex network structure into the simplified domain model.
//    var domainProduct: SearchProduct {
//        // 1. Extract and convert price (String to Double)
//        let priceString = self.priceRange.minVariantPrice.amount
//        let price = Double(priceString) ?? 0.0
//
//        // 2. Safely extract the primary image URL
//        let imageUrl = self.images.firstImageUrl
//        
//        return SearchProduct(
//            id: self.id,
//            title: self.title,
//            handle: self.handle,
//            price: price,
//            imageUrl: imageUrl
//        )
//    }
//}
