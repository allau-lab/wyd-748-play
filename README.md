# WYD 7.48 — packs jogáveis

Cliente e servidor **prontos para jogar**.

**Funciona em GNU/Linux x86_64, GNU/Linux ARM64 e Nintendo Switch (Atmosphere / homebrew desbloqueado).**

Source e skills: [wyd-748-ports](https://github.com/allau-lab/wyd-748-ports) · [wyd-port-skills](https://github.com/allau-lab/wyd-port-skills)

---

## Conteúdo do repositório

| Pasta | Plataforma |
|---|---|
| `client/linux/` | Assets + binário **x86_64** (`project`) + binário **ARM64** (`WYD Arm64`) + DXVK |
| `client/linux/dxvk-aarch64/` | `libdxvk_d3d9.so` para o client ARM64 |
| `client/switch/` | `wyd748.nro` (homebrew Switch) |
| `server/amd64/` | Servidor WYD-Go **x86_64** |
| `server/arm64/` | Servidor WYD-Go **ARM64** (+ Docker) |

`serverlist.bin` vem com **127.0.0.1:8281**. Senha do painel admin nos configs: `CHANGE_ME` (ou env `WYD_ADMIN_PASSWORD`).

---

## Como jogar no GNU/Linux

### 1. Subir o servidor

**x86_64:**

```bash
cd server/amd64
./iniciar.sh --cli
# ou headless:
./bin/wydserver -config data/server.txt -addr 0.0.0.0:8281
```

**ARM64** (Orange Pi, etc.):

```bash
cd server/arm64
./iniciar.sh --daemon
# ou Docker:
docker compose -f docker/docker-compose.yml up -d --build
```

Confirme a porta **8281** aberta (`ss -ltn | grep 8281`).

### 2. Rodar o client

Dependências típicas: Vulkan, Wayland (ou X11), SDL2/SDL3 conforme o binário.

**x86_64:**

```bash
cd client/linux
export DXVK_WSI_DRIVER=SDL3          # se falhar, tente SDL2
export SDL_VIDEODRIVER=wayland       # fallback: x11
export LD_LIBRARY_PATH="$PWD:$LD_LIBRARY_PATH"
export VK_LOADER_LAYERS_DISABLE='*steam*'
./project
```

**ARM64:**

```bash
cd client/linux
export DXVK_WSI_DRIVER=SDL2
export SDL_VIDEODRIVER=wayland
export LD_LIBRARY_PATH="$PWD/dxvk-aarch64:$LD_LIBRARY_PATH"
export VK_LOADER_LAYERS_DISABLE='*steam*'
./"WYD Arm64"
```

Fluxo esperado: splash → lista de servidores (127.0.0.1) → login → personagem → campo.

Para jogar em outro PC da LAN, regenere o `serverlist.bin` com o IP do servidor e aponte o client para essa pasta.

---

## Como jogar no Nintendo Switch (desbloqueado)

Requisitos: console com **Atmosphere** (ou CFW compatível), homebrew menu, e idealmente servidor FTP no Switch (para copiar arquivos).

### 1. Instalar no cartão SD

1. Crie uma pasta, por exemplo `sdmc:/switch/wyd748/`.
2. Copie **todo** o conteúdo de `client/linux/` para essa pasta  
   (UI, mesh, Env, Effect, fonts, `serverlist.bin`, `config.txt`, bins de dados, …).
3. Copie `client/switch/wyd748.nro` para a **mesma** pasta.
4. (Opcional) Remova do SD os ELF Linux (`project`, `WYD Arm64`, `libdxvk_*.so`, pasta `dxvk-aarch64`) — não são usados no Switch.

Estrutura mínima:

```text
sdmc:/switch/wyd748/
  wyd748.nro
  serverlist.bin
  config.txt
  UI/  mesh/  Env/  Effect/  fonts/  …
```

### 2. Servidor

O Switch só roda o **client**. O servidor continua no PC/VPS/Orange Pi (veja seção Linux).  
Ajuste `serverlist.bin` para o IP LAN do servidor (não use `127.0.0.1` no console).

### 3. Executar

1. Ligue o CFW / Atmosphere.
2. Abra o **Homebrew Menu**.
3. Inicie `wyd748.nro`.
4. Faça login na lista de servidores apontando para a máquina onde o WYD-Go está escutando na porta **8281**.

Controles: Joy-Con + toque (conforme o port). Se a tela ficar cinza/preta, confira se UI/mesh/fonts foram copiados por completo.

---

## Avisos

- Pacote community / estudo — não é o cliente oficial da Softnyx.
- Troque senhas e não exponha `8281` na internet sem firewall.
- Binários Linux precisam de GPU com Vulkan; no ARM use as libs em `dxvk-aarch64/`.
