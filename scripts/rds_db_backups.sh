s3cmd get  --force s3://emami-ci-packages-2/deploy_keys/databag_secret ~/.chef
db_details=$(knife data bag show databases ecom-platform --secret-file ~/.chef/databag_secret -F json)
PASSWORD=$(echo $db_details| jq ".production"".password" | sed 's/"//g')
USER=$(echo $db_details | jq ".production"".username" | sed 's/"//g')
HOST=$(echo $db_details |jq ".production"".host" | sed 's/"//g')
DB_NAME=$(echo $db_details |jq ".production"".database" | sed 's/"//g')

export PGPASSWORD=$PASSWORD
BACKUP_NAME=$1_$2_production-$(date +"%Y%m%d%H%M")
echo "starting pg dump"
pg_dump -h $HOST --port=5432 --username=$USER --dbname=$DB_NAME > $BACKUP_NAME.sql

echo "pg dump complete..; preparing to compress dump"
tar -zcf $BACKUP_NAME.sql.tar $BACKUP_NAME.sql

echo "compression complete..; preparing to upload to s3"
echo "--------------------- S3 CP START ---------------------------------"
s3cmd put $BACKUP_NAME.sql.tar s3://emami-rds-backups-2/$DB_NAME/$2/
echo "--------------------- S3 CP STOP  ---------------------------------"

echo "remove generated dump file..;"
rm -f $BACKUP_NAME*

echo "remove old backup"
echo "--------------------- S3 RM START ---------------------------------"
s3cmd ls s3://emami-rds-backups-2/$DB_NAME/$2/ | sort | head $3 | awk '{print $4}' |xargs -I {} s3cmd rm s3://emami-rds-backups-2/$DB_NAME/$2/{}
