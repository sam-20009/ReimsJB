# ReimsJB 0.5 — diagnóstico e pesquisa rootless

**Alvo:** iPhone 13 (iPhone14,5), A15, iOS 27.0.1 (24A446).
**Situação real:** aplicativo de pesquisa. Não possui exploit KRW, bypass SPTM, bootstrap rootless nem instalação automática de Sileo.

## Funcionalidades
- Sete telas SwiftUI: Início, Diagnóstico, Compatibilidade, Pesquisa, Bootstrap, Logs e Ajustes. O iOS pode agrupar algumas guias em Mais.
- ReimsResearchEngine: seis estados de análise; catálogo de referências; verificação explícita dos pré-requisitos.
- Detecção real via UIDevice, uname e sysctl; a sandbox limita dados privilegiados.
- Referências estáticas à documentação da Apple, Dopamine e histórico comunitário, sem tratar um CVE como exploit confirmado.
- Logs com horários, exportação e limite de 300 eventos em memória.
- Laboratório opcional de APIs dentro da sandbox e inspeção estática de PDFs, preservados da versão 0.4.
- O botão de jailbreak somente explica o que falta e não executa nenhuma modificação.

## Estrutura
- ReimsJB/ReimsResearchEngine.swift: componentes, estados, evidências e interface modular para pesquisa futura.
- ReimsJB/ResearchStore.swift: logs, sessão e relatórios.
- ReimsJB/ContentView.swift: sete telas nativas.
- ReimsJB/DeviceReport.swift: metadados do aparelho.
- ReimsJB/SafeResearchView.swift e PDFResearchView.swift: experimentos não destrutivos.
- ReimsJBTests: testes de identidade, gate e fontes.

## Compilação e testes
- Actions → **Build ReimsJB (unsigned)**: gera IPA não assinado, testa a integridade ZIP, calcula e publica SHA-256.
- Actions → **ReimsJB unit tests**: executa XCTest num simulador iPhone disponível, registra xcresult.
- macOS: instale Xcode + XcodeGen, execute xcodegen generate e abra o projeto gerado.

**O IPA não assinado não instala diretamente no iPhone.** Para uso autorizado, abra o projeto no Xcode, ajuste Signing & Capabilities para sua equipe Apple Development e use Run com o iPhone conectado. Nunca envie credenciais ou certificados a terceiros. Compilação no macOS e testes no simulador não equivalem a testes físicos no A15.

Leia [o relatório de compatibilidade](Docs/CompatibilityReport.md). O tracker comunitário [ios27-jb-tracker](https://github.com/iMaxTomas/ios27-jb-tracker), de iMaxTomas (CC BY 4.0), é citado com atribuição; não distribui um jailbreak.
