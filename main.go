package main

import (
	"context"
	"log"
	"os"
	"os/signal"

	"github.com/RyazanovAlexander/pipeline-manager/scheduler/v1/internal/config"
	"github.com/RyazanovAlexander/pipeline-manager/scheduler/v1/internal/consumer"
	"github.com/RyazanovAlexander/pipeline-manager/scheduler/v1/internal/producer"
)

func main() {
	cleanup := config.InitTracer()
	defer cleanup(context.Background())

	ctx, cancel := context.WithCancel(context.Background())

	sigterm := make(chan os.Signal, 1)
	signal.Notify(sigterm, os.Interrupt)

	errCh := make(chan error)
	go func() {
		errCh <- producer.Run(ctx)
	}()
	go func() {
		errCh <- consumer.Run(ctx)
	}()

	select {
	case <-sigterm:
		cancel()
		log.Println("Interrupt signal received. Finishing the application...")
	case err := <-errCh:
		if err != nil {
			log.Fatal(err)
		}
	}
}
