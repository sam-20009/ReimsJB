import SwiftUI
import UIKit

struct ContentView: View {
    @State private var report = DeviceReport.capture()
    @State private var showBlocker = false
    @State private var showResearch = false
    @State private var showPDFResearch = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Este dispositivo")
                            .font(.headline)
                        infoRow("Modelo", report.modelName)
                        infoRow("Identificador", report.identifier)
                        infoRow("Sistema", "iOS " + report.systemVersion)
                        infoRow("Build", report.build)
                        infoRow("Kernel", report.kernelRelease)
                        infoRow("Proteção", report.protection)
                    }
                    .reimsCard()

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Diagnóstico")
                                .font(.headline)
                            Spacer()
                            Text(report.lastCheck, style: .time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(report.checks) { check in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: check.level.symbol)
                                    .foregroundStyle(check.level.color)
                                    .frame(width: 20)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(check.name).font(.subheadline.bold())
                                    Text(check.message)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                            .accessibilityElement(children: .combine)
                            if check.id != report.checks.last?.id {
                                Divider()
                            }
                        }
                    }
                    .reimsCard()

                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            report = DeviceReport.capture()
                        } label: {
                            Label("Analisar novamente", systemImage: "arrow.clockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            showPDFResearch = true
                        } label: {
                            Label("Analisar PDF (Calif)", systemImage: "doc.text.magnifyingglass")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            showResearch = true
                        } label: {
                            Label("Laboratório de análise local", systemImage: "checkmark.shield")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            showBlocker = true
                        } label: {
                            Label("Iniciar jailbreak", systemImage: "lock.open")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!report.canExecute)

                        if report.rootlessFound {
                            Button {
                                guard let url = URL(string: "sileo://") else { return }
                                UIApplication.shared.open(url)
                            } label: {
                                Label("Abrir Sileo (se instalado)", systemImage: "shippingbox")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }

                        ShareLink(item: report.exportText) {
                            Label("Compartilhar diagnóstico", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .reimsCard()

                    Text("O ReimsJB não usa tentativas repetidas de injeção. Sem um exploit KRW e um bypass SPTM comprovadamente compatíveis, executar injeção ou instalar Sileo seria inseguro e não funcionaria.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("ReimsJB")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showResearch) {
                SafeResearchView()
            }
            .sheet(isPresented: $showPDFResearch) {
                PDFResearchView()
            }
            .alert("Cadeia de jailbreak indisponível", isPresented: $showBlocker) {
                Button("Entendi", role: .cancel) { }
            } message: {
                Text("O aplicativo ainda não tem um backend KRW e bypass SPTM compatível com este iPhone. Nenhuma modificação no sistema foi realizada.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "iphone.gen3")
                    .font(.title)
                    .foregroundStyle(.blue)
                Text("ReimsJB")
                    .font(.largeTitle.bold())
                Spacer()
                Text("0.4")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Text("Diagnóstico de compatibilidade para iOS 27.0.1")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(report.statusText, systemImage: "shield.lefthalf.filled")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(report.rootlessFound ? .green : .orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .reimsCard()
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(.secondary)
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
        .font(.subheadline)
    }
}

private extension View {
    func reimsCard() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
