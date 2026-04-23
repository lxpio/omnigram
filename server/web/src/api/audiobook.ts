import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "./client";

/** Status codes from schema/audiobook.go:TaskStatus */
export const TASK_STATUS_LABELS: Record<number, string> = {
  0: "Pending",
  1: "Running",
  2: "Completed",
  3: "Failed",
  4: "Paused",
  5: "Cancelled",
};

export interface AudiobookQueueItem {
  task_id: string;
  book_id: string;
  book_title: string;
  author: string;
  voice: string;
  status: number;
  total_chapters: number;
  done_chapters: number;
  failed_chapters: number;
  progress_pct: number;
  ctime: number;
  utime: number;
  error_message?: string;
}

export interface AudiobookQueueResponse {
  items: AudiobookQueueItem[];
}

export interface BatchAudiobookRequest {
  book_ids: string[];
  voice?: string;
  speed?: number;
}

export interface BatchAudiobookItem {
  book_id: string;
  task_id?: string;
  status: "queued" | "exists" | "error";
  error?: string;
}

export interface BatchAudiobookResponse {
  submitted: number;
  items: BatchAudiobookItem[];
}

/** Admin queue monitor — polls while any task is running. */
export function useAudiobookQueue() {
  return useQuery({
    queryKey: ["audiobookQueue"],
    queryFn: () => apiFetch<AudiobookQueueResponse>("/tts/audiobook/queue"),
    refetchInterval: (query) => {
      const anyRunning = query.state.data?.items?.some((i) => i.status === 1);
      return anyRunning ? 3000 : false;
    },
  });
}

/** Submit a multi-book audiobook generation batch (admin only). */
export function useBatchAudiobook() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: (req: BatchAudiobookRequest) =>
      apiFetch<BatchAudiobookResponse>("/tts/audiobook/batch", {
        method: "POST",
        body: JSON.stringify(req),
      }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["audiobookQueue"] });
    },
  });
}
