from django.shortcuts import render
from .models import Expenses
from rest_framework.views import APIView
from rest_framework.response import Response

class ExpensesList(APIView):
    def get(self, request):
        expenses = Expenses.objects.all()
        data = [{"name": e.name, "description": e.description, "amount": e.amount, "category": e.category} for e in expenses]
        return Response(data)
    def post(self, request):
        name = request.data.get("name")
        description = request.data.get("description")
        amount = request.data.get("amount")
        category = request.data.get("category")
        new_expense = Expenses.objects.create(name=name, description=description, amount=amount, category=category)
        new_expense.save()
        return Response({"message": "Expense created", "id": new_expense.id})
    def delete(self, request, expense_id):
        try:
            e = Expenses.objects.get(id=expense_id)
            e.delete()
            return Response({"message": "Expense deleted"})
        except Expenses.DoesNotExist:
            return Response({"error": "Expense not found"}, status=404)
    def put(self, request, expense_id):
        try:
            e = Expenses.objects.get(id=expense_id)
            e.name = request.data.get("name", e.name)
            e.description = request.data.get("description", e.description)
            e.amount = request.data.get("amount", e.amount)
            e.category = request.data.get("category", e.category)
            e.save()
            return Response({"message": "Expense updated"})
        except Expenses.DoesNotExist:
            return Response({"error": "Expense not found"}, status=404)
# Create your views here.
