# Servidor WYD-Go — Produção

Tudo que o servidor precisa está nesta pasta. O código-fonte fica em
`../codigo-fonte/` e é só para desenvolvimento.

```
servidor/
├── bin/wydserver      ← o ÚNICO binário (servidor + admin CLI + janela admin)
├── data/              ← todos os dados do jogo (server.txt, maps, npcs, wydgo.db)
├── logs/              ← saída do servidor (boot.log e seguintes)
├── backup/            ← lugar para cópias do wydgo.db antes de operações grandes
├── iniciar.sh         ← inicia tudo: servidor + janela de administração
└── LEIA-ME.md         ← este arquivo
```

## Iniciar / parar / reiniciar

```bash
./iniciar.sh          # abre a JANELA de administração; servidor sobe como filho dela
./iniciar.sh --cli    # servidor + console de administração no terminal (sem janela)
```

**A janela é o app principal** (aba Status):

- **Iniciar / Parar / Reiniciar** controlam o processo do servidor.
- A linha "Processo do servidor" mostra `rodando (pid N)` ou `parado (motivo)`.
- Fechar a janela NÃO derruba o servidor em execução — use "Parar" para isso
  (persiste tudo antes de sair).

**Onde configurar usuário e senha do painel:**

O painel usa **senha única de admin** — não há multiusuário. O campo
"usuário" não existe na janela; só a senha é pedida.

Configure em `data/server.txt` (final do arquivo):

```
admin_user=admin          # rótulo/auditoria (o login não pede usuário)
admin_password=admin748   # senha do painel
```

Prioridade da senha: `WYD_ADMIN_PASSWORD` (ambiente) **>** `admin_password`
do `server.txt` **>** aleatória logada no boot. O `iniciar.sh` também aceita
`WYD_ADMIN_PASSWORD=suasenha ./iniciar.sh` sem tocar no arquivo.

## O que editar

- **Configuração do servidor**: `data/server.txt` (porta do jogo em
  `listen_address`, banco em `database_driver/database_path`, taxas, etc.).
  Também dá para ver/mudar configurações pela janela admin (aba Config)
  sem abrir arquivo.
- **Contas, personagens, bans, config persistida**: tudo fica no
  `data/wydgo.db` (SQLite). Não edite à mão — use a janela admin, o
  `--cli` ou os subcomandos:

  ```bash
  ./bin/wydserver account list
  ./bin/wydserver account create jogador senha123
  ./bin/wydserver account ban jogador "motivo" 7
  ./bin/wydserver chars.list
  ```

- **Lista de servidores do client (`serverlist.bin`)**: o que o client
  mostra na tela de seleção (nome do grupo e IP para conectar). Gere pela
  **aba Lista** da janela admin — carrega, edita grupo a grupo (nome +
  IP) e grava direto na pasta do client — ou por comando:

  ```bash
  ./bin/wydserver serverlist show
  ./bin/wydserver serverlist generate WYD748 192.168.1.21
  ```

  O caminho do arquivo do client fica em `client_serverlist=` no
  `server.txt` (já configurado para a pasta `client748`). O client lê o
  arquivo quando abre a tela de seleção — reinicie-o depois de salvar.
  Cópia de fábrica do pack (IP de internet antigo):
  `codigo-fonte/client748/serverlist.bin`.

## Porta do jogo

`server.txt` vem com `listen_address=0.0.0.0:8281` (a porta clássica do
WYD). Se ela estiver ocupada por outro processo (ex.: o tmsrv 2.0 de outro
diretório), troque a porta no `server.txt` ou passe na linha de comando:

```bash
./bin/wydserver --gui -addr 0.0.0.0:8282
```

O client conecta na porta configurada no serverlist dele.

## Painel de administração (rede)

A janela admin fala com o processo pela porta `127.0.0.1:7480` (só
loopback, por segurança). Para administrar de outra máquina, use túnel SSH:

```bash
ssh -L 7480:127.0.0.1:7480 usuario@servidor
# então rode a janela admin local apontando para 127.0.0.1:7480
```

## Backup

```bash
cp data/wydgo.db backup/wydgo-$(date +%Y%m%d-%H%M).db
```

Faça backup antes de operações grandes (migração, exclusão em massa) e
periodicamente. O servidor grava transacionalmente — copiar o arquivo com o
servidor parado é sempre seguro.

## Rebuild (após mudar o código em ../codigo-fonte)

```bash
cd ../codigo-fonte
go build -tags gui -o ../servidor/bin/wydserver ./cmd/server
```

Sem a tag `gui` o binário sai headless (sem janela — para VPS puro).
