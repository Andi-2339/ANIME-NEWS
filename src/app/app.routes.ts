import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home';
import { Contact } from './pages/contact/contact';
import { Privacy } from './pages/privacy/privacy';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'contact', component: Contact },
  { path: 'privacy', component: Privacy }
];