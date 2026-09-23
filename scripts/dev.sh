#!/usr/bin/env bash
# Sobe a stack local de desenvolvimento: a API (NestJS) e o app web (Flutter).
#
#   ./scripts/dev.sh                 API + app no navegador (hot reload)
#   ./scripts/dev.sh --no-browser    API + app servido em http://localhost:PORT
#   ./scripts/dev.sh --api-only      só a API (Swagger em /swagger)
#
# Ctrl+C derruba os dois. O banco é o Postgres remoto configurado no apps/api/.env;
# não há nada de banco para subir localmente.
set -euo pipefail

# readlink -f resolve o symlink: o script pode estar no PATH apontando para cá
REPO="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
API_DIR="$REPO/apps/api"
WEB_DIR="$REPO/apps/web"
API_PORT="${NOTIF_API_PORT:-5050}"
WEB_PORT="${NOTIF_WEB_PORT:-8080}"
API_LOG="${TMPDIR:-/tmp}/notif-api.log"

MODE="browser"
case "${1:-}" in
  --no-browser) MODE="web-server" ;;
  --api-only)   MODE="api" ;;
  "" ) ;;
  *) echo "opção desconhecida: $1" >&2; exit 2 ;;
esac

# Navegador usado pelo `flutter run -d chrome`. Sem isso, ou se o caminho não
# existir, o script cai para o modo web-server e você abre a URL no seu navegador.
export CHROME_EXECUTABLE="${CHROME_EXECUTABLE:-/usr/bin/brave-browser}"

for dir in "$API_DIR" "$WEB_DIR"; do
  [ -d "$dir" ] || { echo "não encontrei $dir" >&2; exit 1; }
done

port_busy() { ss -ltn 2>/dev/null | grep -q ":$1 "; }

if port_busy "$API_PORT"; then
  echo "a porta $API_PORT já está ocupada (API rodando?)" >&2; exit 1
fi
if [ "$MODE" != "api" ] && port_busy "$WEB_PORT"; then
  echo "a porta $WEB_PORT já está ocupada (outro flutter run?)" >&2; exit 1
fi

API_PID=""
cleanup() {
  [ -n "$API_PID" ] || return 0
  # npm gera netos (npm -> sh -> nest -> tsc). Matar só o pai deixa o neto vivo,
  # então a API sobe em sessão própria (setsid) e o sinal vai para o grupo inteiro.
  local pgid
  pgid="$(ps -o pgid= -p "$API_PID" 2>/dev/null | tr -d ' ')"
  if [ -n "$pgid" ]; then
    echo; echo "encerrando a API (grupo $pgid)..."
    kill -TERM -- "-$pgid" 2>/dev/null || true
    sleep 1
    kill -KILL -- "-$pgid" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "subindo a API..."
setsid bash -c 'cd "$1" && exec npm run start:dev' _ "$API_DIR" > "$API_LOG" 2>&1 &
API_PID=$!

for _ in $(seq 1 40); do
  if curl -s -o /dev/null --max-time 2 "http://127.0.0.1:$API_PORT/api" || port_busy "$API_PORT"; then break; fi
  if ! kill -0 "$API_PID" 2>/dev/null; then
    echo "a API morreu na largada — veja $API_LOG" >&2; exit 1
  fi
  sleep 1
done

if port_busy "$API_PORT"; then
  echo "API:      http://localhost:$API_PORT/api   (swagger: /swagger, log: $API_LOG)"
else
  echo "atenção: a API não respondeu na porta $API_PORT em 40s — veja $API_LOG" >&2
fi

if [ "$MODE" = "api" ]; then
  echo; echo "só a API. Ctrl+C para encerrar."
  wait "$API_PID"
  exit 0
fi

echo
echo "logins criados pelo seed (npm run prisma:seed em apps/api):"
echo "  admin.dev@notif.com      / password123   (ADMIN)"
echo "  supervisor.dev@notif.com / password123   (SUPERVISOR)"
echo "  employee.dev@notif.com   / password123   (EMPLOYEE)"
echo

cd "$WEB_DIR"
if [ "$MODE" = "browser" ] && [ ! -x "$CHROME_EXECUTABLE" ]; then
  echo "aviso: $CHROME_EXECUTABLE não existe, caindo para web-server" >&2
  MODE="web-server"
fi

if [ "$MODE" = "browser" ]; then
  echo "app:      abrindo no navegador (hot reload: r · reiniciar: R · sair: q)"
  flutter run -d chrome
else
  echo "app:      http://localhost:$WEB_PORT  (hot reload: r · reiniciar: R · sair: q)"
  flutter run -d web-server --web-port "$WEB_PORT"
fi
