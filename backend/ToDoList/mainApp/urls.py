from django.urls import path
from .views import *
from . import views



urlpatterns = [
    #list to do paths
    path('<int:pk>/',DetailTodo.as_view()),
    path('',ListToDo.as_view()),
    path('create',CreateTodo.as_view()),
    path('delete/<int:pk>', DeleteTodo.as_view()),
    path('byId/<int:pk>',RetrieveTodoById.as_view()),
    path('get_todos_by_user',get_todos_by_user),
    path('get_todos_by_group',get_todos_by_group),
    path('marcar_como_concluido',marcar_como_concluido),
    path('desmarcar_como_concluido',desmarcar_como_concluido),
    #user paths
    path('users/', ListUser.as_view(), name='list_users'),
    path('users/create',CreateUser.as_view(), name='create_users'),
    path('users/<int:pk>/',UpdateUser.as_view(), name='update_user'),
    path('users/delete/<int:pk>/',DeleteUser.as_view(), name='delete_user'),
    path('login/', views.user_login, name='user_login'),
    path('users/byId/<int:pk>',UserById.as_view()),
    #group paths
    path('group/', ListGroupTodo.as_view(), name='list_group'),
    path('group/create',CreateGroupTodo.as_view(), name='create_group'),
    path('group/<int:pk>/',DetailGroupTodo.as_view(),name='update_group'),
    path('group/delete/<int:pk>/',DeleteGroupTodo.as_view(),name='delete_group'),
    path('group/byId/<int:pk>',GroupTodoById.as_view()),
    path('group/get_groups_by_user_owner',get_groups_by_user_owner),
    #user group paths
    path('userGroup/', ListGroupTodoUser.as_view(), name='list_userGroup'),
    path('userGroup/create',CreateGroupTodoUser.as_view(), name='create_userGroup'),
    path('userGroup/<int:pk>/',DetailGroupTodoUser.as_view(),name='update_userGroup'),
    path('userGroup/delete/<int:pk>/',DeleteGroupTodoUser.as_view(),name='delete_userGroup'),
    path('userGroup/byId/<int:pk>',GroupTodoUserById.as_view()),
    path('userGroup/GetGroupTodoUser',get_group_todo_user),
    path('csrf-token/', csrf_token, name='csrf_token'),
    path('users/listar_grupos_usuario',listar_grupos_usuario),
    path('users/listar_grupos_usuario_por_grupo',listar_grupos_usuario_por_grupo),
]