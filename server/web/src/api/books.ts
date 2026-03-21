import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "./client";
import type { Book, BooksResponse } from "@/types";

interface BooksParams {
  page?: number;
  page_size?: number;
  q?: string;
  sort?: string;
}

export function useBooks(params: BooksParams = {}) {
  const { page = 1, page_size = 20, q, sort } = params;
  const searchParams = new URLSearchParams();
  searchParams.set("page", String(page));
  searchParams.set("page_size", String(page_size));
  if (q) searchParams.set("q", q);
  if (sort) searchParams.set("sort", sort);

  return useQuery({
    queryKey: ["books", { page, page_size, q, sort }],
    queryFn: () =>
      apiFetch<BooksResponse>(
        `/reader/books?${searchParams.toString()}`
      ),
  });
}

export function useRecentBooks() {
  return useQuery({
    queryKey: ["books", "recent"],
    queryFn: () => apiFetch<BooksResponse>("/reader/recent"),
  });
}

export function useFavoriteBooks() {
  return useQuery({
    queryKey: ["books", "favorites"],
    queryFn: () => apiFetch<Book[]>("/reader/fav"),
  });
}

export function useBook(bookId: string) {
  return useQuery({
    queryKey: ["book", bookId],
    queryFn: () => apiFetch<Book>(`/reader/books/${bookId}`),
    enabled: !!bookId,
  });
}

export function useUpdateBook() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Book> & { id: string }) =>
      apiFetch<Book>(`/reader/books/${id}`, {
        method: "PUT",
        body: JSON.stringify(data),
      }),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["books"] });
      qc.invalidateQueries({ queryKey: ["book", vars.id] });
    },
  });
}

export function useDeleteBook() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({
      id,
      deleteFile = false,
    }: {
      id: string;
      deleteFile?: boolean;
    }) =>
      apiFetch(`/reader/books/${id}?delete_file=${deleteFile}`, {
        method: "DELETE",
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["books"] });
    },
  });
}

export function useUploadBook() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (file: File) => {
      const form = new FormData();
      form.append("file", file);
      return apiFetch<Book>("/reader/upload", {
        method: "POST",
        body: form,
      });
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["books"] });
    },
  });
}

export function useUploadCover() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, file }: { id: string; file: File }) => {
      const form = new FormData();
      form.append("cover", file);
      return apiFetch(`/reader/books/${id}/cover`, {
        method: "PUT",
        body: form,
      });
    },
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["books"] });
      qc.invalidateQueries({ queryKey: ["book", vars.id] });
    },
  });
}

export function useBookStats() {
  return useQuery({
    queryKey: ["bookStats"],
    queryFn: () => apiFetch<Record<string, number>>("/reader/stats"),
  });
}

interface SearchParams {
  q?: string;
  tag?: string;
  author?: string;
  format?: string;
  language?: string;
  sort?: string;
  order?: string;
  page?: number;
  page_size?: number;
}

export function useSearchBooks(params: SearchParams) {
  const sp = new URLSearchParams();
  if (params.q) sp.set("q", params.q);
  if (params.tag) sp.set("tag", params.tag);
  if (params.author) sp.set("author", params.author);
  if (params.format) sp.set("format", params.format);
  if (params.language) sp.set("language", params.language);
  if (params.sort) sp.set("sort", params.sort);
  if (params.order) sp.set("order", params.order);
  sp.set("page", String(params.page ?? 1));
  sp.set("page_size", String(params.page_size ?? 50));

  return useQuery({
    queryKey: ["search", params],
    queryFn: () =>
      apiFetch<{ data: Book[]; total: number }>(
        `/reader/search?${sp.toString()}`
      ),
    enabled: !!(params.q || params.tag || params.author || params.format),
  });
}

export function useBatchDelete() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { book_ids: string[]; delete_files?: boolean }) =>
      apiFetch<{ data: { deleted: number } }>("/reader/books/batch/delete", {
        method: "POST",
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["books"] });
    },
  });
}

export function useBatchTag() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { book_ids: string[]; tags: string[]; action: "add" | "remove" | "set" }) =>
      apiFetch<{ data: { updated: number } }>("/reader/books/batch/tag", {
        method: "POST",
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["books"] });
      qc.invalidateQueries({ queryKey: ["tags"] });
    },
  });
}

export function useBatchShelf() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (data: { book_ids: string[]; shelf_id: number; action: "add" | "remove" }) =>
      apiFetch<{ data: { updated: number } }>("/reader/books/batch/shelf", {
        method: "POST",
        body: JSON.stringify(data),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["books"] });
      qc.invalidateQueries({ queryKey: ["shelves"] });
    },
  });
}

export function getCoverUrl(coverUrl: string): string {
  if (!coverUrl) return "";
  return `/img/covers/${coverUrl}`;
}
