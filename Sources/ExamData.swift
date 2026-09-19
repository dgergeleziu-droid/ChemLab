import SwiftUI

enum ExamTaskType: String, CaseIterable {
    case singleChoice = "Один ответ"
    case multipleChoice = "Несколько ответов"
    case matching = "Соответствие"
    case shortAnswer = "Краткий ответ"
    case equationInput = "Уравнение"
}

struct ExamTask: Identifiable {
    let id = UUID()
    let number: Int
    let type: ExamTaskType
    let question: String
    let options: [String]?
    let matchingItems: [String]?
    let correctAnswer: String
    let explanation: String
    let topic: String
}

struct ExamVariant { let id: UUID; let title: String; let tasks: [ExamTask] }

struct ExamResult {
    let totalTasks: Int
    let correctCount: Int
    let score: Int
    let grade: Int
    let details: [(taskNumber: Int, userAnswer: String, correct: String, isCorrect: Bool)]
}

enum ExamData {

    static let allTasks: [ExamTask] = [

        // ==================== ОДИН ОТВЕТ ====================
        ExamTask(number: 7, type: .singleChoice,
            question: "Кислотным оксидом и щёлочью соответственно являются:",
            options: ["1) SiO₂ и Ba(OH)₂",
                      "2) NO₂ и Fe(OH)₃",
                      "3) CaO и Cu(OH)₂",
                      "4) CO₂ и Al(OH)₃"],
            matchingItems: nil,
            correctAnswer: "1",
            explanation: "SiO₂ — кислотный оксид, Ba(OH)₂ — щёлочь (растворимое основание).",
            topic: "Классификация веществ"),

        ExamTask(number: 10, type: .singleChoice,
            question: "К сильным электролитам относится каждое из двух веществ:",
            options: ["1) Al(OH)₃ и KOH",
                      "2) NaOH и Ba(OH)₂",
                      "3) Fe(OH)₃ и Fe(OH)₂",
                      "4) Cu(OH)₂ и NaOH"],
            matchingItems: nil,
            correctAnswer: "2",
            explanation: "NaOH и Ba(OH)₂ — щёлочи, диссоциируют полностью.",
            topic: "Электролитическая диссоциация"),

        ExamTask(number: 11, type: .singleChoice,
            question: "Признаком химической реакции не является:",
            options: ["1) выделение теплоты",
                      "2) изменение окраски",
                      "3) образование осадка",
                      "4) изменение объёма"],
            matchingItems: nil,
            correctAnswer: "4",
            explanation: "Изменение объёма — физическое явление. Признаки реакции: газ, осадок, тепло, цвет, запах.",
            topic: "Признаки реакций"),

        ExamTask(number: 12, type: .singleChoice,
            question: "С выделением осадка протекает реакция между:",
            options: ["1) NaI и AgNO₃",
                      "2) MgCO₃ и HCl",
                      "3) CaO и H₂O",
                      "4) NaOH и Al₂O₃"],
            matchingItems: nil,
            correctAnswer: "1",
            explanation: "NaI + AgNO₃ → AgI↓ (жёлтый осадок) + NaNO₃.",
            topic: "Реакции ионного обмена"),

        ExamTask(number: 14, type: .singleChoice,
            question: "К сильным электролитам относится:",
            options: ["1) H₂S", "2) H₂CO₃", "3) HNO₃", "4) H₂SiO₃"],
            matchingItems: nil,
            correctAnswer: "3",
            explanation: "HNO₃ — сильная кислота, диссоциирует полностью.",
            topic: "Электролиты"),

        // ==================== НЕСКОЛЬКО ОТВЕТОВ ====================
        ExamTask(number: 1, type: .multipleChoice,
            question: "Выберите два высказывания, в которых говорится об алюминии как о простом веществе.",
            options: ["1) В качестве конструкционного материала обычно используют сплавы на его основе.",
                      "2) Соли, в которых алюминий входит в состав кислотного остатка, называются алюминаты.",
                      "3) ПДК алюминия в воде составляет 0,2 мг/л.",
                      "4) Алюминий способен накапливаться в тканях костей, мозга и печени.",
                      "5) Лидерами по производству алюминия являются Китай и Россия."],
            matchingItems: nil,
            correctAnswer: "15",
            explanation: "О простом веществе — о свойствах, применении, производстве. Высказывания 1 и 5 — об алюминии как металле. 2, 3, 4 — о химическом элементе.",
            topic: "Атомы и молекулы"),

        ExamTask(number: 5, type: .multipleChoice,
            question: "Из предложенного перечня выберите два вещества с ионной связью:",
            options: ["1) Li₂O", "2) Al", "3) NH₄I", "4) HNO₃", "5) SO₂"],
            matchingItems: nil,
            correctAnswer: "13",
            explanation: "Ионная связь — между металлом и неметаллом. Li₂O и NH₄I — ионные.",
            topic: "Химическая связь"),

        ExamTask(number: 6, type: .multipleChoice,
            question: "Какие два утверждения верны для характеристики как кальция, так и калия?",
            options: ["1) Во внешнем слое атом содержит один электрон.",
                      "2) Атомный радиус больше атомного радиуса магния.",
                      "3) Металлические свойства менее выражены, чем у магния.",
                      "4) Соответствующий гидроксид является сильным основанием.",
                      "5) Высший оксид имеет состав Э₂O."],
            matchingItems: nil,
            correctAnswer: "14",
            explanation: "Ca и K — металлы 4 периода. Правильные: 1 (у K — 1 электрон на внешнем слое) и 4 (оба гидроксида — сильные основания).",
            topic: "Свойства металлов"),

        ExamTask(number: 8, type: .multipleChoice,
            question: "Выберите две пары веществ, с каждым из которых реагирует оксид углерода(IV):",
            options: ["1) Li₂O, NaOH",
                      "2) HCl, H₂SO₄",
                      "3) BaO, KOH",
                      "4) Ca(OH)₂, H₂O",
                      "5) Na₂O, SO₂"],
            matchingItems: nil,
            correctAnswer: "13",
            explanation: "CO₂ — кислотный оксид. Реагирует с основными оксидами (Li₂O, BaO) и щелочами (NaOH, KOH).",
            topic: "Свойства оксидов"),

        ExamTask(number: 13, type: .multipleChoice,
            question: "Выберите две пары, каждое вещество из которых при диссоциации образует сульфат-анион:",
            options: ["1) Cu₂S и K₂SO₄",
                      "2) H₂SO₄ и CuSO₄",
                      "3) BaSO₄ и K₂SO₃",
                      "4) Na₂S и Na₂SO₄",
                      "5) H₂SO₄ и ZnSO₄"],
            matchingItems: nil,
            correctAnswer: "25",
            explanation: "Сульфат-анион SO₄²⁻ из сульфатов и серной кислоты. Пары 2 и 5.",
            topic: "Электролитическая диссоциация"),

        ExamTask(number: 21, type: .multipleChoice,
            question: "Выберите два вещества, с которыми реагирует оксид серы(VI):",
            options: ["1) HCl", "2) H₂O", "3) NaOH", "4) Au", "5) O₂"],
            matchingItems: nil,
            correctAnswer: "23",
            explanation: "SO₃ — кислотный оксид. Реагирует с водой и щелочами.",
            topic: "Свойства оксидов"),

        ExamTask(number: 22, type: .multipleChoice,
            question: "Выберите две пары веществ, взаимодействие которых приводит к выделению газа:",
            options: ["1) Cu и HCl",
                      "2) Zn и H₂SO₄",
                      "3) CuO и HCl",
                      "4) NaOH и HCl",
                      "5) Na₂CO₃ и HCl"],
            matchingItems: nil,
            correctAnswer: "25",
            explanation: "Zn + H₂SO₄ → ZnSO₄ + H₂↑ (газ). Na₂CO₃ + 2HCl → 2NaCl + H₂O + CO₂↑ (газ).",
            topic: "Химические свойства"),

        // ==================== СООТВЕТСТВИЕ ====================
        ExamTask(number: 4, type: .matching,
            question: "Установите соответствие между формулой вещества и степенью окисления серы в нём.",
            options: ["1) –2", "2) +3", "3) +4", "4) +6"],
            matchingItems: ["А) Fe₂(SO₄)₃", "Б) P₂S₃", "В) MgSO₃"],
            correctAnswer: "413",
            explanation: "A) Fe₂(SO₄)₃ — сульфат, S⁺⁶ (4). Б) P₂S₃ — сульфид, S⁻² (1). В) MgSO₃ — сульфит, S⁺⁴ (3).",
            topic: "Степень окисления"),

        ExamTask(number: 9, type: .matching,
            question: "Установите соответствие между реагирующими веществами и продуктами их взаимодействия.",
            options: ["1) Zn(NO₃)₂ + NO₂ + H₂O",
                      "2) Zn(NO₃)₂ + NO + H₂O",
                      "3) ZnO + NO₂ + O₂",
                      "4) Zn(NO₃)₂ + H₂"],
            matchingItems: ["А) Zn + HNO₃(конц.)",
                            "Б) Zn + HNO₃(разб.)",
                            "В) Zn(NO₃)₂ →"],
            correctAnswer: "123",
            explanation: "A) Конц. → NO₂ (1). Б) Разб. → NO (2). В) Разложение нитрата → ZnO + NO₂ + O₂ (3).",
            topic: "Химические свойства"),

        ExamTask(number: 23, type: .matching,
            question: "Установите соответствие между веществом и классом неорганических соединений.",
            options: ["1) Кислота", "2) Основание", "3) Кислотный оксид", "4) Соль"],
            matchingItems: ["А) H₂SO₄", "Б) NaOH", "В) CO₂"],
            correctAnswer: "123",
            explanation: "H₂SO₄ — кислота (1), NaOH — основание (2), CO₂ — кислотный оксид (3).",
            topic: "Классификация веществ"),

        // ==================== КРАТКИЙ ОТВЕТ ====================
        ExamTask(number: 2, type: .shortAnswer,
            question: "В атоме химического элемента содержится 15 электронов. Сколько из них находятся на внешнем энергетическом уровне?",
            options: nil, matchingItems: nil,
            correctAnswer: "5",
            explanation: "15 электронов — фосфор (P). Распределение: 2, 8, 5. На внешнем уровне 5.",
            topic: "Строение атома"),

        ExamTask(number: 3, type: .shortAnswer,
            question: "Расположите элементы 1) фосфор 2) кремний 3) хлор в порядке увеличения атомного радиуса. Ответ — последовательность цифр без пробелов.",
            options: nil, matchingItems: nil,
            correctAnswer: "312",
            explanation: "В периоде слева направо радиус уменьшается. Si → P → Cl. В порядке увеличения: Cl (3), P (1), Si (2) → 312.",
            topic: "Периодический закон"),

        ExamTask(number: 18, type: .shortAnswer,
            question: "Вычислите массу 0,5 моль газообразного водорода H₂. Ответ в граммах.",
            options: nil, matchingItems: nil,
            correctAnswer: "1",
            explanation: "M(H₂) = 2 г/моль. m = 0,5 · 2 = 1 г.",
            topic: "Количественные отношения"),

        ExamTask(number: 19, type: .shortAnswer,
            question: "Какой объём (н.у.) займут 2 моль кислорода O₂? Ответ в литрах.",
            options: nil, matchingItems: nil,
            correctAnswer: "44.8",
            explanation: "V = n · Vm = 2 · 22,4 = 44,8 л.",
            topic: "Количественные отношения"),

        ExamTask(number: 20, type: .shortAnswer,
            question: "Какова масса 3 моль воды H₂O? Ответ в граммах.",
            options: nil, matchingItems: nil,
            correctAnswer: "54",
            explanation: "M(H₂O) = 18 г/моль. m = 3 · 18 = 54 г.",
            topic: "Количественные отношения"),

        ExamTask(number: 24, type: .shortAnswer,
            question: "Какой объём (н.у.) займут 3 моль азота N₂? Ответ в литрах.",
            options: nil, matchingItems: nil,
            correctAnswer: "67.2",
            explanation: "V = 3 · 22,4 = 67,2 л (н.у.).",
            topic: "Количественные отношения"),

        // ==================== УРАВНЕНИЕ ====================
        ExamTask(number: 15, type: .equationInput,
            question: "Напишите уравнение реакции между железом и хлором. Укажите сумму коэффициентов.",
            options: nil, matchingItems: nil,
            correctAnswer: "7",
            explanation: "2Fe + 3Cl₂ → 2FeCl₃. Сумма: 2 + 3 + 2 = 7.",
            topic: "Химические уравнения"),

        ExamTask(number: 16, type: .equationInput,
            question: "Напишите уравнение реакции между натрием и водой. Укажите сумму коэффициентов.",
            options: nil, matchingItems: nil,
            correctAnswer: "7",
            explanation: "2Na + 2H₂O → 2NaOH + H₂↑. Сумма: 2 + 2 + 2 + 1 = 7.",
            topic: "Химические уравнения"),

        ExamTask(number: 17, type: .equationInput,
            question: "Напишите уравнение реакции между оксидом кальция и водой. Укажите сумму коэффициентов.",
            options: nil, matchingItems: nil,
            correctAnswer: "3",
            explanation: "CaO + H₂O → Ca(OH)₂. Сумма: 1 + 1 + 1 = 3.",
            topic: "Химические уравнения"),

        ExamTask(number: 25, type: .equationInput,
            question: "Напишите уравнение горения магния в кислороде. Укажите сумму коэффициентов.",
            options: nil, matchingItems: nil,
            correctAnswer: "5",
            explanation: "2Mg + O₂ → 2MgO. Сумма: 2 + 1 + 2 = 5.",
            topic: "Химические уравнения"),
    ]

    static func generateVariant(count: Int = 10) -> ExamVariant {
        let shuffled = allTasks.shuffled().prefix(count)
        return ExamVariant(id: UUID(), title: "Тренировочный вариант", tasks: Array(shuffled))
    }
}
