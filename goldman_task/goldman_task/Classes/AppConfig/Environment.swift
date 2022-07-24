//
//  Environment.swift
//  Task
//
//  Created by Hiren Joshi on 07/21/22.
//

import Foundation

//Set up the application environment for the development so that would be good while the final project would be in production.

internal enum Environment {
    
    case beta, test, live
    
    internal var url: String {
        switch self {
        case .beta:
            return "https://api.nasa.gov/"
        case .test:
            return "https://api.nasa.gov/"
        case .live:
            return "https://api.nasa.gov/"
        }
    }
}

internal enum NASA_KEY {
    
    case beta, test, live
    
    internal var API_Key: String {
        switch self {
        case .beta:
            return "2RrcD3eXeIqsGX85OWCI1nInDX4znt7C4jFJFqUz"
        case .test:
            return "2RrcD3eXeIqsGX85OWCI1nInDX4znt7C4jFJFqUz"
        case .live:
            return "2RrcD3eXeIqsGX85OWCI1nInDX4znt7C4jFJFqUz"
        }
    }
}
