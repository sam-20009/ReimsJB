# ReimsJB 0.5 — compatibilidade do iPhone 13
**Pesquisa de 2026-11-07. Alvo informado:** iPhone14,5, Apple A15, iOS 27.0.1, build 24A446, kernel informado 27.0.0. Nenhum iPhone físico foi acessado nesta sessão.

| Tema | Fonte e evidência | Consequência |
| --- | --- | --- |
| SPTM | [Apple Platform Security](https://support.apple.com/guide/security/welcome/web) | Documentado em chips A15 e posteriores, bypass não demonstrado aqui |
| PDF / CoreGraphics CVE-2026-112611 | [Apple iOS 27.2](https://support.apple.com/en-us/149230) | Boletim indica correção de corrupção de memória em PDF; não comprova cadeia de jailbreak |
| AVEVideoEncoder CVE-2026-112705 | [Apple iOS 27.2](https://support.apple.com/en-us/149230) | Correção de escrita fora dos limites; não equivale a KRW |
| Dopamine | [GitHub](https://github.com/opa334/Dopamine) | Não declara suporte A15 / 27.0.1 |
| Calif | [Tracker](https://github.com/iMaxTomas/ios27-jb-tracker) | Demonstração e relatos, não código validado para iPhone 13 |

**Sandbox:** não permite validar todos os caminhos e serviços privilegiados; /var/jb pode estar oculto. **Não implementado:** KRW, SPTM, mecanismo de assinatura, bootstrap ou Sileo. **Não confirmado:** um exploit público comprovado para este build.

Estados usados no ReimsResearchEngine: não verificado, em verificação, compatível, incompatível, indeterminado, falha. O estado compatível para identidade **não** indica jailbreak.

Teste real no iPhone físico: **não realizado**. O status de CI e de XCTest deve ser verificado no GitHub Actions do commit correspondente.
