"use client";

import { ArrowRight, KeyRound, Loader2, ShieldCheck } from "lucide-react";
import { useMemo, useState } from "react";
import { createSupabaseBrowserClient } from "@/lib/supabase/client";

type AuthState = {
  status: "idle" | "loading" | "success" | "error";
  message: string;
};

export function AuthScreen() {
  const supabase = useMemo(() => createSupabaseBrowserClient(), []);
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [state, setState] = useState<AuthState>({
    status: "idle",
    message: "Sign in to open the Sembl workspace."
  });

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setState({ status: "loading", message: "Contacting Supabase Auth..." });

    const credentials = {
      email: email.trim(),
      password
    };
    const response =
      mode === "signin"
        ? await supabase.auth.signInWithPassword(credentials)
        : await supabase.auth.signUp(credentials);

    if (response.error) {
      setState({ status: "error", message: response.error.message });
      return;
    }

    if (mode === "signup" && !response.data.session) {
      setState({
        status: "success",
        message: "Account created. Check your email if confirmation is enabled."
      });
      return;
    }

    setState({ status: "success", message: "Signed in. Opening workspace..." });
    window.location.assign("/");
  }

  return (
    <main className="auth-shell">
      <section className="auth-panel" aria-label="Sembl sign in">
        <div className="brand auth-brand">
          <div className="brand-mark">s</div>
          <div>
            <strong>sembl</strong>
            <span>graph-native engineering</span>
          </div>
        </div>

        <div className="auth-copy">
          <ShieldCheck size={24} />
          <h1>Open the canonical workspace</h1>
          <p>
            Sembl now requires Supabase Auth. Specs, graph versions, approvals,
            execution runs, and deployments are persisted before the UI marks them
            complete.
          </p>
        </div>

        <div className="auth-tabs" role="tablist" aria-label="Authentication mode">
          <button
            type="button"
            className={mode === "signin" ? "active" : undefined}
            onClick={() => setMode("signin")}
          >
            Sign in
          </button>
          <button
            type="button"
            className={mode === "signup" ? "active" : undefined}
            onClick={() => setMode("signup")}
          >
            Create account
          </button>
        </div>

        <form className="auth-form" onSubmit={submit}>
          <label className="field">
            <span>Email</span>
            <input
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              placeholder="you@example.com"
            />
          </label>
          <label className="field">
            <span>Password</span>
            <input
              type="password"
              autoComplete={mode === "signin" ? "current-password" : "new-password"}
              required
              minLength={8}
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              placeholder="At least 8 characters"
            />
          </label>
          <button
            className="primary-action auth-submit"
            type="submit"
            disabled={state.status === "loading"}
          >
            {state.status === "loading" ? <Loader2 size={16} /> : <KeyRound size={16} />}
            {mode === "signin" ? "Sign in" : "Create account"}
            <ArrowRight size={16} />
          </button>
        </form>

        <p className={`auth-message auth-message-${state.status}`}>{state.message}</p>
      </section>
    </main>
  );
}
