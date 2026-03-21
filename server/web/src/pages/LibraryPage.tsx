import { useState, useCallback, useRef } from "react";
import { useBooks, useUploadBook, useRecentBooks, useFavoriteBooks, useBatchDelete, useBatchTag } from "@/api/books";
import { SearchBar } from "@/components/SearchBar";
import { BookGrid } from "@/components/BookGrid";
import { BookList } from "@/components/BookList";
import { BookDetail } from "@/components/BookDetail";
import { Button } from "@/components/ui/button";
import { toast } from "@/components/ui/use-toast";
import { LayoutGrid, List, Upload, ChevronLeft, ChevronRight, Loader2, CheckSquare, X, Trash2 } from "lucide-react";
import { Input } from "@/components/ui/input";
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
  const batchDelete = useBatchDelete();
  const batchTag = useBatchTag();
  const [selectMode, setSelectMode] = useState(false);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [batchTagInput, setBatchTagInput] = useState("");

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

  const toggleSelect = (bookId: string) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(bookId)) next.delete(bookId);
      else next.add(bookId);
      return next;
    });
  };

  const handleBatchDelete = async () => {
    if (!selectedIds.size || !confirm(`Delete ${selectedIds.size} books?`)) return;
    try {
      const result = await batchDelete.mutateAsync({ book_ids: Array.from(selectedIds), delete_files: true });
      toast({ title: `Deleted ${result.data.deleted} books` });
      setSelectedIds(new Set());
      setSelectMode(false);
    } catch {
      toast({ title: "Batch delete failed", variant: "destructive" });
    }
  };

  const handleBatchTag = async () => {
    if (!selectedIds.size || !batchTagInput.trim()) return;
    const tags = batchTagInput.split(",").map((t) => t.trim()).filter(Boolean);
    try {
      await batchTag.mutateAsync({ book_ids: Array.from(selectedIds), tags, action: "add" });
      toast({ title: `Added tags to ${selectedIds.size} books` });
      setBatchTagInput("");
    } catch {
      toast({ title: "Batch tag failed", variant: "destructive" });
    }
  };

  const exitSelectMode = () => {
    setSelectMode(false);
    setSelectedIds(new Set());
  };

  const handleBookClick = useCallback((book: Book) => {
    if (selectMode) {
      toggleSelect(book.id);
    } else {
      setSelectedBook(book);
      setDetailOpen(true);
    }
  }, [selectMode]);

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
        {mode === "all" && !selectMode && <SearchBar value={search} onChange={(v) => { setSearch(v); setPage(1); }} />}
        {mode !== "all" && !selectMode && <h2 className="text-lg font-semibold capitalize">{mode}</h2>}

        {selectMode ? (
          <>
            <span className="text-sm font-medium">{selectedIds.size} selected</span>
            <div className="ml-auto flex items-center gap-2">
              <Input
                placeholder="Tags (comma separated)"
                value={batchTagInput}
                onChange={(e) => setBatchTagInput(e.target.value)}
                className="w-48"
                onKeyDown={(e) => e.key === "Enter" && handleBatchTag()}
              />
              <Button variant="outline" size="sm" onClick={handleBatchTag} disabled={!batchTagInput.trim() || batchTag.isPending}>
                Add Tags
              </Button>
              <Button variant="destructive" size="sm" onClick={handleBatchDelete} disabled={!selectedIds.size || batchDelete.isPending} className="gap-1">
                <Trash2 className="h-3.5 w-3.5" />
                Delete
              </Button>
              <Button variant="ghost" size="sm" onClick={exitSelectMode}>
                <X className="h-4 w-4" />
              </Button>
            </div>
          </>
        ) : (
          <div className="ml-auto flex items-center gap-1">
            {mode === "all" && (
              <Button variant="ghost" size="icon" onClick={() => setSelectMode(true)} title="Select mode">
                <CheckSquare className="h-4 w-4" />
              </Button>
            )}
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
        )}
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
