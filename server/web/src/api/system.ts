import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "./client";
import type { SystemInfo, ScanStatus, AccountsResponse } from "@/types";

export function useSystemInfo() {
  return useQuery({
    queryKey: ["systemInfo"],
    queryFn: () => apiFetch<SystemInfo>("/sys/info"),
  });
}

export function useScanStatus() {
  return useQuery({
    queryKey: ["scanStatus"],
    queryFn: () => apiFetch<ScanStatus>("/sys/scan/status"),
    refetchInterval: (query) =>
      query.state.data?.running ? 2000 : false,
  });
}

export function useRunScan() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () =>
      apiFetch("/sys/scan/run", { method: "POST" }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["scanStatus"] });
    },
  });
}

export function useStopScan() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: () =>
      apiFetch("/sys/scan/stop", { method: "POST" }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["scanStatus"] });
    },
  });
}

export function useAccounts() {
  return useQuery({
    queryKey: ["accounts"],
    queryFn: () => apiFetch<AccountsResponse>("/admin/accounts"),
  });
}

export function useCreateAccount() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { user_name: string; password: string; role_id?: number }) =>
      apiFetch("/admin/accounts", {
        method: "POST",
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["accounts"] });
    },
  });
}

export function useDeleteAccount() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (userId: number) =>
      apiFetch(`/admin/accounts/${userId}`, { method: "DELETE" }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["accounts"] });
    },
  });
}
