package producer

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/Shopify/sarama"
	"go.opentelemetry.io/contrib/instrumentation/github.com/Shopify/sarama/otelsarama"
)

var (
	kafkaAddress = os.Getenv("KAFKA_ADDRESS")
)

func Run(ctx context.Context) error {
	log.Println("Starting a new event producer")

	config := sarama.NewConfig()
	config.Producer.RequiredAcks = sarama.WaitForAll
	config.Producer.Retry.Max = 10 // Retry up to 10 times to produce the message
	config.Producer.Return.Successes = true

	var err error
	producer, err := sarama.NewSyncProducer(strings.Split(kafkaAddress, ","), config)
	if err != nil {
		log.Panicf("Error creating consumer group client: %v", err)
		return err
	}

	producer = otelsarama.WrapSyncProducer(config, producer)
	defer producer.Close()

	ticker := time.NewTicker(1000 * time.Millisecond)
	for i := 0; ; i++ {
		select {
		case <-ticker.C:
			message := &sarama.ProducerMessage{
				Topic: "scheduler",
				Key:   sarama.StringEncoder("message"),
				Value: sarama.StringEncoder(fmt.Sprintf("Hello %d", i)),
			}
			partition, offset, err := producer.SendMessage(message)
			if err != nil {
				log.Panicf("Error from consumer: %v", err)
				return err
			} else {
				// The tuple (topic, partition, offset) can be used as a unique identifier
				// for a message in a Kafka cluster.
				log.Printf("(PRODUCER) Your data is stored with unique identifier scheduler/%d/%d\n", partition, offset)
			}
		case <-ctx.Done():
			return nil
		}
	}
}
