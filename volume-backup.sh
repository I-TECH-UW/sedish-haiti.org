export VOLUME_NAME=isanteplus_isanteplus-mysql-1-data

docker run --rm \
      -v "$VOLUME_NAME":/backup-volume \
      -v "$(pwd)/isante-backup":/backup \
      busybox \
      tar -zcf /backup/my-backup-mysql.tar.gz /backup-volume