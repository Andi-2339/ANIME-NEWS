import { Component } from '@angular/core';
import { SidebarComponent } from '../../components/sidebar/sidebar';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [SidebarComponent],
  templateUrl: './home.html',
  styleUrl: './home.css'
})
export class HomeComponent {}