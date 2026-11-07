import Foundation

enum CatalogKind: String, CaseIterable, Identifiable {
    case cve = "CVE"
    case jailbreak = "Jailbreak histórico"
    case protection = "Proteção"
    var id: String { rawValue }
}

struct SecurityCatalogEntry: Identifiable {
    let id: String
    let kind: CatalogKind
    let title: String
    let subsystem: String
    let description: String
    let applicability: String
    let fixedIn: String?
    let reference: URL
}

struct PatchComparison {
    let earlier: String
    let later: String
    let documentedFixes: [SecurityCatalogEntry]
    let explanation: String
}

enum SecurityKnowledgeBase {
    static let reviewedOn = "2026-11-07"
    private static let appleAdvisory = URL(string: "https://support.apple.com/en-us/149230")!
    private static let applePlatform = URL(string: "https://support.apple.com/guide/security/welcome/web")!
    private static let historicalReference = URL(string: "https://en.wikipedia.org/wiki/IOS_jailbreaking")!

    static let entries: [SecurityCatalogEntry] = [
        SecurityCatalogEntry(id: "CVE-2026-112611", kind: .cve,
            title: "CoreGraphics — PDF", subsystem: "CoreGraphics",
            description: "A Apple documentou uma escrita fora dos limites no processamento de PDFs.",
            applicability: "Corrigido em iOS 27.2; exploração em 27.0.1 não foi verificada pelo ReimsJB.",
            fixedIn: "27.2", reference: appleAdvisory),
        SecurityCatalogEntry(id: "CVE-2026-112705", kind: .cve,
            title: "AVEVideoEncoder — escrita fora de limites", subsystem: "AVEVideoEncoder",
            description: "A Apple documentou risco de encerramento inesperado do sistema.",
            applicability: "Correção em 27.2. Não equivale a KRW e não demonstra bypass SPTM.",
            fixedIn: "27.2", reference: appleAdvisory),
        SecurityCatalogEntry(id: "CVE-2026-112507", kind: .cve,
            title: "Kernel — escrita fora de limites", subsystem: "Kernel",
            description: "O boletim da Apple descreve possível encerramento do sistema ou escrita na memória do kernel.",
            applicability: "Corrigido em 27.2; a aplicabilidade exata ao build 24A446 não foi reproduzida.",
            fixedIn: "27.2", reference: appleAdvisory),
        SecurityCatalogEntry(id: "CVE-2026-112692", kind: .cve,
            title: "App Intents — acesso indevido a dados", subsystem: "App Intents",
            description: "A Apple documentou uma correção envolvendo checagens adicionais de permissões.",
            applicability: "Corrigido em 27.2, sem prova de exploração reproduzível neste projeto.",
            fixedIn: "27.2", reference: appleAdvisory),

        SecurityCatalogEntry(id: "JailbreakMe", kind: .jailbreak,
            title: "JailbreakMe", subsystem: "Superfícies de conteúdo",
            description: "Referência histórica para separar entrada por conteúdo e escalada de privilégios.",
            applicability: "Pesquisa histórica; não reutilizável como exploit do iOS 27.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "redsn0w", kind: .jailbreak,
            title: "redsn0w", subsystem: "Ferramentas de computador",
            description: "Referência de fluxo de diagnóstico, compatibilidade e recuperação.",
            applicability: "Histórico; nenhum suporte ao A15 atual declarado.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "Absinthe", kind: .jailbreak,
            title: "Absinthe", subsystem: "Histórico do jailbreak",
            description: "Projeto antigo para estudo de compatibilidade e lançamento de ferramentas.",
            applicability: "Histórico; detalhes técnicos exigem revisão de fonte primária.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "evasi0n", kind: .jailbreak,
            title: "evasi0n", subsystem: "Histórico do jailbreak",
            description: "Referência de cadeia de componentes e testes de versão.",
            applicability: "Histórico; sem equivalência com iOS 27.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "Pangu / TaiG", kind: .jailbreak,
            title: "Pangu e TaiG", subsystem: "Histórico do jailbreak",
            description: "Projetos históricos; metadados de suporte devem ser conferidos nas fontes originais.",
            applicability: "Nenhum suporte ao iPhone 13 com 27.0.1.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "Yalu / Electra", kind: .jailbreak,
            title: "Yalu e Electra", subsystem: "Histórico do jailbreak",
            description: "Material histórico para revisão de limitações de versão e dependências.",
            applicability: "Não demonstra vulnerabilidade no build atual.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "Chimera / Odyssey", kind: .jailbreak,
            title: "Chimera e Odyssey", subsystem: "Arquitetura de jailbreak",
            description: "Referências de organização de componentes e evolução da instalação.",
            applicability: "Não há compatibilidade automática com o iOS 27.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "unc0ver", kind: .jailbreak,
            title: "unc0ver", subsystem: "Pipeline modular",
            description: "Projeto aberto útil para pesquisar organização, pré-requisitos e recuperação.",
            applicability: "Versões históricas; não usar como backend no A15/27.0.1.",
            fixedIn: nil, reference: URL(string:"https://github.com/pwn20wndstuff/Undecimus")!),
        SecurityCatalogEntry(id: "Taurine", kind: .jailbreak,
            title: "Taurine", subsystem: "Pipeline modular",
            description: "Referência pública para separação dos componentes e compatibilidade.",
            applicability: "Não é um exploit para o iOS 27.",
            fixedIn: nil, reference: URL(string:"https://github.com/Odyssey-Team/Taurine")!),
        SecurityCatalogEntry(id: "checkra1n", kind: .jailbreak,
            title: "checkra1n / checkm8", subsystem: "BootROM",
            description: "Exemplo de exploração de hardware com escopo limitado a gerações antigas.",
            applicability: "checkm8 não é compatível com A15.",
            fixedIn: nil, reference: URL(string:"https://checkra.in/")!),
        SecurityCatalogEntry(id: "palera1n", kind: .jailbreak,
            title: "palera1n", subsystem: "Rootless e BootROM",
            description: "Pesquisa de arquitetura rootless em dispositivos da geração A8–A11.",
            applicability: "A15 fora do escopo da cadeia baseada em checkm8.",
            fixedIn: nil, reference: URL(string:"https://github.com/palera1n/palera1n")!),
        SecurityCatalogEntry(id: "Fugu15", kind: .jailbreak,
            title: "Fugu15", subsystem: "Mitigações",
            description: "Estudo público de componentes separados para exploração, assinatura e proteções.",
            applicability: "Testes históricos em A15 não provam suporte ao iOS 27.",
            fixedIn: nil, reference: URL(string:"https://github.com/pinauten/Fugu15")!),
        SecurityCatalogEntry(id: "XinaA15", kind: .jailbreak,
            title: "XinaA15", subsystem: "Histórico arm64e",
            description: "Referência histórica para análise de compatibilidade de gerações A12–A15.",
            applicability: "Não existe evidência de suporte ao iOS 27.0.1.",
            fixedIn: nil, reference: historicalReference),
        SecurityCatalogEntry(id: "Dopamine", kind: .jailbreak,
            title: "Dopamine", subsystem: "Jailbreak rootless",
            description: "Projeto rootless semi-untethered com compatibilidade delimitada por versão e SoC.",
            applicability: "Dopamine 3.0.13 não declara A15/iOS 27.0.1 como suportado.",
            fixedIn: nil, reference: URL(string:"https://github.com/opa334/Dopamine")!),
        SecurityCatalogEntry(id: "TrollStore", kind: .jailbreak,
            title: "TrollStore (não é jailbreak)", subsystem: "CoreTrust",
            description: "Demonstra que persistência de aplicativos é diferente de controle do kernel.",
            applicability: "Não oferece uma cadeia de jailbreak para iOS 27.",
            fixedIn: nil, reference: URL(string:"https://github.com/opa334/TrollStore")!),

        SecurityCatalogEntry(id: "SPTM", kind: .protection,
            title: "Secure Page Table Monitor", subsystem: "Integridade de memória",
            description: "A Apple documenta suporte a SPTM desde a família A15.",
            applicability: "Capacidade de hardware documentada; atividade e bypass não medidos pelo app.",
            fixedIn: nil, reference: applePlatform),
        SecurityCatalogEntry(id: "PAC", kind: .protection,
            title: "Pointer Authentication", subsystem: "ARM64e",
            description: "Proteção de integridade de ponteiros relacionada à arquitetura ARM64e.",
            applicability: "Mapa de proteção, não avaliação de eficácia ou bypass.",
            fixedIn: nil, reference: applePlatform),
        SecurityCatalogEntry(id: "AMFI", kind: .protection,
            title: "AMFI e assinatura de código", subsystem: "Execução",
            description: "Controle da assinatura e da execução de código em aplicativos.",
            applicability: "O app não inspeciona nem modifica as permissões de processos de terceiros.",
            fixedIn: nil, reference: applePlatform),
        SecurityCatalogEntry(id: "Sandbox", kind: .protection,
            title: "Sandbox e entitlements", subsystem: "Isolamento de apps",
            description: "Processos de terceiros ficam limitados por sandbox e permissões declaradas.",
            applicability: "Apenas o ambiente e os dados próprios podem ser verificados.",
            fixedIn: nil, reference: applePlatform),
        SecurityCatalogEntry(id: "PPL", kind: .protection,
            title: "Page Protection Layer", subsystem: "Proteção de tabelas de páginas",
            description: "Mecanismo importante historicamente; a Apple documenta SPTM como sucessor em plataformas compatíveis.",
            applicability: "Não pressupor PPL ativo apenas porque aparece em jailbreaks antigos.",
            fixedIn: nil, reference: applePlatform)
    ]

    static func search(_ query: String, kind: CatalogKind) -> [SecurityCatalogEntry] {
        let filtered = entries.filter { $0.kind == kind }
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return filtered }
        return filtered.filter {
            [$0.id, $0.title, $0.subsystem, $0.description, $0.applicability]
                .contains { $0.localizedCaseInsensitiveContains(q) }
        }
    }

    // Compara apenas boletins PUBLICADOS, não a presença de falhas no binário do usuário.
    static func compare(earlier: String, later: String) -> PatchComparison {
        let fixes = earlier == "27.0.1" && later == "27.2"
            ? entries.filter { $0.kind == .cve && $0.fixedIn == "27.2" }
            : []
        let explanation: String
        if earlier == "27.0.1" && later == "27.2" {
            explanation = "O iOS 27.0.1 não teve entradas CVE publicadas para aquela atualização. Os itens abaixo são correções documentadas em 27.2, não provas de que todos sejam exploráveis no 27.0.1. A seleção é parcial."
        } else if earlier == later {
            explanation = "Não há mudança de versão. Este é um comparador de boletins, não de binários."
        } else {
            explanation = "Par de versões sem dados catalogados. Não é possível inferir o conjunto de falhas."
        }
        return PatchComparison(earlier: earlier, later: later, documentedFixes: fixes, explanation: explanation)
    }
}
