//
//  CSVManager.swift
//  SpineRVU
//
//  Created by Tim Yoon on 12/28/24.
//

import Foundation
import CodableCSV
struct Answer : Codable {
    var text : String = ""
}
class CSVManager {
    static func getDataFrom<T: Decodable>(fileName: String, rowLimit: Int = 20_000) async throws -> [T] {
        print("CSVManager: Starting async get CPT data from CSV file.")
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                do {
                    guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
                        throw NSError(domain: "CSVFileManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(fileName)"])
                    }
                    print("Found file")
                    let decoder = try CSVDecoder {
                        $0.encoding = .utf8
                        $0.headerStrategy = .firstLine
                        $0.bufferingStrategy = .sequential
                        /*
                         Be careful of the \r with the \n. It prevented it working on
                         pollution data for reasons.
                         */
                        $0.delimiters.row = "\r\n"
                    }.lazy(from: fileURL)
                    
                    var items: [T] = []
                    var index = 0
                    
                    while let decodedCPT = try? decoder.decodeRowIfPresent(T.self) {
                        items.append(decodedCPT)
                        index += 1
                        if index >= rowLimit {
                            print("Reached row limit: \(rowLimit)")
                            break
                        }
                    }
                    print("# of rows: \(items.count)")
                    continuation.resume(returning: items)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
