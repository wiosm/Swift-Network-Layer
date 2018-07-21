//
//  Request.swift
//  Wios
//
//  Created by Wios on 6/26/18.
//  Copyright © 2018 Wios. All rights reserved.
//

import UIKit

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

class Request: NSObject {
    let defaultTimeout:TimeInterval = 15
    override init() {
        
    }
    
    func request(withURL url:String, method: HTTPMethod, params: [String: Any]?, headers: [String: String]?, timeout: TimeInterval?, encode: String?, onSuccess success:@escaping ((_ token:Data)->Void),  onFailed fail:@escaping((_ error:NSError) -> Void)){
        self.startRequest(withURL: url, method: method, params: params, headers: headers, timeout: timeout, encode: encode, onSuccess: success, onFailed: fail)
    }
    
    func startRequest(withURL urlEndpoint:String, method: HTTPMethod, params: [String: Any]?, headers: [String: String]?, timeout: TimeInterval?, encode: String?, onSuccess success:@escaping ((_ token:Data)->Void),  onFailed fail:@escaping((_ error:NSError) -> Void)){
        print("\n\n\n\n\n\n=======================")
        print("\nREQUEST")
        print("\nURL: " + urlEndpoint)
        
        if let url = URL(string: urlEndpoint) {
            var request = URLRequest.init(url: url)
            
            //Set method
            request.httpMethod = method.rawValue
            request.timeoutInterval = timeout ?? defaultTimeout
            print("\n" + method.rawValue)
            
            // Set headers
            if(headers != nil){
                if let headers = headers {
                    for (headerField, headerValue) in headers {
                        request.setValue(headerValue, forHTTPHeaderField: headerField)
                    }
                }
            }
            print("\n\nHeader: " + (headers?.description ?? ""))
            
            //Set body
            if let params = params {
                let data = try! JSONSerialization.data(withJSONObject: params, options: [])
                request.httpBody = data
            }
            print("\n\nParam: " + (params?.description ?? ""))
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                print("\n\n------------\nRESPOND\n")
                print(response?.description ?? "")
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                        print(json ?? [])
                        print("\n>>>>>RESPOND JSON")
                        print("\n" + (json?.description)!)
                        print("\nDONE REQUEST\n=======================\n")
                    }
                    catch {
                        
                    }
                    
                    DispatchQueue.main.async {
                        if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 500 {
                                let error = NSError(domain: urlEndpoint, code:httpResponse.statusCode, userInfo:nil)
                                fail(error)
                            }
                            else {
                                success(data)
                            }
                        }
                    }
                   
                } else if let error = error {
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        fail(NSError.init(domain: urlEndpoint, code: -999, userInfo: ["message" : error.localizedDescription]))
                    }
                }
            }
            
            task.resume()
        }
    }
}
