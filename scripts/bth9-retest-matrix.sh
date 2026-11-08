#!/usr/bin/env bash
# Ma tran PASS/FAIL/NOT_TESTED — khong khong che. Khong dung tien that.
set -uo pipefail
AUTH="${AUTH:-http://localhost:6060}"
GW="${GW:-http://localhost:8099}"
PAY="${PAY:-http://localhost:5070}"
DASH="${DASH:-http://localhost:5035}"
BLAZOR="${BLAZOR:-http://localhost:5081}"
CHAT="${CHAT:-http://localhost:4099}"
REPORT="${1:-/opt/cursor/artifacts/bth9-test-report.txt}"

mkdir -p "$(dirname "$REPORT")"
: >"$REPORT"

log() { echo "$1" | tee -a "$REPORT"; }
pass() { log "PASS  $1"; }
fail() { log "FAIL  $1 — $2"; }
skip() { log "NOT_TESTED  $1 — $2"; }

# --- Auth ---
if LOGIN=$(curl -sf --max-time 10 -X POST "$AUTH/api/User" -H 'Content-Type: application/json' \
  -d '{"login":"jimmy.solid","password":"secret"}'); then
  TOKEN=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1]).get("token",""))' "$LOGIN")
  if [[ -n "$TOKEN" ]]; then pass "Auth: dang nhap agent (API AuthService)"; else fail "Auth: dang nhap agent" "token rong"; fi
else
  fail "Auth: dang nhap agent" "POST /api/User loi"
  TOKEN=""
fi

if [[ -n "${TOKEN:-}" ]]; then
  CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -H "Authorization: Bearer $TOKEN" "$GW/api/Products")
  if [[ "$CODE" == "200" ]]; then pass "Auth: JWT hop le qua gateway"; else fail "Auth: JWT qua gateway" "HTTP $CODE"; fi
fi

# --- Product catalogue ---
if [[ -n "${TOKEN:-}" ]]; then
  if curl -sf --max-time 15 -H "Authorization: Bearer $TOKEN" "$GW/api/Products" -o /tmp/bth9-retest-products.json; then
    if python3 -c 'import json; d=json.load(open("/tmp/bth9-retest-products.json")); assert set(x["code"] for x in d) >= {"TRI","HSI"}' 2>/dev/null; then
      pass "Product catalogue: GET /api/Products (TRI, HSI,...)"
    else
      fail "Product catalogue" "danh sach thieu ma san pham"
    fi
  else fail "Product catalogue" "gateway products"
  fi
fi

# --- Pricing / quote ---
if [[ -n "${TOKEN:-}" ]]; then
  OFFER=$(curl -sf --max-time 20 -X POST "$GW/api/Offers" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d '{"productCode":"TRI","policyFrom":"2026-12-01T00:00:00","policyTo":"2026-12-15T00:00:00","selectedCovers":["C2","C3"],"answers":[{"questionCode":"DESTINATION","questionType":"Choice","answer":"EUR"},{"questionCode":"NUM_OF_ADULTS","questionType":"Numeric","answer":1},{"questionCode":"NUM_OF_CHILDREN","questionType":"Numeric","answer":1}]}' || true)
  if [[ -n "$OFFER" ]] && python3 -c 'import json,sys; o=json.loads(sys.argv[1]); assert float(o["totalPrice"])>0' "$OFFER" 2>/dev/null; then
    pass "Pricing/quote: POST /api/Offers (PricingService qua PolicyService)"
    ONUM=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["offerNumber"])' "$OFFER")
  else
    fail "Pricing/quote" "POST /api/Offers: $OFFER"
    ONUM=""
  fi
fi

# --- Create policy ---
if [[ -n "${ONUM:-}" ]]; then
  POLICY=$(curl -sf --max-time 20 -X POST "$GW/api/Policies" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
    -d "{\"offerNumber\":\"$ONUM\",\"policyHolder\":{\"firstName\":\"Demo\",\"lastName\":\"Retest\",\"taxId\":\"001099000222\"},\"policyHolderAddress\":{\"country\":\"VN\",\"zipCode\":\"70000\",\"city\":\"HCM\",\"street\":\"2 Le Loi\"}}" || true)
  if [[ -n "$POLICY" ]] && python3 -c 'import json,sys; print(json.loads(sys.argv[1])["policyNumber"])' "$POLICY" >/dev/null 2>&1; then
    PNUM=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["policyNumber"])' "$POLICY")
    pass "Create policy: POST /api/Policies so $PNUM"
  else
    fail "Create policy" "$POLICY"
    PNUM=""
  fi
fi

# --- Policy search + async index ---
if [[ -n "${PNUM:-}" ]]; then
  sleep 3
  SEARCH=$(curl -sf --max-time 15 -H "Authorization: Bearer $TOKEN" --get "$GW/api/PolicySearch" --data-urlencode "q=Retest" || true)
  if [[ -n "$SEARCH" ]] && python3 -c 'import json,sys; d=json.loads(sys.argv[1]); assert any(p["policyNumber"]==sys.argv[2] for p in d.get("policies",[]))' "$SEARCH" "$PNUM" 2>/dev/null; then
    pass "Policy search + indexing: PolicySearch (Elasticsearch) tim thay $PNUM"
  else
    fail "Policy search + indexing" "q=Retest: $SEARCH"
  fi
  GETP=$(curl -sf --max-time 10 -H "Authorization: Bearer $TOKEN" "$GW/api/Policies/$PNUM" || true)
  if [[ -n "$GETP" ]]; then pass "Policy details: GET /api/Policies/{number}"; else fail "Policy details" "GET policy"; fi
fi

# --- Payment (local, no real money) ---
if [[ -n "${PNUM:-}" ]]; then
  PBAL=""
  for _ in 1 2 3 4 5 6; do
    CODE=$(curl -s -o /tmp/bth9-pay.json -w '%{http_code}' --max-time 10 "http://localhost:5070/api/Payment/accounts/$PNUM" || echo 000)
  if [[ "$CODE" == "200" ]]; then PBAL=ok; break; fi
    sleep 3
  done
  if [[ -n "$PBAL" ]]; then
    BAL=$(python3 -c 'import json; print(json.load(open("/tmp/bth9-pay.json"))["balance"]["balance"])' 2>/dev/null || echo "?")
    pass "Payment: GET $PAY/api/Payment/accounts/{policyNumber} HTTP 200 — balance=$BAL (lab; 0.0 hop le neu premium chua effective, khong tien that)"
  else
    MSG=$(head -c 120 /tmp/bth9-pay.json 2>/dev/null)
    fail "Payment: so du tai khoan" "HTTP $CODE — $MSG (chi du lieu lab, khong tien that)"
  fi
else
  skip "Payment" "khong co policyNumber tu buoc truoc"
fi

# --- Dashboard ---
if [[ -n "${TOKEN:-}" ]]; then
  DCODE=$(curl -s -o /tmp/bth9-dash.json -w '%{http_code}' --max-time 15 -X POST "$GW/api/Dashboard/total-sales" \
    -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{}' || echo 000)
  if [[ "$DCODE" == "200" ]]; then pass "Dashboard: POST /api/Dashboard/total-sales qua gateway"; else fail "Dashboard API qua gateway" "HTTP $DCODE"; fi
fi

# --- DocumentService ---
if curl -sf --max-time 2 http://localhost:5090/ >/dev/null 2>&1; then skip "DocumentService" "co port nhung chua xac minh"; else skip "DocumentService" "khong trong docker-compose / khong expose"; fi

# --- Blazor reachability ---
BCODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$BLAZOR/" || echo ERR)
if [[ "$BCODE" == "200" ]]; then pass "Blazor UI: HTTP $BLAZOR"; else fail "Blazor UI" "HTTP $BCODE"; fi

# --- Chat negotiate (khong lo credential trong report) ---
if [[ -n "${TOKEN:-}" ]]; then
  NCODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 -X POST \
    -H "Authorization: Bearer $TOKEN" "$CHAT/agentsChat/negotiate?negotiateVersion=1" || echo 000)
  if [[ "$NCODE" == "200" ]]; then pass "Chat: SignalR negotiate (co JWT)"; else fail "Chat negotiate" "HTTP $NCODE"; fi
fi

log "--- ket thuc ma tran API ---"
