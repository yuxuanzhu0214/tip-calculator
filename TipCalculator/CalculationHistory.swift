import Foundation

struct CalculationRecord: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let subtotal: Double
    let tax: Double
    let totalBeforeTip: Double
    let tip: Double
    let total: Double
    let tipPercentage: Double
    let taxRate: Double
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class HistoryManager: ObservableObject {
    @Published var records: [CalculationRecord] = []
    
    private let saveKey = "TipCalculatorHistory"
    
    init() {
        loadHistory()
    }
    
    func addRecord(subtotal: Double, tax: Double, totalBeforeTip: Double, tip: Double, total: Double, tipPercentage: Double, taxRate: Double) {
        let newRecord = CalculationRecord(
            date: Date(),
            subtotal: subtotal,
            tax: tax,
            totalBeforeTip: totalBeforeTip,
            tip: tip,
            total: total,
            tipPercentage: tipPercentage,
            taxRate: taxRate
        )
        
        records.append(newRecord)
        saveHistory()
    }
    
    func clearHistory() {
        records.removeAll()
        saveHistory()
    }
    
    public func saveHistory() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([CalculationRecord].self, from: data) {
                records = decoded
                return
            }
        }
        
        records = []
    }
}
