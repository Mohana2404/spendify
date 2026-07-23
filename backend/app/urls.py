from django.contrib import admin
from django.urls import include, path
from expenses.views import ExpensesList, ExpensesList
from splits.views import GroupListCreate, GroupDetail, GroupExpenseListCreate, GroupExpenseDetail

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/groups/", GroupListCreate.as_view(), name="group-list"),
    path("api/groups/<int:group_id>/", GroupDetail.as_view(), name="group-detail"),
    path("api/groups/<int:group_id>/expenses/", GroupExpenseListCreate.as_view(), name="group-expense-list"),
    path("api/groups/<int:group_id>/expenses/<int:expense_id>/", GroupExpenseDetail.as_view(), name="group-expense-detail"),
    path("api/expenses/", ExpensesList.as_view(), name="expense-list"),
    path("api/expenses/<int:expense_id>/", ExpensesList.as_view(), name="expense-detail"),
]
