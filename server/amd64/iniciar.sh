#!/usr/bin/env bash
# Inicia o servidor WYD-Go: abre a JANELA de administracao (app principal)
# e o servidor do jogo roda como processo-filho dela.
#
#   SENHA DO PAINEL ADMIN: CHANGE_ME   (troque com WYD_ADMIN_PASSWORD=suasenha)
#
# Uso:
#   ./iniciar.sh            # janela + servidor
#   ./iniciar.sh --cli      # servidor + console no terminal (sem janela)
#   WYD_ADMIN_PASSWORD=x ./iniciar.sh   # senha customizada
set -e
cd "$(dirname "$0")"

export WYD_ADMIN_PASSWORD="${WYD_ADMIN_PASSWORD:-CHANGE_ME}"

if [ "$1" = "--cli" ]; then
    exec ./bin/wydserver --cli -admin 127.0.0.1:7480 "$@"
fi
exec ./bin/wydserver --gui -admin 127.0.0.1:7480 "$@"
