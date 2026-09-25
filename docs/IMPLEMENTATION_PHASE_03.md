# Fase adicional de implementação

Este pacote amplia o jogo com componentes funcionais de execução:

- bootstrap que conecta os sistemas e inicializa registros;
- consoles de reparo, ciência, navegação e airlock;
- banco de conteúdo para locais, incidentes e notas científicas;
- contador real de linhas GDScript no projeto;
- self-test para validar subsistemas;
- alertas de recursos, falhas e viagens;
- integração de telemetria com a pesquisa e o arquivo da missão.

O contador interno está em `scripts/tools/LineCounter.gd`. Ele pode ser chamado pelo jogo para mostrar a contagem real; não é correto declarar 10.000 linhas sem executar essa contagem no clone do projeto.
