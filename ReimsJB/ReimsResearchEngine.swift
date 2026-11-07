import Foundation
import SwiftUI

enum ResearchState: String, CaseIterable, Codable {
    case unverified, checking, compatible, incompatible, indeterminate, failed

    var label: String {
        switch self {
        case .unverified: return "Não verificado"
        case .checking: return "Em verificação"
        case .compatible: return "Compatível"
        case .incompatible: return "Incompatível"
        case .indeterminate: return "Indeterminado"
        case .failed: return "Falha"
        }
    }
    var symbol: String {
        switch self {
        case .unverified: return "questionmark.circle"
        case .checking: return "arrow.triangle.2.circlepath"
        case .compatible: return "checkmark.circle.fill"
        case .incompatible: return "xmark.circle.fill"
        case .indeterminate: return "exclamationmark.circle"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }
    var color: Color {
        switch self {
        case .compatible: return .green
        case .incompatible, .failed: return .red
        case .indeterminate: return .orange
        case .checking: return .blue
        case .unverified: return .secondary
        }
    }
}

enum ResearchComponentID: String, CaseIterable, Hashable {
    case device, kernel, sptm, codeSigning, rootless, packageManager

    var title: String {
        switch self {
        case .device: return "Identidade do dispositivo"
        case .kernel: return "Kernel — KRW"
        case .sptm: return "Proteção SPTM"
        case .codeSigning: return "Assinatura e execução"
        case .rootless: return "Bootstrap rootless"
        case .packageManager: return "Gerenciador de pacotes"
        }
    }
}

struct ComponentAssessment: Identifiable {
    let id: ResearchComponentID
    let state: ResearchState
    let detail: String
    let evidence: String
}

struct ResearchSource: Identifiable {
    let id: String
    let title: String
    let url: URL
    let explanation: String
    let kind: String
}

struct PublishedFinding: Identifiable {
    let id: String
    let summary: String
    let patch: String
    let relevance: String
    let reference: URL
}

struct BackendAttestation {
    let identifier: String
    let model: String
    let systemVersion: String
    let osBuild: String
    let onDeviceValidated: Bool
    let reproducibleEvidence: String?
}

protocol VerifiedResearchBackend {
    func attest(for device: DeviceReport) -> BackendAttestation?
}

// Backend explícito de indisponibilidade; não simula permissões nem exploração.
struct UnavailableResearchBackend: VerifiedResearchBackend {
    func attest(for device: DeviceReport) -> BackendAttestation? { nil }
}

struct JailbreakGate {
    let canRun: Bool
    let missing: [String]
}

struct ResearchSnapshot {
    let device: DeviceReport
    let checkedAt: Date
    let targetMatched: Bool
    let components: [ComponentAssessment]
    let gate: JailbreakGate
}

enum ReimsResearchEngine {
    static let sourceCatalog: [ResearchSource] = [
        ResearchSource(
            id: "apple-platform",
            title: "Apple Platform Security",
            url: URL(string: "https://support.apple.com/guide/security/welcome/web")!,
            explanation: "Arquitetura de segurança, SPTM e integridade de código.",
            kind: "Apple — documentação"
        ),
        ResearchSource(
            id: "apple-27.2",
            title: "Boletim de segurança iOS 27.2",
            url: URL(string: "https://support.apple.com/en-us/149230")!,
            explanation: "CVE e correções publicadas pela Apple.",
            kind: "Apple — boletim"
        ),
        ResearchSource(
            id: "dopamine",
            title: "Dopamine — código oficial",
            url: URL(string: "https://github.com/opa334/Dopamine")!,
            explanation: "Intervalos de suporte reais do jailbreak rootless.",
            kind: "Projeto de código aberto"
        ),
        ResearchSource(
            id: "tracker",
            title: "ios27-jb-tracker — pesquisas e alegações",
            url: URL(string: "https://github.com/iMaxTomas/ios27-jb-tracker")!,
            explanation: "Acompanhamento comunitário: declarações não significam exploit liberado. Crédito: iMaxTomas, CC BY 4.0.",
            kind: "Rastreador comunitário"
        )
    ]

    static let findings: [PublishedFinding] = [
        PublishedFinding(
            id: "CVE-2026-112611",
            summary: "CoreGraphics: processamento de PDF criado maliciosamente pode causar corrupção de memória.",
            patch: "Correção documentada pela Apple no iOS 27.2.",
            relevance: "O boletim inclui iPhone 11 e posteriores, mas não comprova exploração no iPhone 13 com iOS 27.0.1, nem fornece um jailbreak.",
            reference: URL(string: "https://support.apple.com/en-us/149230")!
        ),
        PublishedFinding(
            id: "CVE-2026-112705",
            summary: "AVEVideoEncoder: escrita fora dos limites, com possível encerramento inesperado do sistema.",
            patch: "Correção documentada pela Apple no iOS 27.2.",
            relevance: "CVE documentada não equivale a KRW, bypass SPTM ou exploit público validado.",
            reference: URL(string: "https://support.apple.com/en-us/149230")!
        )
    ]

    static func isExactTarget(identifier: String, version: String, build: String) -> Bool {
        identifier == "iPhone14,5" && version == "27.0.1" && build == "24A446"
    }

    static func assess(
        device: DeviceReport,
        backend: any VerifiedResearchBackend = UnavailableResearchBackend()
    ) -> ResearchSnapshot {
        let match = isExactTarget(
            identifier: device.identifier,
            version: device.systemVersion,
            build: device.build
        )
        let identityState: ResearchState = match ? .compatible : .incompatible

        // Metadados e fontes públicas não demonstram capacidade de bypass.
        // O /var/jb pode estar invisível ao app por sandbox e NÃO valida bootstrap.
        let components: [ComponentAssessment] = [
            ComponentAssessment(
                id: .device,
                state: identityState,
                detail: match ? "Modelo, versão e build correspondem ao alvo." :
                    "Este aparelho difere do alvo iPhone14,5 / 27.0.1 / 24A446.",
                evidence: "UIDevice + uname + kern.osversion, observados pelo processo."
            ),
            ComponentAssessment(
                id: .kernel,
                state: .indeterminate,
                detail: "Não há backend KRW público integrado ou demonstrado neste build.",
                evidence: "Estado do código local; não é uma prova de invulnerabilidade."
            ),
            ComponentAssessment(
                id: .sptm,
                state: .indeterminate,
                detail: "SPTM pertence à classe de proteções do A15. Nenhum bypass foi validado.",
                evidence: "Apple Platform Security; presença documentada ≠ bypass."
            ),
            ComponentAssessment(
                id: .codeSigning,
                state: .indeterminate,
                detail: "Nenhuma autorização de execução de código não assinado foi comprovada.",
                evidence: "Nenhum backend de assinatura / trust cache integrado."
            ),
            ComponentAssessment(
                id: .rootless,
                state: .indeterminate,
                detail: device.rootlessFound
                    ? "Caminho /var/jb observado; não comprova bootstrap utilizável."
                    : "Bootstrap não verificável a partir da sandbox do app.",
                evidence: "Leitura limitada à sandbox; resultado inconclusivo."
            ),
            ComponentAssessment(
                id: .packageManager,
                state: .indeterminate,
                detail: "Sileo não será instalado sem bootstrap real e verificável.",
                evidence: "Nenhum instalador ou permissões elevadas incluídos."
            )
        ]

        let attestation = backend.attest(for: device)
        let attested = attestation?.onDeviceValidated == true
            && attestation?.model == device.identifier
            && attestation?.systemVersion == device.systemVersion
            && attestation?.osBuild == device.build
            && !(attestation?.reproducibleEvidence?.isEmpty ?? true)

        let missing = components
            .filter { $0.id != .device && $0.state != .compatible }
            .map { $0.id.title }
        var blockers = missing
        if !match { blockers.insert("Modelo, versão ou build fora do alvo", at: 0) }
        if !attested { blockers.append("Backend com evidência reproduzível e validação neste dispositivo") }

        // Sem backend real, nenhum botão pode executar alterações no sistema.
        let gate = JailbreakGate(
            canRun: match && attested && missing.isEmpty,
            missing: blockers
        )
        return ResearchSnapshot(
            device: device,
            checkedAt: Date(),
            targetMatched: match,
            components: components,
            gate: gate
        )
    }
}
