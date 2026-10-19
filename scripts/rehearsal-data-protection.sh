#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
: "${REHEARSAL_PROJECT:?}" "${REHEARSAL_PRIVATE:?}" "${REHEARSAL_SPEC:?}" "${REHEARSAL_PROFILE:?}" "${SERVER_SOURCE:?}"
project="$REHEARSAL_PROJECT"
private_dir="$REHEARSAL_PRIVATE"
profile="$REHEARSAL_PROFILE"
rc() { docker compose --env-file "$private_dir/compose.env" -p "$project" -f "$REHEARSAL_SPEC/docker/rehearsal.compose.yml" "$@"; }
operator_env="$(mktemp "$SERVER_SOURCE/.env.rehearsal.XXXXXX")"
trap 'rm -f "$operator_env"' EXIT
backup_root="$private_dir/backups"
mkdir -p "$backup_root" "$private_dir/bin"
openssl rand -hex 32 > "$private_dir/key"
container_id="$(rc ps -q "$profile")"
cat > "$operator_env" <<ENV
DB_TYPE=$profile
DB_NAME=cashlenx
MONGO_CONTAINER_NAME=$container_id
MYSQL_CONTAINER_NAME=$container_id
BACKUP_ROOT=$backup_root
BACKUP_ENCRYPTION_KEY_FILE=$private_dir/key
BACKUP_DAILY_RETENTION=1
BACKUP_WEEKLY_RETENTION=1
BACKUP_MONTHLY_RETENTION=1
ENV
# Invoke the repository backup implementation through Compose exec, with a
# fail-closed adapter that cannot execute against any other container.
real_docker="$(command -v docker)"
export REHEARSAL_DOCKER="$real_docker" REHEARSAL_CONTAINER="$container_id"
cat > "$private_dir/bin/docker" <<'ADAPTER'
#!/usr/bin/env bash
set -euo pipefail
case "$1" in
  inspect) [[ "$2" == "$REHEARSAL_CONTAINER" ]] || exit 1; exec "$REHEARSAL_DOCKER" "$@" ;;
  exec)
    shift
    [[ "$1" == "$REHEARSAL_CONTAINER" ]] || exit 1
    shift
    exec "$REHEARSAL_DOCKER" compose --env-file "$REHEARSAL_PRIVATE/compose.env" -p "$REHEARSAL_PROJECT" -f "$REHEARSAL_SPEC/docker/rehearsal.compose.yml" exec -T "$REHEARSAL_PROFILE" "$@"
    ;;
  *) echo 'Backup adapter refused unsupported container operation.' >&2; exit 1 ;;
esac
ADAPTER
chmod +x "$private_dir/bin/docker"
for tier in daily weekly monthly; do
  mkdir -p "$backup_root/$tier"
  touch "$backup_root/$tier/cashlenx-$profile-20000101T000000Z.tar.gz.enc" "$backup_root/$tier/cashlenx-$profile-20000101T000000Z.tar.gz.enc.sha256"
  PATH="$private_dir/bin:$PATH" ENV_FILE="$operator_env" bash "$SERVER_SOURCE/scripts/data-protection/backup.sh" "$tier"
  [[ "$(find "$backup_root/$tier" -name '*.enc' | wc -l | tr -d ' ')" == 1 ]]
  [[ ! -f "$backup_root/$tier/cashlenx-$profile-20000101T000000Z.tar.gz.enc.sha256" ]]
done
backup="$(find "$backup_root/daily" -name '*.enc' -print -quit)"
validate_archive() {
  local input="$1" output="$2"
  (cd "$(dirname "$input")"; sha256sum -c "$(basename "$input").sha256") || return 1
  mkdir -p "$output"
  openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -md sha256 -pass stdin -in "$input" -out "$output/payload.tar.gz" < "$private_dir/key" || return 1
  # Accept only the exact format-one entries, excluding links and unsafe paths.
  python3 - "$output/payload.tar.gz" "$output" "$profile" <<'PY'
import sys,tarfile,pathlib
archive,target,profile=sys.argv[1:]
dump='database.archive.gz' if profile=='mongodb' else 'database.sql'
with tarfile.open(archive) as tar:
    members=tar.getmembers()
    assert {m.name for m in members}=={'metadata.env','manifest.sha256',dump}
    assert len(members)==3 and all(m.isfile() for m in members)
    for m in members:
        pathlib.Path(target,m.name).write_bytes(tar.extractfile(m).read())
PY
  (cd "$output"; sha256sum -c manifest.sha256) || return 1
  grep -qx FORMAT_VERSION=1 "$output/metadata.env"
  grep -qx "DATABASE_TYPE=$profile" "$output/metadata.env"
  grep -qx DATABASE_NAME=cashlenx "$output/metadata.env"
}
validate_archive "$backup" "$private_dir/restore"
cp "$backup" "$private_dir/corrupt.enc"
printf 'corruption' >> "$private_dir/corrupt.enc"
printf '%s  corrupt.enc\n' "$(sha256sum "$backup" | awk '{print $1}')" > "$private_dir/corrupt.enc.sha256"
if validate_archive "$private_dir/corrupt.enc" "$private_dir/corrupt-result"; then echo 'Corrupt artifact accepted.' >&2; exit 1; fi
# Wrong key must fail before restore as well.
openssl rand -hex 32 > "$private_dir/wrong-key"
if openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -md sha256 -pass stdin -in "$backup" -out "$private_dir/wrong.tar.gz" < "$private_dir/wrong-key" 2>/dev/null; then exit 1; fi
mv "$private_dir/key" "$private_dir/key.saved"
if PATH="$private_dir/bin:$PATH" ENV_FILE="$operator_env" bash "$SERVER_SOURCE/scripts/data-protection/backup.sh" daily; then exit 1; fi
mv "$private_dir/key.saved" "$private_dir/key"
restore="restore-$profile"
rc --profile restore up -d "$restore"
mongo() { rc exec -T "$1" sh -ec 'test "$(cat /proc/1/comm)" = mongod; exec mongosh --quiet --username root --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --eval "$1" cashlenx' sh "$2"; }
mysql() { rc exec -T "$1" sh -ec 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql --host=127.0.0.1 -uroot --batch --skip-column-names cashlenx -e "$1"' sh "$2"; }
ready=false
for ((i=0;i<120;i++)); do
  if [[ "$profile" == mongodb ]]; then
    if mongo "$restore" 'quit(db.runCommand({ping:1}).ok ? 0 : 1)'; then ready=true; break; fi
  else
    if mysql "$restore" 'SELECT 1'; then ready=true; break; fi
  fi
  sleep 2
done
[[ "$ready" == true ]]
if [[ "$profile" == mongodb ]]; then
  rc exec -T "$restore" sh -ec 'exec mongorestore --host 127.0.0.1 --username root --password "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --archive --gzip --drop' < "$private_dir/restore/database.archive.gz"
  query='printjson(db.getCollectionNames().sort().map(n=>({name:n,count:db.getCollection(n).countDocuments({})}))); printjson(db.schema_migrations.find({}, {_id:1,name:1,checksum:1,dirty:1}).sort({_id:1}).toArray())'
  mongo "$profile" "$query" > "$private_dir/source-counts"
  mongo "$restore" "$query" > "$private_dir/restored-counts"
else
  rc exec -T "$restore" sh -ec 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysql -uroot cashlenx' < "$private_dir/restore/database.sql"
  query='SELECT version,dirty FROM schema_migrations ORDER BY version; SELECT COUNT(*) FROM users; SELECT COUNT(*) FROM cash_flows; SELECT COUNT(*) FROM categories;'
  mysql "$profile" "$query" > "$private_dir/source-counts"
  mysql "$restore" "$query" > "$private_dir/restored-counts"
fi
cmp "$private_dir/source-counts" "$private_dir/restored-counts"
[[ -s "$private_dir/source-counts" ]]
echo 'Encrypted backup, checksum/corruption/wrong-key rejection, three-tier retention, failure reporting and isolated restore passed.'
