import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewView()
                .tabItem { Label("Visão geral", systemImage: "square.grid.2x2") }
                .tag(0)
            ComponentsView()
                .tabItem { Label("Componentes", systemImage: "shippingbox") }
                .tag(1)
            AboutView()
                .tabItem { Label("Sobre", systemImage: "info.circle") }
                .tag(2)
        }
        .tint(.blue)
    }
}

private struct OverviewView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ReimsJB")
                            .font(.largeTitle.bold())
                        Text("Laboratório de pesquisa iOS")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Ambiente informativo para organizar observações e estudar componentes do sistema. Esta versão não executa jailbreak nem altera proteções do iPhone.")
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                }
                Section("Estado do projeto") {
                    LabeledContent("Aplicativo", value: "0.1.0")
                    LabeledContent("Modo", value: "Somente leitura")
                    LabeledContent("Exploit", value: "Não incluído")
                    LabeledContent("Compatibilidade", value: "iOS 16 ou posterior")
                }
                Section("Próximos passos") {
                    Label("Catalogar binários e metadados", systemImage: "doc.text.magnifyingglass")
                    Label("Registrar observações de pesquisa", systemImage: "note.text")
                    Label("Documentar versões e dispositivos", systemImage: "iphone")
                }
            }
            .navigationTitle("ReimsJB")
        }
    }
}

private struct ComponentsView: View {
    private let items: [(String, String, String)] = [
        ("Executáveis", "Inventário e metadados", "terminal"),
        ("Frameworks", "Bibliotecas e dependências", "shippingbox"),
        ("Serviços", "Descrições e funções conhecidas", "gearshape.2"),
        ("Relatórios", "Anotações de análise estática", "doc.richtext")
    ]

    var body: some View {
        NavigationStack {
            List(items, id: \.0) { item in
                Label {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.0)
                        Text(item.1)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: item.2)
                        .foregroundStyle(.blue)
                }
            }
            .navigationTitle("Componentes")
        }
    }
}

private struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Sobre o ReimsJB") {
                    Text("O ReimsJB é um projeto de estudo e documentação. Ele não contém cadeia de exploração, bypass de assinatura, persistência ou código para escapar da sandbox.")
                }
                Section("Informações") {
                    LabeledContent("Versão", value: "0.1.0")
                    LabeledContent("Plataforma", value: "iOS")
                    LabeledContent("Interface", value: "SwiftUI")
                }
                Section {
                    Link(destination: URL(string: "https://github.com/sam-20009/ReimsJB")!) {
                        Label("Abrir repositório no GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                    }
                }
            }
            .navigationTitle("Sobre")
        }
    }
}
