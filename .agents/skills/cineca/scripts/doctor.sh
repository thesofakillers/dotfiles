#!/usr/bin/env bash

set -u

live=false
case "${1:-}" in
  "") ;;
  --live) live=true ;;
  *)
    printf 'Usage: %s [--live]\n' "$0" >&2
    exit 2
    ;;
esac

failures=0
warnings=0

pass() { printf '[ok] %s\n' "$1"; }
warn() {
  printf '[warn] %s\n' "$1"
  warnings=$((warnings + 1))
}
fail() {
  printf '[fail] %s\n' "$1"
  failures=$((failures + 1))
}

for required_command in step jq ssh ssh-keygen; do
  if command -v "$required_command" >/dev/null 2>&1; then
    pass "$required_command is available"
  else
    fail "$required_command is missing"
  fi
done

if command -v step >/dev/null 2>&1; then
  if step ca health >/dev/null 2>&1; then
    pass 'CINECA certificate authority is healthy'
  else
    fail 'CINECA certificate authority is not bootstrapped or unhealthy'
  fi
fi

cineca_email_file="${CINECA_EMAIL_FILE:-$HOME/.step/cineca-email}"
if [[ -r "$cineca_email_file" ]]; then
  pass 'CINECA identity file is readable'
  if [[ "$(stat -f '%Lp' "$cineca_email_file" 2>/dev/null || true)" == 600 ]]; then
    pass 'CINECA identity file mode is 600'
  else
    fail 'CINECA identity file mode is not 600'
  fi
else
  fail 'CINECA identity file is missing'
fi

if command -v ssh >/dev/null 2>&1; then
  ssh_config=$(ssh -G cineca 2>/dev/null || true)
  alias_user=$(awk '$1 == "user" { print $2; exit }' <<<"$ssh_config")
  alias_host=$(awk '$1 == "hostname" { print $2; exit }' <<<"$ssh_config")
  if [[ "$alias_user" == gstarace && "$alias_host" == login.leonardo.cineca.it ]]; then
    pass 'cineca SSH alias resolves to gstarace@login.leonardo.cineca.it'
  else
    fail 'cineca SSH alias is missing or resolves incorrectly'
  fi
fi

known_hosts_file="$HOME/.ssh/known_hosts"
if [[ -r "$known_hosts_file" ]]; then
  leonardo_key_count=$(awk '$1 == "login*.leonardo.cineca.it" { count++ } END { print count + 0 }' "$known_hosts_file")
  if ((leonardo_key_count > 0)); then
    pass "Leonardo wildcard host keys are present ($leonardo_key_count entries)"
  else
    fail 'Leonardo wildcard host keys are missing'
  fi
else
  fail 'SSH known_hosts file is missing'
fi

agent_socket="${SSH_AUTH_SOCK:-}"
if [[ -z "$agent_socket" || ! -S "$agent_socket" ]]; then
  if command -v launchctl >/dev/null 2>&1; then
    agent_socket=$(
      launchctl print "gui/$(id -u)/com.openssh.ssh-agent" 2>/dev/null |
        awk '$1 == "SSH_AUTH_SOCK" && $2 == "=>" { print $3; exit }'
    )
  fi
fi

if [[ -n "$agent_socket" && -S "$agent_socket" ]]; then
  export SSH_AUTH_SOCK="$agent_socket"
  pass 'persistent SSH agent is available'
else
  fail 'persistent SSH agent is unavailable'
fi

if [[ -r "$cineca_email_file" ]] && command -v step >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 && [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
  cineca_email=$(tr -d '\r\n' <"$cineca_email_file")
  if certificate_json=$(step ssh list --raw "$cineca_email" 2>/dev/null | step ssh inspect --format json 2>/dev/null); then
    principal=$(jq -r '(.Principals // []) | join(",")' <<<"$certificate_json")
    valid_before=$(jq -r '.ValidBefore // "unknown"' <<<"$certificate_json")
    if [[ "$principal" == gstarace ]]; then
      pass "CINECA certificate for gstarace is loaded (valid before $valid_before)"
    else
      fail 'loaded CINECA certificate has an unexpected principal'
    fi
  else
    warn 'no CINECA certificate is currently loaded; the launcher will request one'
  fi
fi

if command -v nc >/dev/null 2>&1; then
  if nc -z -G 5 login.leonardo.cineca.it 22 >/dev/null 2>&1; then
    pass 'Leonardo SSH port is reachable'
  else
    fail 'Leonardo SSH port is not reachable'
  fi
else
  warn 'nc is unavailable; skipped the Leonardo network check'
fi

if [[ "$live" == true ]]; then
  if ssh -o BatchMode=yes -o ConnectTimeout=15 cineca \
    'test "$(id -un)" = gstarace && saldo -b | awk '\''$1 == "IscrB_INSIGHT" { found = 1 } END { exit !found }'\'' ' \
    >/dev/null 2>&1; then
    pass 'live Leonardo login and IscrB_INSIGHT allocation check succeeded'
  else
    fail 'live Leonardo login or IscrB_INSIGHT allocation check failed'
  fi
fi

printf 'Summary: %d failure(s), %d warning(s)\n' "$failures" "$warnings"
((failures == 0))
