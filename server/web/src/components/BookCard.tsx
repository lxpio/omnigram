import type { Book } from "@/types";
import { getCoverUrl } from "@/api/books";
import { Badge } from "@/components/ui/badge";
import { BookOpen } from "lucide-react";

interface BookCardProps {
  book: Book;
  onClick: (book: Book) => void;
}

export function BookCard({ book, onClick }: BookCardProps) {
  const coverUrl = getCoverUrl(book.cover_url);

  return (
    <button
      onClick={() => onClick(book)}
      className="group flex flex-col overflow-hidden rounded-xl border bg-card text-left shadow-sm transition-all hover:shadow-md hover:ring-1 hover:ring-primary/30 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
    >
      <div className="relative aspect-[2/3] w-full overflow-hidden bg-muted">
        {coverUrl ? (
          <img
            src={coverUrl}
            alt={book.title}
            className="h-full w-full object-cover transition-transform group-hover:scale-105"
            loading="lazy"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-gradient-to-br from-primary/10 to-primary/5">
            <BookOpen className="h-12 w-12 text-primary/30" />
          </div>
        )}
        {book.file_type && (
          <Badge variant="secondary" className="absolute right-2 top-2 text-[10px] uppercase">
            {book.file_type}
          </Badge>
        )}
      </div>
      <div className="flex flex-1 flex-col gap-1 p-3">
        <h3 className="line-clamp-2 text-sm font-semibold leading-tight">{book.title}</h3>
        <p className="line-clamp-1 text-xs text-muted-foreground">{book.author || "Unknown Author"}</p>
        {book.rating > 0 && (
          <div className="mt-auto flex items-center gap-1 pt-1">
            <div className="flex">
              {[1, 2, 3, 4, 5].map((star) => (
                <span
                  key={star}
                  className={`text-xs ${star <= book.rating ? "text-amber-500" : "text-muted-foreground/30"}`}
                >
                  ★
                </span>
              ))}
            </div>
          </div>
        )}
      </div>
    </button>
  );
}
