//
//  APIRouter.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 12/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import Alamofire

enum APIRouter: URLRequestConvertible {
    
    
    case photoList(page: Int, limit: Int)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .photoList:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .photoList:
            return "/list"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .photoList(let page, let limit):
            return [Const.APIParameterKey.page: page, Const.APIParameterKey.limit: limit]
        }
        
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try Const.ServerURL.baseURL.asURL()
        var  urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(Const.ContentType.json.rawValue, forHTTPHeaderField: Const.HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(Const.ContentType.json.rawValue, forHTTPHeaderField: Const.HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if method == .get {
            return try URLEncoding.default.encode(urlRequest, with: parameters)
        } else {
            if let parameters = parameters {
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
                }
            }
            return urlRequest
        }
    }
}

