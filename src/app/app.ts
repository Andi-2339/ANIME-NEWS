import { Component, ElementRef } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  searchQuery = '';
  showPrivacyModal = false;

  constructor(private elementRef: ElementRef) {}

  onSearch() {
    if (this.searchQuery.trim()) {
      alert(`Buscando: ${this.searchQuery}`);
      this.searchQuery = '';
    }
  }

  scrollTo(sectionId: string, event: Event) {
    event.preventDefault();
    const element = this.elementRef.nativeElement.querySelector(`#${sectionId}`);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  openSocial(platform: string, event: Event) {
    event.preventDefault();
    const urls: Record<string, string> = {
      facebook: 'https://facebook.com/animenews',
      twitter: 'https://twitter.com/animenews',
      instagram: 'https://instagram.com/animenews',
      youtube: 'https://youtube.com/animenews'
    };
    window.open(urls[platform], '_blank');
  }

  togglePrivacy(event: Event) {
    event.preventDefault();
    this.showPrivacyModal = !this.showPrivacyModal;
  }
}