import { Component, inject, computed } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet, Router } from '@angular/router';
import { Header } from './components/header/header';
import { Footer } from './components/footer/footer';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, RouterOutlet, Header, Footer],
  templateUrl: './app.html',
})
export class App {
  authService = inject(AuthService);
  private router = inject(Router);

  // Lógica para mostrar la UI solo si el usuario ha iniciado sesión
  showUI = computed(() => {
    return this.authService.isLoggedIn();
  });
}
