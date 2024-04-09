//
//  BookModels.swift
//  FirstProject
//
//  Created by Erwin on 04/04/24.
//

import Foundation

struct Book: Codable {
    let data: BookData
}

struct BookDetails: Codable {
    let data: BookDetailData
}

struct BookData: Codable {
    let book_lists: [BookList]
}

struct BookDetailData: Codable {
    let book_lists: BookDetail
}

struct BookList: Codable, Identifiable {
    let id: Int
    let category_id: Int
    let language_id: Int
    let name: String
    let writer: String
    let cover_path: String
    let rate: Double?
    let borrow: [Borrow]?
    let pivot: Pivot?
}

struct BookDetail: Codable, Identifiable {
    let id: Int
    let category_id: Int
    let language_id: Int
    let name: String
    let writer: String
    let publish_place: String
    let publish_year: Int
    let synopsis: String
    let cover_path: String
    let book_path: String
    let stock: Int
    let stock_left: Int
    let rate: Double?
    let borrow: [Borrow]?
    let pivot: Pivot?
}

struct Borrow: Codable {
    let id: Int
    let user_id: Int
    let book_id: Int
    let borrow_date: String
    let return_date: String?
    let expires_date: String
    let rate: Double?
}

struct Pivot: Codable {
    let user_id: Int
    let book_id: Int
    let borrow_date: String
}
