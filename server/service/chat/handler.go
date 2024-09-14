package chat

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"

	"github.com/lxpio/omnigram/server/service/chat/llms/schema"
	"github.com/lxpio/omnigram/server/log"
	"github.com/lxpio/omnigram/server/utils"
)

func editEndpointHandler() gin.HandlerFunc {
	return func(c *gin.Context) {

	}
}

// https://platform.openai.com/docs/api-reference/completions
func completionEndpointHandler() gin.HandlerFunc {
	return func(c *gin.Context) {

		log.I(`parse input...`)
		input := &schema.CompletionRequest{}

		if err := c.Bind(input); err != nil {
			// return nil, fmt.Errorf("failed reading parameters from request: ", err.Error())
			log.E("failed reading parameters from request: ", err.Error())
			//todo 从中间件拿取语言类型
			c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
			return
		}

		log.D(`current input:`, input.String())

		llm, err := mng.LLMChain(input.Model, input.Langchain)

		if err != nil {

			log.E("model not found or loaded:", err)

			c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
			return
		}

		resp, err := llm.Completion(context.TODO(), input)

		if err != nil {

			log.E("model not found or loaded:", err)

			c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
			return
		}
		// jsonResult, _ := json.Marshal(resp)
		// log.Debug().Msgf("Response: %s", jsonResult)

		// Return the prediction in the response body
		c.JSON(http.StatusOK, resp)

	}
}

// https://platform.openai.com/docs/api-reference/embeddings
func embeddingsEndpointHandler() gin.HandlerFunc {
	return func(c *gin.Context) {

		log.I(`parse input...`)
		input := &schema.EmbeddingsRequest{}

		if err := c.Bind(input); err != nil {
			// return nil, fmt.Errorf("failed reading parameters from request: ", err.Error())
			log.E("failed reading parameters from request: ", err.Error())

			c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
			return
		}

		if err := input.Verify(); err != nil {
			log.E("failed reading parameters from request: ", err.Error())
			c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
			return
		}

		log.D(`current input:`, input.String())

		llm, err := mng.LLMChain(input.Model, "")

		if err != nil {

			log.E("model not found or loaded:", err)

			c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
			return
		}

		resp, err := llm.Embeddings(context.TODO(), input)

		if err != nil {

			log.E("model not found or loaded:", err)

			c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
			return
		}
		// jsonResult, _ := json.Marshal(resp)
		// log.Debug().Msgf("Response: %s", jsonResult)

		// Return the prediction in the response body
		c.JSON(http.StatusOK, resp)

	}
}

func listModelsHandler() gin.HandlerFunc {
	return func(c *gin.Context) {

		log.I(`received list model req`)
		list := mng.ListModels()

		models := []OpenAIModel{}
		for _, m := range list {
			models = append(models, OpenAIModel{ID: m, Object: "model"})
		}

		resp := struct {
			Object string        `json:"object"`
			Data   []OpenAIModel `json:"data"`
		}{
			Object: "list",
			Data:   models,
		}

		c.JSON(http.StatusOK, resp)

	}
}

func chatCallback(resp chan *schema.ChatResponse, done chan error) schema.SreamCallBack {
	return func(r *schema.ChatResponse, d bool, e error) {
		if d {
			done <- e
		} else {
			resp <- r
		}
	}
}

func chatEndpointHandler() gin.HandlerFunc {

	return func(c *gin.Context) {

		input := &schema.ChatRequest{}

		if err := c.Bind(input); err != nil {
			// return nil, fmt.Errorf("failed reading parameters from request: ", err.Error())
			log.E("failed reading parameters from request: ", err.Error())
			//todo 从中间件拿取语言类型
			c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
			return
		}

		log.D(`current input:`, input.String())

		llm, err := mng.LLMChain(input.Model, input.Langchain)

		if err != nil {

			log.E("model not found or loaded:", err)

			c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
			return
		}

		if input.Stream {

			data := make(chan *schema.ChatResponse)
			done := make(chan error)
			defer close(data)
			defer close(done)

			input.StreamCallback = chatCallback(data, done)

			resp, err := llm.Chat(context.TODO(), input)

			if err != nil {
				log.E("run stream completion failed: ", err.Error(), resp.String())
				// return resp, err
				c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
				return
			}

			c.Header("Content-Type", "text/event-stream")
			c.Header("Cache-Control", "no-cache")
			c.Header("Connection", "keep-alive")
			c.Header("Transfer-Encoding", "chunked")

			c.Stream(func(w io.Writer) bool {

				for {
					select {
					case payload := <-data:

						var buf bytes.Buffer
						enc := json.NewEncoder(&buf)
						enc.Encode(payload)
						io.WriteString(w, "event: data\n\n")
						io.WriteString(w, fmt.Sprintf("data: %s\n\n", buf.String()))
						// log.D(`send: `, buf.String())
						//continue
						return true

						// fmt.Print(payload.Choices[0].Delta.Content)
					case err = <-done:

						io.WriteString(w, "event: data\n\n")

						resp := &schema.ChatResponse{
							ID: `todo`,
							// Model:   input.Model, // we have to return what the user sent here, due to OpenAI spec.
							Choices: []schema.Choice{{FinishReason: "stop"}},
						}
						respData := resp.String()

						io.WriteString(w, fmt.Sprintf("data: %s\n\n", resp.String()))
						log.D("Sending chunk: ", respData)
						//close stream
						return false

						// fmt.Print("\n")
						// return res, err
					}
				}

			})

			log.D(`finish chat...`)
			return

		}

		//completion
		resp, err := llm.Chat(context.TODO(), input)

		if err != nil {
			log.E(`run chat without stream: `, err.Error())
			c.JSON(http.StatusInternalServerError, utils.ErrReqArgs.WithMessage(err.Error()))

		}
		c.JSON(http.StatusOK, resp)

	}

}

func fakeChatEndpointHandler() gin.HandlerFunc {

	return func(c *gin.Context) {

		input := &schema.ChatRequest{}

		if err := c.Bind(input); err != nil {
			// return nil, fmt.Errorf("failed reading parameters from request: ", err.Error())
			log.E("failed reading parameters from request: ", err.Error())
			//todo 从中间件拿取语言类型
			c.JSON(http.StatusBadRequest, utils.ErrReqArgs.WithMessage(err.Error()))
			return
		}

		log.D(`fake current input:`, input.String())

		// llm, err := mng.LLMChain(input.Model, input.Langchain)

		// if err != nil {

		// 	log.E("model not found or loaded:", err)

		// 	c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
		// 	return
		// }

		if input.Stream {

			data := make(chan *schema.ChatResponse)
			done := make(chan error)
			defer close(data)
			defer close(done)

			input.StreamCallback = chatCallback(data, done)

			// resp, err := llm.Chat(context.TODO(), input)

			// if err != nil {
			// 	log.E("run stream completion failed: ", err.Error(), resp.String())
			// 	// return resp, err
			// 	c.JSON(http.StatusInternalServerError, utils.ModelNotExistsErr.WithMessage(err.Error()))
			// 	return
			// }

			go func() {

				for i := 0; i < 20; i++ {

					msg := &schema.ChatResponse{
						ID: "todo",
						// Created: 0,
						Choices: []schema.Choice{{
							// FinishReason: entry.FinishReason,
							Delta: &schema.Message{Role: `assistant`, Content: `hellowssfagagaga ` + strconv.Itoa(i)},
						}},
						// Usage: entry.Usage,
					}
					data <- msg
					time.Sleep(time.Millisecond * 300)
				}

				// msg := &schema.ChatResponse{
				// 	ID: "todo",
				// 	// Created: 0,
				// 	Choices: []schema.Choice{{
				// 		FinishReason: `finsh`,
				// 		Message:      &schema.Message{Role: `assistant`, Content: `hellow `},
				// 	}},
				// 	// Usage: entry.Usage,
				// }
				// data <- msg

				done <- nil

			}()

			// var err error

			c.Header("Content-Type", "text/event-stream")
			c.Header("Cache-Control", "no-cache")
			c.Header("Connection", "keep-alive")
			c.Header("Transfer-Encoding", "chunked")

			c.Stream(func(w io.Writer) bool {
				// log.D(`Stream function `)
				for {
					select {
					case payload := <-data:
						log.D(`payload function `)
						var buf bytes.Buffer
						enc := json.NewEncoder(&buf)
						enc.Encode(payload)
						io.WriteString(w, "event: data\n\n")
						io.WriteString(w, fmt.Sprintf("data: %s\n\n", buf.String()))
						// log.D(`send: `, buf.String())
						//continue
						return true

						// fmt.Print(payload.Choices[0].Delta.Content)
					case <-done:

						io.WriteString(w, "event: data\n\n")

						resp := &schema.ChatResponse{
							ID: "todo",
							// Model:   input.Model, // we have to return what the user sent here, due to OpenAI spec.
							Choices: []schema.Choice{{FinishReason: "stop"}},
						}
						respData := resp.String()

						io.WriteString(w, fmt.Sprintf("data: %s\n\n", resp.String()))
						log.D("Sending chunk: ", respData)
						//close stream
						return false

						// fmt.Print("\n")
						// return res, err
					}
				}

			})

			log.D(`finish chat...`)
			return

		}

		//completion
		// resp, err := llm.Chat(context.TODO(), input)

		// if err != nil {
		// 	log.E(`run chat without stream: `, err.Error())
		// 	c.JSON(http.StatusInternalServerError, utils.ErrReqArgs.WithMessage(err.Error()))

		// }
		// c.JSON(http.StatusOK, resp)

	}

}
