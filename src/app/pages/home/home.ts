import { Component, OnInit, OnDestroy, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SidebarComponent } from '../../components/sidebar/sidebar';
import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { SeasonalThemeService } from '../../services/seasonal-theme.service';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, SidebarComponent],
  templateUrl: './home.html',
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class HomeComponent implements OnInit, OnDestroy {

  themeService = inject(SeasonalThemeService);

  images: string[] = [
    'assets/flores.jpeg',
    'assets/DemonSlayer.jpg',
    'assets/JujutsuKaisen.jpg',
    'assets/Naruto.jpg',
    'assets/gato.jpg'
  ];

  currentIndex: number = 0;
  interval: any;

  // Highlight hover effect (Práctica 9-10)
  highlightedCard = signal<number | null>(null);

  ngOnInit(): void {
    this.interval = setInterval(() => {
      this.nextSlide();
    }, 5000);
  }

  nextSlide() {
    this.currentIndex = (this.currentIndex + 1) % this.images.length;
  }

  // Evento: Destacar contenido mediante el puntero
  onCardHover(index: number) {
    this.highlightedCard.set(index);
  }

  onCardLeave() {
    this.highlightedCard.set(null);
  }

  ngOnDestroy(): void {
    clearInterval(this.interval);
  }
}