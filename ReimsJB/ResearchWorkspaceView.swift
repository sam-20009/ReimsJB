import SwiftUI

struct ResearchCatalogView: View {
    @State private var query = ""
    @State private var kind: CatalogKind = .cve
    @State private var earlier = "27.0.1"
    @State private var later = "27.2"

    private var comparison: PatchComparison {
        SecurityKnowledgeBase.compare(earlier: earlier, later: later)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Pesquisa documentada") {
                    Picker("Categoria", selection: $kind) {
                        ForEach(CatalogKind.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    Text("Fontes catalogadas em \(SecurityKnowledgeBase.reviewedOn). Use os links originais para revalidar datas e intervalos.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if kind == .cve {
                    Section("Comparar boletins públicos") {
                        Picker("De", selection: $earlier) {
                            Text("iOS 27.0.1").tag("27.0.1")
                            Text("iOS 27.2").tag("27.2")
                        }
                        Picker("Para", selection: $later) {
                            Text("iOS 27.0.1").tag("27.0.1")
                            Text("iOS 27.2").tag("27.2")
                        }
                        Text(comparison.explanation)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        LabeledContent("Itens selecionados", value: "\(comparison.documentedFixes.count)")
                        Link(destination: URL(string: "https://support.apple.com/en-us/149230")!) {
                            Label("Boletim oficial do iOS 27.2", systemImage: "arrow.up.right.square")
                        }
                    }
                }

                Section(kind.rawValue) {
                    let items = SecurityKnowledgeBase.search(query, kind: kind)
                    if items.isEmpty {
                        Text("Nenhum item nesta seleção.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(item.title).font(.headline)
                                Spacer(minLength: 6)
                                if kind == .cve {
                                    Text(item.id).font(.caption2.monospaced())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Text(item.subsystem)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.indigo)
                            Text(item.description).font(.subheadline)
                            Text(item.applicability)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let fixed = item.fixedIn {
                                Label("Correção publicada em iOS \(fixed)", systemImage: "checkmark.shield")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                            Link(destination: item.reference) {
                                Label("Abrir fonte", systemImage: "arrow.up.right.square")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }

                Section("Método") {
                    Text("Essas entradas são referências históricas e descrições de boletins — não testes de vulnerabilidade executados no aparelho. O catálogo é um recorte estático, não um inventário completo de correções.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Link(destination: URL(string: "https://github.com/apple-oss-distributions/xnu")!) {
                        Label("Código público XNU", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Link(destination: URL(string: "https://security.apple.com/bounty/guidelines")!) {
                        Label("Regras do Apple Security Bounty", systemImage: "book")
                    }
                }
            }
            .searchable(text: $query, prompt: "Pesquisar CVE, proteção ou projeto")
            .navigationTitle("Pesquisa")
        }
    }
}

struct EvidenceWorkspaceView: View {
    @ObservedObject var vault: EvidenceVault
    let device: DeviceReport?
    @State private var title = ""
    @State private var expected = ""
    @State private var source = ""
    @State private var component = "Foundation"

    private let components = [
        "Foundation", "CoreGraphics", "WebKit", "XNU", "IOKit", "AMFI", "Outro"
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Registro de hipótese") {
                    TextField("Título da hipótese", text: $title)
                        .textInputAutocapitalization(.sentences)
                    Picker("Componente", selection: $component) {
                        ForEach(components, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    TextField("Comportamento esperado", text: $expected, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("URL da referência (opcional)", text: $source)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                    Button {
                        vault.addHypothesis(
                            title: title, component: component,
                            expected: expected, sourceURL: source
                        )
                        if vault.lastError == nil {
                            title = ""
                            expected = ""
                            source = ""
                        }
                    } label: {
                        Label("Registrar hipótese", systemImage: "plus.circle")
                    }
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        expected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }

                Section("Experimento sintético seguro") {
                    Text("Executa uma rodada real de serialização e leitura de JSON no processo do ReimsJB. Nenhum dado de terceiros é acessado e o teste não procura um exploit.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button {
                        vault.runSyntheticJSONTest()
                    } label: {
                        Label("Testar serialização JSON", systemImage: "checkmark.shield")
                    }
                }

                if let error = vault.lastError {
                    Section {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("Evidências locais (\(vault.records.count))") {
                    if vault.records.isEmpty {
                        Text("Nenhuma evidência registrada. Crie uma hipótese ou execute o teste sintético.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(vault.records) { record in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(record.title).font(.headline)
                                Spacer(minLength: 8)
                                Text(record.stage.label)
                                    .font(.caption)
                                    .foregroundStyle(record.stage == .observed ? .green : .orange)
                            }
                            Text(record.component)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !record.observed.isEmpty {
                                Text(record.observed).font(.subheadline)
                            } else {
                                Text("Sem execução registrada")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(record.createdAt, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ShareLink(item: SecurityReportBuilder.export(record, device: device)) {
                                Label("Exportar rascunho privado", systemImage: "square.and.arrow.up")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete { offsets in
                        let ids = offsets.map { vault.records[$0].id }
                        ids.forEach { vault.delete($0) }
                    }
                }

                Section("Critérios de evidência") {
                    Text("Hipótese → Observado → Reproduzido → Impacto validado → Confirmação independente.")
                        .font(.subheadline)
                    Text("Somente testes realmente executados podem gerar o estado Observado. A promoção para impacto de segurança exige evidência técnica e revisão humana; este app não a concede automaticamente.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("Os registros ficam no armazenamento local do aplicativo, sem envio automático ao GitHub ou à Apple. O compartilhamento é manual; revise os dados antes de exportar.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Evidências")
        }
    }
}
