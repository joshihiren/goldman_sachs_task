//
//  ApiManager.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import Foundation
import Alamofire
import Reachability

class ApiManager: NSObject {
    
    //public var manager: Alamofire.SessionManager
    var AFManager = Session()
    private let queueApi = DispatchQueue(label: "com.queue.api", qos: DispatchQoS.userInitiated)
    
    override init() {
        AFManager = Alamofire.Session(configuration: URLSessionConfiguration.default)
        AFManager.session.configuration.timeoutIntervalForRequest = 30
    }
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    static let sharedInstance = ApiManager()
    
    func GETRequest<ResponseType :Decodable>(url: String, method : HTTPMethod,  parameter : [String : Any], responseType : ResponseType.Type ,completion: @escaping (ResponseType? ,Error? ) -> Void) {
        print("\(Endpoints.baseURL.url)\(url)")
        print(parameter)
        print(method)
        
        var header = HTTPHeaders()
        
        AFManager.requestWithCacheOrLoad(url, method: method, parameters: parameter, encoding: URLEncoding.default, headers: header).validate().response(completionHandler: { (responce) in
            guard let data = responce.data else{
                completion(nil,responce.error)
                return
            }
            // if !(self.checkMaintenance(responseObject: data) ?? false){
            let decoder = JSONDecoder()
            do{
                let responseData = try decoder.decode(ResponseType.self, from: data)
                completion(responseData, nil)
            }
            catch let error{
                completion(nil, error)
            }
        })
        
    }
    
    func checkMaintenance(responseObject: Data) -> Bool{
        _ = JSONDecoder()
        do{
            return false
        }
        
        catch _{
            return false
        }
    }

    
    //MARK: ----------------------------Get Nasa records Setting details --------------------------
    func doGet_nasa_details(param : [String:Any], completion: @escaping (PlanetryApodModel? ,Error? ) -> Void){
        self.GETRequest(url: "\(Endpoints.baseURL.url)\(Endpoints.GET_Apod_List)?api_key=\(Endpoints.NASA_SECRETKEY.API_Key)", method: .get, parameter: param, responseType: PlanetryApodModel.self) { (response, error) in
            completion(response, error)
        }
    }
    
}

extension Alamofire.Session {
    
    @discardableResult
    open func requestWithCacheOrLoad(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}
