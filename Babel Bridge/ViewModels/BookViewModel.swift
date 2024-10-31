import Foundation

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    
    func addBook(_ book: Book) {
        books.append(book)
    }
    
    var translatingBooks: [Book] {
        books.filter { $0.translationStatus == .inProgress }
    }
    
    var completedBooks: [Book] {
        books.filter { $0.translationStatus == .completed }
    }
} 
