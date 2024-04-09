//
//  BookDetail.swift
//  PerpusUvers
//
//  Created by Erwin on 04/04/24.
//

import SwiftUI

struct BookDetailView: View {
    let userDefault = UserDefaults.standard
    let bookId: Int
    @State private var currentStock: Int = 0
    @State private var books: BookDetail? = nil
    @State private var isBorrowing: Bool = false
    @State private var isBookReturnedSuccess: Bool = false
    @State private var isBookBorrowedSuccess: Bool = false
    @State private var isError: Bool = false
    @State var isDoneLoading: Bool = false
    var body: some View {
        VStack{
            if(isDoneLoading){
                Image(systemName: "book")
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("\(books?.name ?? "")").bold().font(.title)
                Text("\(books?.writer ?? "")").font(.subheadline)
                Text("\(books?.synopsis ?? "")")
                Text("Stock: \(currentStock)/\(books?.stock ?? 0)")
                Text("Rate: \(String(format: "%.1f", books?.rate ?? 0))")
                NavigationStack{
                    if isBorrowing {
                        NavigationLink("Read now!", destination: BookPdfView(url: URL(string: "https://www.mkri.id/public/content/infoumum/regulation/pdf/UUD45%20ASLI.pdf")!))
                            .frame(width: 200, height: 50)
                            .border(Color.secondary)
                        Button("Return the book"){
                            returnBook()
                        }.foregroundStyle(Color.red)
                            .frame(width: 200, height: 50)
                            .border(Color.secondary)
                        
                    } else if !isBorrowing {
                        Button("Borrow Now!") {
                            borrowBook()
                        }
                        .foregroundStyle(Color.blue)
                            .frame(width: 200, height: 50)
                            .border(Color.secondary)
                    } else if books?.stock == 0 {
                        Text("This book is out of stock!")
                    }
                }
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear{
            fetchBookData()
        }
        .alert(isPresented: $isBookReturnedSuccess){
            Alert(title: Text("Success"), message: Text("Book returned successfully"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $isBookBorrowedSuccess){
            Alert(title: Text("Success"), message: Text("Book borrowed successfully"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $isError){
            Alert(title: Text("Error"), message: Text("An error occurred, try again"), dismissButton: .default(Text("OK")))
        }
    }
    
    func fetchBookData(){
        guard let url = URL(string: "http://lib.uvers.ac.id/api/book/get_book_detail?book_id=\(bookId)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let book = try JSONDecoder().decode(BookDetails.self, from: data)
                DispatchQueue.main.async {
                    self.books = book.data.book_lists
                    self.currentStock = book.data.book_lists.stock_left
                    checkHasBorrowed()
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func checkHasBorrowed(){
        let token = userDefault.string(forKey: "user_token")
        guard let url = URL(string: "http://lib.uvers.ac.id/api/user/get_book_list") else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let book = try JSONDecoder().decode(Book.self, from: data)
                DispatchQueue.main.async {
                    let currentBook = book.data.book_lists.filter{$0.id == self.bookId}
                    if currentBook.count > 0 {
                        isBorrowing = true
                    }
                    isDoneLoading = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func returnBook() {
        let token = userDefault.string(forKey: "user_token")
        guard let url = URL(string: "http://lib.uvers.ac.id/api/user/return_book?book_id=\(bookId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return }

            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 {
                    isBookReturnedSuccess = true
                    currentStock += 1
                    isBorrowing = false
                } else {
                    isError = true
                }
            }
        }.resume()
    }
    
    func borrowBook() {
        let token = userDefault.string(forKey: "user_token")
        guard let url = URL(string: "http://lib.uvers.ac.id/api/user/borrow_book?book_id=\(bookId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data else { return }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            DispatchQueue.main.async {
                if httpResponse.statusCode == 200 {
                    isBookBorrowedSuccess = true
                    currentStock -= 1
                    isBorrowing = true
                } else {
                    isError = true
                }
            }
        }.resume()
    }
}
