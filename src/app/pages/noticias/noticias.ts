import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SidebarComponent } from '../../components/sidebar/sidebar';

@Component({
  selector: 'app-noticias',
  standalone: true,
  imports: [CommonModule, SidebarComponent],
  template: `
    <div class="content-wrapper">
      <main class="main-content">
        <section class="basic-info">
          <h1>Noticias de Anime y Manga</h1>
          <p class="persuasive-text">Las últimas novedades del mundo otaku, actualizadas al minuto.</p>
          
          <article class="news-item neon-animated-box">
            <div class="news-item-content">
              <div class="news-text">
                <h2>Temporada de Primavera 2026: Lo más esperado</h2>
                <p>Análisis detallado de los estrenos que dominarán la conversación este trimestre.</p>
              </div>
            </div>
          </article>

          <section id="calendario" style="margin-top: 50px;">
            <h2>📅 Calendario de Emisiones</h2>
            <p>No te pierdas ningún episodio. Aquí tienes el horario semanal de tus series favoritas.</p>
            <div class="neon-animated-box" style="padding: 20px;">
              <p>Lunes: Neon Nights</p>
              <p>Miércoles: Cyber Origins</p>
              <p>Viernes: Final Fantasy Echoes</p>
            </div>
          </section>
        </section>
      </main>
      
      <aside class="sidebar-root">
        <app-sidebar></app-sidebar>
      </aside>
    </div>
  `
})
export class Noticias {}
