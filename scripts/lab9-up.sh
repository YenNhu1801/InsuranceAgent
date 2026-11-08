#!/usr/bin/env bash
# Start the Lab 9 process topology on this machine.
# Docker is not required. Eureka, Auth, Gateway, Product, Pricing, Policy and Policy Search
# are separate processes. Postgres, RabbitMQ and Elasticsearch must already be listening.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PATH="${HOME}/.dotnet:${HOME}/.local/bin:${PATH}"
export DOTNET_ROOT="${HOME}/.dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export ASPNETCORE_ENVIRONMENT="${ASPNETCORE_ENVIRONMENT:-Development}"
TMUX="tmux -f /exec-daemon/tmux.portal.conf"

wait_http() {
  local name="$1" url="$2" tries="${3:-40}"
  local i
  for i in $(seq 1 "$tries"); do
    if curl -fsS -o /dev/null "$url"; then
      echo "READY $name $url"
      return 0
    fi
    sleep 2
  done
  echo "NOT READY $name $url"
  return 1
}

start_session() {
  local name="$1" dir="$2" cmd="$3"
  $TMUX has-session -t "=$name" 2>/dev/null || $TMUX new-session -d -s "$name" -c "$dir" -- bash -l
  $TMUX send-keys -t "$name:0.0" C-c
  sleep 1
  $TMUX send-keys -t "$name:0.0" "$cmd" C-m
}

echo "== infra =="
curl -fsS -o /dev/null http://localhost:9200 && echo "READY elasticsearch" || echo "MISSING elasticsearch :9200"
curl -fsS -o /dev/null http://localhost:15672 >/dev/null 2>&1 || true
(echo >/dev/tcp/127.0.0.1/5432) >/dev/null 2>&1 && echo "READY postgres :5432" || echo "MISSING postgres"
(echo >/dev/tcp/127.0.0.1/5672) >/dev/null 2>&1 && echo "READY rabbitmq :5672" || echo "MISSING rabbitmq"

echo "== eureka =="
if ! curl -fsS -o /dev/null http://localhost:8761; then
  start_session eureka "$ROOT/eureka-server/eureka-server" \
    "java -jar target/eureka-server.jar --server.port=8761"
fi
wait_http eureka http://localhost:8761 30

COMMON="export PATH=\"\$HOME/.dotnet:\$HOME/.local/bin:\$PATH\"; export DOTNET_ROOT=\"\$HOME/.dotnet\"; export DOTNET_CLI_TELEMETRY_OPTOUT=1; export ASPNETCORE_ENVIRONMENT=Development; unset Eureka__Client__ShouldRegisterWithEureka; unset Eureka__Client__ShouldFetchRegistry; export Eureka__Client__ShouldRegisterWithEureka=true; export Eureka__Client__ShouldFetchRegistry=true; "

start_session auth "$ROOT/src/AuthService/AuthService" \
  "${COMMON}dotnet run --no-launch-profile --urls http://localhost:6060"
start_session product "$ROOT/src/ProductService/ProductService" \
  "${COMMON}dotnet run --no-launch-profile --urls http://localhost:5030"
start_session pricing "$ROOT/src/PricingService/PricingService" \
  "${COMMON}dotnet run --no-launch-profile --urls http://localhost:5040"
start_session policy "$ROOT/src/PolicyService/PolicyService" \
  "${COMMON}dotnet run --no-launch-profile --urls http://localhost:5050"
start_session policy-search "$ROOT/src/PolicySearchService/PolicySearchService" \
  "${COMMON}dotnet run --no-launch-profile --urls http://localhost:5065"
start_session gateway "$ROOT/AgentPortalApiGateway/AgentPortalApiGateway" \
  "${COMMON}dotnet run --no-launch-profile --urls http://localhost:8099"

wait_http auth http://localhost:6060/swagger/index.html 40
wait_http product http://localhost:5030/swagger/index.html 40
wait_http pricing http://localhost:5040/swagger/index.html 40
wait_http policy http://localhost:5050/swagger/index.html 40
wait_http policy-search http://localhost:5065/swagger/index.html 40
wait_http gateway http://localhost:8099/swagger/index.html 20 || echo "gateway has no swagger; continuing"

echo "== eureka apps =="
curl -fsS -H 'Accept: application/json' http://localhost:8761/eureka/apps | python3 -c 'import json,sys
raw=sys.stdin.read()
try:
    data=json.loads(raw)
except Exception:
    print(raw[:1500]); raise SystemExit(0)
apps=data.get("applications",{}).get("application",[])
if isinstance(apps, dict):
    apps=[apps]
for app in apps:
    name=app.get("name")
    inst=app.get("instance",[])
    if isinstance(inst, dict):
        inst=[inst]
    for i in inst:
        print(f"{name} {i.get(\"hostName\")}:{i.get(\"port\",{}).get(\"$\") or i.get(\"port\")} status={i.get(\"status\")}")
'
echo "Lab9 processes launched. Frontend: cd Web/Web && npm run serve"
