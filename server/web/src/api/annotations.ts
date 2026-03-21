import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiFetch } from "./client";

export interface Annotation {
  id: number;
  book_id: string;
  chapter: string;
  content: string;
  selected_text: string;
  cfi: string;
  page_number: number;
  color: string;
  type: string;
  ctime: number;
  utime: number;
}

export function useAnnotations(bookId: string | undefined) {
  return useQuery({
    queryKey: ["annotations", bookId],
    queryFn: () => apiFetch<{ data: Annotation[] }>(`/reader/books/${bookId}/annotations`),
    enabled: !!bookId,
  });
}

export function useDeleteAnnotation() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ bookId, annotationId }: { bookId: string; annotationId: number }) =>
      apiFetch(`/reader/books/${bookId}/annotations/${annotationId}`, { method: "DELETE" }),
    onSuccess: (_, vars) => {
      qc.invalidateQueries({ queryKey: ["annotations", vars.bookId] });
    },
  });
}
