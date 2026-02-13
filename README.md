# racha_multi-GTA-RP-CORRIDA-APOSTADA-
codico em lua para corrida ilegal dentro de servidores fivem
Perfeito 👍
Abaixo está a instrução pronta, clara e profissional para você copiar e colar direto no README.md do resource.

🏁 Sistema de Corrida (Racha) 1x1

Sistema independente de racha entre jogadores, baseado em aposta 1x1, com checkpoints obrigatórios, fumaça visual, GPS automático e pote total para o vencedor.
Compatível com cidades grandes (100+ jogadores) e múltiplas corridas simultâneas.

🎯 Funcionamento Geral

Cada círculo no chão representa uma corrida diferente

Dois jogadores entram no mesmo círculo

Ambos digitam o comando correr [valor]

O sistema faz o pareamento automático 1x1

Vence quem completar todos os checkpoints primeiro

O vencedor recebe 100% do pote

⌨️ Comando
correr [valor]
Exemplo
correr 50000
💰 Regras de Aposta

Valor mínimo e máximo configurável

Valor máximo padrão: $50.000

Ambos apostam o mesmo valor

O servidor segura o dinheiro (escrow)

O vencedor recebe o valor total

Exemplo

Jogador A: $50.000

Jogador B: $50.000

Pote total: $100.000

Vencedor recebe: $100.000

🎟️ Ticket de Corrida

Para participar, cada jogador precisa de 1 Ticket de Corrida:

Item: raceticket

O ticket é consumido somente após o pareamento

🗺️ Sistema de Checkpoints

Cada corrida possui uma rota fixa definida no config.lua

Os checkpoints devem ser feitos na ordem correta

Cada checkpoint possui:

🚬 Fumaça dupla (esquerda e direita da via)

📍 GPS marcando apenas o próximo checkpoint

Regras

Não é possível pular checkpoints

Só finaliza após passar por todos

O primeiro que completa vence

🏆 Finalização

O primeiro jogador que concluir todos os checkpoints vence

O servidor entrega automaticamente:

💰 Dinheiro do pote

📢 Notificação para ambos os jogadores

🚫 Regras de Desclassificação

O jogador perde automaticamente se:

Sair do veículo

Não estiver no banco do motorista

Desconectar do servidor

Tentar iniciar outra corrida ao mesmo tempo

👉 Em qualquer caso acima, o outro jogador vence imediatamente

⚙️ Configuração das Corridas

As corridas são pré-definidas no código:

Arquivo: config.lua

Cada item em Config.Races representa:

Um círculo no chão

Uma corrida independente

Uma rota própria

Estrutura básica:
{
  id = "c1",
  name = "Racha Praça",
  circle = { center = vec3(x,y,z), radius = 35.0 },
  checkpoints = {
    { left = vec3(), center = vec3(), right = vec3() },
    ...
  }
}
📊 Performance

Suporta 100+ jogadores

Apenas 2 jogadores por corrida executam loops ativos

Sistema otimizado para múltiplos círculos (10 ou mais)

Anti-spam e limite de fila por corrida

📦 Instalação

Coloque o resource na pasta:

resources/[scripts]/racha_multi

Adicione no server.cfg:

ensure racha_multi

Configure suas corridas no config.lua

✅ Resumo

✔ Sistema independente
✔ Corridas por área (círculo)
✔ Aposta 1x1 com ticket
✔ Checkpoints com fumaça
✔ GPS inteligente
✔ Anti-exploit
✔ Pronto para cidades grandes

Apenas 1 ticket por jogador
