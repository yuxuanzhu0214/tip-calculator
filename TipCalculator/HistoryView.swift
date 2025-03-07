import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager: HistoryManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyManager.records.reversed()) { record in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(record.formattedDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Total: $\(record.total, specifier: "%.2f")")
                                .fontWeight(.bold)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Subtotal: $\(record.subtotal, specifier: "%.2f")")
                            Text("Tax (\(record.taxRate, specifier: "%.1f")%): $\(record.tax, specifier: "%.2f")")
                            Text("Tip (\(record.tipPercentage, specifier: "%.1f")%): $\(record.tip, specifier: "%.2f")")
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    let reversedIndices = indexSet.map { historyManager.records.count - 1 - $0 }
                    for index in reversedIndices.sorted(by: >) {
                        if index < historyManager.records.count {
                            historyManager.records.remove(at: index)
                        }
                    }
                    historyManager.saveHistory()
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        historyManager.clearHistory()
                    }
                }
            }
        }
    }
}
