import type { Book } from "@/types";
import { BookCard } from "./BookCard";

interface BookGridProps {
  books: Book[];
  onBookClick: (book: Book) => void;
}

export function BookGrid({ books, onBookClick }: BookGridProps) {
  if (books.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-muted-foreground">
        <p className="text-lg font-medium">No books found</p>
        <p className="text-sm">Try adjusting your search or upload new books.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6">
      {books.map((book) => (
        <BookCard key={book.id} book={book} onClick={onBookClick} />
      ))}
    </div>
  );
}
