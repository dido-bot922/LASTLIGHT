# Próxima etapa: integração real

Esta etapa conecta os sistemas que estavam isolados:

- hazards ambientais agora são Autoload;
- diário persistente e telemetria agora iniciam junto com o jogo;
- `RuntimeBridge` acompanha posição do jogador, perigos, experimentos e sinal;
- `EventBus` usa caminho absoluto para o `GameState`, com sequência e consultas de eventos;
- `RuntimeAudit` verifica arquivos essenciais, Autoloads e linhas reais;
- salvamento rápido passa a incluir snapshot de missão.

Antes de expandir para conteúdo maior, execute o `RuntimeAudit` no Godot e corrija qualquer erro de compilação ou Autoload ausente. A contagem de 100.000 linhas ainda precisa ser atingida com sistemas e conteúdo reais, não com preenchimento automático.
