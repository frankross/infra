aws s3 cp s3://emami-ci-packages/deploy_keys/databag_secret ~/.chef
db_details=$(knife data bag show databases ecom-platform --secret-file ~/.chef/databag_secret -F json)
PASSWORD=$(echo $db_details| jq ".production"".password" | sed 's/"//g')
USER=$(echo $db_details | jq ".production"".username" | sed 's/"//g')
HOST=$(echo $db_details |jq ".production"".host" | sed 's/"//g')
DB_NAME=$(echo $db_details |jq ".production"".database" | sed 's/"//g')

echo $PASSWORD $USER $HOST $DB_NAME
export PGPASSWORD=$PASSWORD
BACKUP_NAME=$1_$2_production-$(date +"%Y%m%d%H%M")
pg_dump -h $HOST --port=5432 --username=$USER --dbname=$DB_NAME > $BACKUP_NAME.sql
tar -zcf $BACKUP_NAME.sql.tar $BACKUP_NAME.sql
aws s3 cp $BACKUP_NAME.sql.tar s3://emami-rds-backups/$DB_NAME/$2/
rm -f $BACKUP_NAME*
aws s3 ls s3://emami-rds-backups/$DB_NAME/$2/ | sort | head $3 | awk '{print $4}' |xargs -I {} aws s3 rm {}
