import { useQuery } from "@tanstack/react-query";
import { apiFetch } from "./client";

interface StatsOverview {
  total_books: number;
  total_reading_seconds: number;
  books_read: number;
}

interface DailyStat {
  date: string;
  duration: number;
  sessions: number;
}

interface BookStat {
  book_id: string;
  title: string;
  author: string;
  duration: number;
  sessions: number;
}

export function useStatsOverview() {
  return useQuery({
    queryKey: ["stats", "overview"],
    queryFn: () => apiFetch<{ data: StatsOverview }>("/reader/stats/overview"),
  });
}

export function useDailyStats(from?: string, to?: string) {
  const params = new URLSearchParams();
  if (from) params.set("from", from);
  if (to) params.set("to", to);
  return useQuery({
    queryKey: ["stats", "daily", from, to],
    queryFn: () => apiFetch<{ data: DailyStat[] }>(`/reader/stats/daily?${params.toString()}`),
  });
}

export function useBookStats(limit = 10) {
  return useQuery({
    queryKey: ["stats", "books", limit],
    queryFn: () => apiFetch<{ data: BookStat[] }>(`/reader/stats/books?limit=${limit}`),
  });
}
