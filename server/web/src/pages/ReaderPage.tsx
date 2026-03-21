import { useState, useEffect, useRef, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useBook } from "@/api/books";
import { apiFetch } from "@/api/client";
import { Button } from "@/components/ui/button";
import { toast } from "@/components/ui/use-toast";
import {
  ArrowLeft,
  ChevronLeft,
  ChevronRight,
  Loader2,
  List,
  Minus,
  Plus,
  Sun,
  Moon,
} from "lucide-react";
import { ScrollArea } from "@/components/ui/scroll-area";

interface TOCItem {
  label: string;
  href: string;
  subitems?: TOCItem[];
}

interface ReadProgress {
  progress: number;
  progress_index: number;
  para_position: number;
}

export function ReaderPage() {
  const { bookId } = useParams<{ bookId: string }>();
  const navigate = useNavigate();
  const { data: book } = useBook(bookId!);
  const containerRef = useRef<HTMLDivElement>(null);
  const viewRef = useRef<any>(null);
  const [loading, setLoading] = useState(true);
  const [progress, setProgress] = useState(0);
  const [tocItems, setTocItems] = useState<TOCItem[]>([]);
  const [tocOpen, setTocOpen] = useState(false);
  const [chapterTitle, setChapterTitle] = useState("");
  const [fontSize, setFontSize] = useState(() => {
    return parseInt(localStorage.getItem("readerFontSize") || "100");
  });
  const [darkMode, setDarkMode] = useState(() => {
    return localStorage.getItem("readerDarkMode") === "true";
  });

  // Save reading progress to server
  const saveProgress = useCallback(
    async (cfi: string, fraction: number) => {
      if (!bookId) return;
      try {
        await apiFetch(`/reader/books/${bookId}/progress`, {
          method: "PUT",
          body: JSON.stringify({
            progress: fraction,
            progress_index: 0,
            para_position: 0,
          }),
        });
      } catch {
        // Silently fail — don't interrupt reading
      }
    },
    [bookId]
  );

  // Load reading progress from server
  const loadProgress = useCallback(async (): Promise<ReadProgress | null> => {
    if (!bookId) return null;
    try {
      const resp = await apiFetch<ReadProgress>(
        `/reader/books/${bookId}/progress`
      );
      return resp;
    } catch {
      return null;
    }
  }, [bookId]);

  // Initialize reader
  useEffect(() => {
    if (!bookId || !containerRef.current) return;

    let view: any = null;
    let saveTimer: ReturnType<typeof setTimeout>;

    const initReader = async () => {
      try {
        // Dynamically import foliate-js
        const { View } = await import("foliate-js/view.js");

        // Create the view element
        view = new View();
        viewRef.current = view;
        view.style.cssText = "width: 100%; height: 100%;";

        containerRef.current!.innerHTML = "";
        containerRef.current!.appendChild(view);

        // Listen for location changes
        view.addEventListener("relocate", (e: CustomEvent) => {
          const detail = e.detail;
          if (detail?.fraction != null) {
            setProgress(Math.round(detail.fraction * 100));
          }
          if (detail?.tocItem?.label) {
            setChapterTitle(detail.tocItem.label);
          }

          // Debounce save
          clearTimeout(saveTimer);
          saveTimer = setTimeout(() => {
            const cfi = detail?.cfi ?? "";
            const frac = detail?.fraction ?? 0;
            saveProgress(cfi, frac);
          }, 3000);
        });

        // Fetch the book file
        const bookUrl = `/reader/download/books/${bookId}`;
        await view.open(bookUrl);

        // Extract TOC
        if (view.book?.toc) {
          setTocItems(view.book.toc);
        }

        // Restore progress
        const savedProgress = await loadProgress();
        if (savedProgress && savedProgress.progress > 0) {
          await view.init({ lastLocation: savedProgress.progress });
        } else {
          await view.init({ showTextStart: true });
        }

        setLoading(false);
      } catch (err) {
        console.error("Failed to open book:", err);
        toast({ title: "Failed to open book", variant: "destructive" });
        setLoading(false);
      }
    };

    initReader();

    return () => {
      clearTimeout(saveTimer);
      if (view) {
        try {
          view.close();
        } catch {
          // ignore
        }
      }
      viewRef.current = null;
    };
  }, [bookId, saveProgress, loadProgress]);

  // Apply font size
  useEffect(() => {
    const view = viewRef.current;
    if (!view?.renderer) return;
    view.renderer.setAttribute(
      "style",
      `--font-size: ${fontSize}%; font-size: ${fontSize}%;`
    );
    localStorage.setItem("readerFontSize", String(fontSize));
  }, [fontSize]);

  // Apply dark mode
  useEffect(() => {
    localStorage.setItem("readerDarkMode", String(darkMode));
  }, [darkMode]);

  const goNext = () => viewRef.current?.next();
  const goPrev = () => viewRef.current?.prev();

  const goToTocItem = (href: string) => {
    viewRef.current?.goTo(href);
    setTocOpen(false);
  };

  // Keyboard navigation
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === "ArrowRight" || e.key === " ") goNext();
      else if (e.key === "ArrowLeft") goPrev();
      else if (e.key === "Escape") {
        if (tocOpen) setTocOpen(false);
        else navigate(-1);
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, [tocOpen, navigate]);

  return (
    <div
      className={`flex h-screen flex-col ${darkMode ? "bg-neutral-900 text-neutral-100" : "bg-white text-neutral-900"}`}
    >
      {/* Top bar */}
      <div
        className={`flex h-12 items-center gap-2 border-b px-3 ${darkMode ? "border-neutral-700 bg-neutral-800" : "border-neutral-200 bg-neutral-50"}`}
      >
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate(-1)}
          className="gap-1"
        >
          <ArrowLeft className="h-4 w-4" />
          <span className="hidden sm:inline">Back</span>
        </Button>

        <div className="flex-1 min-w-0 px-2">
          <p className="truncate text-sm font-medium">
            {book?.title ?? "Loading..."}
          </p>
          {chapterTitle && (
            <p className="truncate text-xs text-muted-foreground">
              {chapterTitle}
            </p>
          )}
        </div>

        <div className="flex items-center gap-1">
          <Button
            variant="ghost"
            size="sm"
            className="h-8 w-8 p-0"
            onClick={() => setTocOpen(!tocOpen)}
            title="Table of Contents"
          >
            <List className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 w-8 p-0"
            onClick={() => setFontSize((s) => Math.max(60, s - 10))}
            title="Decrease font size"
          >
            <Minus className="h-4 w-4" />
          </Button>
          <span className="w-10 text-center text-xs">{fontSize}%</span>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 w-8 p-0"
            onClick={() => setFontSize((s) => Math.min(200, s + 10))}
            title="Increase font size"
          >
            <Plus className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="h-8 w-8 p-0"
            onClick={() => setDarkMode(!darkMode)}
            title="Toggle dark mode"
          >
            {darkMode ? (
              <Sun className="h-4 w-4" />
            ) : (
              <Moon className="h-4 w-4" />
            )}
          </Button>
        </div>
      </div>

      {/* Main content */}
      <div className="relative flex flex-1 overflow-hidden">
        {/* TOC Sidebar */}
        {tocOpen && (
          <>
            <div
              className="absolute inset-0 z-10 bg-black/30 lg:hidden"
              onClick={() => setTocOpen(false)}
            />
            <aside
              className={`absolute left-0 top-0 z-20 h-full w-72 border-r lg:static ${darkMode ? "border-neutral-700 bg-neutral-800" : "border-neutral-200 bg-neutral-50"}`}
            >
              <div className="flex h-10 items-center border-b px-4 text-sm font-medium">
                Table of Contents
              </div>
              <ScrollArea className="h-[calc(100%-2.5rem)]">
                <nav className="py-2">
                  <TOCTree
                    items={tocItems}
                    onSelect={goToTocItem}
                    darkMode={darkMode}
                  />
                </nav>
              </ScrollArea>
            </aside>
          </>
        )}

        {/* Reader */}
        <div className="flex flex-1 flex-col">
          {loading && (
            <div className="flex flex-1 items-center justify-center">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          )}
          <div
            ref={containerRef}
            className="flex-1"
            style={{ display: loading ? "none" : "block" }}
          />

          {/* Navigation buttons */}
          {!loading && (
            <div className="flex items-center justify-between px-4 py-2">
              <Button variant="ghost" size="sm" onClick={goPrev}>
                <ChevronLeft className="h-4 w-4" />
              </Button>
              <div className="flex items-center gap-2">
                <div
                  className={`h-1 w-32 rounded-full sm:w-48 ${darkMode ? "bg-neutral-700" : "bg-neutral-200"}`}
                >
                  <div
                    className="h-full rounded-full bg-primary transition-all"
                    style={{ width: `${progress}%` }}
                  />
                </div>
                <span className="text-xs text-muted-foreground">
                  {progress}%
                </span>
              </div>
              <Button variant="ghost" size="sm" onClick={goNext}>
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function TOCTree({
  items,
  onSelect,
  darkMode,
  depth = 0,
}: {
  items: TOCItem[];
  onSelect: (href: string) => void;
  darkMode: boolean;
  depth?: number;
}) {
  return (
    <>
      {items.map((item, i) => (
        <div key={`${depth}-${i}`}>
          <button
            onClick={() => onSelect(item.href)}
            className={`w-full truncate px-4 py-1.5 text-left text-sm transition-colors ${
              darkMode
                ? "hover:bg-neutral-700"
                : "hover:bg-neutral-100"
            }`}
            style={{ paddingLeft: `${16 + depth * 16}px` }}
          >
            {item.label}
          </button>
          {item.subitems && item.subitems.length > 0 && (
            <TOCTree
              items={item.subitems}
              onSelect={onSelect}
              darkMode={darkMode}
              depth={depth + 1}
            />
          )}
        </div>
      ))}
    </>
  );
}
