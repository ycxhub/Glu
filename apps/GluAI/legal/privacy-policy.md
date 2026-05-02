# Glu AI — Privacy Policy

**Last updated:** May 1, 2026  

**App:** Glu AI (iOS; bundle identifier `com.ycxlabs.gluai`)  
**Policy URL:** `https://hard75.com/glu-ai/privacy-policy` (use this URL in App Store Connect)

---

## Medical and regulatory disclaimer

Glu AI is **not** medical advice, diagnosis, treatment, or a substitute for professional healthcare. Glu AI is **not** a medical device (including software-as-a-medical-device), **not** a continuous glucose monitoring (CGM) system or replacement for one, **not** a regulated disease treatment tool, and it does **not** prescribe, guarantee, or personalize medical outcomes. Always consult a qualified healthcare professional regarding glucose management, medications, insulin, allergies, metabolic conditions, and any dietary or lifestyle changes.

**What Glu AI is:** an **educational meal-awareness companion** that provides general, non-binding information—based on broadly available knowledge about foods—about how certain foods might relate to glucose responses for some people. Outputs are **informational and educational only**.

---

## Who we are (data controller)

The organization responsible for decisions about your personal data (**controller**) is:

| Field | Detail |
|--------|--------|
| **Product** | Glu AI |
| **Developer listing (App Store)** | YCX Labs (`com.ycxlabs.gluai`) |
| **Privacy contact** | [glu@hard75.com](mailto:glu@hard75.com) |

**Please replace the following placeholders** on your public page if required by your lawyer or storefront: **[registered legal entity name]**, **[registered business address]**, and **[company registration number, if applicable]**. Until those appear on your site, the privacy contact above is the designated channel for privacy requests worldwide.

---

## Scope

This policy describes how we collect, use, store, share, and protect personal information when you use Glu AI’s services delivered through our **iOS app**, **websites** (including this policy page), **cloud backend**, and related infrastructure (**Services**).

By using the Services, you acknowledge this policy. If you do not agree, do not use Glu AI.

This policy is written for a **global** audience. Depending on where you live, you may have **additional rights** under local law (see **Your privacy rights**).

---

## Summary (quick read)

- We **do not sell** your personal information.
- We **do not use** your meal content or account data to **train machine-learning models for Glu AI**; we do not operate proprietary models trained on your submissions.
- **Inference:** Meal photos you submit are processed **only to return an educational analysis** for that request (via our servers and **OpenAI’s API** as described below).
- **Accounts:** Sign-in is **Sign in with Apple**, processed through **Supabase Auth**.
- **Subscriptions:** Handled by **Apple** and **RevenueCat**; we do not receive full payment card numbers from those systems.
- **Current app build:** The shipping codebase does **not** integrate third-party advertising SDKs or third-party analytics SDKs (e.g. no ad networks in-app). Internal **debug** builds may print diagnostics locally for development only.

If anything here conflicts with an **in-app notice** or **App Store “App Privacy” labels**, we will correct the inconsistency—contact [glu@hard75.com](mailto:glu@hard75.com).

---

## Personal information we collect

Categories depend on how you use Glu AI.

### 1. Account and authentication

| Data | Source | Purpose |
|------|--------|---------|
| Apple-provided **identity token** and related Sign in with Apple identifiers | Apple, via your device | Authenticate you |
| **Supabase user id** (UUID), session tokens | Supabase Auth | Maintain your account and secure API access |
| **Email address** (often a private relay address from Apple, or absent if you hide email) | Apple / Supabase where applicable | Account recovery and service communications where enabled |
| **Display name** (if you provide it on first sign-in via Apple) | Apple / profile fields | Personalization in-app |

We use **Supabase** as our authentication and account directory provider.

### 2. Meal-related content you provide

| Data | Purpose |
|------|---------|
| **Meal photographs** (e.g. JPEG) you capture or upload | Sent to our **Supabase Edge Function** for analysis; forwarded to **OpenAI** for vision-language inference as described below |
| **Structured analysis results** (e.g. estimated macros, educational “spike risk” label, rationale text, confidence—returned as JSON) | Shown in the app; may be stored in our database when you save a log |
| **Storage path** for an optional stored image | If you use cloud meal history features that persist images, references may be stored in **Supabase Storage** (private bucket; not public by design) |
| **Timestamps** | Ordering history, debugging, security |

**Please avoid** uploading photos that contain faces of third parties, screens with identifiable third-party data, or sensitive documents. You control what you capture.

### 3. Subscription and billing-related data

| Data | Source | Purpose |
|------|--------|---------|
| **Product identifiers**, **trial/subscription state**, **transaction metadata** | Apple App Store, **RevenueCat** | Provide paid features, restore purchases, comply with storefront rules |
| **App Store account identifiers** | Apple | Managed under Apple’s privacy policy |

We **do not** store complete payment card numbers; Apple / payment processors handle payment instruments.

### 4. Technical, usage, and security data

| Data | Purpose |
|------|---------|
| **Device** type, **OS version**, **app version** | Compatibility, debugging, abuse prevention |
| **IP address**, **approximate region** derived from IP | Security, fraud prevention, jurisdictional compliance |
| **Server logs** (e.g. HTTP requests to Supabase Edge Functions, errors, latency) | Reliability and security |
| **Identifiers** required by SDKs you integrate (e.g. RevenueCat customer identifiers mapped to your account) | Subscription functionality |

When you contact support, we retain **support emails** and contents you voluntarily send.

---

## How we use personal information

We use personal information to:

- Provide, operate, secure, and improve Glu AI (authentication, meal analysis, subscription access).
- Store your **meal logs** and profile data when you choose to save them.
- Communicate **transactional** messages (e.g. password resets if enabled, critical service notices, responses to support).
- Detect, investigate, and prevent **abuse**, fraud, or violations of our terms.
- Comply with **legal obligations** and respond to lawful requests from public authorities, subject to applicable law.
- Defend **legal claims** where permitted.

We **do not**:

- Use your data to **train proprietary Glu AI models** (we do not operate such training on user content).
- **Sell** personal information (including “selling” as defined under U.S. state privacy laws).

---

## Artificial intelligence and OpenAI

### What happens to your meal photo

When you request analysis:

1. The app sends the image (typically as **base64-encoded JPEG**) to our **Supabase Edge Function** (`analyze-meal`).
2. That function calls **OpenAI’s HTTP API** (e.g. multimodal chat completions; model configurable server-side, default **`gpt-4o-mini`** unless we set `OPENAI_VISION_MODEL`) to produce **structured JSON** with educational estimates.

Your image and prompts are processed **for inference only**—to generate a response for you. They may be **temporarily retained** by OpenAI or subprocessors according to **OpenAI’s policies** for API customers; see [OpenAI’s privacy and enterprise/API documentation](https://openai.com/policies/privacy-policy) and applicable **API data usage** terms for your account tier.

**No automated medical decisions:** Outputs are not clinical decisions and do not replace professional judgment.

---

## Legal bases (EEA, UK, Switzerland, and similar regions)

Where GDPR or comparable laws apply, we rely on:

1. **Performance of a contract** — providing the Services you request (account, meal analysis, subscriptions).
2. **Legitimate interests** — securing the Services, debugging reliability, preventing abuse, and improving non-invasive aspects of the product, balanced against your rights.
3. **Consent** — where required for optional communications or optional analytics beyond strict necessity (we currently do not ship third-party analytics SDKs in production).
4. **Legal obligation** — where the law requires retention or disclosure.

You may **withdraw consent** where processing is consent-based (without affecting prior lawful processing). You may **object** to certain legitimate-interest processing where applicable law allows.

---

## Sharing and subprocessors

We **do not sell** personal information. We share information **only** as needed to operate the Services:

| Subprocessor | Role | Notes |
|--------------|------|--------|
| **Supabase** ([supabase.com](https://supabase.com)) | Hosted Postgres database, authentication, Edge Functions, optional Storage | Primary backend; data residency depends on **your Supabase project region** |
| **OpenAI** ([openai.com](https://openai.com)) | Vision-language inference API | Processes meal images / prompts per request |
| **Apple** ([apple.com/privacy](https://www.apple.com/privacy/)) | Sign in with Apple; App Store purchases | Subject to Apple’s terms |
| **RevenueCat** ([revenuecat.com](https://www.revenuecat.com)) | Subscription SDK, entitlements, Customer Center | Processes purchase-related identifiers and events |

Additional vendors (e.g. email delivery for auth, hosting for marketing sites, moderation tools) may be added as the product evolves. **Material changes** to categories or primary vendors will be reflected by updating this page (and, where appropriate, in-app notices).

We may also disclose information:

- To comply with **law**, regulation, or lawful governmental requests.
- To protect **vital interests**, rights, property, or safety.
- In connection with a **business transaction** (merger, acquisition, asset sale), with safeguards for continuity and notices where required.
- As **aggregated or de-identified** information that cannot reasonably identify you.

---

## International transfers

Your information may be processed in countries other than your own (including the **United States**). Where required (EEA/UK/CH → third countries), we rely on appropriate safeguards such as **Standard Contractual Clauses** and supplementary measures offered by our vendors. You may email [glu@hard75.com](mailto:glu@hard75.com) for more detail on transfers and vendor documentation **reasonably available** to us.

---

## Retention

| Category | Retention (general) |
|----------|---------------------|
| **Account / profile** | While your account exists; deleted or **de-identified** after account deletion, except where law requires longer retention |
| **Meal logs and stored images** | Until you delete them or delete your account (subject to backup purge cycles) |
| **Server logs** | Short to moderate rolling retention for security and debugging |
| **Billing records** | As required for tax, accounting, and fraud prevention |
| **Support correspondence** | Long enough to resolve issues and maintain ordinary business records |

After deletion requests, **residual copies** may persist in encrypted backups for a limited period before overwrite.

---

## Security

We implement **commercially reasonable** technical and organizational measures, including **encryption in transit (HTTPS/TLS)**, **authenticated access**, **database row-level security** for user-owned records in our schema design, and **secret management** for API keys (e.g. OpenAI keys **only on servers**, not embedded for client-side model calls).

No online service is perfectly secure. Report suspected incidents to [glu@hard75.com](mailto:glu@hard75.com).

---

## Your privacy rights

Depending on your location, you may have rights to **access**, **rectify**, **delete**, **export**, **restrict**, or **object** to processing, and to **withdraw consent** where processing is consent-based.

**To exercise rights:** Email [glu@hard75.com](mailto:glu@hard75.com) with your request, country/state of residence, and enough information to verify your identity (we may ask follow-up questions). We respond within timelines required by applicable law.

**EEA/UK/CH:** You may lodge a complaint with your local **supervisory authority**.

**United States (CPRA/CCPA-style states):** We do **not sell** personal information and do **not share** it for **cross-context behavioral advertising** as described in current Glu AI builds. If we introduce such processing, we will update this policy and, where required, provide opt-out mechanisms.

**Nevada:** We do not sell covered information as defined under Nevada law; you may still contact us with questions.

---

## Children’s privacy

Glu AI is **not directed at children under 13** (or the age of digital consent in your jurisdiction). We do not knowingly collect personal information from children in violation of applicable rules. If you believe we have collected information from a child, contact [glu@hard75.com](mailto:glu@hard75.com) and we will take appropriate steps.

---

## Cookies and similar technologies (websites)

Our **marketing or documentation websites** may use **essential cookies** required for operation. If we deploy non-essential cookies or similar tracking on web properties, we will provide appropriate notices and, where EU/UK law requires, **consent** mechanisms. This static policy page alone typically uses minimal storage.

---

## Third-party links

The Services may reference third-party sites (e.g. documentation). Their privacy practices are governed by **their** policies, not this one.

---

## Automated processing

Glu AI uses automated systems (including AI) to generate **educational meal commentary**. These outputs **do not** produce legal or similarly significant effects about you in the GDPR sense and **do not** replace professional medical decisions.

---

## Changes to this policy

We may update this policy from time to time. We will revise the **Last updated** date above and, where changes are **material**, provide additional notice (e.g. in-app alert or email if we have your address). Continued use after the effective date constitutes acceptance of the updated policy where permitted by law.

---

## Contact

**Privacy and data requests:** [glu@hard75.com](mailto:glu@hard75.com)

---

## Alignment checklist for App Store Connect

Before submission, confirm:

- **Privacy Policy URL** in App Store Connect matches the published URL (`https://hard75.com/glu-ai/privacy-policy`).
- **App Privacy** (“nutrition labels”) in App Store Connect matches actual data collection (account fields, photos, purchase info, identifiers used by RevenueCat/Apple, etc.).
- **Legal entity / seller name** on the storefront matches the **controller** section once you add **[registered legal entity name]** and **[address]** on the live page.

© 2026 Glu AI. All rights reserved.
