# MySub
1. Run schema.sql in the same Supabase project as جيبلي. It creates only `mysub` schema.
2. Supabase Dashboard > Project Settings > API > Exposed schemas: add `mysub` (retain existing schemas).
3. Set URL and **publishable/anon** key in config.js; NEVER put service_role/secret key in browser.
4. Authentication > URL Configuration: add your deployed HTTPS site URL to Redirect URLs. Configure email SMTP for reliable magic links.
5. Authentication > Users: create/invite your admin user. Copy its UUID and execute `insert into mysub.admins(user_id) values ('YOUR_UUID');` in SQL Editor.
6. Invite customer email accounts using Authentication > Users. Add their UUID in the admin dashboard to assign subscriptions. Customers sign in using email magic links. Public signup is intentionally disabled (`shouldCreateUser:false`).
7. Host the folder as static files on HTTPS (Netlify, Cloudflare Pages, etc.). Opening index.html with file:// is not supported.
8. Validate RLS with two separate accounts before real use. Admin roles cannot be granted from browser; only through SQL Editor.
9. Payments table is ready for future finance module; dashboard total is sum of subscription face values, not collected payments.
10. This MVP does not send automatic email expiry alerts or automatically provision external services. Add scheduled Edge Functions for actual alerts.
