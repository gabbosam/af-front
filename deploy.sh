AWS_PROFILE=AF aws s3 sync ./build/web/ s3://af-static/web/$1 --exclude .DS_Store --exclude .env-dev --exclude .env-prod
AWS_PROFILE=AF aws s3 cp web/.env-$1 s3://af-static/web/$1/.env