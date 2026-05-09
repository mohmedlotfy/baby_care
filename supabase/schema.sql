-- ============================================================
-- Baby Care App — Supabase Database Schema (Normalized - 3NF)
-- Run this entire file in the Supabase SQL Editor
-- ============================================================

-- 0. Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. USERS — Public profile linked to auth.users
-- ============================================================
CREATE TABLE public.users (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name   TEXT        NOT NULL,
    email       TEXT        NOT NULL UNIQUE,
    phone       TEXT,
    avatar_url  TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE public.users IS 'Public user profile, linked to auth.users';

-- ============================================================
-- 2. INFANTS — Infant profiles (one user can have many infants)
-- ============================================================
CREATE TABLE public.infants (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id          UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name             TEXT        NOT NULL,
    date_of_birth    DATE        NOT NULL,
    gender           TEXT        NOT NULL CHECK (gender IN ('male', 'female')),
    birth_weight_kg  NUMERIC(5,2),
    birth_length_cm  NUMERIC(5,2),
    blood_type       TEXT        CHECK (blood_type IN ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
    photo_url        TEXT,
    is_active        BOOLEAN     NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_infants_user_id ON public.infants(user_id);
COMMENT ON TABLE public.infants IS 'Infant profiles belonging to a mother/user';

-- ============================================================
-- 3. CRY_CATEGORIES — Lookup table for cry types (3NF)
-- ============================================================
CREATE TABLE public.cry_categories (
    id          SERIAL PRIMARY KEY,
    label       TEXT NOT NULL UNIQUE,
    label_ar    TEXT NOT NULL,
    description TEXT,
    icon_name   TEXT
);

INSERT INTO public.cry_categories (label, label_ar, description) VALUES
    ('hungry',     'جائع',          'The baby is hungry and needs feeding'),
    ('pain',       'ألم',           'The baby is in pain or discomfort'),
    ('tired',      'متعب',          'The baby is sleepy or tired'),
    ('diaper',     'تغيير حفاضة',   'The baby needs a diaper change'),
    ('colic',      'مغص',           'The baby is experiencing colic'),
    ('attention',  'يحتاج اهتمام',  'The baby wants to be held or comforted'),
    ('discomfort', 'انزعاج',        'General discomfort (temperature, clothing, etc.)');

COMMENT ON TABLE public.cry_categories IS 'Lookup table for AI cry classification labels';

-- ============================================================
-- 4. CRY_ANALYSES — AI cry analysis results
-- ============================================================
CREATE TABLE public.cry_analyses (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    infant_id       UUID        NOT NULL REFERENCES public.infants(id) ON DELETE CASCADE,
    category_id     INT         NOT NULL REFERENCES public.cry_categories(id),
    audio_url       TEXT        NOT NULL,
    duration_sec    NUMERIC(6,2),
    confidence      NUMERIC(5,4) CHECK (confidence BETWEEN 0 AND 1),
    advice          TEXT,
    advice_ar       TEXT,
    analyzed_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_cry_analyses_infant ON public.cry_analyses(infant_id);
CREATE INDEX idx_cry_analyses_date   ON public.cry_analyses(analyzed_at DESC);
COMMENT ON TABLE public.cry_analyses IS 'History of AI cry analysis results per infant';

-- ============================================================
-- 5. GROWTH_RECORDS — Weight, length, head circumference
-- ============================================================
CREATE TABLE public.growth_records (
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    infant_id             UUID        NOT NULL REFERENCES public.infants(id) ON DELETE CASCADE,
    weight_kg             NUMERIC(5,2),
    length_cm             NUMERIC(5,2),
    head_circumference_cm NUMERIC(5,2),
    bmi                   NUMERIC(5,2),
    weight_percentile     NUMERIC(5,2),
    length_percentile     NUMERIC(5,2),
    percentile_status     TEXT CHECK (percentile_status IN ('normal','underweight','overweight','short','tall')),
    alert_level           TEXT DEFAULT 'none' CHECK (alert_level IN ('none','warning','critical')),
    notes                 TEXT,
    recorded_date         DATE        NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_growth_infant       ON public.growth_records(infant_id);
CREATE INDEX idx_growth_date         ON public.growth_records(recorded_date DESC);
CREATE UNIQUE INDEX idx_growth_unique ON public.growth_records(infant_id, recorded_date);
COMMENT ON TABLE public.growth_records IS 'Periodic growth measurements compared to WHO standards';

-- ============================================================
-- 6. VACCINES_CATALOG — Master vaccine list (3NF reference)
-- ============================================================
CREATE TABLE public.vaccines_catalog (
    id                   SERIAL PRIMARY KEY,
    name                 TEXT    NOT NULL,
    name_ar              TEXT    NOT NULL,
    description          TEXT,
    dose_number          INT     NOT NULL DEFAULT 1,
    recommended_age_days INT     NOT NULL,
    is_mandatory         BOOLEAN NOT NULL DEFAULT true,
    UNIQUE(name, dose_number)
);

INSERT INTO public.vaccines_catalog (name, name_ar, dose_number, recommended_age_days, is_mandatory) VALUES
    ('BCG',                'بي سي جي',                                    1, 0,   true),
    ('Hepatitis B',        'التهاب كبدي بي',                              1, 0,   true),
    ('OPV',                'شلل أطفال فموي',                              1, 60,  true),
    ('OPV',                'شلل أطفال فموي',                              2, 120, true),
    ('OPV',                'شلل أطفال فموي',                              3, 180, true),
    ('DPT-HepB-Hib',      'خماسي',                                       1, 60,  true),
    ('DPT-HepB-Hib',      'خماسي',                                       2, 120, true),
    ('DPT-HepB-Hib',      'خماسي',                                       3, 180, true),
    ('IPV',                'شلل أطفال معطل',                              1, 120, true),
    ('Pneumococcal (PCV)', 'المكورات الرئوية',                            1, 60,  true),
    ('Pneumococcal (PCV)', 'المكورات الرئوية',                            2, 120, true),
    ('Pneumococcal (PCV)', 'المكورات الرئوية',                            3, 365, true),
    ('MMR',                'الحصبة والنكاف والحصبة الألمانية',            1, 365, true),
    ('MMR',                'الحصبة والنكاف والحصبة الألمانية',            2, 540, true),
    ('Hepatitis A',        'التهاب كبدي إيه',                             1, 365, true),
    ('Varicella',          'الجديري المائي',                              1, 365, false),
    ('DPT Booster',        'جرعة منشطة ثلاثي',                           1, 540, true);

COMMENT ON TABLE public.vaccines_catalog IS 'Master vaccine catalog with recommended schedule';

-- ============================================================
-- 7. VACCINATION_RECORDS — Per-infant vaccine tracking
-- ============================================================
CREATE TABLE public.vaccination_records (
    id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    infant_id         UUID    NOT NULL REFERENCES public.infants(id) ON DELETE CASCADE,
    vaccine_id        INT     NOT NULL REFERENCES public.vaccines_catalog(id),
    scheduled_date    DATE    NOT NULL,
    administered_date DATE,
    status            TEXT    NOT NULL DEFAULT 'upcoming'
                      CHECK (status IN ('upcoming','overdue','completed','skipped')),
    administered_by   TEXT,
    notes             TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(infant_id, vaccine_id)
);

CREATE INDEX idx_vacc_infant   ON public.vaccination_records(infant_id);
CREATE INDEX idx_vacc_status   ON public.vaccination_records(status);
CREATE INDEX idx_vacc_schedule ON public.vaccination_records(scheduled_date);
COMMENT ON TABLE public.vaccination_records IS 'Per-infant vaccination tracking linked to catalog';

-- ============================================================
-- 8. FEEDING_LOGS — Breastfeeding & formula tracker
-- ============================================================
CREATE TABLE public.feeding_logs (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    infant_id        UUID        NOT NULL REFERENCES public.infants(id) ON DELETE CASCADE,
    feeding_type     TEXT        NOT NULL CHECK (feeding_type IN ('breast','formula','solid','mixed')),
    breast_side      TEXT        CHECK (breast_side IN ('left','right','both')),
    start_time       TIMESTAMPTZ NOT NULL,
    end_time         TIMESTAMPTZ,
    duration_minutes INT         GENERATED ALWAYS AS (
                         EXTRACT(EPOCH FROM (end_time - start_time)) / 60
                     ) STORED,
    amount_ml        NUMERIC(6,1),
    notes            TEXT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_feeding_infant ON public.feeding_logs(infant_id);
CREATE INDEX idx_feeding_time   ON public.feeding_logs(start_time DESC);
COMMENT ON TABLE public.feeding_logs IS 'Breastfeeding and formula feeding log per infant';

-- ============================================================
-- 9. NOTIFICATIONS — Push notification queue
-- ============================================================
CREATE TABLE public.notifications (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id        UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    infant_id      UUID        REFERENCES public.infants(id) ON DELETE CASCADE,
    type           TEXT        NOT NULL CHECK (type IN ('vaccine','feeding','growth_alert','general')),
    title          TEXT        NOT NULL,
    title_ar       TEXT,
    body           TEXT        NOT NULL,
    body_ar        TEXT,
    is_read        BOOLEAN     NOT NULL DEFAULT false,
    scheduled_for  TIMESTAMPTZ NOT NULL,
    sent_at        TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notif_user      ON public.notifications(user_id);
CREATE INDEX idx_notif_unread    ON public.notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notif_scheduled ON public.notifications(scheduled_for);
COMMENT ON TABLE public.notifications IS 'Notification queue for reminders and alerts';

-- ============================================================
-- 10. CHAT_MESSAGES — AI chatbot conversation history
-- ============================================================
CREATE TABLE public.chat_messages (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID        NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    infant_id   UUID        REFERENCES public.infants(id) ON DELETE SET NULL,
    session_id  UUID        NOT NULL DEFAULT uuid_generate_v4(),
    role        TEXT        NOT NULL CHECK (role IN ('user','assistant','system')),
    content     TEXT        NOT NULL,
    tokens_used INT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_chat_user    ON public.chat_messages(user_id);
CREATE INDEX idx_chat_session ON public.chat_messages(session_id, created_at);
COMMENT ON TABLE public.chat_messages IS 'AI chatbot conversation history';

-- ============================================================
-- 11. TRIGGERS — Auto-update updated_at timestamp
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.infants
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.vaccination_records
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- 12. AUTO-CREATE USER PROFILE on Supabase Auth signup
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- 13. ROW LEVEL SECURITY (RLS) — Data isolation per user
-- ============================================================

-- Enable RLS
ALTER TABLE public.users               ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.infants             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cry_analyses        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.growth_records      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vaccination_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feeding_logs        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages       ENABLE ROW LEVEL SECURITY;

-- Users
CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE USING (auth.uid() = id);

-- Infants
CREATE POLICY "Users can manage own infants"
    ON public.infants FOR ALL USING (auth.uid() = user_id);

-- Cry Analyses
CREATE POLICY "Users can manage own cry analyses"
    ON public.cry_analyses FOR ALL
    USING (infant_id IN (SELECT id FROM public.infants WHERE user_id = auth.uid()));

-- Growth Records
CREATE POLICY "Users can manage own growth records"
    ON public.growth_records FOR ALL
    USING (infant_id IN (SELECT id FROM public.infants WHERE user_id = auth.uid()));

-- Vaccination Records
CREATE POLICY "Users can manage own vaccination records"
    ON public.vaccination_records FOR ALL
    USING (infant_id IN (SELECT id FROM public.infants WHERE user_id = auth.uid()));

-- Feeding Logs
CREATE POLICY "Users can manage own feeding logs"
    ON public.feeding_logs FOR ALL
    USING (infant_id IN (SELECT id FROM public.infants WHERE user_id = auth.uid()));

-- Notifications
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- Chat Messages
CREATE POLICY "Users can manage own chat messages"
    ON public.chat_messages FOR ALL USING (auth.uid() = user_id);

-- Lookup tables: read-only for all authenticated users
CREATE POLICY "Anyone can read cry categories"
    ON public.cry_categories FOR SELECT USING (true);
CREATE POLICY "Anyone can read vaccines catalog"
    ON public.vaccines_catalog FOR SELECT USING (true);

-- ============================================================
-- Done! Your Baby Care database is ready.
-- ============================================================
