# Generated by Django 5.0.4 on 2024-09-07 04:09

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('mainApp', '0005_grouptodo_userowner'),
    ]

    operations = [
        migrations.RenameField(
            model_name='grouptodouser',
            old_name='User',
            new_name='Userid',
        ),
    ]
