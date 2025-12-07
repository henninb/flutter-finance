# API Reference - Finance Backend

**Base URL:** `https://finance.bhenning.com/api`

## Authentication

### JWT Token Authentication
The API uses JWT tokens for authentication. Tokens can be sent via:
1. **Cookie**: `token=<jwt_token>` (HttpOnly, Secure in production)
2. **Authorization Header**: `Authorization: Bearer <jwt_token>`

Token expiration: 1 hour

---

## Authentication Endpoints

### POST /api/login
Authenticate user and receive JWT cookie/token.

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:** 200 OK
```json
{
  "message": "Login successful"
}
```
Sets HTTP-only cookie: `token=<jwt_token>`

### POST /api/logout
Invalidate JWT and clear cookie.

**Response:** 204 No Content

### POST /api/register
Register new user and auto-login.

**Request:**
```json
{
  "username": "string",
  "password": "string",
  "email": "string"
}
```

**Response:** 201 Created
```json
{
  "message": "Registration successful"
}
```

### GET /api/me
Get current authenticated user info.

**Response:** 200 OK
```json
{
  "username": "string",
  "email": "string"
}
```

---

## Account Endpoints

### GET /api/account/active
Get all active accounts.

**Response:** 200 OK
```json
[
  {
    "accountId": 1,
    "accountNameOwner": "chase_brian",
    "accountType": "credit",
    "moniker": "1234",
    "cleared": 1500.00,
    "outstanding": 250.00,
    "future": 100.00,
    "activeStatus": true,
    "validationDate": "2025-12-06T10:30:00Z"
  }
]
```

### GET /api/account/{accountNameOwner}
Get specific account by name.

**Response:** 200 OK (same as above, single object)

### POST /api/account
Create new account.

**Request:**
```json
{
  "accountNameOwner": "chase_brian",
  "accountType": "credit",
  "moniker": "1234",
  "activeStatus": true
}
```

**Response:** 201 Created (returns created account)

### PUT /api/account/{accountNameOwner}
Update existing account.

**Request:** Same as POST

**Response:** 200 OK (returns updated account)

### DELETE /api/account/{accountNameOwner}
Delete account.

**Response:** 200 OK (returns deleted account)

### GET /api/account/totals
Get totals across all accounts.

**Response:** 200 OK
```json
{
  "totals": "1850.00",
  "totalsCleared": "1500.00",
  "totalsOutstanding": "250.00",
  "totalsFuture": "100.00"
}
```

### GET /api/account/payment/required
Get accounts that require payment.

**Response:** 200 OK (array of accounts)

### PUT /api/account/rename?old={old}&new={new}
Rename an account.

**Response:** 200 OK (returns renamed account)

### PUT /api/account/activate/{accountNameOwner}
Activate an account.

**Response:** 200 OK (returns activated account)

### PUT /api/account/deactivate/{accountNameOwner}
Deactivate an account.

**Response:** 200 OK (returns deactivated account)

---

## Transaction Endpoints

### GET /api/transaction/account/select/{accountNameOwner}
Get all transactions for an account.

**Response:** 200 OK
```json
[
  {
    "transactionId": 123,
    "guid": "550e8400-e29b-41d4-a716-446655440000",
    "accountId": 1,
    "accountNameOwner": "chase_brian",
    "accountType": "credit",
    "transactionDate": "2025-12-01",
    "description": "amazon",
    "category": "shopping",
    "amount": 49.99,
    "transactionState": "cleared",
    "transactionType": "expense",
    "reoccurringType": "onetime",
    "activeStatus": true,
    "notes": "Christmas gift"
  }
]
```

### GET /api/transaction/{guid}
Get transaction by GUID.

**Response:** 200 OK (single transaction object)

### POST /api/transaction
Create new transaction.

**Request:**
```json
{
  "guid": "550e8400-e29b-41d4-a716-446655440000",
  "accountNameOwner": "chase_brian",
  "transactionDate": "2025-12-06",
  "description": "amazon",
  "category": "shopping",
  "amount": 49.99,
  "transactionState": "outstanding",
  "transactionType": "expense",
  "reoccurringType": "onetime",
  "notes": ""
}
```

**Response:** 201 Created (returns created transaction)

**Note:** The frontend should generate the GUID by calling `/api/uuid/generate` first.

### PUT /api/transaction/{guid}
Update transaction.

**Request:** Same as POST

**Response:** 200 OK (returns updated transaction)

### DELETE /api/transaction/{guid}
Delete transaction.

**Response:** 200 OK (returns deleted transaction)

### GET /api/transaction/account/totals/{accountNameOwner}
Get totals for an account.

**Response:** 200 OK
```json
{
  "totals": 1850.00,
  "totalsCleared": 1500.00,
  "totalsOutstanding": 250.00,
  "totalsFuture": 100.00
}
```

### PUT /api/transaction/state/update/{guid}/{transactionStateValue}
Update transaction state (cleared, outstanding, future).

**Response:** 200 OK (returns updated transaction)

### POST /api/transaction/future
Create future-dated transaction.

**Request:** (same as regular transaction)

**Response:** 201 Created

### PUT /api/transaction/update/account
Move transaction to different account.

**Request:**
```json
{
  "guid": "550e8400-e29b-41d4-a716-446655440000",
  "accountNameOwner": "new_account_name"
}
```

**Response:** 200 OK

### GET /api/transaction/category/{category_name}
Get transactions by category.

**Response:** 200 OK (array of transactions)

### GET /api/transaction/description/{description_name}
Get transactions by description.

**Response:** 200 OK (array of transactions)

### GET /api/transaction/date-range?startDate={date}&endDate={date}&page={n}&size={n}
Get transactions by date range (paginated).

**Query Parameters:**
- `startDate`: yyyy-MM-dd
- `endDate`: yyyy-MM-dd
- `page`: page number (default: 0)
- `size`: page size (default: 20)

**Response:** 200 OK (Spring Data Page object with transactions)

---

## Category Endpoints

### GET /api/category/active
Get all active categories.

**Response:** 200 OK
```json
[
  {
    "categoryId": 1,
    "categoryName": "shopping",
    "activeStatus": true
  }
]
```

### GET /api/category/{categoryName}
Get category by name.

**Response:** 200 OK (single category object)

### POST /api/category
Create category.

**Request:**
```json
{
  "categoryName": "shopping",
  "activeStatus": true
}
```

**Response:** 201 Created

### PUT /api/category/{categoryName}
Update category.

**Response:** 200 OK

### DELETE /api/category/{categoryName}
Delete category.

**Response:** 200 OK

### POST /api/category/merge
Merge multiple categories into one.

**Request:**
```json
{
  "sourceNames": ["shopping", "online_shopping"],
  "targetName": "shopping"
}
```

**Response:** 200 OK

---

## Description Endpoints

### GET /api/description/active
Get all active descriptions.

**Response:** 200 OK
```json
[
  {
    "descriptionId": 1,
    "descriptionName": "amazon",
    "activeStatus": true
  }
]
```

### GET /api/description/{descriptionName}
Get description by name.

**Response:** 200 OK

### POST /api/description
Create description.

**Request:**
```json
{
  "descriptionName": "amazon",
  "activeStatus": true
}
```

**Response:** 201 Created

### PUT /api/description/{descriptionName}
Update description.

**Response:** 200 OK

### DELETE /api/description/{descriptionName}
Delete description.

**Response:** 200 OK

### POST /api/description/merge
Merge multiple descriptions.

**Request:**
```json
{
  "sourceNames": ["amazon", "amazon_com"],
  "targetName": "amazon"
}
```

**Response:** 200 OK

---

## Validation Amount Endpoints

### GET /api/validation_amount/account/{accountNameOwner}
Get latest validation amount for an account.

**Response:** 200 OK
```json
{
  "validationId": 1,
  "accountId": 1,
  "amount": 1500.00,
  "transactionState": "cleared",
  "validationDate": "2025-12-06T10:30:00Z",
  "activeStatus": true
}
```

### POST /api/validation_amount
Create validation amount entry.

**Request:**
```json
{
  "accountId": 1,
  "amount": 1500.00,
  "transactionState": "cleared",
  "activeStatus": true
}
```

**Response:** 201 Created

---

## UUID Generation

### POST /api/uuid/generate
Generate a secure UUID for transactions.

**Response:** 200 OK
```json
{
  "uuid": "550e8400-e29b-41d4-a716-446655440000"
}
```

---

## Data Models

### Account
```typescript
{
  accountId: number;           // Read-only
  accountNameOwner: string;    // 3-40 chars, lowercase, alphanumeric + underscore
  accountType: 'credit' | 'debit';
  moniker: string;             // 4 digits
  cleared: number;             // Decimal(8,2)
  outstanding: number;         // Decimal(8,2)
  future: number;              // Decimal(8,2)
  activeStatus: boolean;
  validationDate: string;      // ISO 8601 datetime
}
```

### Transaction
```typescript
{
  transactionId: number;       // Read-only
  guid: string;                // UUID
  accountId: number;
  accountNameOwner: string;
  accountType: 'credit' | 'debit';
  transactionDate: string;     // yyyy-MM-dd
  description: string;         // 1-75 chars
  category: string;            // Max 50 chars
  amount: number;              // Decimal(8,2)
  transactionState: 'cleared' | 'outstanding' | 'future';
  transactionType: 'expense' | 'income' | 'transfer' | 'undefined';
  reoccurringType: 'onetime' | 'weekly' | 'fortnightly' | 'monthly' | 'quarterly' | 'bi_annually' | 'annually';
  activeStatus: boolean;
  notes: string;               // Max 100 chars
  receiptImage?: ReceiptImage; // Optional
}
```

### Category
```typescript
{
  categoryId: number;          // Read-only
  categoryName: string;        // Alphanumeric + underscore + space, max 255
  activeStatus: boolean;
}
```

### Description
```typescript
{
  descriptionId: number;       // Read-only
  descriptionName: string;     // Alphanumeric + underscore + space, max 255
  activeStatus: boolean;
}
```

### ValidationAmount
```typescript
{
  validationId: number;        // Read-only
  accountId: number;
  amount: number;              // Decimal(8,2)
  transactionState: 'cleared' | 'outstanding' | 'future';
  validationDate: string;      // ISO 8601 datetime
  activeStatus: boolean;
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "Validation error message"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid or expired token"
}
```

### 404 Not Found
```json
{
  "error": "Resource not found"
}
```

### 409 Conflict
```json
{
  "error": "Duplicate resource or constraint violation"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```

---

## Notes

1. **Authentication**: All endpoints except `/login`, `/register`, and `/me` require authentication via JWT token.
2. **Content-Type**: All POST/PUT requests must send `Content-Type: application/json`
3. **CORS**: The API has CORS enabled with `@CrossOrigin` annotations
4. **Validation**: The API performs server-side validation with detailed error messages
5. **Transaction States**:
   - `cleared`: Transaction has cleared the bank
   - `outstanding`: Transaction pending/not yet cleared
   - `future`: Scheduled future transaction
6. **Account Types**:
   - `credit`: Credit card or credit account
   - `debit`: Bank account or debit account
