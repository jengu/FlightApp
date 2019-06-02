//
//  AirportService.swift
//  FlightApp
//
//  Created by Ilyas Siraev on 02/06/2019.
//  Copyright © 2019 com.onthemoon2. All rights reserved.
//

import Foundation

protocol AirportService {
    func searchAirport(with name: String, completion: @escaping (Result<[Airport], Error>) -> Void)
}