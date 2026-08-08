TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/backups/pg

cd $BACKUP_DIR

BACKUP_FILE=$TIMESTAMP.sql
BACKUP_ARCHIVE_FILE=$BACKUP_FILE.tar.zst

docker exec -t pg pg_dumpall -U postgres > $BACKUP_FILE

tar --zstd -cf $BACKUP_ARCHIVE_FILE $BACKUP_FILE

rm $BACKUP_FILE

find . -type f -mtime +14 -delete

echo "Backup completed: $BACKUP_ARCHIVE_FILE"