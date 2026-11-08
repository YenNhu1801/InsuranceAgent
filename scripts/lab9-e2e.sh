#!/usr/bin/env bash
# End-to-end check through Auth JWT and the Agent Portal gateway.
# Does not call Policy or Search directly.
set -u
auth="${AUTH_URL:-http://localhost:6060}"
gateway="${GATEWAY_URL:-http://localhost:8099}"

echo "== login =="
if [ -z "${LAB9_LOGIN:-}" ] || [ -z "${LAB9_PASSWORD:-}" ]; then
  echo "Set LAB9_LOGIN and LAB9_PASSWORD from src/AuthService/AuthService/DataAccess/InsuranceAgentsInMemoryDb.cs"
  exit 1
fi
login=$(curl -sS -H 'Content-Type: application/json' \
  -d "{\"login\":\"${LAB9_LOGIN}\",\"password\":\"${LAB9_PASSWORD}\"}" \
  "$auth/api/User")
echo "$login" | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d.get("token"), d; assert d.get("userType")=="SALESMAN"'
token=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["token"])' "$login")
echo "token_length=${#token} userType=SALESMAN"

echo "== products via gateway =="
products=$(curl -sS -H "Authorization: Bearer $token" "$gateway/api/products")
echo "$products" | python3 -c 'import json,sys; rows=json.load(sys.stdin); assert any(p.get("code")=="TRI" for p in rows), rows; print("product_count", len(rows))'

echo "== create offer via gateway =="
offer=$(curl -sS -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
  -d '{"productCode":"TRI","policyFrom":"2026-12-01","policyTo":"2026-12-15","selectedCovers":["C2","C3"],"answers":[{"questionCode":"NUM_OF_ADULTS","questionType":"Numeric","answer":2},{"questionCode":"NUM_OF_CHILDREN","questionType":"Numeric","answer":1},{"questionCode":"DESTINATION","questionType":"Choice","answer":"EUR"}]}' \
  "$gateway/api/offers")
echo "$offer"
offer_no=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["offerNumber"])' "$offer")

echo "== create policy via gateway =="
created=$(curl -sS -H "Authorization: Bearer $token" -H 'Content-Type: application/json' \
  -d "{\"offerNumber\":\"$offer_no\",\"policyHolder\":{\"firstName\":\"Ha\",\"lastName\":\"Le\",\"taxId\":\"00111222333\"},\"policyHolderAddress\":{\"country\":\"VN\",\"zipCode\":\"70000\",\"city\":\"Ho Chi Minh\",\"street\":\"15 Demo Street\"}}" \
  "$gateway/api/policies")
echo "$created"
policy_no=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["policyNumber"])' "$created")

echo "== policy details via gateway =="
curl -sS -H "Authorization: Bearer $token" "$gateway/api/policies/$policy_no"
echo

echo "== search via gateway =="
export POLICY_NO="$policy_no"
found=""
for i in 1 2 3 4 5 6 7 8 9 10 12; do
  sleep 1
  found=$(curl -sS -H "Authorization: Bearer $token" --get --data-urlencode "q=$policy_no" "$gateway/api/PolicySearch")
  echo "try $i $found"
  echo "$found" | python3 -c 'import json,sys,os; want=os.environ["POLICY_NO"]; d=json.load(sys.stdin); rows=d.get("policies") or []; raise SystemExit(0 if any(p.get("policyNumber")==want for p in rows) else 1)' && break
done

echo "POLICY_NUMBER=$policy_no"
echo "== unauthenticated gateway must fail =="
code=$(curl -sS -o /tmp/lab9-noauth.txt -w "%{http_code}" "$gateway/api/products" || true)
echo "no_token_http=$code"
python3 - <<PY
code="$code"
assert code in ("401","403"), code
print("gateway_blocked_anonymous")
PY
