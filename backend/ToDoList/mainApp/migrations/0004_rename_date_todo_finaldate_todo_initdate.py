# Generated by Django 5.0.4 on 2024-08-25 14:54

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('mainApp', '0003_rename_id_todouser_grouptodouser_id_grouptodouser_and_more'),
    ]

    operations = [
        migrations.RenameField(
            model_name='todo',
            old_name='Date',
            new_name='FinalDate',
        ),
        migrations.AddField(
            model_name='todo',
            name='InitDate',
            field=models.DateField(null=True),
        ),
    ]
