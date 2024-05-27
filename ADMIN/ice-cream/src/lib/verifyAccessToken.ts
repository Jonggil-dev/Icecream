import { NextRequest } from "next/server";
import { verifyJwt } from "@/lib/jwt";

export function verifyAccessToken(request: NextRequest) {
  const accessToken = request.headers.get("authorization");
  return accessToken && verifyJwt(accessToken);
}
