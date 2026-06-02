import { createClient } from "@supabase/supabase-js";
import type { NextRequest } from "next/server";
import { query } from "./db";
import type { WorkspaceRole } from "./types";

export type RouteUser = {
  id: string;
  email: string | null;
  role: WorkspaceRole;
};

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey =
  process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ??
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

export async function requireRouteUser(request: NextRequest): Promise<RouteUser> {
  const authorization = request.headers.get("authorization");
  const token = authorization?.replace(/^Bearer\s+/i, "").trim();

  if (!supabaseUrl || !supabaseAnonKey || !token) {
    throw new Error("unauthorized");
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    auth: {
      persistSession: false
    }
  });
  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data.user) {
    throw new Error("unauthorized");
  }

  await ensureSeedWorkspaceMembership(data.user.id);
  const role = await getPrimaryWorkspaceRole(data.user.id);

  return {
    id: data.user.id,
    email: data.user.email ?? null,
    role
  };
}

export function requireAdmin(user: RouteUser) {
  if (user.role !== "owner" && user.role !== "admin") {
    throw new Error("forbidden");
  }
}

export async function ensureSeedWorkspaceMembership(userId: string) {
  await query(
    `
      insert into public.workspace_members (workspace_id, user_id, role)
      select w.id, $1::uuid, 'owner'::public.workspace_role
      from public.workspaces w
      where w.slug = 'speedvibe'
      on conflict (workspace_id, user_id) do nothing
    `,
    [userId]
  );
}

export async function getPrimaryWorkspaceRole(userId: string): Promise<WorkspaceRole> {
  const { rows } = await query<{ role: WorkspaceRole }>(
    `
      select role::text as role, joined_at
      from public.workspace_members
      where user_id = $1::uuid
      order by
        case role
          when 'owner' then 1
          when 'admin' then 2
          when 'member' then 3
          else 4
        end,
        joined_at
      limit 1
    `,
    [userId]
  );

  return rows[0]?.role ?? "viewer";
}
