from rest_framework import serializers
from .models import *

class TodoSerializer(serializers.ModelSerializer):
    class Meta:
        model = ToDo
        #fields = ('id', 'Title','Description','Date','Completed')
        fields = '__all__'

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'

class GroupTodoSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroupTodo
        fields = '__all__'

class GroupTodoUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroupTodoUser
        fields = '__all__'