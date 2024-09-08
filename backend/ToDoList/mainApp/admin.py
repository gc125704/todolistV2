from django.contrib import admin
from .models import *
from django.contrib.auth.admin import UserAdmin

# Register your models here.
admin.site.register(ToDo)
admin.site.register(GroupTodo)
admin.site.register(GroupTodoUser)
