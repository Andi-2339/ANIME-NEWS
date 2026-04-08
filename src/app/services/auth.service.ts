import { Injectable, signal, inject, computed } from '@angular/core';
import { SupabaseService } from './supabase.service';
import { User } from '@supabase/supabase-js';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private supabase = inject(SupabaseService).client;
  private sbService = inject(SupabaseService);

  // Señales de estado
  user = signal<User | null>(null);
  userProfile = signal<any>(null); // Datos de la tabla 'perfiles'
  userRole = signal<'admin' | 'cliente' | null>(null);
  isProfileComplete = signal<boolean>(false);
  loading = signal<boolean>(true);

  // Computados para UI
  isAdmin = computed(() => this.userRole() === 'admin');
  isLoggedIn = computed(() => !!this.user());
  userName = computed(() => this.userProfile()?.nombre || this.user()?.user_metadata?.['full_name'] || this.user()?.email?.split('@')[0] || 'Usuario');

  constructor() {
    this.initAuth();
  }

  private async initAuth() {
    // 1. Obtener sesión inicial
    const { data: { session } } = await this.supabase.auth.getSession();
    this.handleAuthStateChange(session?.user ?? null);

    // 2. Escuchar cambios futuros
    this.supabase.auth.onAuthStateChange((_event, session) => {
      this.handleAuthStateChange(session?.user ?? null);
    });
  }

  private async handleAuthStateChange(user: User | null) {
    this.user.set(user);
    
    if (user) {
      try {
        const profile = await this.sbService.getUserProfile(user.id);
        if (profile) {
          this.userProfile.set(profile);
          this.userRole.set(profile.rol || 'cliente');
          this.isProfileComplete.set(!!profile.profile_complete);
        } else {
          // Si no tiene perfil, lo marcamos como incompleto
          this.isProfileComplete.set(false);
          this.userRole.set('cliente');
        }
      } catch (error) {
        console.error('[Auth] Error al sincronizar perfil:', error);
      }
    } else {
      this.userProfile.set(null);
      this.userRole.set(null);
      this.isProfileComplete.set(false);
    }
    this.loading.set(false);
  }

  // =========================
  // LOGIN / SIGNUP METHODS
  // =========================
  
  async signUpWithEmail(email: string, pass: string, profileData: any) {
    // 1. Crear usuario en Auth de Supabase
    const { data, error } = await this.supabase.auth.signUp({
      email,
      password: pass,
      options: {
        data: {
          full_name: profileData.nombres + ' ' + (profileData.apellidos || '')
        }
      }
    });

    if (error) throw error;
    if (!data.user) throw new Error('Error al crear usuario');

    // 2. Crear inmediatamente el perfil en la tabla 'perfiles'
    const newProfile = {
      id: data.user.id,
      email: email,
      nombre: profileData.nombres,
      apellidos: profileData.apellidos,
      edad: parseInt(profileData.edad),
      telefono: profileData.phoneNumber,
      avatar_name: profileData.avatarName,
      profile_complete: true, // Lo marcamos como completo de una vez
      rol: 'cliente'
    };

    const savedProfile = await this.sbService.syncUser(newProfile);
    this.userProfile.set(savedProfile);
    this.isProfileComplete.set(true);
    
    // Desloguear automáticamente después del registro para forzar el Log In manual
    await this.supabase.auth.signOut();
    this.user.set(null);
    this.userProfile.set(null);
    this.isProfileComplete.set(false);
    
    return data;
  }

  async loginWithEmail(email: string, pass: string) {
    const { data, error } = await this.supabase.auth.signInWithPassword({
      email,
      password: pass
    });

    if (error) throw error;
    return data;
  }

  async loginWithGoogle() {
    const { error } = await this.supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: window.location.origin + '/signup'
      }
    });
    if (error) throw error;
  }

  async logout() {
    await this.supabase.auth.signOut();
  }

  // =========================
  // UPDATES
  // =========================
  async updateProfileData(uid: string, profileData: any) {
    const formattedData = {
      nombre: profileData.nombres,
      apellidos: profileData.apellidos,
      edad: parseInt(profileData.edad),
      telefono: profileData.phoneNumber,
      avatar_name: profileData.avatarName,
      profile_complete: true,
      email: this.user()?.email
    };
    
    const data = await this.sbService.updateProfile(uid, formattedData);
    this.userProfile.set(data);
    this.isProfileComplete.set(true);
    return data;
  }
}