import SwiftUI
import Foundation
import UIKit
import CryptoKit
import UniformTypeIdentifiers

// Importação local e inspeção superficial: nenhum PDF é renderizado,
// nenhum JavaScript ou anexo é executado e nenhuma exploração é tentada.
struct PDFResearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isImporting = false
    @State private var report: PDFInspection?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Pesquisa com PDF", systemImage: "doc.text.magnifyingglass")
                            .font(.title2.bold())
                        Text("Inspeção local de PDFs para registrar características do arquivo e sinais que merecem revisão.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Não reproduz o exploit privado da Calif. Não executa PDFs, não instala jailbreak e não contorna o iOS.")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                    .pdfCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cadeia da Calif — estado da integração")
                            .font(.headline)
                        statusLine("Entrada PDF", "Análise local disponível", "checkmark.circle.fill", .green)
                        Divider()
                        statusLine("Exploração do parser", "Código não divulgado", "lock.fill", .orange)
                        Divider()
                        statusLine("Exploração do kernel", "Sem exploit integrado", "lock.fill", .orange)
                        Divider()
                        statusLine("Bypass SPTM / A15", "Não disponível", "lock.fill", .orange)
                        Divider()
                        statusLine("Sileo", "Instalação automática indisponível", "lock.fill", .orange)
                    }
                    .pdfCard()

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Analisar documento").font(.headline)
                        Text("O arquivo é lido somente para verificar assinatura PDF, versão, tamanho, marcador de fim, hash SHA-256 e palavras-chave comuns. Os resultados não comprovam presença ou ausência de vulnerabilidades.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button {
                            isImporting = true
                        } label: {
                            Label("Selecionar PDF do Arquivos", systemImage: "doc.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            createExample()
                        } label: {
                            Label("Testar com PDF de exemplo", systemImage: "checkmark.shield")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Text("Limite: 8 MB. Não há upload nem envio para servidores.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .pdfCard()

                    if let report {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Resultado da inspeção").font(.headline)
                            pdfRow("Arquivo", report.fileName)
                            pdfRow("Tamanho", ByteCountFormatter.string(fromByteCount: Int64(report.size), countStyle: .file))
                            pdfRow("Cabeçalho", report.headerValid ? "Assinatura %PDF- reconhecida" : "Assinatura não reconhecida")
                            pdfRow("Versão indicada", report.version)
                            pdfRow("Fim do documento", report.hasEOF ? "%%EOF localizado" : "%%EOF não localizado")
                            pdfRow("Marcadores textuais", report.markers.isEmpty ? "Nenhum reconhecido" : report.markers.joined(separator: ", "))
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SHA-256").foregroundStyle(.secondary)
                                Text(report.sha256)
                                    .font(.caption.monospaced())
                                    .textSelection(.enabled)
                            }
                            Text("Importante: marcadores como JavaScript, ações automáticas e anexos podem aparecer em PDFs legítimos. A inspeção é superficial e não examina conteúdo comprimido.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ShareLink(item: report.exportText) {
                                Label("Compartilhar relatório", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .pdfCard()
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("PDF • ReimsJB")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else {
                        errorMessage = "Nenhum documento selecionado."
                        return
                    }
                    importPDF(at: url)
                case .failure(let error):
                    errorMessage = "Não foi possível abrir o seletor: \(error.localizedDescription)"
                }
            }
            .alert(
                "Análise não concluída",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Erro desconhecido.")
            }
        }
    }

    private func statusLine(_ label: String, _ value: String, _ symbol: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline.bold())
                Text(value).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func pdfRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func importPDF(at url: URL) {
        let granted = url.startAccessingSecurityScopedResource()
        defer {
            if granted {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let values = try url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
            guard values.isRegularFile == true else {
                errorMessage = "Selecione um arquivo PDF comum."
                return
            }
            if let size = values.fileSize, size > PDFInspection.maxBytes {
                errorMessage = "PDF muito grande. O limite é 8 MB."
                return
            }
            let data = try Data(contentsOf: url)
            guard data.count <= PDFInspection.maxBytes else {
                errorMessage = "PDF muito grande. O limite é 8 MB."
                return
            }
            report = PDFInspection.inspect(data, fileName: url.lastPathComponent)
        } catch {
            errorMessage = "Falha ao ler o PDF: \(error.localizedDescription)"
        }
    }

    private func createExample() {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { context in
            context.beginPage()
            let text = "ReimsJB 0.4 — Exemplo benigno"
            text.draw(
                at: CGPoint(x: 40, y: 60),
                withAttributes: [.font: UIFont.systemFont(ofSize: 18)]
            )
        }
        report = PDFInspection.inspect(data, fileName: "exemplo-reimsjb.pdf")
    }
}

private extension View {
    func pdfCard() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct PDFInspection {
    static let maxBytes = 8 * 1024 * 1024

    let fileName: String
    let size: Int
    let version: String
    let headerValid: Bool
    let hasEOF: Bool
    let sha256: String
    let markers: [String]

    var exportText: String {
        [
            "ReimsJB 0.4 — inspeção superficial de PDF",
            "Arquivo: \(fileName)",
            "Tamanho: \(size) bytes",
            "Assinatura PDF: \(headerValid ? "sim" : "não")",
            "Versão indicada: \(version)",
            "Marcador %%EOF: \(hasEOF ? "presente" : "ausente")",
            "SHA-256: \(sha256)",
            "Marcadores textuais: \(markers.isEmpty ? "nenhum" : markers.joined(separator: ", "))",
            "Inspeção estática básica; nenhuma vulnerabilidade foi confirmada.",
            "Nenhum payload foi executado. Não houve modificação no sistema."
        ].joined(separator: "\n")
    }

    static func inspect(_ data: Data, fileName: String) -> PDFInspection {
        let header = String(decoding: data.prefix(8), as: UTF8.self)
        let valid = header.hasPrefix("%PDF-")
        let version = valid ? String(header.dropFirst(5)).trimmingCharacters(in: .whitespacesAndNewlines) : "Não identificada"
        let endMarker = Data(data.suffix(1024)).range(of: Data("%%EOF".utf8)) != nil

        let needles: [(String, String)] = [
            ("/JavaScript", "JavaScript"),
            ("/OpenAction", "Ação de abertura"),
            ("/Launch", "Launch"),
            ("/EmbeddedFile", "Arquivo anexo"),
            ("/Encrypt", "Criptografia"),
            ("/AcroForm", "Formulário"),
            ("/XFA", "Formulário XFA")
        ]
        let hits = needles.compactMap { needle, description -> String? in
            data.range(of: Data(needle.utf8)) == nil ? nil : description
        }
        let digest = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
        return PDFInspection(
            fileName: fileName,
            size: data.count,
            version: version,
            headerValid: valid,
            hasEOF: endMarker,
            sha256: digest,
            markers: hits
        )
    }
}
