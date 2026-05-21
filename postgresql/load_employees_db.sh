#!/usr/bin/env bash
#シェルで動かしてねという命令＞コメントアウトされているから意味ない

#エラーが起きたらすぐに止まるようにする安全装置
set -euo pipefail

#今自分がどこにいるのか
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#データがどこにあるのかを自動で計算している
DUMP_DIR="$(dirname "$SCRIPT_DIR")"
#psqlコマンドを使えるように準備している
PSQL="${PSQL:-psql}"

echo "Creating database schema..."
#テーブルの枠組を作っていますemployees.sqlという設計図を読み込んで空のテーブルを作成している段階です
"$PSQL" -f "$SCRIPT_DIR/employees.sql"

echo "LOADING departments"
#データの加工とインポートをしている（バッククオートを全て削除している）
sed 's/`//g' "$DUMP_DIR/load_departments.dump" | "$PSQL" -d employees -q


echo "LOADING employees"
sed 's/`//g' "$DUMP_DIR/load_employees.dump" | "$PSQL" -d employees -q
echo "LOADING dept_emp"
sed 's/`//g' "$DUMP_DIR/load_dept_emp.dump" | "$PSQL" -d employees -q
echo "LOADING dept_manager"
sed 's/`//g' "$DUMP_DIR/load_dept_manager.dump" | "$PSQL" -d employees -q


echo "LOADING titles"
sed 's/`//g' "$DUMP_DIR/load_titles.dump" | "$PSQL" -d employees -q

#salariesはデータが大量にあるからファイルを三つに分割されている。
echo "LOADING salaries"
sed 's/`//g' "$DUMP_DIR/load_salaries1.dump" | "$PSQL" -d employees -q
sed 's/`//g' "$DUMP_DIR/load_salaries2.dump" | "$PSQL" -d employees -q
sed 's/`//g' "$DUMP_DIR/load_salaries3.dump" | "$PSQL" -d employees -q

echo "Done loading employees database."
