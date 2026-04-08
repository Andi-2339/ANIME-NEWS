import { Component, signal, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SidebarComponent } from '../../components/sidebar/sidebar';
import { SupabaseService } from '../../services/supabase.service';

interface UserItem {
  id: string; // UUID de Supabase/Firebase
  email: string;
  nombre: string;
  rol: 'admin' | 'cliente';
  profile_complete: boolean;
}

@Component({
  selector: 'app-user-management',
  standalone: true,
  imports: [CommonModule, FormsModule, SidebarComponent],
  template: `
    <div class="content-wrapper">
      <main class="main-content">
        <section class="basic-info">
          <h1>Gestión de Usuarios</h1>
          <p class="persuasive-text">Administra los accesos de la comunidad @uteq.edu.mx (vía Supabase)</p>

          <div *ngIf="loading" class="status-msg">Cargando lista de usuarios...</div>

          <!-- Lista de Usuarios -->
          <div class="neon-animated-box" style="padding: 0; overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse; color: white; text-align: left;">
              <thead>
                <tr style="border-bottom: 1px solid #333; background: rgba(255, 46, 209, 0.1);">
                  <th style="padding: 15px;">Nombre</th>
                  <th style="padding: 15px;">Correo</th>
                  <th style="padding: 15px;">Rol</th>
                  <th style="padding: 15px;">Estado</th>
                  <th style="padding: 15px; text-align: center;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr *ngFor="let user of users()" style="border-bottom: 1px solid #222;">
                  <td style="padding: 15px;">{{ user.nombre || 'Sin nombre' }}</td>
                  <td style="padding: 15px;">{{ user.email }}</td>
                  <td style="padding: 15px;">
                    <span [style.color]="user.rol === 'admin' ? 'var(--pink)' : 'var(--blue)'">{{ user.rol.toUpperCase() }}</span>
                  </td>
                  <td style="padding: 15px;">
                    <small [style.color]="user.profile_complete ? '#00ff88' : '#ff4444'">
                      {{ user.profile_complete ? 'COMPLETO' : 'PENDIENTE' }}
                    </small>
                  </td>
                  <td style="padding: 15px; text-align: center;">
                    <button (click)="toggleRole(user)" style="padding: 5px 15px; font-size: 0.8em; margin-right: 5px;">
                      CAMBIAR ROL
                    </button>
                    <!-- Borrar en Supabase (No borra la cuenta de Firebase) -->
                    <button (click)="deleteUser(user.id)" style="padding: 5px 15px; font-size: 0.8em; background: #ff3333; border: none;">Borrar</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </main>

      <aside class="sidebar-root">
        <app-sidebar></app-sidebar>
      </aside>
    </div>
  `,
  styles: [`
    table th { color: var(--blue); text-transform: uppercase; font-size: 0.9em; }
    .status-msg { margin: 20px 0; color: var(--blue); font-style: italic; }
  `]
})
export class UserManagementComponent implements OnInit {
  private supabase = inject(SupabaseService);
  
  users = signal<UserItem[]>([]);
  loading = true;

  ngOnInit() {
    this.refreshUsers();
  }

  async refreshUsers() {
    this.loading = true;
    try {
      const data: any = await this.supabase.getAllUsers();
      this.users.set(data);
    } catch (err) {
      console.error(err);
      alert('Error cargando usuarios');
    } finally {
      this.loading = false;
    }
  }

  async toggleRole(user: UserItem) {
    const newRole = user.rol === 'admin' ? 'cliente' : 'admin';
    try {
      await this.supabase.updateProfile(user.id, { rol: newRole });
      this.refreshUsers();
      alert('Rol actualizado con éxito');
    } catch (err) {
      alert('Error al cambiar rol');
    }
  }

  async deleteUser(id: string) {
    if (confirm('¿Estás seguro de que quieres borrar el registro de este usuario en la base de datos? (No borrará su cuenta de Gmail)')) {
      try {
        const { error } = await this.supabase.client
          .from('perfiles')
          .delete()
          .eq('id', id);
        
        if (error) throw error;
        this.refreshUsers();
      } catch (err) {
        alert('Error al borrar usuario');
      }
    }
  }
}
