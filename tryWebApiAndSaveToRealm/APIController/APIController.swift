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
import Reachability

class ApiController {
    
    struct Domain {
        static let baseUrl = URL(string: "https://service.e-materials.com/api")!
        static let baseTrackerURL = URL(string: "http://tracker.e-materials.com/")!
    }
    
    /// The shared instance
    static var shared = ApiController()
    
    /// The api key to communicate with Navus
    private let apiKey = "sv5NPptQyZHkBDx4fkMgNhO2Z4ONl4VP"
    
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
    
    func reportSingleCode(report: CodeReport?) -> Observable<(CodeReport,Bool)> {
        
        guard let report = report else {return Observable.empty()}
        
        let params = report.getPayload()
        
        return buildRequest(base: Domain.baseTrackerURL,
                            method: "POST",
                            pathComponent: "attendances",
                            params: params)
            .map { data in
                guard let object = try? JSONSerialization.jsonObject(with: data),
                    let json = object as? [String: Any],
                    let created = json["created"] as? Int, created == 201 else {
                        return (report, false)
                }
                return (report, true)
            }
            .catchErrorJustReturn((report, false))
    }
    
    func reportMultipleCodes(reports: [CodeReport]?) -> Observable<Bool> {
        
        guard let reports = reports else {return Observable.empty()}
        
        let params = CodeReport.getPayload(reports)
        
        return buildRequest(base: Domain.baseTrackerURL,
                            method: "POST",
                            pathComponent: "attendances",
                            params: params)
            .map() { data in
                guard let object = try? JSONSerialization.jsonObject(with: data),
                    let json = object as? [String: Any],
                    let created = json["created"] as? Int, created == 201 else {
//                        print("reportCodes vraca FALSE!!")
                    return false
                }
//                print("reportCodes vraca TRUE!!")
            return true
        }
    }
    
    // Session
    
    func reportSelectedSession(report: SessionReport?) -> Observable<(SessionReport,Bool)> {
        
        guard let report = report else {return Observable.empty()}
        
        let params = report.getPayload()
        
        return buildRequest(base: Domain.baseTrackerURL,
                            method: "PUT",
                            pathComponent: "devices/DEVICE_ID",
                            params: params)
            .map { data in
                guard let object = try? JSONSerialization.jsonObject(with: data),
                    let json = object as? [String: Any],
                    let created = json["created"] as? Int, created == 201 else {
                        return (report, false)
                }
                return (report, true)
            }
            .catchErrorJustReturn((report, false))
    }
 
    
    //MARK: - Private Methods
    
    /** * Private method to build a request with RxCocoa */
    
    // bez veze je Any... // treba ili [(String, String)] ili [String: Any]
    
    private func buildRequest(base: URL = Domain.baseUrl, method: String = "GET", pathComponent: String, params: Any) -> Observable<Data> {
    
        //print("APIController.buildingRequest.calling API !!!")
        
        let url = base.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)

        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" || method == "PUT" {
            guard let params = params as? [(String, String)] else {
                return Observable.empty()
            }
            let queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            urlComponents.queryItems = queryItems
            
        } else {
            guard let params = params as? [String: Any] else {
                return Observable.empty()
            }
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
            
//            print("response.statusCode = \(response.statusCode)")
            
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
