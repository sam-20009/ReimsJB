# ReimsJB 0.6 — laboratório de pesquisa de segurança iOS

Projeto SwiftUI para **pesquisa documentada, diagnóstico e evidências reproduzíveis**, sem apresentar um jailbreak inexistente.

**Dispositivo-alvo:** iPhone 13 (iPhone14,5), Apple A15, iOS 27.0.1, build 24A446.

## Funcionalidades

- Identificação de modelo, versão, build e kernel, com as limitações da sandbox do iOS.
- **SecurityKnowledgeBase:** catálogo pesquisável de CVEs publicados pela Apple, jailbreaks históricos e proteções. Fontes são links oficiais ou históricos identificados. A lista é parcial e estática.
- **Comparador de boletins:** apresenta correções documentadas entre iOS 27.0.1 e 27.2, sem concluir automaticamente que o aparelho antigo é vulnerável.
- **EvidenceVault:** hipóteses e observações salvas somente no armazenamento local do aplicativo, com exclusão e exportação manuais.
- **EvidenceValidator:** critérios separados para hipótese, observação, reprodução, impacto e confirmação independente.
- **SafeEvidenceExperiment:** teste real e benigno de serialização JSON sintética com SHA-256.
- **SecurityReportBuilder:** relatório em texto para revisão humana, não enviado automaticamente à Apple.
- **Laboratórios anteriores:** testes de Foundation na sandbox e inspeção estática de PDFs.
- **Jailbreak bloqueado:** falta um backend KRW, bypass SPTM, ambiente de assinatura, bootstrap e Sileo comprovadamente compatíveis. Nenhuma injeção nem instalação são realizadas.

## Estrutura

| Caminho | Função |
| --- | --- |
| ReimsJB/ContentView.swift | navegação e diagnóstico |
| ReimsJB/ResearchWorkspaceView.swift | interface de pesquisa e evidências |
| ReimsJB/SecurityKnowledgeBase.swift | catálogo e comparador de boletins |
| ReimsJB/EvidenceLedger.swift | armazenamento local, verificação e relatório |
| ReimsJB/ReimsResearchEngine.swift | compatibilidade e bloqueios |
| ReimsJB/DeviceReport.swift | dados de dispositivo |
| ReimsJBTests | testes XCTest |
| Docs/ResearchLab06.md | detalhes técnicos da versão 0.6 |
| Docs/CompatibilityReport.md | análise de requisitos no iPhone 13 |

## Compilação e instalação

- **Build ReimsJB (unsigned)** no GitHub Actions: compila com Xcode, verifica o ZIP e publica o IPA não assinado mais seu SHA-256.
- **ReimsJB unit tests**: executa os testes num simulador iOS disponível e disponibiliza o relatório xcresult.
- Para instalar no aparelho autorizado, use um Mac com Xcode e XcodeGen, execute `xcodegen generate`, abra o projeto, configure Signing & Capabilities com uma equipe Apple Development legítima e escolha o iPhone conectado.

O IPA do CI não é assinado e **não pode ser instalado diretamente**. Testes no simulador ou a compilação de um IPA não validam compatibilidade de um jailbreak no iPhone físico.

## Divulgação responsável

Evidências inéditas devem permanecer privadas até serem avaliadas pelo pesquisador e encaminhadas pelos canais oficiais. Consulte [Apple Security Bounty Guidelines](https://security.apple.com/bounty/guidelines) e não publique código sensível ou dados pessoais. Este projeto não envia relatórios automaticamente.

Leia [Pesquisa 0.6](Docs/ResearchLab06.md). Fontes: [Apple Security](https://support.apple.com/guide/security/welcome/web), [boletim iOS 27.2](https://support.apple.com/en-us/149230), [Dopamine](https://github.com/opa334/Dopamine), [XNU](https://github.com/apple-oss-distributions/xnu). Referência comunitária com atribuição: [ios27-jb-tracker](https://github.com/iMaxTomas/ios27-jb-tracker), iMaxTomas (CC BY 4.0).
