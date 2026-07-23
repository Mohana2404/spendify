from rest_framework import serializers
from .models import Group, GroupMember, GroupExpense

class GroupMemberSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroupMember
        fields = ['id', 'name', 'group']
        read_only_fields = ['group']

class GroupExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = GroupExpense
        fields = ['id', 'group', 'name', 'description', 'amount', 'category', 'created_at', 'paid_by']
        read_only_fields = ['group', 'created_at']

class GroupSerializer(serializers.ModelSerializer):
    members = GroupMemberSerializer(many=True, read_only=True)
    expenses = GroupExpenseSerializer(many=True, read_only=True)

    class Meta:
        model = Group
        fields = ['id', 'name', 'created_at', 'members', 'expenses']
