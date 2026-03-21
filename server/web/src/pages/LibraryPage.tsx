import { useState, useCallback, useRef } from "react";
import { useBooks, useUploadBook, useRecentBooks, useFavoriteBooks } from "@/api/books";
import { SearchBar } from "@/components/SearchBar";
import { BookGrid } from "@/components/BookGrid";
import { BookList } from "@/components/BookList";
import { BookDetail } from "@/components/BookDetail";
import { Button } from "@/components/ui/button";
import { toast } from "@/components/ui/use-toast";
import { LayoutGrid, List, Upload, ChevronLeft, ChevronRight, Loader2 } from "lucide-react";
import type { Book, BooksResponse } from "@/types";

interface LibraryPageProps {
  mode?: "all" | "recent" | "favorites";
  onUploadOpen?: boolean;
  onUploadClose?: () => void;
}

export function LibraryPage({ mode = "all", onUploadOpen, onUploadClose }: LibraryPageProps) {
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [view, setView] = useState<"grid" | "list">(() => {
    return (localStorage.getItem("bookView") as "grid" | "list") || "grid";
  });
  const [selectedBook, setSelectedBook] = useState<Book | null>(null);
  const [detailOpen, setDetailOpen] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);
  const uploadBook = useUploadBook();

  const pageSize = 24;

  const allBooksQuery = useBooks({ page, page_size: pageSize, q: search || undefined });
  const recentQuery = useRecentBooks();
  const favQuery = useFavoriteBooks();

  const activeQuery = mode === "recent" ? recentQuery : mode === "favorites" ? favQuery : allBooksQuery;
  const books = mode === "favorites"
    ? (favQuery.data ?? []) as Book[]
    : (activeQuery.data as BooksResponse | undefined)?.books ?? [];
  const total = mode === "favorites"
    ? (favQuery.data as Book[] | undefined)?.length ?? 0
    : (activeQuery.data as BooksResponse | undefined)?.total ?? 0;
  const totalPages = Math.ceil(total / pageSize);

  const toggleView = (v: "grid" | "list") => {
    setView(v);
    localStorage.setItem("bookView", v);
  };

  const handleBookClick = useCallback((book: Book) => {
    setSelectedBook(book);
    setDetailOpen(true);
  }, []);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files?.length) return;
    for (const file of Array.from(files)) {
      try {
        await uploadBook.mutateAsync(file);
        toast({ title: `Uploaded: ${file.name}` });
      } catch {
        toast({ title: `Failed to upload: ${file.name}`, variant: "destructive" });
      }
    }
    if (fileRef.current) fileRef.current.value = "";
    onUploadClose?.();
  };

  const handleDrop = useCallback(
    async (e: React.DragEvent) => {
      e.preventDefault();
      const files = Array.from(e.dataTransfer.files);
      for (const file of files) {
        try {
          await uploadBook.mutateAsync(file);
          toast({ title: `Uploaded: ${file.name}` });
        } catch {
          toast({ title: `Failed to upload: ${file.name}`, variant: "destructive" });
        }
      }
    },
    [uploadBook]
  );

  // Trigger file picker when upload is requested
  if (onUploadOpen && fileRef.current) {
    fileRef.current.click();
    onUploadClose?.();
  }

  return (
    <div
      className="flex flex-1 flex-col gap-4 p-4 lg:p-6"
      onDragOver={(e) => e.preventDefault()}
      onDrop={handleDrop}
    >
      <input ref={fileRef} type="file" className="hidden" multiple accept=".epub,.pdf,.mobi,.azw,.azw3,.fb2,.cbz,.cbr" onChange={handleFileUpload} />

      {/* Toolbar */}
      <div className="flex items-center gap-3">
        {mode === "all" && <SearchBar value={search} onChange={(v) => { setSearch(v); setPage(1); }} />}
        {mode !== "all" && <h2 className="text-lg font-semibold capitalize">{mode}</h2>}
        <div className="ml-auto flex items-center gap-1">
          <Button variant={view === "grid" ? "secondary" : "ghost"} size="icon" onClick={() => toggleView("grid")}>
            <LayoutGrid className="h-4 w-4" />
          </Button>
          <Button variant={view === "list" ? "secondary" : "ghost"} size="icon" onClick={() => toggleView("list")}>
            <List className="h-4 w-4" />
          </Button>
          <Button variant="outline" size="sm" className="ml-2 gap-2" onClick={() => fileRef.current?.click()}>
            {uploadBook.isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Upload className="h-4 w-4" />}
            <span className="hidden sm:inline">Upload</span>
          </Button>
        </div>
      </div>

      {/* Loading */}
      {activeQuery.isLoading && (
        <div className="flex flex-1 items-center justify-center">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      )}

      {/* Content */}
      {!activeQuery.isLoading && (
        <>
          {view === "grid" ? (
            <BookGrid books={books} onBookClick={handleBookClick} />
          ) : (
            <BookList books={books} onBookClick={handleBookClick} />
          )}
        </>
      )}

      {/* Pagination */}
      {mode === "all" && totalPages > 1 && (
        <div className="flex items-center justify-center gap-2 py-4">
          <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => setPage(page - 1)}>
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <span className="text-sm text-muted-foreground">
            Page {page} of {totalPages}
          </span>
          <Button variant="outline" size="sm" disabled={page >= totalPages} onClick={() => setPage(page + 1)}>
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      )}

      {/* Book Detail Sheet */}
      <BookDetail
        book={selectedBook}
        open={detailOpen}
        onClose={() => { setDetailOpen(false); setSelectedBook(null); }}
      />
    </div>
  );
}
