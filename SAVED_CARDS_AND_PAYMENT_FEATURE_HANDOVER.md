# Saved Cards & Payment Feature — Implementation Handover for AI Agent

This document describes the **Saved Cards** and **Pay with saved card** feature so an AI agent can implement it in a (possibly different) Flutter project. It covers backend API contract, Paymob SDK usage, screens, and implementation order.

---

## 1. Feature overview

- **Saved cards**: User can save a card after a successful Paymob payment (checkbox “Save this card”), then list, delete, and pay with saved cards.
- **Payment flow**: Either “pay with new card” (Paymob card form + optional save) or “pay with saved card” (Paymob token flow, no card form).
- **Confirm purchase**: A screen to review package/order, optional promo code, **select payment method** (saved cards or “Manage Cards”), and “Pay Now”.

The app uses a **backend** for: creating payment/transaction, saving cards, listing cards, getting card token for payment, deleting cards, and polling payment status. The app uses the **Paymob native SDK** (Accept SDK) for card entry and 3DS only.

---

## 2. User identity (auth for saved cards)

- Every saved-cards request must identify the user (e.g. authenticated client or stable device user).
- **Option A:** Header `X-User-Id: <userId>` (opaque string: UUID, device id, or JWT subject). Backend scopes cards to this user.
- **Option B:** Standard auth (e.g. `Authorization: Bearer <token>`). Backend derives user from token.
- **Flutter:** Store a stable `userId` (e.g. UUID in SharedPreferences, or from auth). Send it on every saved-cards API call. Initialize before `runApp()` if needed.

---

## 3. Backend API contract

Base URL is project-specific (e.g. `https://your-api.com` or `/api`). Below are two common styles; implement the one your backend exposes.

### 3.1 Style A — Client API (e.g. `/api/client/...`)

Typical for an authenticated “client” with bearer token.

| Purpose | Method | Path | Auth | Body / params |
|--------|--------|------|------|----------------|
| Create payment | `POST` | `/api/client/transaction` | Bearer (or session) | See below |
| Payment status | `GET` | `/api/client/orders/{transaction_id}/payment-status` | Same | Path: `transaction_id` |
| Save card | `POST` | `/api/client/saved-cards` | Same | `paymob_token`, `masked_pan`, `card_subtype` (optional) |
| List saved cards | `GET` | `/api/client/saved-cards` | Same | — |
| Get card for payment | `GET` | `/api/client/saved-cards/{uuid}` | Same | Path: card `uuid` |
| Delete saved card | `DELETE` | `/api/client/saved-cards/{uuid}` | Same | Path: card `uuid` |

**Create payment (POST /api/client/transaction)**  
Request body (JSON), example:

```json
{
  "type": "package",
  "packageId": 1,
  "coins": 200,
  "promoCode": "SUMMER2025",
  "savedCardUuid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "sdk": false
}
```

- `savedCardUuid`: optional; when user pays with a saved card, send that card’s UUID; otherwise omit or null.
- `sdk`: e.g. `true` when the client will open the Paymob SDK (card or token flow); backend may return a `payment_key` or similar for the SDK.
- Response: define with backend (e.g. `transaction_id`, `payment_key`, order id). App needs at least:
  - Something to pass to Paymob SDK (e.g. `payment_key`).
  - Something to poll status (e.g. `transaction_id` or `merchant_order_id`).

**Payment status (GET /api/client/orders/{transaction_id}/payment-status)**  
- Returns payment state (e.g. paid, failed, pending).  
- App polls this after the SDK returns until terminal state, then navigates to success/failure.

**Save card (POST /api/client/saved-cards)**  
Body example:

```json
{
  "paymob_token": "tok_P...xyz",
  "masked_pan": "xxxx-xxxx-xxxx-4242",
  "card_subtype": "Visa"
}
```

- Success (e.g. 201): response includes saved card resource (e.g. `id` / `uuid`, `masked_pan`, `card_subtype`). Store `id`/`uuid` for “pay with this card” and “delete”.

**List saved cards (GET /api/client/saved-cards)**  
- Success (200): array (or wrapper like `{ "cards": [...] }`) of items with at least: `id`/`uuid`, `masked_pan`, optional `card_subtype`/brand, optional `expired` or expiry.

**Get card for payment (GET /api/client/saved-cards/{uuid})**  
- When user chose a saved card to pay, call with that card’s `uuid`.  
- Success (200): must include **`paymob_token`** and **`masked_pan`** (and optionally brand). App passes these to the Paymob SDK “pay with token” flow.

**Delete saved card (DELETE /api/client/saved-cards/{uuid})**  
- Success: 204 or 200. On 404 show “Card not found”.

---

### 3.2 Style B — User-scoped cards (e.g. `/users/me/cards`)

| Purpose | Method | Path | Auth |
|--------|--------|------|------|
| Save card | `POST` | `/users/me/cards` | `X-User-Id` (or Bearer) |
| List cards | `GET` | `/users/me/cards` | Same |
| Get card for payment | `GET` | `/users/me/cards/:cardId` | Same |
| Delete card | `DELETE` | `/users/me/cards/:cardId` | Same |

- Save body: `paymob_token`, `masked_pan`, optional `card_brand`, `last_four`.  
- List/Get/Delete: use returned `id` as `:cardId`. Get-for-payment response must include `paymob_token` and `masked_pan`.  
- Payment session/transaction creation is a **separate** endpoint (e.g. `POST /payments/paymob/session` or `POST /api/client/transaction`); create session first, then for saved-card payment call get-card-by-id and pass token + masked_pan to SDK.

---

## 4. Paymob SDK integration (Accept SDK)

- The app uses the **native** Paymob Accept SDK (Android Activity, iOS ViewController), not a WebView-only solution.
- **Payment key / session:** Backend creates a Paymob session (or transaction) and returns a **payment_key** (or equivalent). The app never calls Paymob’s auth/order/payment_key APIs directly if the backend does that.

### 4.1 Pay with new card (and optional save)

1. App calls backend to **create payment/session** (e.g. `POST /api/client/transaction` with `sdk: true` and no `savedCardUuid`, or `POST /payments/paymob/session`).  
2. Backend returns **payment_key** (and order/transaction id for status polling).  
3. App opens Paymob SDK **without** a saved-card token (e.g. `startPayActivityNoToken`), with:
   - `payment_key`
   - **showSaveCard: true** (and saveCardDefault: false if desired)
   - theme/language/actionbar as needed
4. User enters card, may check “Save this card”, completes payment (and 3DS if required).  
5. On **success**:
   - If SDK indicates “card saved” (e.g. `TRANSACTION_SUCCESSFUL_CARD_SAVED`) and returns **token** and **masked_pan**, call backend **save card** (e.g. `POST /api/client/saved-cards` or `POST /users/me/cards`) with `paymob_token`, `masked_pan`, and optional brand.  
   - Then poll **payment status** (e.g. `GET /api/client/orders/{transaction_id}/payment-status`) and navigate to success/failure.  
6. On **error/cancel**: still poll status and show appropriate screen; optionally show SDK error message.

### 4.2 Pay with saved card

1. User has already selected a saved card (e.g. on “Confirm Purchase” or “My Cards”). App has the card **id/uuid**.  
2. App calls backend to **create payment/session** (e.g. with `savedCardUuid` set, or same session endpoint as above).  
3. Backend returns **payment_key** and order/transaction id.  
4. App calls **get card for payment** (e.g. `GET /api/client/saved-cards/{uuid}` or `GET /users/me/cards/:cardId`) and receives **paymob_token** and **masked_pan**.  
5. App opens Paymob SDK **with token** (e.g. `startPayActivityToken`) with:
   - `payment_key`
   - `token` = paymob_token
   - `maskedPanNumber` = masked_pan
   - **customer** object (required by many SDKs: name, email, phone, address fields from billing/checkout)
   - showSaveCard: false
6. SDK may do 3DS only (no card form). On success/failure, poll payment status and navigate.

### 4.3 Platform notes

- **Android:** 3DS redirect may be to a URL that doesn’t start with `accept.paymob.com`. Treat success when the redirect URL contains `data.message=Approved` and has query params; parse and pass them to the SDK so the flow completes.  
- **iOS:** Use the correct **country** for the SDK (e.g. `.Egypt` for Egypt); wrong country (e.g. `.Pakistan`) can cause “Error processing payment”.  
- **Result parsing:** SDK may return `data_message` / `dataMessage` (e.g. `TRANSACTION_SUCCESSFUL`, `TRANSACTION_SUCCESSFUL_CARD_SAVED`). For “card saved”, require non-null `token` and `masked_pan` before calling the save-card API.

### 4.4 Using the native SDK: copy the local plugin (recommended)

This feature is designed to work with the **native** Paymob Accept SDK (Android Activity, iOS ViewController), not a WebView-only package. The reference implementation uses a **local Flutter plugin** that wraps the native SDK and includes required fixes (3DS success URL handling, iOS country, card-saved result).

**When implementing in another project:**

1. **Copy the plugin directory** from the reference project into the new project:
   - Copy the entire **`packages/paymob_flutter_lib`** directory (Dart API, platform interface, Android and iOS native code, including the Accept SDK integration and the fixes above).
2. **Add a path dependency** in the new project’s `pubspec.yaml`:
   ```yaml
   dependencies:
     paymob_flutter_lib:
       path: packages/paymob_flutter_lib
   ```
3. Run **`flutter pub get`** and ensure the app builds for Android and iOS (native dependencies such as Accept SDK / AcceptCardSDK pod are resolved).
4. Use the plugin’s API: **`startPayActivityNoToken`** (for new card + optional save) and **`startPayActivityToken`** (for pay with saved card), as described in sections 4.1 and 4.2.

**Do not** copy the plugin if the target project will use a different Paymob integration (e.g. a pub package or WebView-based flow); in that case the API and flows in this handover would need to be adapted to that integration.

---

## 5. Screens and UI

### 5.1 Saved Cards screen

- **Title:** “Saved Cards” (or “My Cards”).  
- **List:** Each item shows:
  - Card brand (e.g. Visa, Mastercard) and masked number (e.g. `****4321`).
  - Optional **EXPIRED** badge if the backend or list item exposes expiry/expired.
  - **Delete** control (e.g. trash icon); on tap → confirm dialog → `DELETE` saved card → on success remove from list; on 404 show “Card not found”.
- **Actions per card:**
  - “Pay with this card” (or select for payment): navigate to checkout/confirm-purchase with this card’s **id/uuid** as selected payment method.
  - “Manage Cards” in other screens can navigate here.
- **Empty state:**  
  - Illustration or icon (e.g. magnifying glass or card icon).  
  - Title: “No Saved Cards”.  
  - Short copy: e.g. “You don’t have any saved cards yet. Add one for faster checkout. Your details are encrypted and securely processed.”  
  - Primary action: e.g. “Add card” or “Pay with new card” (navigate to checkout without a saved card).
- **Loading / error:** Loading indicator while fetching; on error show message and “Retry”.  
- **Pull-to-refresh:** Optional; refresh list from backend.

### 5.2 Confirm Your Purchase screen

- **Sections:**
  - **Package (or order) details:** Name, description, quantity/classes, price, any “Exclusive” or promo tag.
  - **Promo code:** Optional text field and apply action.
  - **Payment method:**  
    - List of **saved cards** (e.g. “Mastercard - ****4321”, “Visa - ****4321”) with radio/checkmark for selection.  
    - Option “Manage Cards” (navigate to Saved Cards screen).  
  - **Payment summary:** Package amount, total due (e.g. “300 EGP”).
- **Primary button:** “Pay Now”.  
  - If a saved card is selected: create payment with `savedCardUuid`, get payment_key and card token, then start SDK with token (pay with saved card).  
  - If “new card” or no card selected: create payment without `savedCardUuid`, get payment_key, then start SDK without token (pay with new card, optional save).  
- After SDK returns, poll payment status and navigate to success or failure screen.

### 5.3 Success / failure screens

- **Success:** Order/transaction id, amount, “Payment successful” (or similar).  
- **Failure:** Message (e.g. from SDK or “Payment was declined or failed”), optional order id, “Back to checkout” or “Try again”.

---

## 6. Data models (suggested)

- **SavedCard** (for list): `id` (or `uuid`), `maskedPan`, `cardBrand` / `cardSubtype`, optional `lastFour`, optional `createdAt`, optional `expired`.  
- **CardDetailsForPayment** (for pay with saved card): extends or includes SavedCard fields plus **paymobToken**.  
- Map backend JSON keys (e.g. `masked_pan`, `card_subtype`, `paymob_token`) to these models.

---

## 7. Implementation order (suggested)

1. **Config and user identity**  
   - Base URL / API config.  
   - User id (e.g. UUID in SharedPreferences or from auth). Initialize before `runApp()` if needed.

2. **API layer**  
   - Create payment/session (returns payment_key and transaction/order id).  
   - Payment status (poll by transaction_id or order id).  
   - Saved cards: save (POST), list (GET), get-for-payment (GET by id), delete (DELETE).  
   - All with correct auth (e.g. Bearer or X-User-Id).

3. **Paymob SDK**  
   - Integrate native Accept SDK (no-token and token flows).  
   - Ensure iOS country and 3DS success handling match backend region (e.g. Egypt).

4. **Checkout / pay flow**  
   - Create session → open SDK (no-token or token).  
   - On “card saved” success, call save-card API.  
   - Poll payment status and navigate to success/failure.

5. **Saved Cards screen**  
   - List, empty state, delete with confirmation, “Pay with this card” (pass card id to checkout).

6. **Confirm Purchase screen**  
   - Package details, promo, payment method (saved cards + “Manage Cards”), Pay Now using selected card or new card.

7. **Navigation**  
   - Entry to Saved Cards from profile or “Manage Cards” on confirm screen.  
   - Checkout/confirm screen accepts optional selected card id/uuid for “pay with saved card”.

---

## 8. Error handling

- **401 on saved-cards APIs:** Invalid or missing auth; show “Please sign in” or “Session invalid”.  
- **404 on get/delete card:** “Card not found” (e.g. already deleted); refresh list.  
- **SDK errors:** Show SDK message or generic “Payment failed”; still poll backend status to confirm final state.  
- **Save card failure after payment success:** Log and optionally show “Card could not be saved”; do not block success screen.

---

## 9. Summary table (backend)

| Action | API | App use |
|--------|-----|--------|
| Create payment/session | POST transaction/session | Get payment_key + transaction/order id for SDK and polling. |
| Payment status | GET orders/{id}/payment-status | Poll after SDK; navigate success/failure. |
| Save card | POST saved-cards (or /users/me/cards) | After SDK “card saved” with token + masked_pan. |
| List saved cards | GET saved-cards | Saved Cards screen; also for payment method list on Confirm Purchase. |
| Get card for payment | GET saved-cards/{uuid} | When user pays with saved card; get paymob_token + masked_pan for SDK. |
| Delete saved card | DELETE saved-cards/{uuid} | On “Remove” with confirmation. |

Use this handover together with the project’s actual API base path and auth scheme. For the Paymob SDK, use the native Accept SDK via the **local plugin** as described in section 4.4 (copy `packages/paymob_flutter_lib` and add the path dependency) unless the project opts for a different integration.
