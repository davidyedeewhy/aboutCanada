//
//  NetworkManager.swift
//  AboutCanada
//
//  Created by David Ye on 26/5/18.
//  Copyright © 2018 David Ye. All rights reserved.
//

import Foundation

class NetworkManager {
    
    func loadFacts(_ urlString: String, success: @escaping ([String: AnyObject]) -> Void, failure: @escaping (Error) -> Void) {
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data,
                let resultString = NSString(data: data, encoding: String.Encoding.isoLatin1.rawValue),
                let utf8Data = (resultString as String).data(using: .utf8),
                let facts = try? JSONSerialization.jsonObject(with: utf8Data, options: .mutableContainers) as? [String: AnyObject]
            {
                success(facts!)
            } else if let error = error {
                failure(error)
            }
        }
        task.resume()
    }
    
    func loadImage(_ imageUrl: URL, success: @escaping (Data) -> Void, failure: @escaping (Error) -> Void) {
        let urlRequest = URLRequest(url: imageUrl)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                success(data)
            } else if let error = error {
                failure(error)
            }
        }
        task.resume()
    }
    
}
