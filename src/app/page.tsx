import { AuthScreen } from "@/components/auth-screen";
import { SemblWorkspace } from "@/components/sembl-workspace";
import { getRuntimeHomeData } from "@/lib/runtime-store";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function Home() {
  const supabase = await createSupabaseServerClient();
  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    return <AuthScreen />;
  }

  const data = await getRuntimeHomeData(user.id, undefined, user.email ?? null);

  return <SemblWorkspace initialData={data} />;
}
