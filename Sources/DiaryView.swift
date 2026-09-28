import SwiftUI

struct DiaryView: View {
    @ObservedObject private var store = DiaryStorage.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showClear = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#475569"))
                        Text("Пока пусто")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("Проведи реакцию в лаборатории —\nзапись появится здесь.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "#94A3B8"))
                            .font(.system(size: 14))
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(store.entries) { e in
                                entryRow(e)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("📓 Дневник опытов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !store.entries.isEmpty {
                        Button(role: .destructive) { showClear = true } label: {
                            Image(systemName: "trash")
                                .foregroundColor(Color(hex: "#EF4444"))
                        }
                    }
                }
            }
            .alert("Очистить дневник?", isPresented: $showClear) {
                Button("Отмена", role: .cancel) {}
                Button("Очистить", role: .destructive) { store.clear() }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func entryRow(_ e: DiaryEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dateString(e.date))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#94A3B8"))
                Spacer()
                if e.warning != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "#F59E0B"))
                        .font(.system(size: 11))
                }
            }
            Text(e.equation)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(hex: "#FBBF24"))
            Text("Продукты: \(e.products.joined(separator: ", "))")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#CBD5E1"))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
    }

    private func dateString(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMM, HH:mm"
        return f.string(from: d)
    }
}
