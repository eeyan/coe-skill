#!/usr/bin/env bash
#
# Structure validation for the COE skill.
# Checks file existence, frontmatter, cross-references, and section consistency.
#
# Usage: bash tests/validate-skill.sh
#

set -uo pipefail

SKILL_DIR=".claude/skills/coe"
PASS=0
FAIL=0

check() {
  local description="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "[PASS] $description"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $description"
    FAIL=$((FAIL + 1))
  fi
}

# Helper: check if a string matches a grep pattern
check_grep() {
  local description="$1"
  local input="$2"
  local pattern="$3"
  if echo "$input" | grep -q "$pattern"; then
    echo "[PASS] $description"
    PASS=$((PASS + 1))
  else
    echo "[FAIL] $description"
    FAIL=$((FAIL + 1))
  fi
}

# Navigate to repo root (works from any directory)
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0"/..)"

# ─── Check 1: Required files exist and are non-empty ───

REQUIRED_FILES="SKILL.md template.md examples.md anti-patterns.md"
for f in $REQUIRED_FILES; do
  check "Required file exists: $f" test -s "$SKILL_DIR/$f"
done

# ─── Check 2: YAML frontmatter in SKILL.md ───

# Extract frontmatter (between first and second ---)
FRONTMATTER=$(awk '/^---$/{n++; next} n==1{print} n>=2{exit}' "$SKILL_DIR/SKILL.md")

check "SKILL.md has frontmatter delimiters" test -n "$FRONTMATTER"
check_grep "Frontmatter has 'name' field" "$FRONTMATTER" '^name:'
check_grep "Frontmatter has 'description' field" "$FRONTMATTER" '^description:'
check_grep "Frontmatter has 'allowed-tools' field" "$FRONTMATTER" '^allowed-tools:'
check_grep "Frontmatter has 'argument-hint' field" "$FRONTMATTER" '^argument-hint:'
check_grep "Frontmatter 'name' is 'coe'" "$FRONTMATTER" '^name: coe'

# ─── Check 3: Cross-references from SKILL.md resolve ───

REFERENCED_FILES=$(grep -oE '\]\([a-zA-Z0-9_-]+\.md\)' "$SKILL_DIR/SKILL.md" | sed 's/\](//;s/)//' | sort -u)
for ref in $REFERENCED_FILES; do
  check "Cross-reference resolves: $ref" test -f "$SKILL_DIR/$ref"
done

# ─── Check 4: Template has expected sections ───

EXPECTED_SECTIONS=(
  "Summary"
  "Customer Impact"
  "Timeline"
  "Metrics"
  "Incident Questions"
  "Five Whys"
  "Action Items"
  "Recurrence"
  "Narrative"
  "Related Items"
)

for section in "${EXPECTED_SECTIONS[@]}"; do
  check "Template has section: ## $section" grep -q "^## $section" "$SKILL_DIR/template.md"
done

# ─── Check 5: Example follows template structure ───

# Every ## heading in template.md should appear in examples.md
TEMPLATE_HEADINGS=$(grep '^## ' "$SKILL_DIR/template.md" | sed 's/^## //')
while IFS= read -r heading; do
  check "Example has template section: ## $heading" grep -q "^## $heading" "$SKILL_DIR/examples.md"
done <<< "$TEMPLATE_HEADINGS"

# ─── Check 6: Anti-patterns structure ───

ANTIPATTERN_COUNT=$(grep -c '^## [0-9]' "$SKILL_DIR/anti-patterns.md" || true)
check "Anti-patterns has at least 3 entries" test "$ANTIPATTERN_COUNT" -ge 3

# Each anti-pattern section should have Bad, Good, and Rule markers
ANTIPATTERN_SECTIONS=$(grep '^## [0-9]' "$SKILL_DIR/anti-patterns.md" | sed 's/^## //')
while IFS= read -r section; do
  num=$(echo "$section" | grep -oE '^[0-9]+')
  # Check between this section and the next (or EOF)
  check "Anti-pattern $num has **Bad:** marker" \
    awk "/^## $num\\./{found=1} found && /\\*\\*Bad:\\*\\*/{ok=1; exit} /^## [0-9]/ && found && !/^## $num\\./{exit} END{exit !ok}" "$SKILL_DIR/anti-patterns.md"
  check "Anti-pattern $num has **Good:** marker" \
    awk "/^## $num\\./{found=1} found && /\\*\\*Good:\\*\\*/{ok=1; exit} /^## [0-9]/ && found && !/^## $num\\./{exit} END{exit !ok}" "$SKILL_DIR/anti-patterns.md"
  check "Anti-pattern $num has **Rule:** marker" \
    awk "/^## $num\\./{found=1} found && /\\*\\*Rule:\\*\\*/{ok=1; exit} /^## [0-9]/ && found && !/^## $num\\./{exit} END{exit !ok}" "$SKILL_DIR/anti-patterns.md"
done <<< "$ANTIPATTERN_SECTIONS"

# ─── Check 7: Action item types in example match SKILL.md's canonical list ───

# Canonical types from SKILL.md
VALID_TYPES="CLAUDE.md update|New skill|New memory|Hook configuration|Settings change|Code change|Process change|Test addition"

# Extract Type column (4th column) from the action items table in examples.md
# Skip header and separator rows
EXAMPLE_TYPES=$(awk '/^\| AI-/{split($0, cols, "|"); gsub(/^[ \t]+|[ \t]+$/, "", cols[4]); print cols[4]}' "$SKILL_DIR/examples.md")
if [ -n "$EXAMPLE_TYPES" ]; then
  ALL_TYPES_VALID=true
  while IFS= read -r t; do
    if ! echo "$t" | grep -qE "^($VALID_TYPES)$"; then
      ALL_TYPES_VALID=false
      echo "  Invalid type found: '$t'"
    fi
  done <<< "$EXAMPLE_TYPES"
  check "Example action item types match canonical list" $ALL_TYPES_VALID
else
  check "Example has action items to validate" false
fi

# ─── Check 8: Quality audit checklist in SKILL.md ───

AUDIT_ROWS=$(grep -c '^\| \*\*' "$SKILL_DIR/SKILL.md" || true)
check "Quality audit has at least 10 checks" test "$AUDIT_ROWS" -ge 10

AUDIT_CHECKS=("Five Whys depth" "Blamelessness" "Action items complete" "Agentic improvements")
for ac in "${AUDIT_CHECKS[@]}"; do
  check "Audit checklist includes: $ac" grep -q "$ac" "$SKILL_DIR/SKILL.md"
done

# ─── Results ───

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit $( [ "$FAIL" -eq 0 ] && echo 0 || echo 1 )
