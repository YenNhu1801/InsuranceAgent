#!/usr/bin/env bash
# Smoke BTH9: login, products, offer, policy, search. Không thanh toán tiền thật.
set -euo pipefail
AUTH="${AUTH:-http://localhost:6060}"
GW="${GW:-http://localhost:8099}"

LOGIN=$(curl -sf -X POST "$AUTH/api/User" -H 'Content-Type: application/json' \
  -d '{"login":"jimmy.solid","password":"secret"}')
TOKEN=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["token"])' "$LOGIN")
echo "LOGIN_OK user=jimmy.solid"

curl -sf -H "Authorization: Bearer $TOKEN" "$GW/api/Products" -o /tmp/bth9-products.json
python3 -c 'import json; d=json.load(open("/tmp/bth9-products.json")); print("PRODUCTS_OK", [p["code"] for p in d])'

OFFER=$(curl -sf -X POST "$GW/api/Offers" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d '{"productCode":"TRI","policyFrom":"2026-12-01T00:00:00","policyTo":"2026-12-15T00:00:00","selectedCovers":["C2","C3"],"answers":[{"questionCode":"DESTINATION","questionType":"Choice","answer":"EUR"},{"questionCode":"NUM_OF_ADULTS","questionType":"Numeric","answer":1},{"questionCode":"NUM_OF_CHILDREN","questionType":"Numeric","answer":1}]}')
echo "OFFER_OK $OFFER"
ONUM=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["offerNumber"])' "$OFFER")

POLICY=$(curl -sf -X POST "$GW/api/Policies" -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  -d "{\"offerNumber\":\"$ONUM\",\"policyHolder\":{\"firstName\":\"An\",\"lastName\":\"Nguyen\",\"taxId\":\"001099000111\"},\"policyHolderAddress\":{\"country\":\"VN\",\"zipCode\":\"70000\",\"city\":\"HCM\",\"street\":\"1 Le Loi\"}}")
echo "POLICY_OK $POLICY"
PNUM=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["policyNumber"])' "$POLICY")

sleep 2
SEARCH=$(curl -sf -H "Authorization: Bearer $TOKEN" --get "$GW/api/PolicySearch" --data-urlencode "q=Nguyen")
echo "SEARCH_OK $SEARCH"
python3 -c 'import json,sys; d=json.loads(sys.argv[1]); nums=[p["policyNumber"] for p in d["policies"]]; assert sys.argv[2] in nums, nums' "$SEARCH" "$PNUM"
echo "SMOKE_OK policy=$PNUM"
