import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "./client";
import type { Shelf, Book } from "@/types";

export function useShelves() {
  return useQuery({
    queryKey: ["shelves"],
    queryFn: () => apiFetch<{ data: Shelf[] }>("/reader/shelves"),
  });
}

export function useShelf(shelfId: number | null) {
  return useQuery({
    queryKey: ["shelf", shelfId],
    queryFn: () =>
      apiFetch<{ data: { shelf: Shelf; books: Book[] } }>(
        `/reader/shelves/${shelfId}`
      ),
    enabled: !!shelfId,
  });
}

export function useCreateShelf() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { name: string; description?: string }) =>
      apiFetch<{ data: Shelf }>("/reader/shelves", {
        method: "POST",
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["shelves"] });
    },
  });
}

export function useUpdateShelf() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      ...data
    }: { id: number; name?: string; description?: string }) =>
      apiFetch<{ data: Shelf }>(`/reader/shelves/${id}`, {
        method: "PUT",
        body: JSON.stringify(data),
      }),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["shelves"] });
      qc.invalidateQueries({ queryKey: ["shelf", vars.id] });
    },
  });
}

export function useDeleteShelf() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (id: number) =>
      apiFetch(`/reader/shelves/${id}`, { method: "DELETE" }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["shelves"] });
    },
  });
}

export function useAddBooksToShelf() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      shelfId,
      bookIds,
    }: {
      shelfId: number;
      bookIds: string[];
    }) =>
      apiFetch(`/reader/shelves/${shelfId}/books`, {
        method: "POST",
        body: JSON.stringify({ book_ids: bookIds }),
      }),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["shelves"] });
      qc.invalidateQueries({ queryKey: ["shelf", vars.shelfId] });
    },
  });
}

export function useRemoveBooksFromShelf() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      shelfId,
      bookIds,
    }: {
      shelfId: number;
      bookIds: string[];
    }) =>
      apiFetch(`/reader/shelves/${shelfId}/books`, {
        method: "DELETE",
        body: JSON.stringify({ book_ids: bookIds }),
      }),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["shelves"] });
      qc.invalidateQueries({ queryKey: ["shelf", vars.shelfId] });
    },
  });
}
