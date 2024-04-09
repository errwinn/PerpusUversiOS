//
//  ContentView.swift
//  PerpusUvers
//
//  Created by Erwin on 29/02/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    let token = "75|PXlg2p1nmEbBxnY4AbKvcbP5YvZWLwpecD7iGA6J"
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyword: String = ""
    @State private var books: [BookList] = []
    @State private var booksBorrowing: [BookList] = []
    @State private var searchText = ""
    @State private var isAuthenticated: Bool = true
    
    var body: some View {
        if isAuthenticated {
            TabView {
                NavigationStack {
                    List(searchResult, id: \.id) { book in
                        NavigationLink(destination: BookDetailView(bookId: book.id)){
                            HStack {
                                Image(systemName: "book")
                                VStack(alignment: .leading) {
                                    Text(book.name)
                                    Text(book.writer)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                        }
                    }.navigationTitle("Books")
                }.searchable(text: $searchText, prompt: "Search by book's title")
                    .tabItem { Label("Home", systemImage: "book") }
                NavigationStack {
                    List(booksBorrowing, id: \.id) { book in
                        NavigationLink(destination: BookDetailView(bookId: book.id)){
                            HStack {
                                Image(systemName: "book")
                                VStack(alignment: .leading) {
                                    Text(book.name)
                                    Text(book.writer)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Borrow date: \(book.pivot?.borrow_date ?? "")")
                                }
                            }
                        }
                    }.navigationTitle("Borrowing")
                        .searchable(text: $searchText)
                }
                    .tabItem { Label("Borrowing", systemImage: "books.vertical") }
                NavigationStack{
                    List{
                        NavigationLink(destination: {}){
                            HStack {
                                Image(systemName: "book")
                            }
                        }
                    }.navigationTitle("Setting")
                    List {
                        NavigationLink("Change password", destination: ChangePassword())
                        NavigationLink("History", destination: ChangePassword())
                        Button("Logout"){
                            isAuthenticated = false
                        }
                        .foregroundStyle(Color.red)
                    }

                }
                    .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            }
            
            .onAppear {
                fetchData()
                fetchBooksBorrowing()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)){
                notif in
                let keyboardRect = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                withAnimation{
                    self.keyboardHeight = keyboardRect.height
                }
            }
        } else {
            LoginView(onLogin: {
                isAuthenticated = true
            })
        }
    }
    
    func fetchData() {
        guard let url = URL(string: "http://lib.uvers.ac.id/api/book/get_book_list") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let book = try JSONDecoder().decode(Book.self, from: data)
                DispatchQueue.main.async {
                    self.books = book.data.book_lists
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func fetchBooksBorrowing() {
        guard let url = URL(string: "http://lib.uvers.ac.id/api/user/get_book_list") else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let book = try JSONDecoder().decode(Book.self, from: data)
                DispatchQueue.main.async {
                    self.booksBorrowing = book.data.book_lists
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    var searchResult: [BookList] {
        if searchText.isEmpty {
            return books
        } else {
            return books.filter {$0.name.contains(searchText)}
        }
    }
}


#Preview {
    ContentView().previewDevice("iPhone 15")
}
