import { useState } from "react";
import { useTags, useDeleteTag } from "@/api/tags";
import { useSearchBooks } from "@/api/books";
import { BookGrid } from "@/components/BookGrid";
import { BookDetail } from "@/components/BookDetail";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { toast } from "@/components/ui/use-toast";
import { Tags, ArrowLeft, Search, Loader2, Trash2 } from "lucide-react";
import type { Book, TagInfo } from "@/types";

export function TagsPage() {
  const { data: tagsResp, isLoading } = useTags();
  const [selectedTag, setSelectedTag] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [detailBook, setDetailBook] = useState<Book | null>(null);
  const [detailOpen, setDetailOpen] = useState(false);

  const deleteTag = useDeleteTag();

  // When a tag is selected, search books by that tag
  const { data: booksResp, isLoading: booksLoading } = useSearchBooks({
    tag: selectedTag ?? undefined,
    page_size: 100,
  });

  const tags: TagInfo[] = tagsResp?.data ?? [];
  const filteredTags = search
    ? tags.filter((t) => t.tag.toLowerCase().includes(search.toLowerCase()))
    : tags;

  const handleDelete = async (tag: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (!confirm(`Delete tag "${tag}"? This will remove it from all books.`))
      return;
    try {
      await deleteTag.mutateAsync(tag);
      if (selectedTag === tag) setSelectedTag(null);
      toast({ title: `Tag "${tag}" deleted` });
    } catch {
      toast({ title: "Failed to delete tag", variant: "destructive" });
    }
  };

  const handleBookClick = (book: Book) => {
    setDetailBook(book);
    setDetailOpen(true);
  };

  // Tag detail view — show books with this tag
  if (selectedTag) {
    const books = booksResp?.data ?? [];

    return (
      <div className="flex flex-1 flex-col gap-6 p-4 lg:p-6">
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setSelectedTag(null)}
          >
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <Tags className="h-5 w-5 text-primary" />
          <h1 className="text-xl font-semibold">Tag: {selectedTag}</h1>
        </div>

        {booksLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : (
          <>
            <p className="text-sm text-muted-foreground">
              {books.length} books
            </p>
            <BookGrid books={books} onBookClick={handleBookClick} />
          </>
        )}

        <BookDetail
          book={detailBook}
          open={detailOpen}
          onClose={() => setDetailOpen(false)}
        />
      </div>
    );
  }

  // Tags list view
  return (
    <div className="flex flex-1 flex-col gap-6 p-4 lg:p-6">
      <div className="flex items-center gap-2">
        <Tags className="h-5 w-5 text-primary" />
        <h1 className="text-xl font-semibold">Tags</h1>
      </div>

      <div className="relative max-w-sm">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          placeholder="Search tags..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="pl-10"
        />
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      ) : filteredTags.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-muted-foreground">
          <Tags className="mb-3 h-12 w-12" />
          <p className="text-lg font-medium">
            {search ? "No matching tags" : "No tags yet"}
          </p>
          <p className="text-sm">Tags are added when editing book metadata.</p>
        </div>
      ) : (
        <div className="flex flex-wrap gap-2">
          {filteredTags.map((t) => (
            <div
              key={t.tag}
              className="group flex items-center gap-1 cursor-pointer"
              onClick={() => setSelectedTag(t.tag)}
            >
              <Badge
                variant="secondary"
                className="px-3 py-1.5 text-sm transition-colors hover:bg-primary hover:text-primary-foreground"
              >
                {t.tag}
                <span className="ml-1.5 text-xs opacity-60">{t.count}</span>
              </Badge>
              <Button
                variant="ghost"
                size="sm"
                className="h-6 w-6 p-0 opacity-0 group-hover:opacity-100 text-destructive hover:text-destructive"
                onClick={(e) => handleDelete(t.tag, e)}
              >
                <Trash2 className="h-3 w-3" />
              </Button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
