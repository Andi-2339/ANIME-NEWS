import { Injectable } from '@angular/core';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable({
  providedIn: 'root'
})
export class SupabaseService {
  private supabase: SupabaseClient;

  constructor() {
    // NUEVA URL DEL PROYECTO LIMPIO
    const supabaseUrl = 'https://mtwhobrdwjlffflxnrud.supabase.co';
    // NUEVA CLAVE ANON PUBLIC
    const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im10d2hvYnJkd2psZmZmbHhucnVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NjYzMzIsImV4cCI6MjA5MTI0MjMzMn0.IZy-nH12l9pbiDcu94jdPhwhTNks8-9ts01wd2-A5g4';
    
    console.log('[Supabase] Conectado al nuevo proyecto:', supabaseUrl);
    this.supabase = createClient(supabaseUrl, supabaseKey);
  }

  get client() {
    return this.supabase;
  }

  // --- MÉTODOS DE USUARIOS ---
  
  async getUserProfile(uid: string) {
    const { data, error } = await this.supabase
      .from('perfiles')
      .select('*')
      .eq('id', uid)
      .single();
    
    if (error && error.code !== 'PGRST116') {
      console.error('[Supabase] Error al obtener perfil:', error);
    }
    return data;
  }

  async syncUser(userData: any) {
    const { data, error } = await this.supabase
      .from('perfiles')
      .upsert(userData)
      .select()
      .single();

    if (error) {
      console.error('[Supabase] Error en sync:', error);
      throw error;
    }
    return data;
  }

  async updateProfile(uid: string, profileData: any) {
    const { data, error } = await this.supabase
      .from('perfiles')
      .update(profileData)
      .eq('id', uid)
      .select()
      .single();

    if (error) {
      console.error('[Supabase] Error en update:', error);
      throw error;
    }
    return data;
  }

  async getAllUsers() {
    const { data, error } = await this.supabase
      .from('perfiles')
      .select('*')
    if (error) throw error;
    return data;
  }

  // --- CRUD MODERACIÓN (POSTS & REPORTES) ---

  async getPosts(isAdmin: boolean = false) {
    let query = this.supabase.from('posts').select('*').order('created_at', { ascending: false });
    
    // Si no es admin, solo traemos los posts que NO están ocultos
    if (!isAdmin) {
      query = query.eq('is_hidden', false);
    }
    
    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  async deletePost(postId: string) {
    const { error } = await this.supabase.from('posts').delete().eq('id', postId);
    if (error) throw error;
  }

  async togglePostVisibility(postId: string, currentHiddenStatus: boolean) {
    const { error } = await this.supabase
      .from('posts')
      .update({ is_hidden: !currentHiddenStatus })
      .eq('id', postId);
    if (error) throw error;
  }

  async createReport(postId: string, reporterId: string, motivo: string) {
    const { error } = await this.supabase
      .from('reports')
      .insert({
        post_id: postId,
        reporter_id: reporterId,
        motivo: motivo
      });
    if (error) throw error;
  }

  async getReports() {
    const { data, error } = await this.supabase
      .from('reports')
      .select('*, posts(titulo)')
      .order('created_at', { ascending: false });
    if (error) throw error;
    return data;
  }
}
