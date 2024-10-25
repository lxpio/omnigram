package utils

import "fmt"

type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

func (r *Response) WithMessage(err string) *Response {
	r.Message = err
	return r
}

func (r *Response) WithData(data interface{}) *Response {
	r.Data = data
	return r
}

func (r Response) Error() string {
	return fmt.Sprintf("%d: %s", r.Code, r.Message)
}

type Query struct {
	Search   string `json:"search" form:"search"`
	PageSize int    `json:"page_size" form:"page_size" binding:"gte=0"` //返回第几页，0开始
	PageNum  int    `json:"page_num" form:"page_num" binding:"gte=0"`   //每页数量
	// OrderFields []string    `json:"order_fields" form:"order_fields"`
	// OrderMethod types.ORDER `json:"order_method" form:"order_method"`
}
