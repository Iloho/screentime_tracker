-- Location: supabase/migrations/20241216120000_screentime_data_collection.sql
-- Screen Time Data Collection Module Migration

-- 1. Types
CREATE TYPE public.user_role AS ENUM ('admin', 'member');
CREATE TYPE public.app_category AS ENUM ('social', 'productivity', 'entertainment', 'communication', 'health', 'education', 'games', 'browser', 'music', 'photography', 'other');
CREATE TYPE public.data_sync_status AS ENUM ('pending', 'synced', 'failed');

-- 2. Core Tables
-- User profiles table (intermediary for auth relationships)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'member'::public.user_role,
    anonymous_id TEXT UNIQUE NOT NULL,
    privacy_settings JSONB DEFAULT '{"location_enabled": true, "health_enabled": true, "notifications_enabled": true}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Screen time sessions table
CREATE TABLE public.screen_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    app_name TEXT NOT NULL,
    app_package TEXT,
    app_category public.app_category DEFAULT 'other'::public.app_category,
    session_start TIMESTAMPTZ NOT NULL,
    session_end TIMESTAMPTZ,
    duration_minutes INTEGER,
    location_lat DECIMAL(8, 6),
    location_lng DECIMAL(9, 6),
    sync_status public.data_sync_status DEFAULT 'pending'::public.data_sync_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Health data correlation table
CREATE TABLE public.health_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    steps_count INTEGER DEFAULT 0,
    sleep_hours DECIMAL(4, 2) DEFAULT 0,
    heart_rate INTEGER,
    active_minutes INTEGER DEFAULT 0,
    sync_status public.data_sync_status DEFAULT 'pending'::public.data_sync_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Notification events table
CREATE TABLE public.notification_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    app_name TEXT NOT NULL,
    notification_time TIMESTAMPTZ NOT NULL,
    response_time_seconds INTEGER,
    sync_status public.data_sync_status DEFAULT 'pending'::public.data_sync_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Data collection statistics table
CREATE TABLE public.collection_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    total_screen_time_minutes INTEGER DEFAULT 0,
    total_sessions INTEGER DEFAULT 0,
    total_notifications INTEGER DEFAULT 0,
    location_points INTEGER DEFAULT 0,
    is_collection_active BOOLEAN DEFAULT true,
    last_sync_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, date)
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_anonymous_id ON public.user_profiles(anonymous_id);
CREATE INDEX idx_screen_sessions_user_id ON public.screen_sessions(user_id);
CREATE INDEX idx_screen_sessions_date ON public.screen_sessions(DATE(session_start));
CREATE INDEX idx_screen_sessions_app_category ON public.screen_sessions(app_category);
CREATE INDEX idx_health_data_user_date ON public.health_data(user_id, date);
CREATE INDEX idx_notification_events_user_id ON public.notification_events(user_id);
CREATE INDEX idx_notification_events_date ON public.notification_events(DATE(notification_time));
CREATE INDEX idx_collection_stats_user_date ON public.collection_stats(user_id, date);

-- 4. RLS Setup
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screen_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collection_stats ENABLE ROW LEVEL SECURITY;

-- 5. Helper Functions
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
)
$$;

CREATE OR REPLACE FUNCTION public.owns_data(data_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT data_user_id = auth.uid() OR public.is_admin()
$$;

-- Function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role, anonymous_id)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'member'::public.user_role),
    encode(gen_random_bytes(16), 'hex')
  );  
  RETURN NEW;
END;
$$;

-- Update function for timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

-- 6. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- 7. RLS Policies
CREATE POLICY "users_own_profile" 
ON public.user_profiles 
FOR ALL
USING (auth.uid() = id) 
WITH CHECK (auth.uid() = id);

CREATE POLICY "users_own_screen_data" 
ON public.screen_sessions 
FOR ALL
USING (public.owns_data(user_id)) 
WITH CHECK (public.owns_data(user_id));

CREATE POLICY "users_own_health_data" 
ON public.health_data 
FOR ALL
USING (public.owns_data(user_id)) 
WITH CHECK (public.owns_data(user_id));

CREATE POLICY "users_own_notification_data" 
ON public.notification_events 
FOR ALL
USING (public.owns_data(user_id)) 
WITH CHECK (public.owns_data(user_id));

CREATE POLICY "users_own_collection_stats" 
ON public.collection_stats 
FOR ALL
USING (public.owns_data(user_id)) 
WITH CHECK (public.owns_data(user_id));

-- 8. Complete Mock Data
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    user_uuid UUID := gen_random_uuid();
    today_date DATE := CURRENT_DATE;
    yesterday_date DATE := CURRENT_DATE - INTERVAL '1 day';
BEGIN
    -- Create auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (user_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@example.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Test User"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create sample screen sessions for today
    INSERT INTO public.screen_sessions (user_id, app_name, app_package, app_category, session_start, session_end, duration_minutes, location_lat, location_lng, sync_status) VALUES
        (user_uuid, 'Instagram', 'com.instagram.android', 'social', now() - INTERVAL '2 hours', now() - INTERVAL '1 hour 37 minutes', 23, 37.7749, -122.4194, 'synced'),
        (user_uuid, 'Chrome', 'com.android.chrome', 'browser', now() - INTERVAL '3 hours', now() - INTERVAL '2 hours 45 minutes', 15, 37.7749, -122.4194, 'synced'),
        (user_uuid, 'Spotify', 'com.spotify.music', 'music', now() - INTERVAL '4 hours', now() - INTERVAL '3 hours 15 minutes', 45, 37.7749, -122.4194, 'synced'),
        (user_uuid, 'Gmail', 'com.google.android.gm', 'productivity', now() - INTERVAL '5 hours', now() - INTERVAL '4 hours 52 minutes', 8, 37.7749, -122.4194, 'synced'),
        (user_uuid, 'WhatsApp', 'com.whatsapp', 'communication', now() - INTERVAL '6 hours', now() - INTERVAL '5 hours 48 minutes', 12, 37.7749, -122.4194, 'synced');

    -- Create health data
    INSERT INTO public.health_data (user_id, date, steps_count, sleep_hours, heart_rate, active_minutes, sync_status) VALUES
        (user_uuid, today_date, 8432, 7.5, 72, 45, 'synced'),
        (user_uuid, yesterday_date, 6890, 6.8, 75, 32, 'synced');

    -- Create notification events
    INSERT INTO public.notification_events (user_id, app_name, notification_time, response_time_seconds, sync_status) VALUES
        (user_uuid, 'Instagram', now() - INTERVAL '1 hour', 15, 'synced'),
        (user_uuid, 'WhatsApp', now() - INTERVAL '2 hours', 5, 'synced'),
        (user_uuid, 'Gmail', now() - INTERVAL '3 hours', 30, 'synced'),
        (user_uuid, 'Spotify', now() - INTERVAL '4 hours', null, 'synced');

    -- Create collection stats
    INSERT INTO public.collection_stats (user_id, date, total_screen_time_minutes, total_sessions, total_notifications, location_points, is_collection_active, last_sync_at) VALUES
        (user_uuid, today_date, 312, 34, 156, 156, true, now()),
        (user_uuid, yesterday_date, 285, 28, 142, 134, true, yesterday_date + INTERVAL '23 hours');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;

-- 9. Analytics Functions
CREATE OR REPLACE FUNCTION public.get_user_daily_stats(target_date DATE DEFAULT CURRENT_DATE)
RETURNS TABLE(
    total_screen_time_minutes INTEGER,
    total_sessions INTEGER,
    total_notifications INTEGER,
    most_used_app TEXT,
    most_used_category TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE(SUM(ss.duration_minutes), 0)::INTEGER as total_screen_time_minutes,
        COUNT(ss.id)::INTEGER as total_sessions,
        COALESCE((
            SELECT COUNT(*) FROM public.notification_events ne 
            WHERE ne.user_id = auth.uid() AND DATE(ne.notification_time) = target_date
        ), 0)::INTEGER as total_notifications,
        (
            SELECT ss2.app_name 
            FROM public.screen_sessions ss2 
            WHERE ss2.user_id = auth.uid() AND DATE(ss2.session_start) = target_date
            GROUP BY ss2.app_name 
            ORDER BY SUM(ss2.duration_minutes) DESC 
            LIMIT 1
        ) as most_used_app,
        (
            SELECT ss3.app_category::TEXT 
            FROM public.screen_sessions ss3 
            WHERE ss3.user_id = auth.uid() AND DATE(ss3.session_start) = target_date
            GROUP BY ss3.app_category 
            ORDER BY SUM(ss3.duration_minutes) DESC 
            LIMIT 1
        ) as most_used_category
    FROM public.screen_sessions ss
    WHERE ss.user_id = auth.uid() AND DATE(ss.session_start) = target_date;
END;
$$;

-- 10. Cleanup Function
CREATE OR REPLACE FUNCTION public.cleanup_test_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    auth_user_ids_to_delete UUID[];
BEGIN
    -- Get auth user IDs first
    SELECT ARRAY_AGG(id) INTO auth_user_ids_to_delete
    FROM auth.users
    WHERE email LIKE '%@example.com';

    -- Delete in dependency order (children first, then auth.users last)
    DELETE FROM public.collection_stats WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.notification_events WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.health_data WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.screen_sessions WHERE user_id = ANY(auth_user_ids_to_delete);
    DELETE FROM public.user_profiles WHERE id = ANY(auth_user_ids_to_delete);

    -- Delete auth.users last (after all references are removed)
    DELETE FROM auth.users WHERE id = ANY(auth_user_ids_to_delete);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint prevents deletion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;