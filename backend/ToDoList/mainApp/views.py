import json
from django.http import JsonResponse
from rest_framework import generics, status
from rest_framework.response import Response
from .serializers import *
from .models import ToDo
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login
from django.shortcuts import get_list_or_404, get_object_or_404
from django.middleware.csrf import get_token
from django.views.decorators.csrf import csrf_exempt

# CRUD para ToDo (já existente)
class ListToDo(generics.ListAPIView):  # GET
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer

class DetailTodo(generics.RetrieveUpdateAPIView):  # UPDATE/PUT
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer

class CreateTodo(generics.CreateAPIView):  # CREATE/POST
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer

class DeleteTodo(generics.DestroyAPIView):  # DELETE
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer

class RetrieveTodoById(generics.RetrieveAPIView):
    queryset = ToDo.objects.all()
    serializer_class = TodoSerializer

    def get_object(self):
        queryset = self.get_queryset()
        obj = get_object_or_404(queryset, pk=self.kwargs.get('pk'))
        return obj
    
def get_todos_by_user(request):
    user_id = request.GET.get('user_id')
    toDos = ToDo.objects.filter(User=user_id)
    serializer = TodoSerializer(toDos,many=True)
    return JsonResponse({'items': serializer.data}, safe=False)

def get_todos_by_group(request):
    group_id = request.GET.get('group_id')
    toDos = ToDo.objects.filter(idGroupTodo=group_id)
    serializer = TodoSerializer(toDos,many=True)
    return JsonResponse({'items': serializer.data}, safe=False)

def marcar_como_concluido(request):
    todo_id = request.GET.get('id')
    try:
        # Obtém o item ToDo pelo ID
        todo = ToDo.objects.get(pk=todo_id)
        
        # Atualiza o campo Completed para True
        todo.Completed = True
        todo.save()

        return JsonResponse({'status': 'success', 'message': 'Tarefa marcada como concluída.'}, status=200)

    except ToDo.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Tarefa não encontrada.'}, status=404)
    
def desmarcar_como_concluido(request):
    todo_id = request.GET.get('id')
    try:
        # Obtém o item ToDo pelo ID
        todo = ToDo.objects.get(pk=todo_id)
        
        # Atualiza o campo Completed para False
        todo.Completed = False
        todo.save()

        return JsonResponse({'status': 'success', 'message': 'Tarefa marcada como não concluída.'}, status=200)

    except ToDo.DoesNotExist:
        return JsonResponse({'status': 'error', 'message': 'Tarefa não encontrada.'}, status=404)   
    

# CRUD para User

class ListUser(generics.ListAPIView):  # GET
    queryset = User.objects.all()
    serializer_class = UserSerializer

class CreateUser(generics.CreateAPIView):  # CREATE/POST
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def post(self, request, *args, **kwargs):
        data = request.data
        username = data.get('username')
        password = data.get('password')
        email = data.get('email')

        if not username or not password or not email:
            return Response({'error': 'Username, password, and email are required.'}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(username=username, password=password, email=email)
        serializer = self.get_serializer(user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class UpdateUser(generics.RetrieveUpdateAPIView):  # UPDATE/PUT
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def put(self, request, *args, **kwargs):
        user = self.get_object()
        data = request.data

        # Atualizar os campos que não são a senha
        user.username = data.get('username', user.username)
        user.email = data.get('email', user.email)

        # Atualizar a senha se fornecida
        password = data.get('password')
        if password:
            user.set_password(password)

        user.save()
        serializer = self.get_serializer(user)
        return Response(serializer.data, status=status.HTTP_200_OK)

class DeleteUser(generics.DestroyAPIView):  # DELETE
    queryset = User.objects.all()
    serializer_class = UserSerializer

class UserById(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_object(self):
        queryset = self.get_queryset()
        obj = get_object_or_404(queryset, pk=self.kwargs.get('pk'))
        return obj

@csrf_exempt
def user_login(request):
    try:
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')

        print("Request Method:", request.method)
        print("Request Body:", request.body)
        print("Username:", username)
        print("Password:", password)

        if not username or not password:
            return JsonResponse({'error': 'Username and password are required.'}, status=400)

        user = authenticate(username=username, password=password)
        
        if user is not None:
            login(request, user)
            return JsonResponse( {'id': user.id, 'username': user.username, 'email': user.email}, status=200)
        else:
            return JsonResponse({'error': 'Invalid username or password.'}, status=401)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON.'}, status=400)
    
# CRUD para GroupToDo
class ListGroupTodo(generics.ListAPIView):  # GET
    queryset = GroupTodo.objects.all()
    serializer_class = GroupTodoSerializer

class DetailGroupTodo(generics.RetrieveUpdateAPIView):  # UPDATE/PUT
    queryset = GroupTodo.objects.all()
    serializer_class = GroupTodoSerializer

class CreateGroupTodo(generics.CreateAPIView):  # CREATE/POST
    queryset = GroupTodo.objects.all()
    serializer_class = GroupTodoSerializer

class DeleteGroupTodo(generics.DestroyAPIView):  # DELETE
    queryset = GroupTodo.objects.all()
    serializer_class = GroupTodoSerializer

class GroupTodoById(generics.RetrieveAPIView):
    queryset = GroupTodo.objects.all()
    serializer_class = GroupTodoSerializer

    def get_object(self):
        queryset = self.get_queryset()
        obj = get_object_or_404(queryset, pk=self.kwargs.get('pk'))
        return obj
    
def get_groups_by_user_owner(request):
    userId = request.GET.get('userId')
    groups = GroupTodo.objects.filter(UserOwner=userId)
    serializer = GroupTodoSerializer(groups,many=True)
    return JsonResponse({'grupos': serializer.data}, safe=False)


# CRUD para GroupToDoUser
class ListGroupTodoUser(generics.ListAPIView):  # GET
    queryset = GroupTodoUser.objects.all()
    serializer_class = GroupTodoUserSerializer

class DetailGroupTodoUser(generics.RetrieveUpdateAPIView):  # UPDATE/PUT
    queryset = GroupTodoUser.objects.all()
    serializer_class = GroupTodoUserSerializer

class CreateGroupTodoUser(generics.CreateAPIView):  # CREATE/POST
    queryset = GroupTodoUser.objects.all()
    serializer_class = GroupTodoUserSerializer

class DeleteGroupTodoUser(generics.DestroyAPIView):  # DELETE
    queryset = GroupTodoUser.objects.all()
    serializer_class = GroupTodoUserSerializer

class GroupTodoUserById(generics.RetrieveAPIView):
    queryset = GroupTodoUser.objects.all()
    serializer_class = GroupTodoUserSerializer

    def get_object(self):
        queryset = self.get_queryset()
        obj = get_object_or_404(queryset, pk=self.kwargs.get('pk'))
        return obj
    
def get_group_todo_user(request):
    user_id = request.GET.get('userId')
    group_id = request.GET.get('groupId')

    if not user_id or not group_id:
        return JsonResponse({'error': 'userId and groupId are required'}, status=400)

    try:
        # Buscar o registro com base no userId e groupId
        group_todo_user = get_object_or_404(GroupTodoUser, User_id=user_id, idGroupTodo_id=group_id)

        # Retornar o registro em formato JSON
        data = {
            'id_GroupTodoUser': group_todo_user.id_GroupTodoUser,
            'idGroupTodo': group_todo_user.idGroupTodo.id_groupTodo,
            'User': group_todo_user.User.id
        }
        return JsonResponse(data, status=200)

    except GroupTodoUser.DoesNotExist:
        return JsonResponse({'error': 'No matching record found'}, status=404)
    
def csrf_token(request):
    token = get_token(request)
    return JsonResponse({'csrfToken': token})


def listar_grupos_usuario(request):
    user_id = request.GET.get('user_id','')
    try:
        # Obtém o usuário
        usuario = User.objects.get(pk=user_id)

        # Obtém todos os GroupTodo relacionados ao usuário
        grupos = GroupTodo.objects.filter(grouptodouser__User=usuario)

        # Prepara a lista de grupos para retorno
        grupos_lista = [{'id': grupo.id_groupTodo, 'Description': grupo.Description} for grupo in grupos]

        # Retorna a lista de grupos em formato JSON
        return JsonResponse({'grupos': grupos_lista}, status=200)

    except User.DoesNotExist:
        return None
    
def listar_grupos_usuario_por_grupo(request):
    group_id = request.GET.get('group_id','')
    try:
        # Obtém o usuário
        grupo = GroupTodo.objects.get(pk=group_id)

        # Obtém todos os GroupTodo relacionados ao usuário
        usuarios = User.objects.filter(grouptodouser__idGroupTodo=grupo)

        # Prepara a lista de grupos para retorno
        usuarios_lista = [{'id': usuario.id, 'username': usuario.username, 'email': usuario.username} for usuario in usuarios]

        # Retorna a lista de grupos em formato JSON
        return JsonResponse({'usuarios': usuarios_lista}, status=200)

    except User.DoesNotExist:
        return None