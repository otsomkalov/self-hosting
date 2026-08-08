TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=~/backups/mongo

cd $BACKUP_DIR

BACKUP_FILE=$TIMESTAMP.gz

docker exec mongo-prd sh -c '
mongodump -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --archive --gzip
' > $BACKUP_FILE

find . -type f -mtime +14 -delete

echo "Backup completed: $BACKUP_FILE"