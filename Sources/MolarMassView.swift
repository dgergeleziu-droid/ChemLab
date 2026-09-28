import SwiftUI

struct MolarMassView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var formula: String = "H2SO4"
    @State private var result: (mass: Double, breakdown: [(String, Int, Double)])? = nil

    private let atomicMass: [String: Double] = [
        "H":1.008,"He":4.003,"Li":6.94,"Be":9.012,"B":10.81,"C":12.011,"N":14.007,
        "O":15.999,"F":18.998,"Ne":20.180,"Na":22.990,"Mg":24.305,"Al":26.982,
        "Si":28.085,"P":30.974,"S":32.06,"Cl":35.45,"Ar":39.948,"K":39.098,
        "Ca":40.078,"Sc":44.956,"Ti":47.867,"V":50.942,"Cr":51.996,"Mn":54.938,
        "Fe":55.845,"Co":58.933,"Ni":58.693,"Cu":63.546,"Zn":65.38,"Br":79.904,
        "Ag":107.868,"Sn":118.710,"I":126.904,"Ba":137.327,"Pb":207.2
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0B1020").ignoresSafeArea()
                VStack(spacing: 16) {
                    Spacer().frame(height: 8)

                    HStack(spacing: 10) {
                        TextField("Формула (H2O, H2SO4, Ca(OH)2)", text: $formula)
                            .textFieldStyle(.plain)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: formula) { _ in compute() }

                        Button {
                            formula = ""
                            result = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "#64748B"))
                        }
                    }
                    .padding(.horizontal, 16)

                    if let r = result {
                        VStack(spacing: 12) {
                            Text("M = \(String(format: "%.2f", r.mass)) г/моль")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#FBBF24"))

                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(r.breakdown.enumerated()), id: \.offset) { _, item in
                                    HStack {
                                        Text("\(item.0) × \(item.1)")
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(String(format: "%.2f", item.2)) г/моль")
                                            .foregroundColor(Color(hex: "#94A3B8"))
                                    }
                                    .font(.system(size: 13, design: .monospaced))
                                }
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "#1E293B")))
                        }
                        .padding(.horizontal, 16)
                    } else {
                        Text("Введи формулу — посчитаем молярную массу")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#64748B"))
                            .padding(.top, 12)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Примеры:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#94A3B8"))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(["H2O","CO2","H2SO4","NaOH","Ca(OH)2","C6H12O6","KMnO4"], id: \.self) { s in
                                    Button {
                                        formula = s
                                        compute()
                                        SoundManager.shared.click()
                                    } label: {
                                        Text(s)
                                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12).padding(.vertical, 8)
                                            .background(Capsule().fill(Color(hex: "#1E3A8A")))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("🧮 Молярная масса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                        .foregroundColor(Color(hex: "#60A5FA"))
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear { compute() }
    }

    private func compute() {
        let trimmed = formula.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { result = nil; return }
        guard let parsed = parse(trimmed) else { result = nil; return }
        result = parsed
    }

    // Возвращает: общая масса + список (символ, количество, вклад)
    private func parse(_ s: String) -> (Double, [(String, Int, Double)])? {
        var total = 0.0
        var breakdown: [String: (String, Int, Double)] = [:]
        var i = s.startIndex

        while i < s.endIndex {
            let c = s[i]

            // Группа в скобках
            if c == "(" {
                var depth = 1
                var j = s.index(after: i)
                while j < s.endIndex && depth > 0 {
                    if s[j] == "(" { depth += 1 }
                    if s[j] == ")" { depth -= 1 }
                    if depth > 0 { j = s.index(after: j) }
                }
                let inner = String(s[s.index(after: i)..<j])
                guard let innerParsed = parse(inner) else { return nil }

                var k = s.index(after: j)
                var multStr = ""
                while k < s.endIndex && s[k].isNumber {
                    multStr.append(s[k])
                    k = s.index(after: k)
                }
                let mult = Int(multStr) ?? 1

                total += innerParsed.0 * Double(mult)

                for (el, cnt, _) in innerParsed.1 {
                    let prevCnt = breakdown[el]?.1 ?? 0
                    let newCnt = prevCnt + cnt * mult
                    let m = atomicMass[el] ?? 0
                    breakdown[el] = (el, newCnt, m * Double(newCnt))
                }
                i = k
                continue
            }

            // Элемент
            if c.isUppercase {
                var el = String(c)
                var j = s.index(after: i)
                if j < s.endIndex && s[j].isLowercase {
                    el.append(s[j])
                    j = s.index(after: j)
                }
                var cntStr = ""
                while j < s.endIndex && s[j].isNumber {
                    cntStr.append(s[j])
                    j = s.index(after: j)
                }
                let cnt = Int(cntStr) ?? 1
                guard let m = atomicMass[el] else { return nil }

                total += m * Double(cnt)

                let prevCnt = breakdown[el]?.1 ?? 0
                let newCnt = prevCnt + cnt
                breakdown[el] = (el, newCnt, m * Double(newCnt))
                i = j
                continue
            }

            i = s.index(after: i)
        }

        let sorted = breakdown.values.sorted { $0.0 < $1.0 }
        return (total, Array(sorted))
    }
}
