import XCTest
@testable import ReimsJB

final class ReimsResearchEngineTests: XCTestCase {
    private func sample(
        identifier: String = "iPhone14,5",
        version: String = "27.0.1",
        build: String = "24A446",
        rootlessFound: Bool = false
    ) -> DeviceReport {
        DeviceReport(
            identifier: identifier,
            modelName: "iPhone",
            systemVersion: version,
            build: build,
            kernelRelease: "27.0.0",
            protection: "SPTM (família A15)",
            rootlessFound: rootlessFound,
            checks: [],
            lastCheck: Date()
        )
    }

    func testExactTargetMatching() {
        XCTAssertTrue(ReimsResearchEngine.isExactTarget(
            identifier: "iPhone14,5", version: "27.0.1", build: "24A446"
        ))
        XCTAssertFalse(ReimsResearchEngine.isExactTarget(
            identifier: "iPhone14,5", version: "27.2", build: "24A446"
        ))
        XCTAssertFalse(ReimsResearchEngine.isExactTarget(
            identifier: "iPhone14,4", version: "27.0.1", build: "24A446"
        ))
    }

    func testDefaultBackendCannotAuthorizeJailbreak() {
        let result = ReimsResearchEngine.assess(device: sample())
        XCTAssertTrue(result.targetMatched)
        XCTAssertFalse(result.gate.canRun)
        XCTAssertTrue(result.gate.missing.contains("Kernel — KRW"))
        XCTAssertTrue(result.gate.missing.contains("Proteção SPTM"))
    }

    func testRootlessHintNeverEnablesInstall() {
        let result = ReimsResearchEngine.assess(device: sample(rootlessFound: true))
        XCTAssertFalse(result.gate.canRun)
        XCTAssertEqual(
            result.components.first { $0.id == .rootless }?.state,
            .indeterminate
        )
    }

    func testMismatchedBuildIsIncompatible() {
        let result = ReimsResearchEngine.assess(
            device: sample(build: "UNKNOWN")
        )
        XCTAssertFalse(result.targetMatched)
        XCTAssertEqual(result.components.first?.state, .incompatible)
    }

    func testFindingsHaveTraceableSources() {
        XCTAssertEqual(ReimsResearchEngine.findings.count, 2)
        XCTAssertTrue(ReimsResearchEngine.findings.allSatisfy {
            $0.id.hasPrefix("CVE-") && $0.reference.scheme == "https"
        })
        XCTAssertTrue(ReimsResearchEngine.sourceCatalog.allSatisfy {
            $0.url.scheme == "https"
        })
    }
}
