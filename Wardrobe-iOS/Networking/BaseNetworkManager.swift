//
//  BaseNetworkManager.swift
//  Menu
//
//  Created by Edo on 10/3/19.
//  Copyright © 2019 Menu Group (UK) LTD. All rights reserved.
//

import UIKit
import Alamofire

//MARK:- Enums


enum BaseErrorType : String {
    case notAllowed = "METHOD_NOT_ALLOWED"
    case pathParameterMissed = "PATH_PARAMETER_MISSED"
    case parameterMissed = "PARAMETER_MISSED"
    case requestUrlNotFound = "REQUEST_URI_NOT_FOUND"
    case parameterTypeMismatch = "PARAMETER_TYPE_MISMATCH"
    case internalError = "INTERNAL_ERROR"
}

enum NetworkError: Error {
    case successError(errorType : String)
    case failError(code : Int, message : String)
}

//MARK:- Typealiases
typealias RequestCompletion = (_ response : Any?, _ error : NetworkError?) -> Void
typealias ResponseSuccess = (_ response : Any?) -> Void
typealias ResponseFailure = (_ error : NetworkError?) -> Void

//MARK:- BaseNetworkManager
class BaseNetworkManager: NSObject {
    
    //MARK:- Properties
 
    private var token: String? {
        return CredentialsStorage.credentialWithKey(.authToken)
    }
    var isAuthenticate: Bool = true
    
    private var baseHeaders: [String : String] {
        var headers = [
            "cache-control": "no-cache",
            "Content-Type": "application/json",
            "Platform": "IOS"
        ]
        if let authToken = token, isAuthenticate {
            headers["x-access-token"] = authToken
        }
        
        if let verison = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            headers["Version"] = verison
        }
        
        return headers
    }
}

//MARK:- Public Functions
extension BaseNetworkManager {
    func sendGetRequest(path: String, parameters: [String : Any] = [:], headers: [String : String] = [:], timeOut: Double = 2, isDataType: Bool = false, comletion: @escaping RequestCompletion) {
        
        var _path = path
        if !parameters.isEmpty {
            _path = path + parameters.paramsToString()
        }
        
        sendRequest(type: .get, path: _path, parameters: nil, headers: headers, timeOut: timeOut, isDataType: isDataType) { (response, error) in
            comletion(response, error)
        }
        
        
    }
    
    func sendPostRequest(path: String, parameters: [String : Any] = [:], headers: [String : String] = [:], encoding: ParameterEncoding = JSONEncoding.default, timeOut: Double = 2, isDataType: Bool = false, comletion: @escaping RequestCompletion) {
        
        sendRequest(type: .post, path: path, parameters: parameters, headers: headers, encoding: encoding, timeOut: timeOut, isDataType: isDataType) { (response, error) in
            comletion(response, error)
        }
    }
    
    func sendPutRequest(path: String, parameters: [String : Any] = [:], headers: [String : String] = [:], encoding: ParameterEncoding = JSONEncoding.default, timeOut: Double = 2, isDataType: Bool = false, comletion: @escaping RequestCompletion) {
        
        sendRequest(type: .put, path: path, parameters: parameters, headers: headers, encoding: encoding, timeOut: timeOut, isDataType: isDataType) { (response, error) in
            comletion(response, error)
        }
    }
    
    func sendDeleteRequest(path: String, parameters: [String : Any] = [:], headers: [String : String] = [:], encoding: ParameterEncoding = JSONEncoding.default, timeOut: Double = 2, isDataType: Bool = false, comletion: @escaping RequestCompletion){

        sendRequest(type: .delete, path: path, parameters: parameters, headers: headers, encoding: encoding, timeOut: timeOut, isDataType: isDataType) { (response, error) in
            comletion(response, error)
        }
    }
}

//MARK:- File Managment
extension BaseNetworkManager {
    func uploadImage(path: String, imageData: Data?, completion: @escaping (Bool, Error?) -> ()) {
        let baseURL = URL(string: path)!
        var request = URLRequest(url: baseURL)
        request.httpMethod = "PUT"
        URLSession.shared.uploadTask(with: request, from: imageData) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode{
                guard responseCode == 200 else {
                    print("Invalid response code: \(responseCode)")
                    completion(false, nil)
                    return
                }
                completion(true, nil)
            }
        }.resume()
    }
    
    func downloadImage(path: String, completion: @escaping (Data?, Error?, Int?) -> ()) {
        let baseURL = URL(string: path)!
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                completion(nil, error, nil)
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    print("Invalid response code: \(responseCode)")
                    completion(nil, nil, responseCode)
                    return
                }
                completion(responseData, nil, nil)
            }
        }.resume()
    }
}

//MARK:- Private Functions
extension BaseNetworkManager {
    private func sendRequest(type : HTTPMethod, path : String, parameters : [String : Any]?, headers : [String : String], encoding: ParameterEncoding = JSONEncoding.default,  timeOut : Double, isDataType : Bool, comletion : @escaping RequestCompletion)
    {
        var _headers = headers
        if _headers.isEmpty {
            _headers = baseHeaders
        }
        
        let alamofireManager = Alamofire.Session.default
        alamofireManager.session.configuration.timeoutIntervalForRequest = timeOut
        alamofireManager.request(path, method: type, parameters: parameters, encoding: encoding, headers: HTTPHeaders(_headers)).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                
                let failError = NetworkError.failError(code: response.response?.statusCode ?? 0, message: error.localizedDescription)
                print("BaseNetworkManager request fail error = \(error) path = \(path)")
                comletion(response.data, failError)
                
            case .success(let result):
                
                if let response = result as? [String: Any] {
                    if let isError = response["error"] as? Int, let errorType = response["errorType"] as? String, isError == 1 {
                        let error = NetworkError.successError(errorType: errorType)
                        comletion(nil, error)
                        return
                    } else if let _result = response["result"] {
                        comletion(_result, nil)
                        return
                    }
                
                }
                print("BaseNetworkManager error")
                comletion(nil, nil)
                
            }
        }
    }
    
}

private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}


/// Convert the parameters into a json array, and it is added as the request body.
/// The array must be sent as parameters using its `asParameters` method.
public struct ArrayEncoding: ParameterEncoding {

    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions


    /// Creates a new instance of the encoding using the given options
    ///
    /// - parameter options: The options used to encode the json. Default is `[]`
    ///
    /// - returns: The new instance
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()

        guard let parameters = parameters,
            let array = parameters[arrayParametersKey] else {
                return urlRequest
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data

        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }

        return urlRequest
    }
}
