import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './header.html'
})
export class Header {

  authService = inject(AuthService);
  router = inject(Router);
  searchQuery = '';

  login() {
    this.authService.loginWithGoogle()
      .then(() => {
        this.router.navigate(['/home']);
      });
  }

  logout() {
    this.authService.logout().then(() => {
      this.router.navigate(['/']);
    });
  }

  onSearch() {
    if (this.searchQuery.trim()) {
      console.log('Buscar:', this.searchQuery);
      // Implementar navegación a resultados si es necesario
    }
  }
}