//
//  APIManager.swift
//  FirstProject
//
//  Created by Erwin on 04/04/24.
//

import Foundation

func fetchData() -> [BookList]? {
    var book: [BookList]?
    if let url = URL(string: "http://lib.uvers.ac.id/api/book/get_book_list") {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) {(data, res, error) in
            if error != nil {
                return
            }
            if let safeData = data {
                print(String(data: safeData, encoding: .utf8) ?? "")
                book = parseJson(safeData)
            }
        }
        task.resume()
        print("It's still runing")
        return book
    }
    return nil
}

func parseJson(_ book: Data) -> [BookList]? {
    let decoder = JSONDecoder()
    do {
        let decodedData = try decoder.decode(Book.self, from: book)
        let books = decodedData.data.book_lists
        return books
    } catch {
        print("There's an error occured")
        return nil
    }
}
