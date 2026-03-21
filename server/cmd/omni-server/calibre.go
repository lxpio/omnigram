package main

import (
	"context"
	"fmt"
	"os"

	"github.com/lxpio/omnigram/server/service/sys"
)

func importCalibre(calibrePath, dataPath string) {
	metadataDB := calibrePath + "/metadata.db"
	if _, err := os.Stat(metadataDB); os.IsNotExist(err) {
		fmt.Println("Error: metadata.db not found at", metadataDB)
		os.Exit(1)
	}

	result, err := sys.RunCalibreImport(context.Background(), calibrePath, dataPath)
	if err != nil {
		fmt.Println("Error:", err)
		os.Exit(1)
	}

	fmt.Println("\n--- Calibre Import Report ---")
	fmt.Printf("Total:    %d\n", result.Total)
	fmt.Printf("Imported: %d\n", result.Imported)
	fmt.Printf("Skipped:  %d\n", result.Skipped)
	fmt.Printf("Errors:   %d\n", result.Errors)
	for _, msg := range result.Messages {
		fmt.Println(" ", msg)
	}
}

