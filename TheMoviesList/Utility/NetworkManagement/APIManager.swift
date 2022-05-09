//
//  APIManager.swift
//  TheMoviesList
//
//  Created by Annapurna Relan on 08/04/22.
//


import Alamofire

typealias parameters = [String:Any]

/// Generic Enum to capture sucess / Failure Cases
enum ApiResult<T: Codable> {
    case success(T)
    case failure(String)
    case authorisationError(String)
    case newUpdate(String)
}

/// Responsible for handling  API call
class APIManager {
    
    static var header: HTTPHeaders = ["Content-Type": "application/json", "accept": "application/json"]
    static let networkReachabilityManager = NetworkReachabilityManager(host: "www.apple.com")
    static var apiEndpointToTrack = DefaultValues.empty
    
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    enum RequestError: Error {
        case unknownError
        case connectionError
        case authorizationError(NSDictionary)
        case sessionError
        case serverError
        case newUpdate(NSDictionary)
    }
    
    private enum StatusCode: Int {
        case sessionExpire = 401
        case twoFactorAuthorization  = 403
        case defaultErrorCode = -1
        case versionUpdate = 426
    }
    
    enum NetworkError: String {
        case versionUpdateError = "The application version you are currently running has been marked obsolete by your administer. Kindly upgrade to the latest version to continue using the application."
        case internetError = "Check your Internet connection."
        case unKnownError = "Something went wrong. Please try again later."
        case sessionExpire = "Your last session has expired. Please login again."
        case serverError = "We can not process your request at the moment."
        case noDataAvailable = "No Data Available."
    }
    
    /// Check whether network connection is available or not.
    ///
    /// - Returns: Bool
    static func isNetworkReachable() -> Bool {
        return networkReachabilityManager?.isReachable ?? false
    }
    
    static func requestData<U: Codable>(url: String, method: Alamofire.HTTPMethod, parameters: parameters?, isEncryptedService: Bool = true, encoding : ParameterEncoding = JSONEncoding(),isMockingEnable: (flag: Bool, filename: String) = (false, ""), completion: @escaping (ApiResult<U>) -> Void) {
        
        /// Block to return Mock Response for the API
        if isMockingEnable.flag {
            self.mockJSONToModel(fileName: isMockingEnable.filename, completion: completion)
            return
        }
    
        var req: DataRequest
        let requestParam = [String: Any]()
           
        APIManager.header.add(name: "Authorization", value: "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI3YTAyNmViYWYwMDVjNGIxOTBiNjA3YTQ4OGM3YmFiYiIsInN1YiI6IjYyNGU4YzJiZDE5YTMzMDA2N2FkOWIyMCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.VE4mg7eDN4NMlx8E_w8dp5nl7UxQlx2qQ4H-laTLBNY")
        
      
        let endPoint =  url
        req = method == .post ? AF.request(endPoint, method: method, parameters: parameters, encoding: encoding, headers: APIManager.header) { $0.timeoutInterval = DefaultValues.timeOutInterval }: AF.request(URL(string:url) ?? "", method: method, encoding: encoding, headers: APIManager.header) { $0.timeoutInterval = DefaultValues.timeOutInterval }
        
        let arrApiEndpoint = url.split(separator: "/")
        apiEndpointToTrack = String(arrApiEndpoint.last ?? "")
        
        debugPrint("Req Parameters: \(parameters ?? [:])")
        debugPrint("Req Url: \(endPoint)")
        debugPrint("Encrypted request param: \(requestParam)")
        debugPrint("Headers: \(APIManager.header)")
        
        if isNetworkReachable() {
            req.validate(statusCode: 200..<600).responseJSON { response in
                
                switch response.result {
                case .failure(let error):
                    debugPrint(error)
                    switch error {
                    case .sessionTaskFailed(let urlError as URLError) where urlError.code == .timedOut:
                        debugPrint("Request timeout.")
                        sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: urlError.code.rawValue, failure: .unknownError, completion: completion)
                    default:
                        if isNetworkReachable() {
                            sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: StatusCode.defaultErrorCode.rawValue, failure: .unknownError, completion: completion)
                        } else {
                            sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: StatusCode.defaultErrorCode.rawValue, failure: .connectionError, completion: completion)
                        }
                    }
                case .success(let value):
                    let responseJson = value
                    debugPrint("responseCode: \(response.response?.statusCode ?? 200)")
                    debugPrint("Encrypted responseJSON: \(responseJson)")
                    
                    // TODO:- Comment below code when don't want to use Encryption, Decryption flow of API Response
                    _ = (responseJson as? [String: Any])?["encryptedResponse"] as? String
                    var encryptedResponseSecretKey = (responseJson as? [String: Any])?["encryptedResponseSecretKey"] as? String
                    encryptedResponseSecretKey = encryptedResponseSecretKey?.replacingOccurrences(of: "\n", with: DefaultValues.empty)
                    
                    if let status = response.response?.statusCode
                    {
                        switch status {
                        case 200:
                                self.convertJSONToModel(response: responseJson, completion: completion)
                        case 400...499:
                            if status == StatusCode.sessionExpire.rawValue && (url.contains("login")) {
                                sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: status, failure: .authorizationError(responseJson as? NSDictionary ?? [:]), completion: completion)
                            }

                            else if status == StatusCode.versionUpdate.rawValue  {
                                sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: status, failure: .newUpdate(responseJson as? NSDictionary ?? [:]), completion: completion)
                            }
                            else {
                                sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: status, failure: .authorizationError(responseJson as? NSDictionary ?? [:] ), completion: completion)
                            }
                        case 500...599:
                            if status == 500 {
                                sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: status, failure: .serverError, completion: completion)
                            } else {
                                sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: status, failure: .authorizationError(responseJson as? NSDictionary ?? [:] ), completion: completion)
                            }
                        default:
                            sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: StatusCode.defaultErrorCode.rawValue, failure: .unknownError, completion: completion)
                            break
                        }
                    }
                }
            }
        } else {
            sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: StatusCode.defaultErrorCode.rawValue, failure: .connectionError, completion: completion)
        }
    }
    
    /// Method to convert retrievied JSON from API call to Model Type
    ///
    /// - Parameter response: JSON
    /// - Completion: Completion Block
    private static func convertJSONToModel<T: Codable>(response: Any, completion: @escaping (ApiResult<T>)->Void) {
        let status = (((response as? [String: Any])?["responseMessage"] as? [String: Any])?["message"] as? String ?? "") == APIConstants.status.FAILURE ? APIConstants.status.NOK: APIConstants.status.OK
        switch status {
        case APIConstants.status.OK:
            if let jsonData = (response as? [String: Any])?["responseData"] as? [String: Any] {
                self.decodeJSON(response: jsonData, completion: completion)
            } else {
                self.decodeJSON(response: response, completion: completion)
            }
        case APIConstants.status.NOK:
            let message =  ((((response as? [String: Any])?["errorData"] as? [String: Any])?["message"] as? String) ?? APIManager.NetworkError.unKnownError.rawValue)
            completion(ApiResult.failure(message))
        default:
            sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: StatusCode.defaultErrorCode.rawValue, failure: .unknownError, completion: completion)
        }
    }
    
    /// Method to decode JSON into Model
    ///
    /// - Parameter response: JSON
    /// - Completion: Completion Block
    private static func decodeJSON<T: Codable>(response: Any, completion: @escaping (ApiResult<T>)->Void) {
        do {
            let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            let decoder = JSONDecoder()
            let model = try decoder.decode(T.self, from: data)
            
            completion(ApiResult.success(model))
        } catch {
            debugPrint(error)
            sendErrorType(apiEndpoint: apiEndpointToTrack, errorCode: StatusCode.defaultErrorCode.rawValue, failure: .unknownError, completion: completion)
        }
    }
    
    /// Method to send Error in the completion
    ///
    /// - Parameters:
    ///  - apiEndpoint: String
    ///  - errorCode: Int
    ///  - failure: Error of RequestError Type
    ///  - Completion: Completion Block
    private static func sendErrorType<T: Codable>(apiEndpoint: String = DefaultValues.empty, errorCode: Int = DefaultValues.int, failure: RequestError, completion: @escaping (ApiResult<T>)->Void) {
        switch failure {
        case .connectionError:
            completion(ApiResult.failure(APIManager.NetworkError.internetError.rawValue))
        case .sessionError:
            completion(ApiResult.failure(APIManager.NetworkError.sessionExpire.rawValue))
        case .authorizationError(let returnJson):
            if let message =  (((returnJson as? [String: Any])?["errorData"] as? [String: Any])?["errorMessage"] as? String) {
                completion(ApiResult.authorisationError(message))
            }
            else {
                completion(ApiResult.failure(APIManager.NetworkError.unKnownError.rawValue))
            }
        case .newUpdate(let returnJson):
            if let message = (((returnJson as? [String : Any])?["errorData"] as? [String: Any])?["errorMessage"] as? String) {
                completion(ApiResult.newUpdate(message))
            }
            else {
                completion(ApiResult.newUpdate(APIManager.NetworkError.versionUpdateError.rawValue))
            }
        case .serverError:
            completion(ApiResult.failure(APIManager.NetworkError.serverError.rawValue))
        default:
            completion(ApiResult.failure(APIManager.NetworkError.unKnownError.rawValue))
        }
    }
    
    /// Method to return Model of Mock JSON for API Services
    ///
    /// - Parameter fileName: Mock JSON file
    /// - Completion: Completion Block
    private static func mockJSONToModel<T: Codable>(fileName: String, completion: @escaping (ApiResult<T>)->Void) {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                // Getting data from JSON file using the file URL
                let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                
                if let jsonModel =  try? newJSONDecoder().decode(T.self, from: data) {
                    completion(ApiResult.success(jsonModel))
                }
            } catch let error {
                //JSON decoding Fail Block
                assertionFailure("JSON Decoding Failure. Reason - \(error)")
            }
        } else {
            //Invalid Path
            assertionFailure("Invalid Path for JSON File. Please Check JSON file name (\(fileName)) for Mock API.")
        }
    }
    
    /// Get JSON Decoder with specified date decoding strategy
    ///
    /// - Parameter fileName: Mock JSON file
    /// - Completion: Completion Block
    private static func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }
    
}
