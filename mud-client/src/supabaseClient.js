// src/supabaseClient.ts
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = "https://quwaphrpjfryanvikooj.supabase.co";
const supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1d2FwaHJwamZyeWFudmlrb29qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTg3Mjk3OTgsImV4cCI6MjAzNDMwNTc5OH0.VH0T7JubLrt6t0TeKUUkXOZf1FwsZKJGRkxp5RTAkow"

export const supabase = createClient(supabaseUrl, supabaseKey);
