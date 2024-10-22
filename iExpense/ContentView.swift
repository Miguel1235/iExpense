import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Expenses")
            }
        }
    }
    
    init() {
        // read from user defaults the data of expenses
        if let savedItems = UserDefaults.standard.data(forKey: "Expenses") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                self.items = decodedItems
                return
            }
        }
        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationStack {
            List {
                // we dont need to put the id here because the ExpenseItem is part of Identifiable
                ForEach(expenses.items) { item in
                    HStack {
                        VStack(alignment: .leading, content: {
                            Text(item.name)
                                .font(.headline)
                            Text(item.type)
                        })
                        Spacer()
                        Text(item.amount, format: .currency(code: "USD"))
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add expense", systemImage: "plus") {
                    showingAddExpense = true
//                    let expense = ExpenseItem(name: "New expense", type: "Food", amount: 100)
//                    expenses.items.append(expense)
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                // show add view
                AddView(expenses: expenses) // both shares the same object
            }
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
