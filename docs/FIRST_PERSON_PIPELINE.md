# Direção visual de primeira pessoa

A experiência agora é tratada como primeira pessoa desde a raiz:

- câmera baixa e estável com head-bob controlado;
- mãos e antebraços em view model separado;
- estados de movimento e ações roteados para animações;
- pipeline pronto para personagens rigados e animações importadas;
- fallback procedural explícito, sem fingir que é UHD;
- validação de rig com ossos essenciais;
- perfis CINEMATIC, ULTRA e PERFORMANCE;
- diretor de câmera para impacto, emergência e primeiro contato;
- feedback de dano, interação, alerta e legendas.

Para obter UHD real, os assets `.glb`/`.fbx`, texturas 4K/8K, rig e animações precisam ser adicionados ao projeto. O código não inventa arquivos binários que não existem.
