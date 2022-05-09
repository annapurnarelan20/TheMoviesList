//
//  MovieListApiService.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 19/04/22.
//

import Foundation
typealias resultType = (Result<Any?, FailureError>) -> Void

enum FailureError: Error {
    case fail(String)
    case authorisationError(String)
    case newUpdate(String)
}
class MovieListApiService {
    
    func requestData(params: Dictionary<String, Any> , completion:  @escaping resultType) {
        let jsonParam = [:] as [String: Any]
        
        APIManager.requestData(url: APIConstants.Routes.movieList, method: .post , parameters: jsonParam, isMockingEnable : (true , "MoMockService"), completion: { (result: ApiResult<MovieListModel>) in
            
            switch result {
            case .success(let movieList):
                completion(.success(movieList))
            case .failure(let failure):
                completion(.failure(.fail(failure)))
            case .authorisationError(let message):
                completion(.failure(.authorisationError(message)))
            case .newUpdate(let message):
                completion(.failure(.authorisationError(message)))
            }
        })
    }
    
}
