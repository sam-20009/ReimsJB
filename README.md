# ReimsJB

Aplicativo open source SwiftUI para **diagnóstico verificável de compatibilidade**, com interface simples para iPhone e preparação do projeto para integrações futuras.

## Versão 0.2 — estado real

- Identifica modelo de hardware (por exemplo, `iPhone14,5`), iOS, build e kernel.
- Classifica a família A15, identifica iOS 27.0.1 e mostra pré-requisitos.
- Verifica somente se há *indício* de bootstrap rootless; a sandbox pode ocultar dados.
- Exporta relatório em texto pelo compartilhamento do iOS.
- Mostra opção para abrir Sileo se houver indício de rootless e o aplicativo já estiver instalado.
- **Não contém exploit KRW, bypass SPTM, injeção, persistência nem instalador Sileo.**
- O botão de jailbreak permanece desativado até que um backend real e validado seja integrado. Não faz tentativas repetidas que possam provocar travamentos.

O [ios27-jb-tracker](https://github.com/iMaxTomas/ios27-jb-tracker), de iMaxTomas (CC BY 4.0), foi consultado como fonte informativa sobre o estado das pesquisas. **O tracker não distribui exploits** e não é código de jailbreak. A referência não implica afiliação ou endosso.

## Compilar um IPA não assinado pelo GitHub

1. Acesse **Actions → Build ReimsJB (unsigned)**.
2. Clique em **Run workflow**, ou veja o build iniciado pelo push.
3. Baixe o artefato **ReimsJB-unsigned-ipa** quando a compilação concluir.
4. Para executar no iPhone, o pacote precisa de assinatura legítima compatível com seu dispositivo.

O compilador do GitHub Actions gera o binário, mas não comprova que o app funciona no iOS 27.0.1 em hardware real. É necessário testá-lo no iPhone.

## Compilar localmente

Requer macOS, Xcode e XcodeGen.

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project ReimsJB.xcodeproj -scheme ReimsJB -configuration Release -sdk iphoneos CODE_SIGNING_ALLOWED=NO
```

**Não instale IPAs desconhecidos que afirmem ter jailbreak para A15/iOS 27.0.1 sem validação independente.**
