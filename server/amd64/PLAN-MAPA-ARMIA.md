# Mapa de demonstração — Armia 7.48

## Objetivo

O servidor agora inicia uma pequena área de treino autoritativa perto do spawn
padrão de personagens (`2100,2100`). O client continua carregando o mapa nativo
`Env/Field1616.trn`/`Field1616.dat`; não foi criado um mapa falso no client.

## O que foi implementado

- `servidor/data/NPCGener.txt` possui o gerador `demo_armia`.
- Ele cria um grupo de 3 `Orc_Warrior` em torno de `(2118,2100)`.
- O servidor valida terreno, colisão, altura e ocupação antes de escolher cada
  posição; se a célula estiver bloqueada, procura uma célula próxima.
- Os monstros são criados no servidor, recebem IDs da faixa de mobs e são
  publicados com o pacote nativo `MSG_CreateMob` 7.48.
- A IA, dano, morte, EXP, drops, respawn e visibilidade continuam autoritativos
  no servidor. O client não fabrica monstros.
- O grupo repõe até seis monstros após 30 minutos, respeitando `MaxNumMob`.

## Correção do retorno à seleção

O client SDL3 agora trata `CNFCharacterLogout` de forma defensiva. Se o pacote
de logout chegar durante uma falha de carregamento de terreno, ele não acessa um
`TMHuman` ou slot inexistente. O client muda para `TM_SELECTCHAR_STATE` e mantém
a conexão autenticada, permitindo escolher outro personagem sem fechar o app.

## Arquitetura planejada

1. **Área de treino**: Armia, spawn seguro e monstros de baixo risco.
2. **Expansão**: adicionar áreas por zona, cada uma com seu bloco `NPCGener` e
   seus limites de população.
3. **Eventos**: bosses em `servidor/data/boss/*.lua`, nunca misturados ao
   gerador comum.
4. **Mapa**: manter os arquivos nativos do client e gerar/verificar os mapas do
   servidor a partir da mesma fonte; rejeitar boot quando height/attribute não
   forem compatíveis.
5. **Observabilidade**: usar `npcgener_log=verbose` somente durante testes para
   ver reposicionamentos e células bloqueadas.

## Aplicação

O binário foi recompilado em `servidor/bin/wydserver`, mas um processo já em
execução continua usando o código antigo. Reinicie o servidor antes de testar:

```bash
cd servidor
./iniciar.sh --cli
```

Para diagnóstico temporário:

```ini
npcgener_log=verbose
gameplay_log=verbose
```

Depois do teste, volte ambos para `summary`.

## Validação

- `go test ./internal/game ./internal/data` — aprovado.
- Cliente SDL3 x86_64 recompilado — aprovado.
- Cliente ARM64 continua usando o mesmo código-fonte e a mesma lógica de
  pacotes; deve ser recompilado pelo script Docker após cada mudança comum:
  `WYDLINUX/scripts/build-aarch64-docker.sh`.
