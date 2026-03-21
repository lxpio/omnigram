import { useStatsOverview, useDailyStats, useBookStats } from "@/api/stats";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Loader2, BarChart3, Library, Clock, BookOpen } from "lucide-react";

function formatDuration(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  if (hours > 0) return `${hours}h ${minutes}m`;
  return `${minutes}m`;
}

function getDateRange() {
  const to = new Date();
  const from = new Date();
  from.setDate(from.getDate() - 13);
  const fmt = (d: Date) => d.toISOString().slice(0, 10);
  return { from: fmt(from), to: fmt(to) };
}

export function StatsPage() {
  const { from, to } = getDateRange();
  const { data: overview, isLoading: overviewLoading } = useStatsOverview();
  const { data: daily, isLoading: dailyLoading } = useDailyStats(from, to);
  const { data: books, isLoading: booksLoading } = useBookStats(10);

  const dailyData = daily?.data ?? [];
  const maxDuration = Math.max(...dailyData.map((d) => d.duration), 1);

  return (
    <div className="flex flex-1 flex-col gap-6 p-4 lg:p-6">
      <div className="flex items-center gap-2">
        <BarChart3 className="h-5 w-5 text-primary" />
        <h1 className="text-xl font-semibold">Reading Stats</h1>
      </div>

      {/* Overview Cards */}
      <div className="grid gap-6 md:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Books</CardTitle>
            <Library className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {overviewLoading ? (
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            ) : (
              <div className="text-2xl font-bold">{overview?.data?.total_books ?? 0}</div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Reading Time</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {overviewLoading ? (
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            ) : (
              <div className="text-2xl font-bold">
                {formatDuration(overview?.data?.total_reading_seconds ?? 0)}
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Books Read</CardTitle>
            <BookOpen className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {overviewLoading ? (
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            ) : (
              <div className="text-2xl font-bold">{overview?.data?.books_read ?? 0}</div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Daily Reading Chart */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BarChart3 className="h-4 w-4" />
            Daily Reading (Last 14 Days)
          </CardTitle>
        </CardHeader>
        <CardContent>
          {dailyLoading ? (
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
          ) : dailyData.length === 0 ? (
            <p className="text-sm text-muted-foreground">No reading data for this period.</p>
          ) : (
            <div className="flex items-end gap-2" style={{ height: 200 }}>
              {dailyData.map((d) => {
                const pct = (d.duration / maxDuration) * 100;
                const label = d.date.slice(5); // MM-DD
                return (
                  <div
                    key={d.date}
                    className="flex flex-1 flex-col items-center gap-1"
                  >
                    <div
                      className="group relative w-full rounded-t bg-primary transition-colors hover:bg-primary/80"
                      style={{ height: `${Math.max(pct, 2)}%` }}
                      title={`${d.date}: ${formatDuration(d.duration)} — ${d.sessions} session${d.sessions !== 1 ? "s" : ""}`}
                    >
                      <div className="pointer-events-none absolute -top-8 left-1/2 hidden -translate-x-1/2 whitespace-nowrap rounded bg-popover px-2 py-1 text-xs text-popover-foreground shadow group-hover:block">
                        {formatDuration(d.duration)}
                      </div>
                    </div>
                    <span className="text-[10px] text-muted-foreground">{label}</span>
                  </div>
                );
              })}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Top Books Table */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <BookOpen className="h-4 w-4" />
            Top Books
          </CardTitle>
        </CardHeader>
        <CardContent>
          {booksLoading ? (
            <Loader2 className="h-6 w-6 animate-spin text-primary" />
          ) : !books?.data?.length ? (
            <p className="text-sm text-muted-foreground">No book stats available.</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Title</TableHead>
                  <TableHead>Author</TableHead>
                  <TableHead className="text-right">Reading Time</TableHead>
                  <TableHead className="text-right">Sessions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {books.data.map((book) => (
                  <TableRow key={book.book_id}>
                    <TableCell className="font-medium">{book.title}</TableCell>
                    <TableCell className="text-muted-foreground">{book.author}</TableCell>
                    <TableCell className="text-right">{formatDuration(book.duration)}</TableCell>
                    <TableCell className="text-right">{book.sessions}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
