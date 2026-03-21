declare module "foliate-js/view.js" {
  export class View extends HTMLElement {
    book: {
      metadata?: { title?: string; language?: string };
      toc?: Array<{
        label: string;
        href: string;
        subitems?: Array<{ label: string; href: string }>;
      }>;
      sections: Array<{ id?: string; linear?: string }>;
      landmarks?: Array<{ type: string[]; href: string }>;
      rendition?: { layout?: string };
    };
    renderer: HTMLElement & {
      goTo(target: unknown): Promise<void>;
      setAttribute(name: string, value: string): void;
      destroy(): void;
      open(book: unknown): void;
      getContents(): Array<{ doc: Document; index: number }>;
    };
    lastLocation: unknown;
    history: { pushState(state: unknown): void; clear(): void };
    open(book: string | File | Blob): Promise<void>;
    close(): void;
    init(options: {
      lastLocation?: unknown;
      showTextStart?: boolean;
    }): Promise<void>;
    goTo(target: unknown): Promise<unknown>;
    goToFraction(frac: number): Promise<void>;
    goToTextStart(): Promise<void>;
    next(): Promise<void>;
    prev(): Promise<void>;
    getCFI(index: number, range: Range): string;
  }

  export function makeBook(
    file: string | File | Blob
  ): Promise<View["book"]>;
}
