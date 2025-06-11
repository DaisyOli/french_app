// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
import "controllers"

// Otimizações anti-FOUC
document.addEventListener('DOMContentLoaded', function() {
  // Garantir que body seja visível após carregamento
  document.body.classList.add('page-loaded');
  
  // Remover loading spinner se existir
  const loading = document.querySelector('.page-loading');
  if (loading) {
    setTimeout(() => loading.remove(), 100);
  }
});

// Turbo optimizations para evitar FOUC
document.addEventListener('turbo:before-visit', function(event) {
  // Manter estilos durante navegação
  document.body.style.visibility = 'visible';
});

document.addEventListener('turbo:visit', function(event) {
  // Mostrar loading durante navegação
  document.body.classList.remove('page-loaded');
});

document.addEventListener('turbo:load', function(event) {
  // Garantir visibilidade após carregamento Turbo
  document.body.classList.add('page-loaded');
  document.body.style.visibility = 'visible';
});

// Preload de recursos críticos
document.addEventListener('turbo:before-cache', function() {
  // Manter elementos críticos em cache
  const criticalElements = document.querySelectorAll('.navbar, .modern-navbar');
  criticalElements.forEach(el => el.style.visibility = 'visible');
});
