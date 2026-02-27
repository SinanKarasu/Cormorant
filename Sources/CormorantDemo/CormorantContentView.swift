//
//  ContentView.swift
//  CormorantBench
//
//  Created by Sinan Karasu on 2/26/26.
//

import SwiftUI
import Combine
import Cormorant

final class REPLViewModel: ObservableObject {
    @Published var input: String = ""
    @Published private(set) var transcript: String = ""

    private let interpreter = Interpreter()

    func runCurrentInput() {
        let form = input.trimmingCharacters(in: .whitespacesAndNewlines)
        input = ""
        guard !form.isEmpty else {
            return
        }
        run(form: form)
    }

    func clearTranscript() {
        transcript = ""
    }

    private func run(form: String) {
        append("\(interpreter.currentNamespaceName)-> \(form)\n")
        let result = interpreter.evaluate(form: form)
        switch result {
        case let .Success(value):
            switch interpreter.describe(form: value) {
            case let .Just(description):
                append(description)
            case let .Error(error):
                append(error.description)
            }
        case let .ReadFailure(error):
            append(error.description)
        case let .EvalFailure(error):
            append(error.description)
        }
        append("\n")
    }

    private func append(_ text: String) {
        transcript += text
    }
}

struct CormorantContentView: View {
    @StateObject private var repl = REPLViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("Cormorant REPL")
                .font(.headline)

            ScrollView {
                Text(repl.transcript.isEmpty ? "No output yet." : repl.transcript)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.background)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.quaternary, lineWidth: 1)
            }

            HStack(spacing: 8) {
                TextField("Enter Cormorant form", text: $repl.input)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        repl.runCurrentInput()
                    }

                Button("Run") {
                    repl.runCurrentInput()
                }
                .keyboardShortcut(.return, modifiers: [])

                Button("Clear") {
                    repl.clearTranscript()
                }
            }
        }
        .padding()
        .frame(minWidth: 760, minHeight: 520)
    }
}

#Preview {
    CormorantContentView()
}
