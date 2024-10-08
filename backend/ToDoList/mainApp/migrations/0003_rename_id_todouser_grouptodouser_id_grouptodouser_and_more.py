# Generated by Django 5.0.4 on 2024-08-15 02:16

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('mainApp', '0002_alter_grouptodo_id_grouptodo_and_more'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.RenameField(
            model_name='grouptodouser',
            old_name='id_TodoUser',
            new_name='id_GroupTodoUser',
        ),
        migrations.AddField(
            model_name='grouptodouser',
            name='User',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
    ]
