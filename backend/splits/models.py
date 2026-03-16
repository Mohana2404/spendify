from django.db import models
class split(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)   
    share = models.DecimalField(max_digits=5, decimal_places=2)

    def __str__(self):
        return self.name


