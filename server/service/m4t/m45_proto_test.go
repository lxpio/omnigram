package m4t_test

import (
	context "context"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"testing"

	"github.com/lxpio/omnigram/server/service/m4t"
	"github.com/lxpio/omnigram/server/log"

	"go.uber.org/zap/zapcore"
	grpc "google.golang.org/grpc"
)

func TestManager_LoadConfig(t *testing.T) {

	log.Init(`stdout`, zapcore.DebugLevel)

	conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
	if err != nil {
		t.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	// Create a gRPC client
	client := m4t.NewTextToAudioClient(conn)

	// Send a request to the server
	req := &m4t.TextRequest{
		Text: "安如磐石~收！丝线--交织，古华深秘，裁！断！收！嗨！咻~走~咻~走~嗨~咻~吃饱喝饱一路走好！",
		// Text:    `超过一天的攻击记录不要使用此接口`,
		Lang:    `zh-cn`,
		AudioId: `female_001`,
	}

	response, err := client.ConvertTextToAudio(context.Background(), req)
	if err != nil {
		t.Fatalf("Failed to call SayHello: %v", err)
	}

	// write the whole body at once
	ioutil.WriteFile("output.wav", response.AudioData, 0644)
	// if err != nil {
	// 	panic(err)
	// }
	// // Print the response
	// log.I("Response: %s\n", response.Message)

	// openai :=

}

// func TestTTSStream(t *testing.T) {

// 	log.Init(`stdout`, zapcore.DebugLevel)

// 	conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
// 	if err != nil {
// 		t.Fatalf("Failed to connect: %v", err)
// 	}
// 	defer conn.Close()

// 	// Send a request to the server
// 	req := &m4t.TextRequest{
// 		Text: "鲁迅在中国有“民族魂”之称。",
// 		// Text:    `超过一天的攻击记录不要使用此接口`,
// 		Lang:    `zh-cn`,
// 		AudioId: `female_001`,
// 	}
// 	// Create a gRPC client
// 	client := m4t.NewTextToAudioClient(conn)
// 	stream, err := client.TTSStream(context.Background(), req)
// 	if err != nil {
// 		t.Fatalf("Failed to call SayHello: %v", err)
// 	}

// 	// 创建一个 AudioBuffer，用于存储 WAV 数据
// 	buffer := &audio.IntBuffer{
// 		Format: &audio.Format{SampleRate: 24000, NumChannels: 1},
// 	}

// 	output, _ := os.Create(`stream.wav`)

// 	encoder := wav.NewEncoder(output, buffer.Format.SampleRate, 16, 1, 1)

// 	// 从流中读取 WAVListResponse
// 	for {
// 		wavListResponse, err := stream.Recv()
// 		if err == io.EOF {
// 			break
// 		}
// 		if err != nil {
// 			t.Fatalf("Failed to receive WAVListResponse: %v", err)
// 		}
// 		// buffer.Data = wavListResponse.GetAudioData()
// 		// 处理 WAVListResponse 中的音频数据
// 		// audioDataChunk := buffer.AsIntBuffer()
// 		intList := make([]int, len(wavListResponse.GetAudioData()))
// 		for i, v := range wavListResponse.GetAudioData() {
// 			intList[i] = int(v)
// 		}
// 		buffer.Data = intList

// 		if err := encoder.Write(buffer); err != nil {
// 			fmt.Println("Error writing WAV data:", err)
// 			break
// 		}

// 		// encoder.

// 		// fmt.Printf("Received audio data chunk: %v\n", wavListResponse.GetAudioData())
// 	}
// 	encoder.Close()
// 	output.Close()

// 	stream.CloseSend()

// 	// if err != nil {
// 	// 	panic(err)
// 	// }
// 	// // Print the response
// 	// log.I("Response: %s\n", response.Message)

// 	// openai :=

// }

func TestTTSStreamv2(t *testing.T) {

	log.Init(`stdout`, zapcore.DebugLevel)

	conn, err := grpc.Dial("localhost:50051", grpc.WithInsecure())
	if err != nil {
		t.Fatalf("Failed to connect: %v", err)
	}
	defer conn.Close()

	// Send a request to the server
	req := &m4t.TextRequest{
		Text: "鲁迅在中国有“民族魂”之称。",
		// Text:    `超过一天的攻击记录不要使用此接口`,
		Lang:    `zh-cn`,
		AudioId: `female_001`,
	}
	// Create a gRPC client
	client := m4t.NewTextToAudioClient(conn)
	stream, err := client.TTSStream(context.Background(), req)
	if err != nil {
		t.Fatalf("Failed to call SayHello: %v", err)
	}

	output, _ := os.Create(`streamv2.wav`)

	// encoder := wav.NewEncoderV2(output, 24000, 16, 1, 1)

	// 从流中读取 WAVListResponse
	for {
		wavListResponse, err := stream.Recv()
		if err == io.EOF {
			break
		}
		if err != nil {
			t.Fatalf("Failed to receive WAVListResponse: %v", err)
		}

		// encoder.

		fmt.Printf("Received audio data chunk: %v\n", wavListResponse.GetAudioData())
	}
	// encoder.Close()
	output.Close()

	stream.CloseSend()

	// if err != nil {
	// 	panic(err)
	// }
	// // Print the response
	// log.I("Response: %s\n", response.Message)

	// openai :=

}
