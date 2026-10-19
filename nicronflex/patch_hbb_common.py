"""Aplica a identidade Nicronflex Remote em libs/hbb_common (submodulo).

Executado pelo workflow nicronflex-build.yml antes da compilacao.
Falha se algum trecho esperado nao for encontrado, para nao gerar um
executavel com o servidor ou a chave errados.
"""
import os
import pathlib
import sys

APP_NAME = os.environ.get("NICRONFLEX_APP_NAME", "NicronflexRemote")
ORG = os.environ.get("NICRONFLEX_ORG", "com.nicronflex")
SERVER = os.environ.get("NICRONFLEX_SERVER", "186.202.209.86")
KEY = os.environ.get("NICRONFLEX_KEY", "TOHeD7jKC65oM8R0wVGa2rmKlSbnSxYUovpLFRqrriY=")

CONFIG = pathlib.Path(__file__).resolve().parent.parent / "libs" / "hbb_common" / "src" / "config.rs"

REPLACEMENTS = [
    ('RwLock::new("com.carriez".to_owned())', f'RwLock::new("{ORG}".to_owned())'),
    ('pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());',
     f'pub static ref APP_NAME: RwLock<String> = RwLock::new("{APP_NAME}".to_owned());'),
    ('pub const RENDEZVOUS_SERVERS: &[&str] = &["rs-ny.rustdesk.com"];',
     f'pub const RENDEZVOUS_SERVERS: &[&str] = &["{SERVER}"];'),
    ('pub const RS_PUB_KEY: &str = "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=";',
     f'pub const RS_PUB_KEY: &str = "{KEY}";'),
]


def main() -> int:
    text = CONFIG.read_text(encoding="utf-8")
    for old, new in REPLACEMENTS:
        if new in text:
            continue
        if text.count(old) != 1:
            print(f"ERRO: trecho nao encontrado exatamente uma vez em {CONFIG}: {old}")
            return 1
        text = text.replace(old, new)
    CONFIG.write_text(text, encoding="utf-8")
    print(f"hbb_common configurado: app={APP_NAME} servidor={SERVER} org={ORG}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
