import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = ResearchStore()
    @State private var showLab = false
    @State private var showPDF = false
    @State private var showGate = false

    var body: some View {
        TabView {
            homePage
                .tabItem { Label("Início", systemImage: "house") }
            diagnosisPage
                .tabItem { Label("Diagnóstico", systemImage: "stethoscope") }
            compatibilityPage
                .tabItem { Label("Compatibilidade", systemImage: "checkmark.shield") }
            researchPage
                .tabItem { Label("Pesquisa", systemImage: "books.vertical") }
            bootstrapPage
                .tabItem { Label("Bootstrap", systemImage: "shippingbox") }
            logsPage
                .tabItem { Label("Logs", systemImage: "text.alignleft") }
            settingsPage
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
        }
        .tint(.indigo)
        .sheet(isPresented: $showLab) { SafeResearchView() }
        .sheet(isPresented: $showPDF) { PDFResearchView() }
        .alert("Jailbreak indisponível", isPresented: $showGate) {
            Button("Fechar", role: .cancel) {}
        } message: {
            let blockers = store.snapshot?.gate.missing ??
                ["Realize o diagnóstico", "KRW", "SPTM", "Bootstrap rootless"]
            Text("Faltam:\n" + blockers.joined(separator: "\n") +
                "\n\nNenhuma alteração foi realizada.")
        }
        .onAppear {
            if store.snapshot == nil { store.inspect() }
        }
    }

    private var homePage: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("ReimsJB", systemImage: "iphone.gen3")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                        Text("Pesquisa rootless · versão 0.5")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                        HStack {
                            Image(systemName: store.state.symbol)
                                .foregroundStyle(store.state.color)
                            Text(store.state.label)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 8)
                }
                Section("Este iPhone") {
                    info("Identificador", store.snapshot?.device.identifier ?? "Não verificado")
                    info("Sistema", store.snapshot.map { "iOS " + $0.device.systemVersion } ?? "Não verificado")
                    info("Build", store.snapshot?.device.build ?? "Não verificado")
                    info("Kernel", store.snapshot?.device.kernelRelease ?? "Não verificado")
                    info("Proteção documentada", "A15: SPTM")
                }
                Section("Ações") {
                    Button {
                        store.inspect()
                    } label: {
                        Label("Executar diagnóstico", systemImage: "arrow.clockwise")
                    }
                    Button {
                        showGate = true
                    } label: {
                        Label("Jailbreak — consultar pré-requisitos", systemImage: "lock.shield")
                    }
                    ShareLink(item: store.exportedReport) {
                        Label("Exportar relatório", systemImage: "square.and.arrow.up")
                    }
                }
                Section {
                    Text("O aplicativo identifica o ambiente e organiza evidências. Não possui exploit KRW, bypass SPTM, injeção de código nem instalador de Sileo.")
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
            }
            .navigationTitle("Início")
        }
    }

    private var diagnosisPage: some View {
        NavigationStack {
            List {
                Section("Verificação") {
                    statusHeader
                    Button {
                        store.inspect()
                    } label: {
                        Label("Verificar novamente", systemImage: "arrow.clockwise")
                    }
                }
                Section("Dados reais acessíveis ao aplicativo") {
                    if let report = store.snapshot?.device {
                        ForEach(report.checks) { check in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(check.name).font(.headline)
                                Text(check.message)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 3)
                        }
                    } else {
                        Text("Sem dados verificados.").foregroundStyle(.secondary)
                    }
                }
                Section("Experimentos limitados à sandbox") {
                    Button {
                        if store.allowLocalTests {
                            store.addLog("LAB", "Laboratório local aberto manualmente.")
                            showLab = true
                        }
                    } label: {
                        Label("Laboratório de APIs", systemImage: "checkmark.shield")
                    }
                    .disabled(!store.allowLocalTests)
                    if !store.allowLocalTests {
                        Text("Ative os testes locais em Ajustes para abrir este módulo.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        store.addLog("PDF", "Inspeção estática de PDF aberta.")
                        showPDF = true
                    } label: {
                        Label("Inspecionar PDF", systemImage: "doc.text.magnifyingglass")
                    }
                }
            }
            .navigationTitle("Diagnóstico")
        }
    }

    private var compatibilityPage: some View {
        NavigationStack {
            List {
                Section("Componentes e provas") {
                    if let result = store.snapshot {
                        ForEach(result.components) { component in
                            VStack(alignment: .leading, spacing: 7) {
                                HStack {
                                    Image(systemName: component.state.symbol)
                                        .foregroundStyle(component.state.color)
                                    Text(component.id.title)
                                        .font(.headline)
                                    Spacer(minLength: 8)
                                    Text(component.state.label)
                                        .font(.caption)
                                        .foregroundStyle(component.state.color)
                                }
                                Text(component.detail).font(.subheadline)
                                Text("Base: " + component.evidence)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    } else {
                        Text("Faça o diagnóstico para avaliar as peças.")
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Conclusão") {
                    Text("Reconhecer uma proteção não significa burlá-la. Um CVE corrigido não comprova acesso de leitura e escrita ao kernel.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Compatibilidade")
        }
    }

    private var researchPage: some View {
        NavigationStack {
            List {
                Section("Vulnerabilidades publicamente documentadas") {
                    ForEach(ReimsResearchEngine.findings) { finding in
                        VStack(alignment: .leading, spacing: 7) {
                            Text(finding.id).font(.headline.monospaced())
                            Text(finding.summary).font(.subheadline)
                            Text(finding.patch)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(finding.relevance)
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Link(destination: finding.reference) {
                                Label("Ver boletim original da Apple", systemImage: "arrow.up.right.square")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section("Fontes para verificação") {
                    ForEach(ReimsResearchEngine.sourceCatalog) { item in
                        VStack(alignment: .leading, spacing: 5) {
                            Link(destination: item.url) {
                                Text(item.title)
                                    .font(.headline)
                            }
                            Text(item.kind).font(.caption).foregroundStyle(.secondary)
                            Text(item.explanation)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 3)
                    }
                }
                Section {
                    Text("Fontes catalogadas em 7/11/2026; este aplicativo não consulta servidores automaticamente. Confirme as novidades nas páginas originais. Um anúncio não é evidência de integração.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Pesquisa")
        }
    }

    private var bootstrapPage: some View {
        NavigationStack {
            List {
                Section("Estado do bootstrap rootless") {
                    statusHeader
                    Text("O caminho /var/jb pode estar oculto pela sandbox, e sua presença isolada não demonstra que existe um bootstrap utilizável.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("Pré-requisitos reais") {
                    if let result = store.snapshot {
                        ForEach(result.gate.missing, id: \.self) { item in
                            Label(item, systemImage: "lock")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("Diagnóstico ainda não executado.")
                    }
                }
                Section("Gerenciador de pacotes") {
                    Label("Sileo — instalação bloqueada", systemImage: "shippingbox")
                    Text("Não instalar pacotes, alterar trust cache ou inicializar bootstrap sem permissões comprovadas.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button {
                        showGate = true
                    } label: {
                        Label("Ver o que falta", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Bootstrap")
        }
    }

    private var logsPage: some View {
        NavigationStack {
            List {
                Section("Exportação") {
                    ShareLink(item: store.exportedLog) {
                        Label("Compartilhar logs em texto", systemImage: "square.and.arrow.up")
                    }
                    Text("Registros locais em memória, limitados aos 300 mais recentes. Sem coleta automática de dados pessoais.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Eventos") {
                    ForEach(store.logs.reversed()) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.level)
                                    .font(.caption.bold())
                                    .foregroundStyle(.indigo)
                                Spacer()
                                Text(entry.time, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.message)
                                .font(.subheadline)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .navigationTitle("Logs")
        }
    }

    private var settingsPage: some View {
        NavigationStack {
            List {
                Section("Segurança") {
                    Toggle("Permitir laboratório local", isOn: $store.allowLocalTests)
                    Text("Testes voluntários e limitados à sandbox. Não há tentativas repetidas de injeção, instalação automática ou mudanças em proteções do iOS.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Projeto") {
                    info("Versão", "0.5.0")
                    info("Plataforma", "SwiftUI / iOS 16+")
                    info("Alvo de pesquisa", "iPhone14,5 · 27.0.1")
                    Link(destination: URL(string: "https://github.com/sam-20009/ReimsJB")!) {
                        Label("Código-fonte", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                    Link(destination: URL(string: "https://support.apple.com/guide/security/welcome/web")!) {
                        Label("Apple Platform Security", systemImage: "book")
                    }
                }
                Section {
                    Text("Builds GitHub Actions sem assinatura não são automaticamente instaláveis. Testes no simulador não substituem testes no iPhone físico.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ajustes")
        }
    }

    private var statusHeader: some View {
        HStack {
            Image(systemName: store.state.symbol)
                .foregroundStyle(store.state.color)
            Text(store.state.label)
                .fontWeight(.semibold)
        }
    }

    private func info(_ name: String, _ value: String) -> some View {
        LabeledContent(name) {
            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}
