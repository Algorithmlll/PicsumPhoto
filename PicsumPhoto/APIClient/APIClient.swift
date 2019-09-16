//
//  APIClient.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 12/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import Alamofire

class APIClient {
    
    @discardableResult
    private static func performRequest<T:Decodable>(route:APIRouter, decoder: JSONDecoder = JSONDecoder(), completion:@escaping (Result<T, AFError>)->Void) -> DataRequest {
        return AF.request(route)
            .responseDecodable (decoder: decoder){ (response: DataResponse<T, AFError>) in
                completion(response.result)
        }
    }
    
    static func photoList(page: Int, limit: Int = 10, completion:@escaping (Result<[Photo], AFError>) -> Void) {
        performRequest(route: APIRouter.photoList(page: page, limit: limit), completion: completion)
    }
}
