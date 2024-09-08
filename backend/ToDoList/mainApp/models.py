from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class ToDo(models.Model):
    Title = models.CharField(max_length=255, blank=False)
    Description = models.TextField(blank=False,null=True)
    InitDate = models.DateField(blank=False,null=True)
    FinalDate = models.DateField(blank=False,null=True)
    Completed = models.BooleanField(default=False)
    User = models.ForeignKey(User, on_delete=models.CASCADE, default=1)
    idGroupTodo = models.ForeignKey('GroupTodo', models.RESTRICT, db_column='id_groupTodo',null=True,blank=True)

    def __str__(self):
        return self.Title

class GroupTodo(models.Model):
    id_groupTodo = models.AutoField(primary_key=True)
    Description = models.CharField(max_length=255, blank=False)
    UserOwner = models.ForeignKey(User, on_delete=models.CASCADE, default=1)

    def __str__(self):
        return self.Description
    
class GroupTodoUser(models.Model):
    id_GroupTodoUser = models.AutoField(primary_key=True)
    idGroupTodo = models.ForeignKey('GroupTodo', models.RESTRICT, db_column='id_groupTodo',null=True)
    User = models.ForeignKey(User, on_delete=models.CASCADE, default=1)

    def __str__(self):
        return self.Description