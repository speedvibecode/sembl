import { createClient } from "@supabase/supabase-js";
import type { NextRequest } from "next/server";

export type RouteUser = {
  id: string;
  role: "owner" | "admin" | "member" | "viewer";
  demoMode: boolean;
};

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

export async function requireRouteUser(request: NextRequest): Promise<RouteUser> {
  const authorization = request.headers.get("authorization");
  const token = authorization?.replace(/^Bearer\s+/i, "").trim();
  const strictAuth = process.env.SEMBL_STRICT_AUTH === "true";

  if (!supabaseUrl || !supabaseAnonKey || !token) {
    if (strictAuth) {
      throw new Error("unauthorized");
    }

    return {
      id: "demo-user",
      role: "owner",
      demoMode: true
    };
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
    role: "owner",
    demoMode: false
  };
}

export function requireAdmin(user: RouteUser) {
  if (user.role !== "owner" && user.role !== "admin") {
    throw new Error("forbidden");
  }
}
