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
