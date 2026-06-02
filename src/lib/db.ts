import { Pool, type PoolClient, type QueryResultRow } from "pg";

const rawConnectionString = process.env.SUPABASE_DB_URL ?? process.env.POSTGRES_URL;
const globalForPg = globalThis as typeof globalThis & { __semblPgPool?: Pool };

function normalizeConnectionString(value: string | undefined) {
  if (!value) {
    return null;
  }

  try {
    const url = new URL(value);
    url.searchParams.delete("sslmode");
    url.searchParams.delete("sslcert");
    url.searchParams.delete("sslkey");
    url.searchParams.delete("sslrootcert");
    return url.toString();
  } catch {
    return value.replace(/[?&]sslmode=[^&]+/i, "");
  }
}

const connectionString = normalizeConnectionString(rawConnectionString);

export function hasDatabaseConnection() {
  return Boolean(connectionString);
}

export function getPool() {
  if (!connectionString) {
    throw new Error("supabase_database_unavailable");
  }

  if (!globalForPg.__semblPgPool) {
    globalForPg.__semblPgPool = new Pool({
      connectionString,
      max: 4,
      ssl: { rejectUnauthorized: false }
    });
  }

  return globalForPg.__semblPgPool;
}

export async function query<T extends QueryResultRow>(
  sql: string,
  params: unknown[] = []
) {
  return getPool().query<T>(sql, params);
}

export async function withTransaction<T>(
  run: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await getPool().connect();

  try {
    await client.query("begin");
    const result = await run(client);
    await client.query("commit");
    return result;
  } catch (error) {
    await client.query("rollback");
    throw error;
  } finally {
    client.release();
  }
}

export function toIso(value: Date | string | null | undefined) {
  if (!value) {
    return null;
  }

  return value instanceof Date ? value.toISOString() : value;
}
