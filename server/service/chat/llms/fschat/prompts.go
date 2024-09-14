package fschat

import "github.com/lxpio/omnigram/server/service/chat/llms/schema"

const sysPrompt = `你是一个助手。`

func (l *FSChat) PromptMessage(messages []schema.Message) string {

	cuted := cutHistoryByLen(messages, 8192)

	switch l.Model {

	case `dolly-v2-12b`:
		panic(`TODO`)

	default:
		return vicunaPrompt(cuted)
	}

}

func cutHistoryByLen(messages []schema.Message, max int) []schema.Message {

	//TODO: 如果聊天内容大于max删除部分历史聊天记录.
	//这里默认预设条件，1. messages 最后一次一定是user，

	// curr, max := 0, 1024
	msg_len := 0 //消息长度
	index := []int{}
	msg := []schema.Message{} //计算长度后返回的消息数组
	for i := len(messages) - 1; i >= 0; i-- {
		if i == len(messages)-1 {
			if messages[i].Role == `user` { //用户给出的最后一条消息
				index = append(index, i)
				msg_len += len(messages[i].Content)
			} /* else {
				// todo 如果最后一条不是用户的消息
			} */
		} else {
			if messages[i].Role == `user` && messages[i+1].Role != `user` { //消息成对添加
				index = append(index, []int{i + 1, i}...) //倒序添加索引
				msg_len += len(messages[i].Content) + len(messages[i+1].Content)
			}
		}

		if msg_len >= max {
			break
		}
	}
	for i := len(index) - 1; i >= 0; i-- {
		msg = append(msg, messages[index[i]])
	}

	return msg
}

// vicunaPrompt message
func vicunaPrompt(messages []schema.Message) string {

	//内置
	prompt := sysPrompt //Below is an instruction that describes a task. Write a response that appropriately completes the request.

	// Vicuna v1.1 template
	for _, msg := range messages {

		if len(msg.Content) > 0 {
			if msg.Role == `system` {
				//当前drop 掉system 信息
				// ret[i] = SystemChatMessage{d.Content}
			} else if msg.Role == `user` {

				prompt += `USER: ` + msg.Content + ` `

			} else if msg.Role == `assistant` {
				prompt += `ASSISTANT: ` + msg.Content + `</s>`
			}
		}

	}

	prompt += `ASSISTANT: `

	return prompt

}
