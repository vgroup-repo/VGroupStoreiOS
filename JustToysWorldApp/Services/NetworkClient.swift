//
//  NetworkClient.swift
//  JustToysWorldApp
//
//  Created by Satyam on 27/11/25.
//


import Foundation
import Combine
import Alamofire

//MARK: Fresh API method
struct ShopifyConfig {
    static let SHOP_NAME = ""
    static let STOREFRONT_API_ACCESS_TOKEN = ""
    static let ADMIN_API_ACCESS_TOKEN = ""
    static let API_VERSION = ""
    static let baseURL = ""
    
    
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - 2. Protocol: Decoupling and Testability
protocol NetworkService {
    /// Generic method to perform any GraphQL request and decode the response model.
    func performGraphQLRequest<T: Decodable>(route: APIRoute, model: T.Type) -> AnyPublisher<T, APIError>
}


// MARK: - 3. Error Handling
enum APIError: Error {
    case invalidURL
    case networkError(AFError)
    case decodingError(Error)
    case apiError(String)
    case unauthorized
    case graphQLErrors([String]) // Handles errors returned in the top-level GraphQL 'errors' array
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "The service URL is invalid."
        case .networkError(let error): return "Network failed: \(error.localizedDescription)"
        case .decodingError(let error): return "Data format error: \(error.localizedDescription)"
        case .apiError(let message): return "API Error: \(message)"
        case .unauthorized: return "Authentication required."
        case .graphQLErrors(let messages): return "GraphQL Engine Error(s): \(messages.joined(separator: ", "))"
        case .unknown: return "An unexpected error occurred."
        }
    }
}

// MARK: - 4. Route Definition (GraphQL Operations)
/// Defines all GraphQL operations using the mutation/query string and variables.
enum APIRoute: URLRequestConvertible {
    
    var apiMethod: Alamofire.HTTPMethod  {
            switch self {
            case .graphqlProducts,.graphqlCustomerDetails:
                return .get
            case .graphqlLogin, .graphqlSignup, .graphqlProductsSearch, .graphqlProduct, .graphqlCartCreate, .graphqlCartAdd:
                return .post
            
            }
        }
    // --- AUTHENTICATION ---
    case graphqlLogin(credentials: AuthCredentials)
    case graphqlSignup(customer: SignupRequest)
    case graphqlCustomerDetails(customer: CustomerRequest)
    
    // --- SHOP DATA ---
    case graphqlProducts
    case graphqlProduct(handle: String)
    //----search----
    case graphqlProductsSearch(searchTerm:String)
    
    
    // --- CART MANAGEMENT ---
    case graphqlCartCreate(variantId: String, quantity: Int)
    case graphqlCartAdd(cartId: String, variantId: String, quantity: Int)
    
    // MARK: - GraphQL Query String
    
    var query: String {
        switch self {
        case .graphqlLogin:
            return """
            mutation customerAccessTokenCreate($input: CustomerAccessTokenCreateInput!) { customerAccessTokenCreate(input: $input) { customerAccessToken { accessToken expiresAt } customerUserErrors { field message } } }
            """
            
        case .graphqlSignup:
            return """
            mutation customerCreate($input: CustomerCreateInput!) { customerCreate(input: $input) { customer { id email firstName lastName } customerUserErrors { field message } } }
            """
            
        case .graphqlProducts:
            return ""
            
        case .graphqlProduct:
            return """
            query productByHandle($handle: String!) {
              product(handle: $handle) {
                id
                title
                descriptionHtml
                variants(first: 1) { edges { node { id price { amount } } } }
              }
            }
            """
            
        case .graphqlCartCreate:
            // Corrected query structure (userErrors is outside the Cart object)
            return """
            mutation cartCreate($input: CartInput!) {
              cartCreate(input: $input) {
                cart { id createdAt totalQuantity }
                userErrors { message field }
              }
            }
            """
            
        case .graphqlCartAdd:
            // Corrected query structure (userErrors is outside the Cart object)
            return """
            mutation cartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
              cartLinesAdd(cartId: $cartId, lines: $lines) {
                cart { id totalQuantity }
                userErrors { message field }
              }
            }
            """
        case.graphqlProductsSearch:
            return """
                query ProductSearch($searchTerm: String!) { \n  products(first: 20, query: $searchTerm) { \n    edges { \n      node { \n        id\n        title\n        handle\n        vendor\n        images(first: 1) { \n          edges { \n            node { \n              url\n            } \n          } \n        }\n        priceRange { \n          minVariantPrice { \n            amount\n            currencyCode\n          }\n        }\n      }\n    }\n    pageInfo { \n      hasNextPage\n      hasPreviousPage\n    }\n  }\n}
                """
        case .graphqlCustomerDetails:
            return ""
        }
    }
    
    // MARK: - GraphQL Variables Dictionary
    
    var variables: [String: Any]? {
        switch self {
        case .graphqlLogin(let c):
            return ["input": ["email": c.email, "password": c.password]]
            
        case .graphqlSignup(let s):
            return ["input": [
                "email": s.email,
                "password": s.password,
                "firstName": s.firstname,
                "lastName": s.lastname
            ]]
            
        case .graphqlProducts:
            return nil
            
        case .graphqlProduct(let handle):
            return ["handle": handle]
            
        case .graphqlCartCreate(let variantId, let quantity):
            return ["input": [
                "lines": [
                    ["merchandiseId": variantId, "quantity": quantity]
                ]
            ]]
            
        case .graphqlCartAdd(let cartId, let variantId, let quantity):
            return [
                "cartId": cartId,
                "lines": [
                    ["merchandiseId": variantId, "quantity": quantity]
                ]
            ]
        case .graphqlProductsSearch(searchTerm: let searchTerm):
            let safeQuery = searchTerm
                   .replacingOccurrences(of: "\"", with: "")  // remove invalid chars
                   .trimmingCharacters(in: .whitespacesAndNewlines)

               return [
                   "searchTerm": "title:*\(safeQuery)*"
               ]
        case .graphqlCustomerDetails(customer: let customer):
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible Implementation
    func asURLRequest() throws -> URLRequest {
           
           var urls: String = ""
           let isGraphQLRequest: Bool
           
           switch self {
           case .graphqlProducts: // Renamed from .graphqlProducts for REST endpoint clarity
               urls = ShopifyConfig.baseURL + "/admin/api/\(ShopifyConfig.API_VERSION)/products.json"
               isGraphQLRequest = false
           case .graphqlProductsSearch:
               urls = ShopifyConfig.baseURL + "/admin/api/\(ShopifyConfig.API_VERSION)/graphql.json"
               isGraphQLRequest = false
           case .graphqlCustomerDetails(customer: let customer):
               urls = ShopifyConfig.baseURL + "/admin/api/\(ShopifyConfig.API_VERSION)/customers/search.json?query=email:\(customer.email)"
               isGraphQLRequest = false
               //https://githubcode.myshopify.com/admin/api/2024-10/customers/search.json?query=email:satyamk@vgroupinc.com
           default:
               // All other cases (assuming they are GraphQL)
               urls = ShopifyConfig.baseURL + "/api/\(ShopifyConfig.API_VERSION)/graphql.json"
               isGraphQLRequest = true
           }
           
           guard let url = URL(string: urls) else {
               throw APIError.invalidURL
           }
           
           var urlRequest = URLRequest(url: url)
        urlRequest.method = apiMethod
           // --- 1. Set Method and Headers ---
           if isGraphQLRequest {
               // GraphQL requests (default case) use POST and the Storefront Token
               //urlRequest.method = .post
               urlRequest.setValue(ShopifyConfig.STOREFRONT_API_ACCESS_TOKEN, forHTTPHeaderField: "X-Shopify-Storefront-Access-Token")
               
           } else {
               // REST product list request uses GET and the Admin Token
               //urlRequest.method = .get
               urlRequest.setValue(ShopifyConfig.ADMIN_API_ACCESS_TOKEN, forHTTPHeaderField: "X-Shopify-Access-Token")
           }
           
           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           // --- 2. CRITICAL FIX: Conditionally Set the Body ---
           // The body payload (GraphQL query) must ONLY be included for POST requests.
           if isGraphQLRequest {
               let payload = GraphQLPayload(query: self.query, variables: self.variables)
               
               do {
                   let jsonData = try JSONEncoder().encode(payload)
                   urlRequest.httpBody = jsonData // Only set body for POST/GraphQL requests
               } catch {
                   throw APIError.decodingError(error)
               }
           }
           
           print("urlRequest", urlRequest)
           return urlRequest
       }
   }

class ShopifyNetworkClient {
    private func isRESTProductRoute(route: APIRoute) -> Bool {
        if case .graphqlProducts = route {
            return true
        }
        if case .graphqlCustomerDetails = route {
            return true
        }
        return false
    }
    func performGraphQLRequest<T: Decodable>(route: APIRoute, model: T.Type) -> AnyPublisher<T, APIError> {
        
        let isRestProductsRoute = self.isRESTProductRoute(route: route)
        
        // 1. Initial Request and Data Extraction (Common to both pipelines)
        let dataPublisher = AF.request(route)
            .validate(statusCode: 200..<300)
            .publishData()
            .tryMap { response -> Data in
                // Handle basic HTTP errors
                if let afError = response.error { throw APIError.networkError(afError) }
                guard let data = response.data else {
                    throw APIError.decodingError(DecodingError.dataCorrupted(
                        DecodingError.Context(codingPath: [], debugDescription: "Response data was nil.")
                    ))
                }
                return data
            }
            .eraseToAnyPublisher()
        
        // 2. Select the Decoding Pipeline based on the route
        if isRestProductsRoute {
            // --- REST Pipeline: For endpoints like /products.json ---
            // Decodes the data directly into the expected model (T) without a 'data' wrapper.
            return dataPublisher
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error -> APIError in
                    if let apiError = error as? APIError { return apiError }
                    if let decodingError = error as? DecodingError { return APIError.decodingError(decodingError) }
                    if let afError = error as? AFError { return APIError.networkError(afError) }
                    return APIError.unknown
                }
                .eraseToAnyPublisher()
            
        } else {
            // --- GraphQL Pipeline: For standard GraphQL endpoints ---
            // This is the original logic that expects the 'data' and 'errors' wrapper.
            return dataPublisher
                .decode(type: GraphQLResponse<T>.self, decoder: JSONDecoder())
                .tryMap { graphQLResponse -> T in
                    // 1. Handle top-level GraphQL engine errors
                    if let errors = graphQLResponse.errors, !errors.isEmpty {
                        let messages = errors.map { $0.message }
                        throw APIError.graphQLErrors(messages)
                    }
                    
                    // 2. Extract the data payload (This is where your previous code failed for REST)
                    guard let data = graphQLResponse.data else {
                        // Throw the specific error if the payload wrapper is empty
                        throw APIError.apiError("GraphQL successful, but data payload was missing.")
                    }
                    return data
                }
                .mapError { error -> APIError in
                    if let apiError = error as? APIError { return apiError }
                    if let decodingError = error as? DecodingError { return APIError.decodingError(decodingError) }
                    if let afError = error as? AFError { return APIError.networkError(afError) }
                    return APIError.unknown
                }
                .eraseToAnyPublisher()
        }
    }
}

