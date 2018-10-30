//
//  APIController.swift
//  tryObservableWebApiAndRealm
//
//  Created by Marko Dimitrijevic on 19/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import CoreLocation
import MapKit

class ApiController {
    
    /// The shared instance
    static var shared = ApiController()
    
    /// The api key to communicate with Navus
    let apiKey = "sv5NPptQyZHkBDx4fkMgNhO2Z4ONl4VP"
    
    /// API base URL
    let baseURL = URL(string: "https://service.e-materials.com/api")!
    
    init() {
        Logging.URLRequests = { request in
            return true
        }
    }
    
    //MARK: - Api Calls
    func getRooms(updated_from: Date?, with_pagination: Int, with_trashed: Int) -> Observable<[Room]> {
        let updatedDate = updated_from?.toString(format: Date.defaultFormatString) ?? ""
        return buildRequest(pathComponent: "locations",
                            params: [("updated_from", updatedDate),
                                     ("with_pagination", "\(with_pagination)"),
                                     ("with_trashed", "\(with_trashed)")])
            .map() { json in
                let decoder = JSONDecoder()
                guard let rooms = try? decoder.decode(Rooms.self, from: json) else {
                    throw ApiError.invalidJson
                }
                return rooms.data
            }
    }
    
    func getBlocks(updated_from: Date?, with_pagination: Int, with_trashed: Int) -> Observable<[Block]> {
        let updatedDate = updated_from?.toString(format: Date.defaultFormatString) ?? ""
        return buildRequest(pathComponent: "blocks",
                            params: [("updated_from", updatedDate),
                                     ("with_pagination", "\(with_pagination)"),
                                     ("with_trashed", "\(with_trashed)")])
            .map() { json in
                let decoder = JSONDecoder()
                guard let blocks = try? decoder.decode(Blocks.self, from: json) else {
                    throw ApiError.invalidJson
                }
                return blocks.data
            }
    }
    
    
    //MARK: - Api Calls
    func reportCodes(reports: [CodeReport]?) -> Observable<Bool> {
        
        guard let report = reports?.first else {return Observable.empty()} // hard-coded...!
        
        let params = report.getPayload()
        
        return buildRequest(pathComponent: "attendances",
                            params: params)
            .map() { data in
                guard let object = try? JSONSerialization.jsonObject(with: data),
                    let json = object as? [String: Any],
                    let created = json["created"] as? Int, created == 201 else {
                    return false
                }
            return true
        }
    }
    
    //MARK: - Private Methods
    
    /** * Private method to build a request with RxCocoa */
    
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        
        print("APIController.buildingRequest.calling API !!!")
        
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)

        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            let queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            urlComponents.queryItems = queryItems
        } else {
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        let deviceUdid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        request.allHTTPHeaderFields = ["Api-Key": apiKey,
                                       "device-id": deviceUdid]
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.response(request: request).map() { response, data in
            if 201 == response.statusCode {
                return try! JSONSerialization.data(withJSONObject:  ["created": 201])
            } else if 200 ..< 300 ~= response.statusCode {
                print("buildRequest.imam data... all good")
                return data
            } else if response.statusCode == 401 {
                print("buildRequest.ApiError.invalidKey")
                throw ApiError.invalidKey
            } else if 400 ..< 500 ~= response.statusCode {
                print("buildRequest.ApiError.cityNotFound")
                throw ApiError.cityNotFound
            } else {
                print("buildRequest.ApiError.serverFailure")
                throw ApiError.serverFailure
            }
        }
    }
    
}

enum ApiError: Error {
    case invalidJson
    case invalidKey
    case cityNotFound
    case serverFailure
}
