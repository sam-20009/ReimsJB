import XCTest
@testable import ReimsJB

final class ReimsSecurityLaboratoryTests: XCTestCase {
    func testCatalogSearchIsCaseInsensitive() {
        let items = SecurityKnowledgeBase.search("coregraphics", kind: .cve)
        XCTAssertTrue(items.contains { $0.id == "CVE-2026-112611" })
        XCTAssertTrue(items.allSatisfy { $0.kind == .cve })
    }

    func testCatalogUsesValidSourceLinks() {
        XCTAssertTrue(SecurityKnowledgeBase.entries.allSatisfy {
            $0.reference.scheme == "https"
        })
        XCTAssertTrue(SecurityKnowledgeBase.entries.contains { $0.id == "Dopamine" })
        XCTAssertTrue(SecurityKnowledgeBase.entries.contains { $0.id == "SPTM" })
    }

    func testPatchComparisonDoesNotAssumeVulnerability() {
        let diff = SecurityKnowledgeBase.compare(earlier: "27.0.1", later: "27.2")
        XCTAssertGreaterThan(diff.documentedFixes.count, 0)
        XCTAssertTrue(diff.explanation.contains("não provas"))
        XCTAssertTrue(diff.documentedFixes.allSatisfy { $0.fixedIn == "27.2" })
    }

    func testUncataloguedVersionReturnsNoClaims() {
        let diff = SecurityKnowledgeBase.compare(earlier: "27.0.1", later: "27.3")
        XCTAssertTrue(diff.documentedFixes.isEmpty)
    }

    func testEvidenceCannotJumpFromHypothesisToConfirmed() {
        var item = EvidenceRecord(
            title: "Exemplo", component: "Foundation",
            expected: "Valor preservado", observed: "OK",
            method: "Teste local", inputSHA256: String(repeating: "a", count: 64),
            attempts: 3
        )
        XCTAssertFalse(EvidenceValidator.canTransition(item, to: .reproduced))
        XCTAssertFalse(EvidenceValidator.canTransition(item, to: .impactValidated))
        XCTAssertFalse(EvidenceValidator.canTransition(item, to: .independentlyConfirmed))
        XCTAssertTrue(EvidenceValidator.canTransition(item, to: .observed))
        item.stage = .observed
        XCTAssertTrue(EvidenceValidator.canTransition(item, to: .reproduced))
        XCTAssertFalse(EvidenceValidator.canTransition(item, to: .impactValidated))
    }

    func testSyntheticJSONRoundtripProducesMeasuredResult() {
        let output = SafeEvidenceExperiment.jsonRoundTrip()
        XCTAssertTrue(output.passed)
        XCTAssertEqual(output.attempts, 1)
        XCTAssertTrue(EvidenceValidator.isSHA256(output.inputHash))
    }

    func testDraftNeverClaimsAutomaticSubmission() {
        let item = EvidenceRecord(title: "Exemplo", component: "Foundation",
            expected: "Resultado", observed: "N/D")
        let report = SecurityReportBuilder.export(item, device: nil)
        XCTAssertTrue(report.contains("NÃO SUBMETIDO"))
        XCTAssertTrue(report.contains("não demonstrado"))
        XCTAssertTrue(report.contains("Revisão humana"))
    }
}
