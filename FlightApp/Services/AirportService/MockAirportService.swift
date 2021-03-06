//
//  MockAirportService.swift
//  FlightApp
//
//  Created by Ilyas Siraev on 02/06/2019.
//  Copyright © 2019 com.onthemoon2. All rights reserved.
//

import Foundation

enum MockAirportServiceError: Error {
    case failed
}

class MockAirportService: AirportService {
    private enum AnswerType {
        static let searchAirportAnswerType: SearchAirportAnswerType = .error
    }

    private enum SearchAirportAnswerType {
        case success
        case empty
        case error
    }

    private let answerDelay: TimeInterval = 1

    private(set) var startFromAirport: Airport?
    private(set) var startToAirport: Airport?

    func searchAirport(with name: String, completion: @escaping (Result<[Airport], Error>) -> Void) {
        let airports: [Airport] = (0 ..< 20).map {
            Airport(location: Airport.Location(latitude: 0, longitude: 0), airportName: "\($0)", name: "\($0)", iata: "\($0)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + answerDelay) {
            switch AnswerType.searchAirportAnswerType {
                case .success:
                    completion(.success(airports))
                case .empty:
                    completion(.success([]))
                case .error:
                    completion(.failure(MockAirportServiceError.failed))
            }
        }
    }
}
