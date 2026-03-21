import { useState } from "react";
import { useSystemInfo, useScanStatus, useRunScan, useStopScan, useImportCalibre } from "@/api/system";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { toast } from "@/components/ui/use-toast";
import { Input } from "@/components/ui/input";
import { Settings, RefreshCw, StopCircle, Server, Loader2, FolderOpen } from "lucide-react";

export function SettingsPage() {
  const { data: sysInfo, isLoading: sysLoading } = useSystemInfo();
  const { data: scanStatus } = useScanStatus();
  const runScan = useRunScan();
  const stopScan = useStopScan();
  const [calibrePath, setCalibrePath] = useState("");
  const importCalibre = useImportCalibre();
  const [importResult, setImportResult] = useState<any>(null);

  const handleRunScan = async () => {
    try {
      await runScan.mutateAsync();
      toast({ title: "Library scan started" });
    } catch {
      toast({ title: "Failed to start scan", variant: "destructive" });
    }
  };

  const handleImport = async () => {
    if (!calibrePath.trim()) return;
    try {
      const result = await importCalibre.mutateAsync(calibrePath);
      setImportResult(result);
      toast({ title: `Imported ${result.imported} books` });
    } catch {
      toast({ title: "Import failed", variant: "destructive" });
    }
  };

  const handleStopScan = async () => {
    try {
      await stopScan.mutateAsync();
      toast({ title: "Scan stopped" });
    } catch {
      toast({ title: "Failed to stop scan", variant: "destructive" });
    }
  };

  return (
    <div className="flex flex-1 flex-col gap-6 p-4 lg:p-6">
      <div className="flex items-center gap-2">
        <Settings className="h-5 w-5 text-primary" />
        <h1 className="text-xl font-semibold">Settings</h1>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* System Info */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Server className="h-4 w-4" />
              System Information
            </CardTitle>
            <CardDescription>Server details and status</CardDescription>
          </CardHeader>
          <CardContent>
            {sysLoading ? (
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            ) : (
              <div className="grid gap-3 text-sm">
                {sysInfo && Object.entries(sysInfo).map(([key, value]) => (
                  <div key={key} className="flex justify-between">
                    <span className="text-muted-foreground capitalize">{key.replace(/_/g, " ")}</span>
                    <span className="font-medium">{String(value)}</span>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Library Scan */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <RefreshCw className="h-4 w-4" />
              Library Scan
            </CardTitle>
            <CardDescription>Scan your library folder for new books</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-3">
              <span className="text-sm text-muted-foreground">Status:</span>
              {scanStatus?.running ? (
                <Badge>
                  <Loader2 className="mr-1 h-3 w-3 animate-spin" />
                  Scanning...
                </Badge>
              ) : (
                <Badge variant="secondary">Idle</Badge>
              )}
            </div>

            {scanStatus?.scanned_count !== undefined && (
              <div className="flex items-center gap-3 text-sm">
                <span className="text-muted-foreground">Scanned:</span>
                <span className="font-medium">{scanStatus.scanned_count} books</span>
              </div>
            )}

            {scanStatus?.last_scan_time ? (
              <div className="flex items-center gap-3 text-sm">
                <span className="text-muted-foreground">Last scan:</span>
                <span className="font-medium">{new Date(scanStatus.last_scan_time).toLocaleString()}</span>
              </div>
            ) : null}

            <Separator />

            <div className="flex gap-2">
              <Button
                onClick={handleRunScan}
                disabled={scanStatus?.running || runScan.isPending}
                className="gap-2"
              >
                <RefreshCw className="h-4 w-4" />
                Start Scan
              </Button>
              {scanStatus?.running && (
                <Button variant="destructive" onClick={handleStopScan} disabled={stopScan.isPending} className="gap-2">
                  <StopCircle className="h-4 w-4" />
                  Stop
                </Button>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Calibre Import */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <FolderOpen className="h-4 w-4" />
              Calibre Import
            </CardTitle>
            <CardDescription>Import books from a Calibre library</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <span className="text-sm text-muted-foreground">Calibre Library Path</span>
              <Input
                placeholder="/path/to/calibre/library"
                value={calibrePath}
                onChange={(e) => setCalibrePath(e.target.value)}
              />
            </div>
            <Button
              onClick={handleImport}
              disabled={!calibrePath.trim() || importCalibre.isPending}
              className="gap-2"
            >
              {importCalibre.isPending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <FolderOpen className="h-4 w-4" />
              )}
              Import
            </Button>
            {importResult && (
              <>
                <Separator />
                <div className="grid gap-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Total</span>
                    <span className="font-medium">{importResult.total}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Imported</span>
                    <span className="font-medium text-green-500">{importResult.imported}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Skipped</span>
                    <span className="font-medium">{importResult.skipped}</span>
                  </div>
                  {importResult.errors > 0 && (
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Errors</span>
                      <span className="font-medium text-destructive">{importResult.errors}</span>
                    </div>
                  )}
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
