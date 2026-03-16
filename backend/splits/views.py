from rest_framework.views import APIView
from rest_framework.response import Response
from .models import split

class SplitList(APIView):
    def get(self, request):
        splits = split.objects.all()
        data = [{"name": s.name, "description": s.description, "amount": s.amount, "share": s.share} for s in splits]
        return Response(data)
    def post(self, request):
        name = request.data.get("name")
        description = request.data.get("description")
        amount = request.data.get("amount")
        share = request.data.get("share")
        new_split = split.objects.create(name=name, description=description, amount=amount, share=share)
        new_split.save()    
        return Response({"message": "Split created", "id": new_split.id})
    def delete(self, request, split_id):
        try:
            s = split.objects.get(id=split_id)
            s.delete()
            return Response({"message": "Split deleted"})
        except split.DoesNotExist:
            return Response({"error": "Split not found"}, status=404)
    def put(self, request, split_id):
        try:
            s = split.objects.get(id=split_id)
            s.name = request.data.get("name", s.name)
            s.description = request.data.get("description", s.description)
            s.amount = request.data.get("amount", s.amount)
            s.share = request.data.get("share", s.share)
            s.save()
            return Response({"message": "Split updated"})
        except split.DoesNotExist:
            return Response({"error": "Split not found"}, status=404)
