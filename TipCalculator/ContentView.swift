import SwiftUI

struct ContentView: View {
    @StateObject private var historyManager = HistoryManager()
    @State private var showingHistory = false
    @State private var showingSavedAlert = false
    
    @State private var isTotalSelected = false {
        didSet {
            calculateAmounts()
        }
    }
    @State private var amount: String = ""
    @State private var taxRate: String = ""
    @State private var tipPercentage: Double = 15.0
    @State private var customTip: String = ""
    @State private var isCustomTipSelected = false

    @State private var subtotal: Double = 0.0
    @State private var total: Double = 0.0
    @State private var totalBeforeTip: Double = 0.0
    @State private var tip: Double = 0.0
    @State private var tax: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                // Amount Input Section
                Section(header: Text("Enter Amount")) {
                    Picker("Amount Type", selection: $isTotalSelected) {
                        Text("Subtotal Amount").tag(false)
                        Text("Total Amount").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: isTotalSelected) { _ in
                        calculateAmounts()
                    }

                    HStack {
                        Text("$")
                        TextField(isTotalSelected ? "Enter Total Amount" : "Enter Subtotal Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { _ in
                                calculateAmounts()
                            }
                    }
                }

                // Tax Rate Section
                Section(header: Text("Tax Rate")) {
                    HStack {
                        TextField("Enter Tax Rate", text: $taxRate)
                            .keyboardType(.decimalPad)
                            .onChange(of: taxRate) { _ in
                                calculateAmounts()
                            }
                        Text("%")
                    }
                }

                // Tip Percentage Section
                Section(header: Text("Select Tip Percentage")) {
                    HStack {
                        Button("15%") {
                            tipPercentage = 15.0
                            isCustomTipSelected = false
                            customTip = ""
                            calculateAmounts()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .background(!isCustomTipSelected && tipPercentage == 15.0 ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        
                        Button("18%") {
                            tipPercentage = 18.0
                            isCustomTipSelected = false
                            customTip = ""
                            calculateAmounts()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .background(!isCustomTipSelected && tipPercentage == 18.0 ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        
                        Button("20%") {
                            tipPercentage = 20.0
                            isCustomTipSelected = false
                            customTip = ""
                            calculateAmounts()
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .background(!isCustomTipSelected && tipPercentage == 20.0 ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                    
                    HStack {
                        Text("Custom Tip:")
                        TextField("Enter Custom Tip", text: $customTip)
                            .keyboardType(.decimalPad)
                            .onChange(of: customTip) { _ in
                                if let customValue = Double(customTip) {
                                    tipPercentage = customValue
                                    isCustomTipSelected = true
                                }
                                calculateAmounts()
                            }
                        Text("%")
                    }
                }

                // Dynamic Calculation Section
                Section(header: Text("Breakdown")) {
                    Text("Subtotal: $\(subtotal, specifier: "%.2f")")
                    Text("Tax: $\(tax, specifier: "%.2f")")
                    Text("Total Before Tip: $\(totalBeforeTip, specifier: "%.2f")")
                    Text("Tip: $\(tip, specifier: "%.2f")")
                    Text("Total: $\(total, specifier: "%.2f")")
                }
                
                // Save Button Section
                Section {
                    Button(action: saveCalculation) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                            Spacer()
                        }
                    }
                    .disabled(total == 0)
                }
            }
            .navigationTitle("Tip Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingHistory = true
                    }) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(historyManager: historyManager)
            }
            .alert("Saved!", isPresented: $showingSavedAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    private func taxRateAsDecimal() -> Double {
        guard let tax = Double(taxRate) else { return 0.0 }
        return tax / 100.0
    }

    private func calculateAmounts() {
        guard let enteredAmount = Double(amount), enteredAmount > 0 else {
            subtotal = 0.0
            total = 0.0
            totalBeforeTip = 0.0
            tip = 0.0
            tax = 0.0
            return
        }

        let taxRateDecimal = taxRateAsDecimal()

        if isTotalSelected {
            // When total amount is selected (including tax, before tip)
            totalBeforeTip = enteredAmount
            // Calculate subtotal by removing tax
            subtotal = totalBeforeTip / (1 + taxRateDecimal)
            tax = totalBeforeTip - subtotal
            // Calculate tip based on subtotal
            tip = subtotal * (tipPercentage / 100.0)
            // Final total includes the tip
            total = totalBeforeTip + tip
        } else {
            // When subtotal amount is selected (before tax and tip)
            subtotal = enteredAmount
            // Calculate tax
            tax = subtotal * taxRateDecimal
            totalBeforeTip = subtotal + tax
            // Calculate tip based on subtotal
            tip = subtotal * (tipPercentage / 100.0)
            // Final total includes both tax and tip
            total = totalBeforeTip + tip
        }
    }
    
    private func saveCalculation() {
        let currentTaxRate = Double(taxRate) ?? 0.0
        historyManager.addRecord(
            subtotal: subtotal,
            tax: tax,
            totalBeforeTip: totalBeforeTip,
            tip: tip,
            total: total,
            tipPercentage: tipPercentage,
            taxRate: currentTaxRate
        )
        
        // Show saved alert
        showingSavedAlert = true
    }
}
