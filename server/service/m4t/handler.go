package m4t

import (
	"bytes"
	context "context"
	"io"
	"net/http"
	"os"
	sync "sync"

	"github.com/gin-gonic/gin"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/utils"
	grpc "google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func startfetchTask(ctx context.Context, req *TextRequest, errChan chan<- error) (<-chan *AudioResponse, error) {
	//TODO get remote addr from config file
	conn, err := grpc.Dial(remoteServer.addr(), grpc.WithTransportCredentials(insecure.NewCredentials()))

	if err != nil {

		return nil, err
	}

	// Create a gRPC client
	client := NewTextToAudioClient(conn)
	stream, err := client.TTSStream(ctx, req)
	if err != nil {

		return nil, err
	}

	respChan := make(chan *AudioResponse)

	go func() {
		for {

			wavListResponse, err := stream.Recv()
			if err == io.EOF {
				log.D(`EOF  done `)
				close(respChan)
				// return true
				errChan <- nil
				break

				// break
			}
			if err != nil {

				log.E(err.Error())

				close(respChan)
				errChan <- err

				break
			}
			respChan <- wavListResponse

		}

		stream.CloseSend()

	}()

	return respChan, nil
}

func ttsStreamHandler(c *gin.Context) {

	// Send a request to the server
	req := &TextRequest{
		Lang: `zh-cn`,
		// AudioId: `female_001`,
	}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	// Set up a context with cancellation
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	done := make(chan error)
	defer close(done)
	dataChan, err := startfetchTask(ctx, req, done)

	if err != nil {
		c.JSON(500, utils.ErrInnerServer.WithMessage(err.Error()))
		return
	}

	var bufferPool = sync.Pool{
		New: func() interface{} {
			return new(bytes.Buffer)
		},
	}
	c.Header("Content-Type", "audio/pcm")
	c.Header("Transfer-Encoding", "chunked")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")

	c.Stream(func(w io.Writer) bool {

		for {

			select {
			case audio := <-dataChan:

				if audio != nil {
					buf := bufferPool.Get().(*bytes.Buffer)

					defer func() {
						log.I(`buf.Reset()`)
						buf.Reset()
						bufferPool.Put(buf)
					}()

					// buf := new(bytes.Buffer)

					if _, err := buf.Write(audio.GetAudioData()); err != nil {
						// log.Printf("Binary write error: %v", err)

						return false // Returning false stops the stream
					}

					if _, err := w.Write(buf.Bytes()); err != nil {
						// log.Printf("Stream error: %v", err)
						log.I(`Write  stream `, false)
						return false // Returning false stops the stream
					}

				}

				return true

			case <-done:

				return false
			}

		}

	})
	log.I(`exit  stream `)
}

func getSpeakersHandler(c *gin.Context) {

	// if localCached !=

	if list := cachedSpeaker.All(); list != nil {
		c.JSON(200, utils.SUCCESS.WithData(list))
		return
	}

	list, err := cachedSpeaker.load()

	if err != nil {
		log.E(`loading speakers failed: `, err.Error())
		c.JSON(404, utils.ErrNoFound)
		return
	}

	c.JSON(200, utils.SUCCESS.WithData(list))

}

func postSpeakerHandler(c *gin.Context) {

	// if localCached !=

	req := &UploadRequsest{}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	speaker, err := cachedSpeaker.Upload(context.Background(), req)

	if err != nil {
		log.E(`create speaker failed, audio_id: `, err.Error())
		c.JSON(500, utils.ErrInnerServer)
		return
	}
	c.JSON(200, utils.SUCCESS.WithData(speaker))

}

func delSpeakerHandler(c *gin.Context) {

	id := c.Param("audio_id")
	//todo verify id
	if id == "" {
		c.JSON(400, utils.ErrReqArgs)
		return
	}

	err := cachedSpeaker.Delete(context.Background(), id)

	if err != nil {
		log.E(`delete speaker failed, audio_id: `, id)
		c.JSON(500, utils.ErrInnerServer)
		return
	}
	c.JSON(200, utils.SUCCESS)
	// if localCached !=

}

func fakettsHandler(c *gin.Context) {

	// Send a request to the server
	req := &TextRequest{
		Text: "安如磐石~收！丝线--交织，古华深秘，裁！断！收！嗨！咻~走~咻~走~嗨~咻~吃饱喝饱一路走好！",
		// Text:    `超过一天的攻击记录不要使用此接口`,
		Lang: `zh-cn`,
		// AudioId: `female_001`,
	}

	if err := c.ShouldBind(req); err != nil {
		log.I(`用户登录参数异常`, err)
		c.JSON(200, utils.ErrReqArgs.WithMessage(err.Error()))
		return
	}

	file, err := os.Open("m4t_server/female-0-100.wav")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Unable to open WAV file"})
		return
	}
	defer file.Close()

	// 设置HTTP响应头，指定文件类型为WAV
	c.Header("Content-Type", "audio/wav")

	// 将文件内容写入响应主体
	c.FileAttachment("m4t_server/female-0-100.wav", "filename.wav")

}
