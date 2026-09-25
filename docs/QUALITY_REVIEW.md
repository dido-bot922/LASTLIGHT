# Revisão de acabamento

Esta etapa prioriza qualidade de execução em vez de adicionar código sem integração:

- a cena principal agora cria o ambiente, iluminação e consoles interativos;
- os autoloads que já existem no projeto foram registrados para não ficarem órfãos;
- o contador de linhas deixou de contar a linha fantasma criada por `eof_reached()`;
- `QualityGate` verifica cena, scripts, autoloads e metas de conteúdo;
- `EncounterDirector` cria encontros narrativos com etapas, requisitos e resultados.

A meta de 10.000 linhas continua sendo medida pelo código real. O projeto não deve declarar essa meta como concluída sem o relatório do `QualityGate` ou uma contagem externa equivalente.
