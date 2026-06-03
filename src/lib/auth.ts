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

  return {
    id: data.user.id,
    email: data.user.email ?? null,
    role: "viewer"
  };
}

export async function getProjectWorkspaceRole(
  userId: string,
  projectRef: string
): Promise<WorkspaceRole> {
  const { rows } = await query<{ role: WorkspaceRole }>(
    `
      select wm.role::text as role
      from public.projects p
      join public.workspace_members wm on wm.workspace_id = p.workspace_id
      where wm.user_id = $1::uuid
        and (
          p.id::text = $2
          or p.slug = $2
          or ($2 = 'project_sembl_core' and p.slug = 'sembl-core')
        )
      limit 1
    `,
    [userId, projectRef]
  );

  return rows[0]?.role ?? "viewer";
}

export async function requireProjectRole(
  userId: string,
  projectRef: string,
  allowedRoles: WorkspaceRole[]
) {
  const role = await getProjectWorkspaceRole(userId, projectRef);
  if (!allowedRoles.includes(role)) {
    throw new Error("forbidden");
  }
  return role;
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
