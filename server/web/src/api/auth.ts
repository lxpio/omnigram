import { useMutation, useQuery } from "@tanstack/react-query";
import { apiFetch } from "./client";
import type { LoginRequest, User } from "@/types";

interface ApiResponse {
  code: number;
  message: string;
}

export function useLogin() {
  return useMutation({
    mutationFn: (data: LoginRequest) =>
      apiFetch<ApiResponse>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ ...data, client_id: "web" }),
      }),
  });
}

export function useLogout() {
  return useMutation({
    mutationFn: () =>
      apiFetch("/auth/logout", { method: "POST" }),
    onSuccess: () => {
      window.location.href = "/login";
    },
  });
}

export function useUserInfo() {
  return useQuery({
    queryKey: ["userInfo"],
    queryFn: () => apiFetch<User>("/user/userinfo"),
    retry: false,
  });
}
