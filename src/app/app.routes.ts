import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home';
import { Contact } from './pages/contact/contact';
import { Privacy } from './pages/privacy/privacy';
import { Noticias } from './pages/noticias/noticias';
import { Catalogo } from './pages/catalogo/catalogo';
import { Mangas } from './pages/mangas/mangas';
import { Temporadas } from './pages/temporadas/temporadas';

export const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'noticias', component: Noticias },
  { path: 'catalogo', component: Catalogo },
  { path: 'mangas', component: Mangas },
  { path: 'temporadas', component: Temporadas },
  { path: 'contact', component: Contact },
  { path: 'privacy', component: Privacy }
];