import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SidebarComponent } from '../../components/sidebar/sidebar';
import { CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, SidebarComponent],
  templateUrl: './home.html',
  schemas: [CUSTOM_ELEMENTS_SCHEMA]
})
export class HomeComponent implements OnInit, OnDestroy {

  images: string[] = [
    'assets/flores.jpeg',
    'assets/DemonSlayer.jpg',
    'assets/JujutsuKaisen.jpg',
    'assets/Naruto.jpg',
    'assets/gato.jpg'
  ];

  currentIndex: number = 0;
  interval: any;

  ngOnInit(): void {
    this.interval = setInterval(() => {
      this.nextSlide();
    }, 5000);
  }

  nextSlide() {
    this.currentIndex = (this.currentIndex + 1) % this.images.length;
  }

  ngOnDestroy(): void {
    clearInterval(this.interval);
  }
}