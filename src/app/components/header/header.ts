import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [RouterModule, FormsModule],
  templateUrl: './header.html'
})
export class Header {
  searchQuery = '';

  onSearch() {
    if (this.searchQuery.trim()) {
      alert(`Buscando: ${this.searchQuery}`);
      this.searchQuery = '';
    }
  }
}
