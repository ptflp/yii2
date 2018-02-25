# yii2

ENVIRONMENTS
FRONTEND = test.com
BACKEND = admin.test.com
docker run /path/to/project/:/var/www/web/ -e FRONTEND=test.com -e BACKEND=admin.test.com -p 80:80 --name=yii2t ptflp/yii2