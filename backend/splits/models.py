from django.db import models

class Group(models.Model):
    name = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class GroupMember(models.Model):
    group = models.ForeignKey(Group, related_name='members', on_delete=models.CASCADE)
    name = models.CharField(max_length=100)

    def __str__(self):
        return f"{self.name} ({self.group.name})"

class GroupExpense(models.Model):
    id = models.AutoField(primary_key=True)
    group = models.ForeignKey(Group, related_name='expenses', on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.CharField(max_length=50, default='General')
    created_at = models.DateTimeField(auto_now_add=True)
    paid_by = models.ForeignKey(GroupMember, related_name='paid_expenses', on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.name} - {self.amount}"
