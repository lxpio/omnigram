import type { Book } from "@/types";
import { getCoverUrl } from "@/api/books";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { BookOpen } from "lucide-react";

interface BookListProps {
  books: Book[];
  onBookClick: (book: Book) => void;
}

function formatSize(bytes: number): string {
  if (!bytes) return "—";
  const units = ["B", "KB", "MB", "GB"];
  let i = 0;
  let size = bytes;
  while (size >= 1024 && i < units.length - 1) {
    size /= 1024;
    i++;
  }
  return `${size.toFixed(1)} ${units[i]}`;
}

export function BookList({ books, onBookClick }: BookListProps) {
  if (books.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-muted-foreground">
        <p className="text-lg font-medium">No books found</p>
        <p className="text-sm">Try adjusting your search or upload new books.</p>
      </div>
    );
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-12"></TableHead>
          <TableHead>Title</TableHead>
          <TableHead className="hidden md:table-cell">Author</TableHead>
          <TableHead className="hidden lg:table-cell">Format</TableHead>
          <TableHead className="hidden lg:table-cell">Size</TableHead>
          <TableHead className="hidden xl:table-cell">Rating</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {books.map((book) => {
          const coverUrl = getCoverUrl(book.cover_url);
          return (
            <TableRow
              key={book.id}
              className="cursor-pointer"
              onClick={() => onBookClick(book)}
            >
              <TableCell>
                <div className="h-10 w-7 overflow-hidden rounded bg-muted">
                  {coverUrl ? (
                    <img src={coverUrl} alt="" className="h-full w-full object-cover" loading="lazy" />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center">
                      <BookOpen className="h-3 w-3 text-muted-foreground" />
                    </div>
                  )}
                </div>
              </TableCell>
              <TableCell>
                <div>
                  <p className="font-medium">{book.title}</p>
                  <p className="text-xs text-muted-foreground md:hidden">{book.author}</p>
                </div>
              </TableCell>
              <TableCell className="hidden md:table-cell text-muted-foreground">{book.author || "—"}</TableCell>
              <TableCell className="hidden lg:table-cell">
                {book.file_type && (
                  <Badge variant="outline" className="text-[10px] uppercase">{book.file_type}</Badge>
                )}
              </TableCell>
              <TableCell className="hidden lg:table-cell text-muted-foreground">{formatSize(book.size)}</TableCell>
              <TableCell className="hidden xl:table-cell">
                {book.rating > 0 ? (
                  <span className="text-amber-500">{"★".repeat(Math.round(book.rating))}</span>
                ) : (
                  <span className="text-muted-foreground">—</span>
                )}
              </TableCell>
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}
