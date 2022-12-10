#!/bin/bash
python core/manage.py migrate
python core/manage.py collectstatic --no-input --clear
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'meloadik@gmail.com', '123123123')" | python core/manage.py shell

export DJANGO_SETTINGS_MODULE=core.settings
celery -A core worker -l info --detach
celery -A core beat -l info --detach --scheduler django_celery_beat.schedulers:DatabaseScheduler
exec gunicorn -c config/gunicorn/conf.py --bind :8000 --chdir core core.wsgi:application

exec "$@"