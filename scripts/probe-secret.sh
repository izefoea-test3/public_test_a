#!/usr/bin/env bash
set -euo pipefail

label="${1:-probe}"

check_var() {
  local name="$1"

  if [[ -n "${!name:-}" ]]; then
    echo "[present] ${label}: ${name}"
  else
    echo "[absent ] ${label}: ${name}"
  fi
}

echo "---- ${label} ----"

# 普通secret可能通过不同路径进入当前step/action/script。
check_var "DEMO_SECRET"           # step-level env直接传入脚本
check_var "ACTION_SECRET_INPUT"   # action input转成action内部env
check_var "ACTION_SECRET_ENV"     # caller给action step传入的env
check_var "FROM_GITHUB_ENV"       # 前序step写入GITHUB_ENV后，后续step可见
check_var "JOB_LEVEL_SECRET"      # job级env，所有step可见

# token相关。
check_var "TOKEN_FROM_CONTEXT"    # 显式由 ${{ github.token }} 注入
check_var "GITHUB_TOKEN"          # 默认通常不是普通shell env，除非你显式env传入

echo
