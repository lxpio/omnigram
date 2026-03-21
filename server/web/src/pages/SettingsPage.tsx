import { useSystemInfo, useScanStatus, useRunScan, useStopScan } from "@/api/system";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { toast } from "@/components/ui/use-toast";
import { Settings, RefreshCw, StopCircle, Server, Loader2 } from "lucide-react";

export function SettingsPage() {
  const { data: sysInfo, isLoading: sysLoading } = useSystemInfo();
  const { data: scanStatus } = useScanStatus();
  const runScan = useRunScan();
  const stopScan = useStopScan();

  const handleRunScan = async () => {
    try {
      await runScan.mutateAsync();
      toast({ title: "Library scan started" });
    } catch {
      toast({ title: "Failed to start scan", variant: "destructive" });
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
      </div>
    </div>
  );
}
