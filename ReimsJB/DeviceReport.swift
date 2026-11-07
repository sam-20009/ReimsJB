import Foundation
import UIKit
import Darwin
import SwiftUI

enum CheckLevel {
    case success, warning, unavailable

    var symbol: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.circle.fill"
        case .unavailable: return "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .warning: return .orange
        case .unavailable: return .red
        }
    }
}

struct DiagnosticCheck: Identifiable {
    let id: String
    let name: String
    let message: String
    let level: CheckLevel
}

struct DeviceReport {
    let identifier: String
    let modelName: String
    let systemVersion: String
    let build: String
    let kernelRelease: String
    let protection: String
    let rootlessFound: Bool
    let checks: [DiagnosticCheck]
    let lastCheck: Date

    // A implementação de exploração não existe neste projeto.
    // Nunca indique suporte apenas por identificar a versão ou o chip.
    var canExecute: Bool { false }

    var statusText: String {
        rootlessFound
            ? "Bootstrap rootless detectado; validação necessária"
            : "Jailbreak não confirmado"
    }

    var exportText: String {
        let lines = [
            "ReimsJB 0.2 — diagnóstico",
            "Data: \(lastCheck.formatted())",
            "Dispositivo: \(modelName) (\(identifier))",
            "iOS: \(systemVersion) — build \(build)",
            "Kernel: \(kernelRelease)",
            "Proteção: \(protection)",
            "Rootless: \(rootlessFound ? "indício detectado" : "não verificável/ausente")",
            "Exploit: indisponível",
            "SPTM: indisponível",
            "Alterações: nenhuma"
        ]
        return lines.joined(separator: "\n") + "\n" +
            checks.map { "\($0.name): \($0.message)" }.joined(separator: "\n")
    }

    static func capture() -> DeviceReport {
        let id = hardwareIdentifier()
        let version = UIDevice.current.systemVersion
        let build = kernelValue("kern.osversion") ?? "Indisponível"
        let release = kernelValue("kern.osrelease") ?? "Indisponível"
        let a15Devices: Set<String> = [
            "iPhone14,2", "iPhone14,3", "iPhone14,4",
            "iPhone14,5", "iPhone14,6", "iPhone14,7", "iPhone14,8"
        ]
        let a15 = a15Devices.contains(id)
        let target = version == "27.0.1"
        let rootless = FileManager.default.fileExists(atPath: "/var/jb")
        let checks: [DiagnosticCheck] = [
            .init(
                id: "version",
                name: "Versão do sistema",
                message: target ? "iOS 27.0.1 identificado." : "ReimsJB foi planejado para iOS 27.0.1.",
                level: target ? .success : .warning
            ),
            .init(
                id: "device",
                name: "Identificação de chip",
                message: a15 ? "Família A15 identificada pelos metadados de hardware." : "Chip não identificado como A15 por esta tabela.",
                level: a15 ? .success : .warning
            ),
            .init(
                id: "kernel",
                name: "Acesso ao kernel (KRW)",
                message: "Nenhum exploit de leitura/escrita de kernel foi integrado ou validado.",
                level: .unavailable
            ),
            .init(
                id: "sptm",
                name: "Bypass SPTM",
                message: "Não existe backend público integrado e testado para este projeto.",
                level: .unavailable
            ),
            .init(
                id: "bootstrap",
                name: "Bootstrap rootless / Sileo",
                message: rootless
                    ? "Foi encontrado um possível caminho rootless. Isto não comprova que Sileo esteja instalado."
                    : "Não foi possível confirmar bootstrap rootless; a sandbox limita a verificação.",
                level: rootless ? .warning : .unavailable
            )
        ]
        return DeviceReport(
            identifier: id,
            modelName: UIDevice.current.model,
            systemVersion: version,
            build: build,
            kernelRelease: release,
            protection: a15 ? "SPTM (família A15)" : "Necessita identificação específica",
            rootlessFound: rootless,
            checks: checks,
            lastCheck: Date()
        )
    }

    private static func hardwareIdentifier() -> String {
        var info = utsname()
        guard uname(&info) == 0 else { return "Indisponível" }
        return withUnsafeBytes(of: &info.machine) { rawBytes in
            guard let address = rawBytes.bindMemory(to: CChar.self).baseAddress else {
                return "Indisponível"
            }
            return String(cString: address)
        }
    }

    private static func kernelValue(_ name: String) -> String? {
        var count: size_t = 0
        guard sysctlbyname(name, nil, &count, nil, 0) == 0, count > 0 else { return nil }
        var buffer = [CChar](repeating: 0, count: count)
        let result = buffer.withUnsafeMutableBufferPointer { pointer in
            sysctlbyname(name, pointer.baseAddress, &count, nil, 0)
        }
        guard result == 0 else { return nil }
        return String(cString: buffer)
    }
}
