from django.shortcuts import render

# Create your views here.
def home(request):
    return render(request, 'main/index.html')

def about(request):
    return render(request, 'main/about.html')

def services(request):
    return render(request, 'main/services.html')

def testimonial(request):
    return render(request, 'main/testimonial.html')

def contact(request):
    return render(request, 'main/contact.html')
