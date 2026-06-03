import { AuthScreen } from "@/components/auth-screen";
import { SemblWorkspace } from "@/components/sembl-workspace";
import { getRuntimeHomeData, getRuntimeProjectDirectory } from "@/lib/runtime-store";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

export default async function Home({
  searchParams
}: {
  searchParams?: Promise<{ project?: string }>;
}) {
  const supabase = await createSupabaseServerClient();
  const {
    data: { user }
  } = await supabase.auth.getUser();

  if (!user) {
    return <AuthScreen />;
  }

  const directory = await getRuntimeProjectDirectory(user.id);
  const params = await searchParams;
  const requestedProject = params?.project;
  const selectedProject =
    directory.projects.find(
      (project) => project.id === requestedProject || project.slug === requestedProject
    ) ?? directory.projects[0];
  const data = selectedProject
    ? await getRuntimeHomeData(user.id, selectedProject.id, user.email ?? null)
    : null;

  return <SemblWorkspace initialData={data} initialDirectory={directory} />;
}
