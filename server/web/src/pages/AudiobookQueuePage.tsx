import { useMemo, useState } from "react";
import { Loader2, Plus, Headphones, AlertCircle } from "lucide-react";

import {
  TASK_STATUS_LABELS,
  useAudiobookQueue,
  useBatchAudiobook,
  type AudiobookQueueItem,
} from "@/api/audiobook";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { toast } from "@/components/ui/use-toast";

/** Admin view for monitoring & triggering audiobook generation. */
export function AudiobookQueuePage() {
  const { data, isLoading } = useAudiobookQueue();
  const items = data?.items ?? [];

  const [dialogOpen, setDialogOpen] = useState(false);
  const [bookIdsText, setBookIdsText] = useState("");
  const [voice, setVoice] = useState("serena");
  const batch = useBatchAudiobook();

  const stats = useMemo(() => summarise(items), [items]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const ids = bookIdsText
      .split(/[\s,]+/)
      .map((s) => s.trim())
      .filter(Boolean);
    if (ids.length === 0) {
      toast({ title: "Paste at least one book ID", variant: "destructive" });
      return;
    }
    try {
      const resp = await batch.mutateAsync({ book_ids: ids, voice });
      toast({
        title: `Queued ${resp.submitted} of ${ids.length}`,
        description:
          resp.items.filter((i) => i.status !== "queued").length > 0
            ? "Some books were skipped (already exist / error). See queue below."
            : undefined,
      });
      setDialogOpen(false);
      setBookIdsText("");
    } catch {
      toast({ title: "Batch submit failed", variant: "destructive" });
    }
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold flex items-center gap-2">
            <Headphones className="w-6 h-6" /> Audiobook Queue
          </h1>
          <p className="text-sm text-muted-foreground">
            Pre-generate audiobooks for selected books using the configured TTS sidecar.
          </p>
        </div>
        <Button onClick={() => setDialogOpen(true)}>
          <Plus className="w-4 h-4 mr-2" /> Queue batch
        </Button>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        <StatCard label="Total" value={stats.total} />
        <StatCard label="Running" value={stats.running} highlight={stats.running > 0} />
        <StatCard label="Pending" value={stats.pending} />
        <StatCard label="Completed" value={stats.completed} />
        <StatCard label="Failed" value={stats.failed} warn={stats.failed > 0} />
      </div>

      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Book</TableHead>
            <TableHead>Voice</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Progress</TableHead>
            <TableHead>Updated</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {isLoading && (
            <TableRow>
              <TableCell colSpan={5} className="text-center py-8">
                <Loader2 className="w-4 h-4 animate-spin inline-block mr-2" />
                Loading queue…
              </TableCell>
            </TableRow>
          )}
          {!isLoading && items.length === 0 && (
            <TableRow>
              <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">
                No audiobook tasks yet.
              </TableCell>
            </TableRow>
          )}
          {items.map((i) => (
            <TableRow key={i.task_id}>
              <TableCell className="max-w-[24rem]">
                <div className="font-medium truncate">{i.book_title || i.book_id}</div>
                <div className="text-xs text-muted-foreground truncate">{i.author}</div>
              </TableCell>
              <TableCell className="text-sm">{i.voice}</TableCell>
              <TableCell>
                <Badge variant={statusVariant(i.status)}>
                  {TASK_STATUS_LABELS[i.status] ?? `#${i.status}`}
                </Badge>
                {i.error_message && (
                  <div className="flex items-center gap-1 mt-1 text-xs text-destructive">
                    <AlertCircle className="w-3 h-3" />
                    {i.error_message}
                  </div>
                )}
              </TableCell>
              <TableCell>
                <div className="w-40 bg-muted h-1.5 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-primary transition-all"
                    style={{ width: `${i.progress_pct}%` }}
                  />
                </div>
                <div className="text-xs text-muted-foreground mt-1">
                  {i.done_chapters}/{i.total_chapters}
                  {i.failed_chapters > 0 && ` (${i.failed_chapters} failed)`}
                </div>
              </TableCell>
              <TableCell className="text-xs text-muted-foreground">
                {formatTime(i.utime)}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Queue audiobook batch</DialogTitle>
            <DialogDescription>
              Paste book IDs (one per line or comma-separated). Books that already have
              a task will be skipped automatically.
            </DialogDescription>
          </DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <Label htmlFor="book_ids">Book IDs</Label>
              <Input
                id="book_ids"
                placeholder="2026… 2026…"
                value={bookIdsText}
                onChange={(e) => setBookIdsText(e.target.value)}
                className="font-mono text-xs"
              />
            </div>
            <div>
              <Label htmlFor="voice">Voice</Label>
              <Input
                id="voice"
                value={voice}
                onChange={(e) => setVoice(e.target.value)}
              />
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                Cancel
              </Button>
              <Button type="submit" disabled={batch.isPending}>
                {batch.isPending && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                Queue
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function StatCard({
  label,
  value,
  highlight,
  warn,
}: {
  label: string;
  value: number;
  highlight?: boolean;
  warn?: boolean;
}) {
  return (
    <div
      className={
        "rounded-lg border p-3 " +
        (highlight
          ? "border-primary bg-primary/5"
          : warn
          ? "border-destructive/50 bg-destructive/5"
          : "bg-card")
      }
    >
      <div className="text-xs text-muted-foreground">{label}</div>
      <div className="text-2xl font-semibold">{value}</div>
    </div>
  );
}

function statusVariant(status: number): "default" | "secondary" | "destructive" | "outline" {
  if (status === 2) return "default"; // Completed
  if (status === 1) return "secondary"; // Running
  if (status === 3) return "destructive"; // Failed
  return "outline"; // Pending / other
}

function summarise(items: AudiobookQueueItem[]) {
  return {
    total: items.length,
    pending: items.filter((i) => i.status === 0).length,
    running: items.filter((i) => i.status === 1).length,
    completed: items.filter((i) => i.status === 2).length,
    failed: items.filter((i) => i.status === 3).length,
  };
}

function formatTime(ts: number) {
  if (!ts) return "—";
  const d = new Date(ts * 1000);
  return d.toLocaleString();
}
