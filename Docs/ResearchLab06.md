# ReimsJB 0.6 — laboratório de pesquisa com evidências

**Data de referência:** 7 de novembro de 2026. **Alvo:** iPhone 13 (`iPhone14,5`), A15, iOS 27.0.1, build 24A446.

## O que foi implementado

- **SecurityKnowledgeBase:** catálogo estático e pesquisável de CVEs publicados pela Apple, ferramentas históricas e conceitos de proteção. Todo item contém fonte, escopo e ressalva de compatibilidade.
- **Comparador de boletins:** exibe seleção de correções documentadas entre iOS 27.0.1 e 27.2, **sem concluir que o build antigo é explorável**. Não compara binários nem baixa fontes.
- **EvidenceVault:** dados privados em JSON no armazenamento Application Support do app, sujeitos à política normal de backup do iOS; sem telemetria do aplicativo. Permite registrar hipótese, excluir dados e exportar relatórios por ação manual.
- **EvidenceValidator:** diferencia hipótese, observação, reprodução, impacto e confirmação independente. Nunca promove sozinho um teste benigno para vulnerabilidade.
- **SafeEvidenceExperiment:** executa localmente round-trip JSON sintético com cálculo SHA-256 da entrada para repetição verificável.
- **SecurityReportBuilder:** prepara rascunho privado para revisão humana conforme campos relevantes para Apple Security Bounty. Nenhum envio automático.

## Fontes e limitações

A Apple documenta suporte ao SPTM na geração A15, sem tornar essa detecção uma medição de bypass. O Dopamine 3.0.13 não declara compatibilidade com A15/iOS 27.0.1. O [boletim iOS 27.2](https://support.apple.com/en-us/149230) descreve correções em CoreGraphics, Kernel, AVEVideoEncoder e App Intents, mas não publica automaticamente uma cadeia de exploração.

O app não acessa kernel nem desativa proteções. Um crash, uma CVE histórica ou uma correspondência de versão não são prova de jailbreak. Nenhum zero-day novo foi identificado.

## Testes
O arquivo `ReimsJBTests/ReimsSecurityLaboratoryTests.swift` testa busca, fontes, correções, transições de evidência, JSON sintético e ausência de alegação de submissão. O workflow Xcode/XCTest executa separadamente do empacotamento do IPA. Resultado deve ser confirmado no GitHub Actions.

### Privacidade
Não publique uma hipótese potencialmente inédita no GitHub público nem envie relatórios sem revisão. Dados de evidência permanecem locais até compartilhamento manual. Os testes no simulador não substituem validação no iPhone13 real.
