/**
 * Bind API Client - TypeScript client for BIND Banco Industrial Argentina API.
 *
 * This module provides a simple interface to interact with BIND's
 * Open Banking API (sandbox and production).
 *
 * @example
 * ```typescript
 * import { BindClient, BindEnvironment } from './bind_client';
 *
 * const client = new BindClient({
 *   username: 'your_username',
 *   password: 'your_password',
 *   consumerKey: 'your_consumer_key'
 * });
 *
 * // Get accounts
 * const accounts = await client.getAccounts();
 *
 * // Make a transfer
 * const result = await client.transfer({
 *   fromAccountId: '...',
 *   toCbu: '0140000000000123456789',
 *   amount: 1000.00,
 *   description: 'Service payment'
 * });
 * ```
 */

// ==================== TYPES AND INTERFACES ====================

export enum BindEnvironment {
  SANDBOX = 'https://sandbox.bind.com.ar',
  PRODUCTION = 'https://api.bind.com.ar' // Requires approval
}

export interface BindConfig {
  username: string;
  password: string;
  consumerKey: string;
  environment?: BindEnvironment;
  timeout?: number;
}

export interface AccountRouting {
  scheme: 'CBU' | 'CVU' | 'ALIAS';
  address: string;
}

export interface MoneyValue {
  currency: string;
  amount: string;
}

export interface Account {
  id: string;
  label: string;
  bank_id: string;
  account_routings: AccountRouting[];
}

export interface AccountDetail extends Account {
  number: string;
  owners: Array<{
    id_owner: string;
    display_name: string;
  }>;
  product_code: string;
  balance: MoneyValue;
}

export interface Balance {
  type: 'AVAILABLE' | 'CURRENT';
  currency: string;
  amount: string;
}

export interface Transaction {
  id: string;
  this_account: {
    id: string;
    bank_id: string;
  };
  other_account: {
    holder: {
      name: string;
      is_alias?: boolean;
    };
    account_routings: AccountRouting[];
    bank_routing?: {
      scheme: string;
      address: string;
    };
  };
  details: {
    type: string;
    description: string;
    posted: string;
    completed: string;
    value: MoneyValue;
    new_balance?: MoneyValue;
  };
}

export interface TransferRequest {
  fromAccountId: string;
  toCbu: string;
  amount: number;
  description: string;
  currency?: string;
}

export interface TransferResponse {
  transaction_id: string;
  status: string;
  from: {
    bank_id: string;
    account_id: string;
  };
  to: {
    account_routing: AccountRouting;
  };
  value: MoneyValue;
  description: string;
  created_at: string;
  completed_at?: string;
}

export interface DebinRequest {
  accountId: string;
  fromCbu: string;
  amount: number;
  description: string;
  expiration: Date;
  currency?: string;
}

export interface Debin {
  debin_id: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED' | 'EXPIRED' | 'CANCELLED';
  from: {
    account_routing: AccountRouting;
  };
  to: {
    bank_id: string;
    account_id: string;
  };
  value: MoneyValue;
  description: string;
  expiration: string;
  created_at: string;
  approved_at?: string;
  transaction_id?: string;
}

export interface EcheqRequest {
  accountId: string;
  beneficiaryCuit: string;
  beneficiaryName: string;
  amount: number;
  paymentDate: Date;
  type?: 'COMUN' | 'DIFERIDO' | 'CERTIFICADO';
  concept?: string;
  currency?: string;
}

export interface Echeq {
  echeq_id: string;
  echeq_number: string;
  status: string;
  issuer: {
    cuit: string;
    name: string;
  };
  beneficiary: {
    cuit: string;
    name: string;
  };
  value: MoneyValue;
  issue_date: string;
  payment_date: string;
  type: string;
}

export interface CbuValidation {
  valid: boolean;
  scheme?: string;
  address?: string;
  holder?: {
    name: string;
    cuit: string;
    cuit_type: string;
  };
  bank?: {
    code: string;
    name: string;
  };
  account_type?: string;
  currency?: string;
  error?: string;
}

export interface Cvu {
  cvu: string;
  alias: string;
  holder_cuit: string;
  reference?: string;
  account_id: string;
  created_at: string;
  status: string;
}

export interface BindApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

// ==================== ERROR CLASS ====================

export class BindAPIError extends Error {
  public readonly statusCode: number;
  public readonly errorCode: string;
  public readonly details: Record<string, unknown>;

  constructor(
    statusCode: number,
    errorCode: string,
    message: string,
    details: Record<string, unknown> = {}
  ) {
    super(`[${errorCode}] ${message}`);
    this.name = 'BindAPIError';
    this.statusCode = statusCode;
    this.errorCode = errorCode;
    this.details = details;
  }
}

// ==================== MAIN CLIENT ====================

export class BindClient {
  private static readonly BANK_ID = 'bind.322.ar';
  private static readonly API_VERSION = 'v4.0.0';

  private readonly config: Required<BindConfig>;
  private token: string | null = null;
  private tokenExpiry: Date | null = null;

  constructor(config: BindConfig) {
    this.config = {
      username: config.username,
      password: config.password,
      consumerKey: config.consumerKey,
      environment: config.environment ?? BindEnvironment.SANDBOX,
      timeout: config.timeout ?? 30000
    };
  }

  // ==================== PRIVATE UTILITIES ====================

  private get baseUrl(): string {
    return this.config.environment;
  }

  private get isAuthenticated(): boolean {
    if (!this.token) return false;
    if (this.tokenExpiry && new Date() >= this.tokenExpiry) return false;
    return true;
  }

  private getHeaders(authenticated: boolean = true): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };

    if (authenticated && this.token) {
      headers['Authorization'] = `DirectLogin token="${this.token}"`;
    }

    return headers;
  }

  private async handleResponse<T>(response: Response): Promise<T> {
    if (!response.ok) {
      let errorData: BindApiError;

      try {
        const json = await response.json();
        errorData = json.error || { code: 'UNKNOWN_ERROR', message: response.statusText };
      } catch {
        errorData = { code: 'HTTP_ERROR', message: response.statusText };
      }

      throw new BindAPIError(
        response.status,
        errorData.code,
        errorData.message,
        errorData.details
      );
    }

    if (response.status === 204) {
      return {} as T;
    }

    return response.json();
  }

  private async request<T>(
    method: string,
    endpoint: string,
    options: {
      data?: Record<string, unknown>;
      params?: Record<string, string | number>;
      authenticated?: boolean;
    } = {}
  ): Promise<T> {
    const { data, params, authenticated = true } = options;

    if (authenticated && !this.isAuthenticated) {
      await this.authenticate();
    }

    let url = `${this.baseUrl}${endpoint}`;

    if (params) {
      const searchParams = new URLSearchParams();
      Object.entries(params).forEach(([key, value]) => {
        searchParams.append(key, String(value));
      });
      url += `?${searchParams.toString()}`;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);

    try {
      const response = await fetch(url, {
        method,
        headers: this.getHeaders(authenticated),
        body: data ? JSON.stringify(data) : undefined,
        signal: controller.signal
      });

      return this.handleResponse<T>(response);
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private detectScheme(address: string): 'CBU' | 'CVU' {
    return address.startsWith('000000') ? 'CVU' : 'CBU';
  }

  // ==================== AUTHENTICATION ====================

  /**
   * Authenticates with the API and obtains a token.
   * @returns Authentication token
   */
  async authenticate(): Promise<string> {
    const response = await this.request<{ token: string }>(
      'POST',
      '/api/auth/direct-login',
      {
        data: {
          username: this.config.username,
          password: this.config.password,
          consumer_key: this.config.consumerKey
        },
        authenticated: false
      }
    );

    this.token = response.token;
    // Assume 1 hour validity
    this.tokenExpiry = new Date(Date.now() + 60 * 60 * 1000);

    return this.token;
  }

  // ==================== ACCOUNTS ====================

  /**
   * Gets the user's account list.
   */
  async getAccounts(): Promise<Account[]> {
    const response = await this.request<{ accounts: Account[] }>(
      'GET',
      `/obp/${BindClient.API_VERSION}/my/accounts`
    );
    return response.accounts || [];
  }

  /**
   * Gets the detail of a specific account.
   */
  async getAccountDetail(accountId: string): Promise<AccountDetail> {
    return this.request<AccountDetail>(
      'GET',
      `/obp/${BindClient.API_VERSION}/my/banks/${BindClient.BANK_ID}/accounts/${accountId}/account`
    );
  }

  /**
   * Gets the balances of an account.
   */
  async getBalance(accountId: string): Promise<Balance[]> {
    const response = await this.request<{ balances: Balance[] }>(
      'GET',
      `/obp/${BindClient.API_VERSION}/my/banks/${BindClient.BANK_ID}/accounts/${accountId}/balances`
    );
    return response.balances || [];
  }

  // ==================== TRANSACTIONS ====================

  /**
   * Gets the transactions of an account.
   */
  async getTransactions(
    accountId: string,
    options: {
      fromDate?: Date;
      toDate?: Date;
      limit?: number;
      offset?: number;
    } = {}
  ): Promise<Transaction[]> {
    const params: Record<string, string | number> = {
      limit: options.limit ?? 50,
      offset: options.offset ?? 0
    };

    if (options.fromDate) {
      params.from_date = options.fromDate.toISOString();
    }
    if (options.toDate) {
      params.to_date = options.toDate.toISOString();
    }

    const response = await this.request<{ transactions: Transaction[] }>(
      'GET',
      `/obp/${BindClient.API_VERSION}/my/banks/${BindClient.BANK_ID}/accounts/${accountId}/transactions`,
      { params }
    );
    return response.transactions || [];
  }

  // ==================== TRANSFERS ====================

  /**
   * Makes a transfer to a CBU/CVU.
   */
  async transfer(request: TransferRequest): Promise<TransferResponse> {
    const scheme = this.detectScheme(request.toCbu);

    return this.request<TransferResponse>(
      'POST',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${request.fromAccountId}/transfer-to-account`,
      {
        data: {
          to: {
            account_routing: {
              scheme,
              address: request.toCbu
            }
          },
          value: {
            currency: request.currency ?? 'ARS',
            amount: request.amount.toFixed(2)
          },
          description: request.description,
          challenge_type: 'SANDBOX_TAN'
        }
      }
    );
  }

  // ==================== DEBIN ====================

  /**
   * Creates a DEBIN (immediate debit) request.
   */
  async createDebin(request: DebinRequest): Promise<Debin> {
    const scheme = this.detectScheme(request.fromCbu);

    return this.request<Debin>(
      'POST',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${request.accountId}/debin`,
      {
        data: {
          from: {
            account_routing: {
              scheme,
              address: request.fromCbu
            }
          },
          value: {
            currency: request.currency ?? 'ARS',
            amount: request.amount.toFixed(2)
          },
          description: request.description,
          expiration: request.expiration.toISOString(),
          recurrence: 'ONE_TIME'
        }
      }
    );
  }

  /**
   * Queries the status of a DEBIN.
   */
  async getDebinStatus(accountId: string, debinId: string): Promise<Debin> {
    return this.request<Debin>(
      'GET',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/debin/${debinId}`
    );
  }

  /**
   * Cancels a pending DEBIN.
   */
  async cancelDebin(accountId: string, debinId: string): Promise<void> {
    await this.request<void>(
      'DELETE',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/debin/${debinId}`
    );
  }

  // ==================== eCHEQS ====================

  /**
   * Issues an electronic check (eCheq).
   */
  async issueEcheq(request: EcheqRequest): Promise<Echeq> {
    return this.request<Echeq>(
      'POST',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${request.accountId}/echeq/issue`,
      {
        data: {
          beneficiary: {
            cuit: request.beneficiaryCuit,
            name: request.beneficiaryName
          },
          value: {
            currency: request.currency ?? 'ARS',
            amount: request.amount.toFixed(2)
          },
          payment_date: request.paymentDate.toISOString().split('T')[0],
          type: request.type ?? 'COMUN',
          concept: request.concept ?? ''
        }
      }
    );
  }

  /**
   * Deposits a received eCheq.
   */
  async depositEcheq(
    accountId: string,
    echeqId: string,
    endorsement: boolean = false
  ): Promise<Echeq> {
    return this.request<Echeq>(
      'POST',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/echeq/deposit`,
      {
        data: {
          echeq_id: echeqId,
          endorsement
        }
      }
    );
  }

  /**
   * Endorses an eCheq to another beneficiary.
   */
  async endorseEcheq(
    accountId: string,
    echeqId: string,
    newBeneficiaryCuit: string,
    newBeneficiaryName: string
  ): Promise<Echeq> {
    return this.request<Echeq>(
      'POST',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/echeq/${echeqId}/endorse`,
      {
        data: {
          new_beneficiary: {
            cuit: newBeneficiaryCuit,
            name: newBeneficiaryName
          }
        }
      }
    );
  }

  /**
   * Lists the account's eCheqs.
   */
  async getEcheqs(
    accountId: string,
    options: {
      status?: string;
      role?: 'ISSUER' | 'BENEFICIARY';
    } = {}
  ): Promise<Echeq[]> {
    const params: Record<string, string> = {};
    if (options.status) params.status = options.status;
    if (options.role) params.role = options.role;

    const response = await this.request<{ echeqs: Echeq[] }>(
      'GET',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/echeq`,
      { params }
    );
    return response.echeqs || [];
  }

  // ==================== VALIDATION ====================

  /**
   * Validates a CBU or CVU and gets holder information.
   */
  async validateCbuCvu(address: string): Promise<CbuValidation> {
    const scheme = this.detectScheme(address);

    return this.request<CbuValidation>(
      'GET',
      `/obp/${BindClient.API_VERSION}/banks/validate-account-routing`,
      {
        params: { scheme, address }
      }
    );
  }

  // ==================== CVU ====================

  /**
   * Creates a new CVU associated with the account.
   */
  async createCvu(
    accountId: string,
    alias: string,
    holderCuit: string,
    reference?: string
  ): Promise<Cvu> {
    const data: Record<string, string> = {
      alias,
      holder_cuit: holderCuit
    };
    if (reference) data.reference = reference;

    return this.request<Cvu>(
      'POST',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/cvu`,
      { data }
    );
  }

  /**
   * Lists the CVUs of an account.
   */
  async getCvus(accountId: string): Promise<Cvu[]> {
    const response = await this.request<{ cvus: Cvu[] }>(
      'GET',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/cvu`
    );
    return response.cvus || [];
  }

  /**
   * Deactivates a CVU.
   */
  async deactivateCvu(accountId: string, cvu: string): Promise<void> {
    await this.request<void>(
      'DELETE',
      `/obp/${BindClient.API_VERSION}/banks/${BindClient.BANK_ID}/accounts/${accountId}/cvu/${cvu}`
    );
  }
}

// ==================== USAGE EXAMPLE ====================

/**
 * Usage example
 */
async function main() {
  // Initialize client (use sandbox credentials)
  const client = new BindClient({
    username: 'sandbox_user',
    password: 'sandbox_password',
    consumerKey: 'sandbox_consumer_key',
    environment: BindEnvironment.SANDBOX
  });

  try {
    // Authenticate
    console.log('Authenticating...');
    const token = await client.authenticate();
    console.log(`Token obtained: ${token.substring(0, 20)}...`);

    // Get accounts
    console.log('\nGetting accounts...');
    const accounts = await client.getAccounts();
    for (const acc of accounts) {
      console.log(`  - ${acc.label}: ${acc.id}`);
    }

    if (accounts.length > 0) {
      const accountId = accounts[0].id;

      // Get detail
      console.log(`\nAccount detail ${accountId}:`);
      const detail = await client.getAccountDetail(accountId);
      console.log(`  Balance: ${detail.balance.currency} ${detail.balance.amount}`);

      // Get transactions
      console.log('\nRecent transactions:');
      const transactions = await client.getTransactions(accountId, { limit: 5 });
      for (const txn of transactions) {
        console.log(`  - ${txn.details.posted}: ${txn.details.value.amount} - ${txn.details.description}`);
      }

      // Validate CBU
      console.log('\nValidating CBU...');
      const validation = await client.validateCbuCvu('0140000000000123456789');
      if (validation.valid) {
        console.log(`  Holder: ${validation.holder?.name}`);
        console.log(`  Bank: ${validation.bank?.name}`);
      } else {
        console.log(`  Invalid CBU: ${validation.error}`);
      }
    }
  } catch (error) {
    if (error instanceof BindAPIError) {
      console.error(`\nAPI Error: ${error.message}`);
      console.error(`  Code: ${error.errorCode}`);
      console.error(`  Status: ${error.statusCode}`);
      if (Object.keys(error.details).length > 0) {
        console.error(`  Details:`, error.details);
      }
    } else {
      console.error(`\nError: ${error}`);
    }
  }
}

// Run if main module
// main();

export default BindClient;
