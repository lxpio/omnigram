import { useParams } from "react-router-dom";
import { useBook } from "@/api/books";
import { BookDetail } from "@/components/BookDetail";
import { Loader2 } from "lucide-react";

export function BookPage() {
  const { bookId } = useParams<{ bookId: string }>();
  const { data: book, isLoading } = useBook(bookId || "");

  if (isLoading) {
    return (
      <div className="flex flex-1 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <BookDetail
      book={book ?? null}
      open={!!book}
      onClose={() => window.history.back()}
    />
  );
}
