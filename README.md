# ReimsJB

Aplicativo SwiftUI de laboratório para organizar estudos e documentação sobre componentes do iOS.

## Estado atual

**Versão 0.1.0 — protótipo informativo.** Não é um jailbreak e não contém exploit, bypass de assinatura, persistência ou mecanismo para contornar a sandbox do iOS.

## Estrutura

- `ReimsJB/`: interface SwiftUI.
- `project.yml`: configuração do projeto Xcode gerada pelo XcodeGen.
- `.github/workflows/build-ipa.yml`: compilação automatizada no GitHub Actions.

## Gerar o IPA

1. Abra a aba **Actions** do repositório.
2. Selecione **Build ReimsJB (unsigned)**.
3. Clique em **Run workflow**.
4. Quando terminar, baixe o artefato **ReimsJB-unsigned-ipa**.

O arquivo gerado é **não assinado**. Ele serve como artefato de compilação e não será instalado diretamente em um iPhone. Para instalar, será necessário assinar o app por um método legítimo compatível com sua conta e dispositivo.

## Compilação local

Requer macOS, Xcode e XcodeGen:

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project ReimsJB.xcodeproj -scheme ReimsJB -configuration Release -sdk iphoneos CODE_SIGNING_ALLOWED=NO
```

## Compatibilidade

O projeto declara iOS 16.0 como versão mínima. A execução em versões futuras do iOS deve ser validada em dispositivo real.
