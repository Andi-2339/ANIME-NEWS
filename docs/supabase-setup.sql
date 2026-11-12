-- ============================================
-- ANIME-NEWS: Setup SQL para Prácticas 11-13
-- Ejecutar en Supabase Dashboard > SQL Editor
-- ============================================

-- 1. Agregar columnas nuevas a la tabla 'perfiles'
ALTER TABLE perfiles
ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS ultimo_acceso TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS intentos_fallidos INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS bloqueado_hasta TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS requiere_cambio_password BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 2. Crear tabla de bitácora de auditoría
CREATE TABLE IF NOT EXISTS bitacora (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES perfiles(id) ON DELETE SET NULL,
  usuario_email TEXT,
  accion TEXT NOT NULL,
  detalles TEXT,
  ip TEXT DEFAULT 'N/A',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 3. Habilitar RLS en bitacora
ALTER TABLE bitacora ENABLE ROW LEVEL SECURITY;

-- 4. Política: solo admins pueden leer la bitácora
CREATE POLICY "Admins pueden leer bitacora"
ON bitacora FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM perfiles
    WHERE perfiles.id = auth.uid()
    AND perfiles.rol = 'admin'
  )
);

-- 5. Política: cualquier usuario autenticado puede insertar en bitácora
CREATE POLICY "Usuarios pueden insertar bitacora"
ON bitacora FOR INSERT
TO authenticated
WITH CHECK (true);

-- 6. Actualizar perfiles existentes con los nuevos campos
UPDATE perfiles
SET activo = true, fecha_creacion = now()
WHERE activo IS NULL;

-- ============================================
-- 7. TABLA PARA SINCRONIZACIÓN DE DISPOSITIVOS (WEARABLE -> PHONE -> TV)
-- ============================================
CREATE TABLE IF NOT EXISTS device_sync (
  id INTEGER PRIMARY KEY,
  heart_rate INTEGER DEFAULT 0,
  hype_level INTEGER DEFAULT 0,
  episodes INTEGER DEFAULT 0,
  critical_alert BOOLEAN DEFAULT false,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Para permitir que los dispositivos emulados envíen datos sin login (usando la anon key)
-- y publiquen los cambios en tiempo real (Realtime).
ALTER TABLE device_sync ENABLE ROW LEVEL SECURITY;

ALTER TABLE device_sync 
ADD COLUMN IF NOT EXISTS remote_command TEXT DEFAULT 'IDLE',
ADD COLUMN IF NOT EXISTS selected_card INTEGER DEFAULT 0;

CREATE POLICY "Permitir select anonimo en device_sync"
ON device_sync FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "Permitir insert/update anonimo en device_sync"
ON device_sync FOR ALL
TO anon, authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- 8. TABLA PARA LISTAS DE SEGUIMIENTO (WATCHLIST) PERSONALIZADAS
-- ============================================
CREATE TABLE IF NOT EXISTS watchlist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES perfiles(id) ON DELETE CASCADE,
  anime_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  image_url TEXT,
  score NUMERIC(4, 2) DEFAULT 0,
  status TEXT DEFAULT 'watching', -- 'watching', 'favorite', 'completed'
  episodes_watched INTEGER DEFAULT 0,
  total_episodes INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

ALTER TABLE watchlist ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir gestion completa de watchlist por usuario autenticado"
ON watchlist FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Permitir lectura publica o anonima para evaluacion"
ON watchlist FOR SELECT
TO anon, authenticated
USING (true);

