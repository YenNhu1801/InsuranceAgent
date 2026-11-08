#!/usr/bin/env bash
# Lab 9 end-to-end check against a running local stack.
# Synthetic data only. Requires Pricing :5040, Policy :5050, PolicySearch :5065, Payment :5070.
set -u
pricing="${PRICING_URL:-http://localhost:5040}"
policy="${POLICY_URL:-http://localhost:5050}"
search="${SEARCH_URL:-http://localhost:5065}"
payment="${PAYMENT_URL:-http://localhost:5070}"

echo "== 1. Pricing TRI =="
curl -sS -H 'Content-Type: application/json' \
  -d '{"productCode":"TRI","policyFrom":"2026-12-01T00:00:00Z","policyTo":"2026-12-15T00:00:00Z","selectedCovers":["C1","C2"],"answers":[{"questionCode":"NUM_OF_ADULTS","questionType":"Number","answer":2},{"questionCode":"NUM_OF_CHILDREN","questionType":"Number","answer":1},{"questionCode":"DESTINATION","questionType":"Choice","answer":"EUR"}]}' \
  "$pricing/api/pricing"
echo

echo "== 2. Create offer =="
offer=$(curl -sS -H 'Content-Type: application/json' -H 'AgentLogin: agent.demo' \
  -d '{"productCode":"TRI","policyFrom":"2026-12-01T00:00:00","policyTo":"2026-12-15T00:00:00","selectedCovers":["C1","C2"],"answers":[{"questionCode":"NUM_OF_ADULTS","questionType":"Numeric","answer":2},{"questionCode":"NUM_OF_CHILDREN","questionType":"Numeric","answer":1},{"questionCode":"DESTINATION","questionType":"Choice","answer":"EUR"}]}' \
  "$policy/api/Offer")
echo "$offer"
offer_no=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["offerNumber"])' "$offer")

echo "== 3. Buy policy =="
created=$(curl -sS -H 'Content-Type: application/json' \
  -d "{\"offerNumber\":\"$offer_no\",\"policyHolder\":{\"firstName\":\"An\",\"lastName\":\"Nguyen\",\"taxId\":\"001234567890\"},\"policyHolderAddress\":{\"country\":\"VN\",\"zipCode\":\"70000\",\"city\":\"Ho Chi Minh\",\"street\":\"1 Demo Street\"}}" \
  "$policy/api/Policy")
echo "$created"
policy_no=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["policyNumber"])' "$created")

echo "== 4. Policy details =="
curl -sS "$policy/api/Policy/$policy_no"
echo

echo "== 5. Search (poll) =="
found=""
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
  sleep 1
  found=$(curl -sS --get --data-urlencode "q=$policy_no" "$search/api/PolicySearch")
  echo "try $i $found"
  echo "$found" | python3 -c 'import json,sys; d=json.load(sys.stdin); raise SystemExit(0 if d.get("policies") else 1)' && break
done

echo "== 6. Payment account (poll) =="
for i in 1 2 3 4 5 6 7 8 9 10; do
  code=$(curl -sS -o /tmp/lab9-account.json -w "%{http_code}" "$payment/api/Payment/accounts/$policy_no" || true)
  echo "try $i HTTP $code $(cat /tmp/lab9-account.json)"
  if [ "$code" = "200" ]; then
    break
  fi
  sleep 1
done

echo "POLICY_NUMBER=$policy_no"
