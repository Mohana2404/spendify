from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import Group, GroupMember, GroupExpense
from .serializers import GroupSerializer, GroupMemberSerializer, GroupExpenseSerializer

class GroupListCreate(APIView):
    def get(self, request):
        groups = Group.objects.all()
        serializer = GroupSerializer(groups, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = GroupSerializer(data=request.data)
        if serializer.is_valid():
            group = serializer.save()
            members_data = request.data.get('members', [])
            for member_name in members_data:
                GroupMember.objects.create(group=group, name=member_name)
            
            group.refresh_from_db()
            return Response(GroupSerializer(group).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class GroupDetail(APIView):
    def get(self, request, group_id):
        group = get_object_or_404(Group, id=group_id)
        serializer = GroupSerializer(group)
        return Response(serializer.data)

class GroupExpenseListCreate(APIView):
    def get(self, request, group_id):
        group = get_object_or_404(Group, id=group_id)
        expenses = GroupExpense.objects.filter(group=group)
        serializer = GroupExpenseSerializer(expenses, many=True)
        return Response(serializer.data)

    def post(self, request, group_id):
        group = get_object_or_404(Group, id=group_id)
        serializer = GroupExpenseSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(group=group)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
