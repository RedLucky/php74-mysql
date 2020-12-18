how to run this container
===========================================================
docker-compose up -d

-- CEK DB Connection --
docker exec -it php74-oracle bash
cd ./src/test
php artisan tinker
DB::select(DB::raw("select 'A' from dual"))  
exit


-- to configure serverless --
open docker-compose.yml