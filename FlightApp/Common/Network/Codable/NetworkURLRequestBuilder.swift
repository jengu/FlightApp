//
//  NetworkURLRequestBuilder.swift
//  FlightApp
//
//  Created by Ilyas Siraev on 05/06/2019.
//  Copyright © 2019 com.onthemoon2. All rights reserved.
//

import Foundation

struct NetworkURLRequestBuilder: URLRequestBuilder {
    private var baseURL: URL?
    private var path: String?
    private var method: HttpMethod?
    private var parameters: [String: String] = [:]
    private var object: AnyEncodable?
    private var headers: [String: String] = [:]

    private let serializer: UrlParametersSerializer
    private let encoder: NetworkEncoder
    private let userAgent: String
    private let contentType: String

    init(serializer: UrlParametersSerializer, encoder: NetworkEncoder, userAgent: String, contentType: String) {
        self.serializer = serializer
        self.encoder = encoder
        self.userAgent = userAgent
        self.contentType = contentType
    }

    func baseURL(_ newBaseURL: URL) -> URLRequestBuilder {
        var new = self
        new.baseURL = newBaseURL
        return new
    }

    func path(_ newPath: String) -> URLRequestBuilder {
        var new = self
        new.path = newPath
        return new
    }

    func method(_ newMethod: HttpMethod) -> URLRequestBuilder {
        var new = self
        new.method = newMethod
        return new
    }

    func parameters(_ newParameters: [String: String]) -> URLRequestBuilder {
        var new = self
        new.parameters = newParameters
        return new
    }

    func object(_ newObject: AnyEncodable) -> URLRequestBuilder {
        var new = self
        new.object = newObject
        return new
    }

    func headers(_ newHeaders: [String: String]) -> URLRequestBuilder {
        var new = self
        new.headers = newHeaders
        return new
    }

    func build() throws -> URLRequest {
        guard let baseURL = baseURL else { throw NetworkURLRequestBuilderError.baseURLIsNil }
        guard let path = path else { throw NetworkURLRequestBuilderError.pathIsNil }
        guard let method = method else { throw NetworkURLRequestBuilderError.httpMethodIsNil }

        let fullPath = "\(baseURL.absoluteString)/\(path)"
        guard let fullPathURL = URL(string: fullPath), let url = url(fullPathURL, withParameters: parameters) else {
            throw NetworkURLRequestBuilderError.badURL(fullPath)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        headers.forEach { name, value in
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }
        urlRequest.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        if let object = object {
            let body = try encoder.encode(object)
            urlRequest.httpBody = body
        }
        return urlRequest
    }

    private func url(_ url: URL, withParameters parameters: [String: String]) -> URL? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }

        if !parameters.isEmpty {
            var queryParameters = serializer.deserialize(components.query ?? "")
            parameters.forEach { key, value in
                queryParameters[key] = value
            }
            components.percentEncodedQuery = serializer.serialize(queryParameters)
        }

        return components.url
    }
}
