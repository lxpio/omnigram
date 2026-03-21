import { useState } from "react";
import {
  useShelves,
  useShelf,
  useCreateShelf,
  useUpdateShelf,
  useDeleteShelf,
  useRemoveBooksFromShelf,
} from "@/api/shelves";
import { BookGrid } from "@/components/BookGrid";
import { BookDetail } from "@/components/BookDetail";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "@/components/ui/use-toast";
import {
  BookMarked,
  Plus,
  Pencil,
  Trash2,
  ArrowLeft,
  Loader2,
  Library,
} from "lucide-react";
import type { Book, Shelf } from "@/types";

export function ShelvesPage() {
  const { data: shelvesResp, isLoading } = useShelves();
  const [selectedShelfId, setSelectedShelfId] = useState<number | null>(null);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editShelf, setEditShelf] = useState<Shelf | null>(null);
  const [formName, setFormName] = useState("");
  const [formDesc, setFormDesc] = useState("");
  const [detailBook, setDetailBook] = useState<Book | null>(null);
  const [detailOpen, setDetailOpen] = useState(false);

  const { data: shelfDetail, isLoading: shelfLoading } =
    useShelf(selectedShelfId);
  const createShelf = useCreateShelf();
  const updateShelf = useUpdateShelf();
  const deleteShelf = useDeleteShelf();
  const removeBooks = useRemoveBooksFromShelf();

  const shelves: Shelf[] = shelvesResp?.data ?? [];

  const openCreate = () => {
    setEditShelf(null);
    setFormName("");
    setFormDesc("");
    setDialogOpen(true);
  };

  const openEdit = (shelf: Shelf) => {
    setEditShelf(shelf);
    setFormName(shelf.name);
    setFormDesc(shelf.description || "");
    setDialogOpen(true);
  };

  const handleSubmit = async () => {
    if (!formName.trim()) return;
    try {
      if (editShelf) {
        await updateShelf.mutateAsync({
          id: editShelf.id,
          name: formName,
          description: formDesc,
        });
        toast({ title: "Shelf updated" });
      } else {
        await createShelf.mutateAsync({
          name: formName,
          description: formDesc,
        });
        toast({ title: "Shelf created" });
      }
      setDialogOpen(false);
    } catch {
      toast({ title: "Failed to save shelf", variant: "destructive" });
    }
  };

  const handleDelete = async (shelf: Shelf) => {
    if (!confirm(`Delete shelf "${shelf.name}"?`)) return;
    try {
      await deleteShelf.mutateAsync(shelf.id);
      if (selectedShelfId === shelf.id) setSelectedShelfId(null);
      toast({ title: "Shelf deleted" });
    } catch {
      toast({ title: "Failed to delete shelf", variant: "destructive" });
    }
  };

  const handleRemoveBook = async (book: Book) => {
    if (!selectedShelfId) return;
    try {
      await removeBooks.mutateAsync({
        shelfId: selectedShelfId,
        bookIds: [book.id],
      });
      toast({ title: `Removed "${book.title}" from shelf` });
    } catch {
      toast({ title: "Failed to remove book", variant: "destructive" });
    }
  };

  const handleBookClick = (book: Book) => {
    setDetailBook(book);
    setDetailOpen(true);
  };

  // Shelf detail view
  if (selectedShelfId) {
    const shelf = shelfDetail?.data?.shelf;
    const books = shelfDetail?.data?.books ?? [];

    return (
      <div className="flex flex-1 flex-col gap-6 p-4 lg:p-6">
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setSelectedShelfId(null)}
          >
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <BookMarked className="h-5 w-5 text-primary" />
          <h1 className="text-xl font-semibold">{shelf?.name ?? "Shelf"}</h1>
          {shelf?.description && (
            <span className="text-sm text-muted-foreground">
              — {shelf.description}
            </span>
          )}
        </div>

        {shelfLoading ? (
          <div className="flex items-center justify-center py-20">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
          </div>
        ) : books.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20 text-muted-foreground">
            <Library className="mb-3 h-12 w-12" />
            <p className="text-lg font-medium">This shelf is empty</p>
            <p className="text-sm">
              Add books to this shelf from the book detail page.
            </p>
          </div>
        ) : (
          <>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <span>{books.length} books</span>
            </div>
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

  // Shelves list view
  return (
    <div className="flex flex-1 flex-col gap-6 p-4 lg:p-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <BookMarked className="h-5 w-5 text-primary" />
          <h1 className="text-xl font-semibold">Shelves</h1>
        </div>
        <Button onClick={openCreate} className="gap-2">
          <Plus className="h-4 w-4" />
          New Shelf
        </Button>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-20">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      ) : shelves.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-muted-foreground">
          <BookMarked className="mb-3 h-12 w-12" />
          <p className="text-lg font-medium">No shelves yet</p>
          <p className="text-sm">
            Create a shelf to organize your books into collections.
          </p>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {shelves.map((shelf) => (
            <Card
              key={shelf.id}
              className="cursor-pointer transition-colors hover:bg-accent/50"
              onClick={() => setSelectedShelfId(shelf.id)}
            >
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0">
                    <CardTitle className="text-base truncate">
                      {shelf.name}
                    </CardTitle>
                    {shelf.description && (
                      <CardDescription className="mt-1 line-clamp-2">
                        {shelf.description}
                      </CardDescription>
                    )}
                  </div>
                  <div
                    className="flex gap-1 ml-2"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <Button
                      variant="ghost"
                      size="sm"
                      className="h-8 w-8 p-0"
                      onClick={() => openEdit(shelf)}
                    >
                      <Pencil className="h-3.5 w-3.5" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="h-8 w-8 p-0 text-destructive hover:text-destructive"
                      onClick={() => handleDelete(shelf)}
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </Button>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="pt-0">
                <span className="text-sm text-muted-foreground">
                  {shelf.book_count ?? 0} books
                </span>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {editShelf ? "Edit Shelf" : "Create Shelf"}
            </DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label htmlFor="shelf-name">Name</Label>
              <Input
                id="shelf-name"
                value={formName}
                onChange={(e) => setFormName(e.target.value)}
                placeholder="My Reading List"
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="shelf-desc">Description</Label>
              <Textarea
                id="shelf-desc"
                value={formDesc}
                onChange={(e) => setFormDesc(e.target.value)}
                placeholder="Optional description..."
                rows={3}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={
                !formName.trim() ||
                createShelf.isPending ||
                updateShelf.isPending
              }
            >
              {createShelf.isPending || updateShelf.isPending ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : null}
              {editShelf ? "Save" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
