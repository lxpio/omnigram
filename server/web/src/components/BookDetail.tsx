import { useState } from "react";
import type { Book } from "@/types";
import { getCoverUrl, useUpdateBook, useDeleteBook, useUploadCover } from "@/api/books";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetDescription,
} from "@/components/ui/sheet";
import { toast } from "@/components/ui/use-toast";
import { BookOpen, Save, Trash2, Download, ImagePlus, MessageSquare, Highlighter, Bookmark as BookmarkIcon } from "lucide-react";
import { useAnnotations, useDeleteAnnotation } from "@/api/annotations";
import type { Annotation } from "@/api/annotations";

interface BookDetailProps {
  book: Book | null;
  open: boolean;
  onClose: () => void;
}

export function BookDetail({ book, open, onClose }: BookDetailProps) {
  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState<Partial<Book>>({});
  const updateBook = useUpdateBook();
  const deleteBook = useDeleteBook();
  const uploadCover = useUploadCover();
  const { data: annotationsResp } = useAnnotations(book?.id);
  const deleteAnnotation = useDeleteAnnotation();
  const annotations: Annotation[] = annotationsResp?.data ?? [];

  const startEdit = () => {
    if (!book) return;
    setForm({
      title: book.title,
      author: book.author,
      description: book.description,
      publisher: book.publisher,
      isbn: book.isbn,
      series: book.series,
      tags: book.tags,
      rating: book.rating,
    });
    setEditing(true);
  };

  const handleSave = async () => {
    if (!book) return;
    try {
      await updateBook.mutateAsync({ id: book.id, ...form });
      toast({ title: "Book updated successfully" });
      setEditing(false);
      onClose();
    } catch {
      toast({ title: "Failed to update book", variant: "destructive" });
    }
  };

  const handleDelete = async () => {
    if (!book || !confirm("Are you sure you want to delete this book?")) return;
    try {
      await deleteBook.mutateAsync({ id: book.id, deleteFile: true });
      toast({ title: "Book deleted" });
      onClose();
    } catch {
      toast({ title: "Failed to delete book", variant: "destructive" });
    }
  };

  const handleDeleteAnnotation = async (ann: Annotation) => {
    if (!book) return;
    try {
      await deleteAnnotation.mutateAsync({ bookId: book.id, annotationId: ann.id });
      toast({ title: "Annotation deleted" });
    } catch {
      toast({ title: "Failed to delete", variant: "destructive" });
    }
  };

  const handleCoverUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!book || !e.target.files?.[0]) return;
    try {
      await uploadCover.mutateAsync({ id: book.id, file: e.target.files[0] });
      toast({ title: "Cover updated" });
    } catch {
      toast({ title: "Failed to upload cover", variant: "destructive" });
    }
  };

  if (!book) return null;

  const coverUrl = getCoverUrl(book.cover_url);

  return (
    <Sheet open={open} onOpenChange={(o) => { if (!o) { setEditing(false); onClose(); } }}>
      <SheetContent className="flex flex-col p-0 sm:max-w-lg">
        <SheetHeader className="px-6 pt-6">
          <SheetTitle className="line-clamp-1">{book.title}</SheetTitle>
          <SheetDescription>{book.author || "Unknown Author"}</SheetDescription>
        </SheetHeader>
        <ScrollArea className="flex-1">
          <div className="space-y-6 px-6 pb-6">
            {/* Cover */}
            <div className="relative mx-auto w-48 overflow-hidden rounded-lg shadow-lg">
              <div className="aspect-[2/3] w-full bg-muted">
                {coverUrl ? (
                  <img src={coverUrl} alt={book.title} className="h-full w-full object-cover" />
                ) : (
                  <div className="flex h-full w-full items-center justify-center bg-gradient-to-br from-primary/10 to-primary/5">
                    <BookOpen className="h-16 w-16 text-primary/30" />
                  </div>
                )}
              </div>
              <label className="absolute inset-0 flex cursor-pointer items-center justify-center bg-black/0 opacity-0 transition-opacity hover:bg-black/40 hover:opacity-100">
                <ImagePlus className="h-8 w-8 text-white" />
                <input type="file" accept="image/*" className="hidden" onChange={handleCoverUpload} />
              </label>
            </div>

            {/* Info badges */}
            <div className="flex flex-wrap gap-2">
              {book.file_type && <Badge variant="outline" className="uppercase">{book.file_type}</Badge>}
              {book.isbn && <Badge variant="secondary">ISBN: {book.isbn}</Badge>}
              {book.series && <Badge variant="secondary">{book.series}</Badge>}
            </div>

            <Separator />

            {editing ? (
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label>Title</Label>
                  <Input value={form.title || ""} onChange={(e) => setForm({ ...form, title: e.target.value })} />
                </div>
                <div className="space-y-2">
                  <Label>Author</Label>
                  <Input value={form.author || ""} onChange={(e) => setForm({ ...form, author: e.target.value })} />
                </div>
                <div className="space-y-2">
                  <Label>Description</Label>
                  <Textarea rows={4} value={form.description || ""} onChange={(e) => setForm({ ...form, description: e.target.value })} />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Publisher</Label>
                    <Input value={form.publisher || ""} onChange={(e) => setForm({ ...form, publisher: e.target.value })} />
                  </div>
                  <div className="space-y-2">
                    <Label>ISBN</Label>
                    <Input value={form.isbn || ""} onChange={(e) => setForm({ ...form, isbn: e.target.value })} />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Series</Label>
                    <Input value={form.series || ""} onChange={(e) => setForm({ ...form, series: e.target.value })} />
                  </div>
                  <div className="space-y-2">
                    <Label>Tags</Label>
                    <Input value={form.tags || ""} onChange={(e) => setForm({ ...form, tags: e.target.value })} placeholder="comma separated" />
                  </div>
                </div>
                <div className="flex gap-2">
                  <Button onClick={handleSave} disabled={updateBook.isPending} className="gap-2">
                    <Save className="h-4 w-4" />
                    Save
                  </Button>
                  <Button variant="outline" onClick={() => setEditing(false)}>Cancel</Button>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                {book.description && (
                  <div>
                    <h4 className="mb-1 text-sm font-medium text-muted-foreground">Description</h4>
                    <p className="text-sm leading-relaxed">{book.description}</p>
                  </div>
                )}

                <div className="grid grid-cols-2 gap-4 text-sm">
                  {book.publisher && (
                    <div>
                      <span className="text-muted-foreground">Publisher</span>
                      <p className="font-medium">{book.publisher}</p>
                    </div>
                  )}
                  {book.rating > 0 && (
                    <div>
                      <span className="text-muted-foreground">Rating</span>
                      <p className="font-medium text-amber-500">{"★".repeat(Math.round(book.rating))} {book.rating}</p>
                    </div>
                  )}
                </div>

                {book.tags && (
                  <div>
                    <h4 className="mb-2 text-sm font-medium text-muted-foreground">Tags</h4>
                    <div className="flex flex-wrap gap-1">
                      {String(book.tags).split(",").filter(Boolean).map((tag) => (
                        <Badge key={tag} variant="secondary" className="text-xs">{tag.trim()}</Badge>
                      ))}
                    </div>
                  </div>
                )}

                <Separator />

                <div className="flex gap-2">
                  <Button onClick={startEdit} className="gap-2">Edit Metadata</Button>
                  <Button variant="outline" asChild className="gap-2">
                    <a href={`/reader/download/books/${book.id}`} download>
                      <Download className="h-4 w-4" />
                      Download
                    </a>
                  </Button>
                  <Button variant="destructive" size="icon" onClick={handleDelete} className="ml-auto">
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>

                {/* Annotations */}
                {annotations.length > 0 && (
                  <>
                    <Separator />
                    <div>
                      <h4 className="mb-3 text-sm font-medium text-muted-foreground">
                        Annotations ({annotations.length})
                      </h4>
                      <div className="space-y-3">
                        {annotations.map((ann) => (
                          <div key={ann.id} className="group rounded-lg border p-3 text-sm">
                            <div className="flex items-start justify-between gap-2">
                              <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                                {ann.type === "highlight" && <Highlighter className="h-3 w-3" />}
                                {ann.type === "note" && <MessageSquare className="h-3 w-3" />}
                                {ann.type === "bookmark" && <BookmarkIcon className="h-3 w-3" />}
                                <span className="capitalize">{ann.type}</span>
                                {ann.chapter && <span>· {ann.chapter}</span>}
                              </div>
                              <Button
                                variant="ghost"
                                size="sm"
                                className="h-6 w-6 p-0 opacity-0 group-hover:opacity-100 text-destructive"
                                onClick={() => handleDeleteAnnotation(ann)}
                              >
                                <Trash2 className="h-3 w-3" />
                              </Button>
                            </div>
                            {ann.selected_text && (
                              <p className="mt-1.5 border-l-2 border-primary/30 pl-2 italic text-muted-foreground">
                                {ann.selected_text}
                              </p>
                            )}
                            {ann.content && (
                              <p className="mt-1.5">{ann.content}</p>
                            )}
                          </div>
                        ))}
                      </div>
                    </div>
                  </>
                )}
              </div>
            )}
          </div>
        </ScrollArea>
      </SheetContent>
    </Sheet>
  );
}
