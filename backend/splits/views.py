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

class GroupExpenseDetail(APIView):
    def get(self, request, group_id, expense_id):
        expense = get_object_or_404(GroupExpense, id=expense_id, group_id=group_id)
        serializer = GroupExpenseSerializer(expense)
        return Response(serializer.data)

    def put(self, request, group_id, expense_id):
        expense = get_object_or_404(GroupExpense, id=expense_id, group_id=group_id)
        serializer = GroupExpenseSerializer(expense, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, group_id, expense_id):
        expense = get_object_or_404(GroupExpense, id=expense_id, group_id=group_id)
        expense.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

class GroupSettlementView(APIView):
    def get(self, request, group_id):
        group = get_object_or_404(Group, id=group_id)
        return calculate_settlements(group)

def calculate_settlements(group):
    expenses = GroupExpense.objects.filter(group=group)
    
    # Calculate total paid by each member
    paid = {}
    for member in group.members.all():
        paid[member.id] = 0.0
        
    for expense in expenses:
        paid[expense.paid_by.id] += expense.amount
        
    # Calculate total spent
    total_spent = sum(expenses.values_list('amount', flat=True))
    
    # Calculate share per person
    num_members = group.members.count()
    share = total_spent / num_members if num_members > 0 else 0
    
    # Calculate net balance (positive = paid too much, negative = paid too little)
    balances = {}
    for member in group.members.all():
        balances[member.id] = paid[member.id] - share
        
    # Settle up
    credits = []  # People who paid too much (creditors)
    debts = []    # People who paid too little (debtors)
    
    for member in group.members.all():
        balance = balances[member.id]
        if balance > 0:
            credits.append({'member_id': member.id, 'name': member.name, 'amount': balance})
        elif balance < 0:
            debts.append({'member_id': member.id, 'name': member.name, 'amount': -balance})
            
    # Match credits and debts
    settlements = []
    credit_idx = 0
    debt_idx = 0
    
    while credit_idx < len(credits) and debt_idx < len(debts):
        credit = credits[credit_idx]
        debt = debts[debt_idx]
        
        amount = min(credit['amount'], debt['amount'])
        
        settlements.append({
            'from_member_id': debt['member_id'],
            'from_member_name': debt['name'],
            'to_member_id': credit['member_id'],
            'to_member_name': credit['name'],
            'amount': amount
        })
        
        credit['amount'] -= amount
        debt['amount'] -= amount
        
        if credit['amount'] == 0:
            credit_idx += 1
            
        if debt['amount'] == 0:
            debt_idx += 1
            
    return Response({
        'total_spent': total_spent,
        'share_per_person': share,
        'balances': balances,
        'settlements': settlements
    })