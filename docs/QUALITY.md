# Qualidade e integração

Esta revisão deixa a base executável mais coerente:

- registra todos os autoloads usados pelos sistemas avançados;
- corrige as ações de teclado de salvamento rápido;
- inicializa consoles jogáveis na cena principal;
- sincroniza o sistema novo de recursos com o HUD legado;
- impede que a arquitetura tenha dois valores divergentes de energia, oxigênio e sinal;
- adiciona contador de comentários e linhas não vazias;
- mantém a regra de não declarar 10.000 linhas sem contagem real.

O número de linhas deve ser obtido pelo `LL_LineCounter` ou por uma ferramenta externa no clone do repositório. Sistemas não integrados não devem ser tratados como conteúdo final.
