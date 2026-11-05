# Roblox iOS VR Lab — demo experimental

Este experimento testa o que um iPhone consegue acessar **dentro de uma experiência Roblox** sem modificar o aplicativo oficial.

## Incluído

- Duas visões 3D lado a lado com ViewportFrames e separação de câmeras (estéreo *simulado*).
- Rotação de câmera por giroscópio do próprio celular, quando disponível.
- Diagnóstico de VRService.VREnabled, suporte a rastreamento de cabeça e controles vistos pelo Roblox.
- Duas mãos virtuais **simuladas** (marcadores), levantadas pelos botões da tela ou L1/R1 em gamepad compatível.
- Alternar entre visão mono/estéreo e recentralizar a orientação.

## Limites importantes

- **Não** modifica, injeta ou desbloqueia o cliente Roblox para iOS.
- **Não** ativa VRService.VREnabled e **não** fornece VR 6DoF, OpenXR, rastreamento de mãos ou dedos.
- A cena em ViewportFrame é separada do mundo normal de outras experiências Roblox.
- O giroscópio do iPhone pode ter orientação de eixos diferente conforme a posição do aparelho; use **Recentrar**.
- Gamepads Bluetooth podem ser reconhecidos como controle sem expor giroscópio ao Roblox; a demo **não lê sensores individuais de Joy-Con**.
- Renderizar duas ViewportFrames consome GPU; pode reduzir FPS no celular.
- **Não foi validado em dispositivo iOS ou no Roblox Studio nesta sessão**. Código disponibilizado como teste inicial.

## Como executar

1. Abra **Roblox Studio** em Windows ou macOS, crie um projeto Baseplate.
2. No Explorer, localize StarterPlayer > StarterPlayerScripts.
3. Crie um **LocalScript** e cole o conteúdo de VRLab.client.luau.
4. Clique em Play no Studio para verificar a interface.
5. Use File > Publish to Roblox As... para publicar **sua própria experiência**, depois abra no iPhone.
6. No telefone, ponha a tela em paisagem, teste **Recentrar** e leia VR nativo/Giroscopio/Gamepads.
7. Para controles, conecte-os ao iPhone primeiro. Não compre esperando funcionamento do giroscópio de controles paralelos sem teste.

## Por que está numa branch separada?

O GitHub conectado não ofereceu criação de repositório novo; a demo foi disponibilizada numa branch experimental do ReimsJB, sem alterar sua branch principal. Isso **não tem relação com jailbreak**.

## Referências oficiais

- https://create.roblox.com/docs/reference/engine/classes/UserInputService
- https://create.roblox.com/docs/reference/engine/classes/VRService
- https://create.roblox.com/docs/studio/cli

Este projeto é independente e não é afiliado à Roblox ou à Nintendo.
