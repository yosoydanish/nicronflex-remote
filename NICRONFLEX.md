# Nicronflex Remote

Nicronflex Remote é uma versão personalizada do [RustDesk](https://github.com/rustdesk/rustdesk),
distribuída sob a mesma licença **AGPL-3.0** (ver [LICENCE](LICENCE)).
Este repositório contém o código-fonte completo da versão distribuída.

## Alterações em relação ao RustDesk

- Nome do aplicativo, ícones, logotipo e cores da Nicronflex
  (`nicronflex/branding/`, `res/`, `flutter/assets/`, `flutter/windows/runner/`, `flutter/android/.../res/`).
- Servidor de ID/retransmissão e chave pública próprios, aplicados na compilação por
  `nicronflex/patch_hbb_common.py`.
- Workflow de compilação `.github/workflows/nicronflex-build.yml`.

## Compilar

GitHub → Actions → **Nicronflex Remote - build Windows** → *Run workflow*.
O executável fica nos artefatos da execução.

"RustDesk" é marca dos seus respectivos titulares; este projeto não é afiliado ao RustDesk.
