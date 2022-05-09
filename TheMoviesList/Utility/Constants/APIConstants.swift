//
//  APIConstants.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 08/04/22.
//

import Foundation

/// Used to store API Constants
// MARK: - APIConstants
struct APIConstants {
    
    // MARK: - Server Side details
    struct Server {
        static let baseURL = Domains.runtime
        static let environmentName = Domains.environmentName
    }
    
    private struct Domains {
        static let  runtime = Bundle.main.infoDictionary?["BaseUrl"] as? String ?? DefaultValues.empty
        static let environmentName = Bundle.main.infoDictionary?["Environment"] as? String ?? DefaultValues.empty
    }
    
    // MARK: - Response Status
    struct status {
        static let OK = "OK"
        static let NOK = "NOK"
        static let REQUEST_FAIL = "FAIL"
        static let NETWORK_UNAVAILABLE = "NETWORK_UNAVAILABLE"
        static let RESOURCE_UNAVAILABLE = "RESOURCE_UNAVAILABLE"
        static let SUCCESS = "SUCCESS"
        static let FAILURE = "FAILURE"
    }
    
    // MARK: - Routes
    struct Routes {
        
        // MARK: - Auth Flow
        static let movieList = "https://api.themoviedb.org/3/movie/popular?api_key=7a026ebaf005c4b190b607a488c7babb&language=en-US&page=1"
        static let movieDetail = "https://api.themoviedb.org/3/movie/?api_key=7a026ebaf005c4b190b607a488c7babb&language=en-US"
    }
    
}

