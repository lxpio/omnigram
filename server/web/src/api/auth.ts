import { useMutation, useQuery } from "@tanstack/react-query";
import { apiFetch, setToken, removeToken } from "./client";
import type { LoginRequest, LoginResponse, User } from "@/types";

export function useLogin() {
  return useMutation({
    mutationFn: (data: LoginRequest) =>
      apiFetch<LoginResponse>("/auth/login", {
        method: "POST",
        body: JSON.stringify({ ...data, client_id: "web" }),
      }),
    onSuccess: (data) => {
      setToken(data.access_token);
    },
  });
}

export function useLogout() {
  return useMutation({
    mutationFn: () =>
      apiFetch("/auth/logout", { method: "POST" }),
    onSuccess: () => {
      removeToken();
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
