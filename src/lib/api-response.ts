import { NextResponse } from "next/server";

export function ok<T>(data: T, meta: Record<string, unknown> | null = null) {
  return NextResponse.json({ data, meta });
}

export function fail(
  code: string,
  message: string,
  status = 400,
  details: Record<string, unknown> | null = null
) {
  return NextResponse.json(
    {
      error: {
        code,
        message,
        details
      }
    },
    { status }
  );
}
