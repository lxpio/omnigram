package utils

import "math/rand"

func RandomString(length int) string {
	// 可用字符集合
	const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

	// 创建一个字符切片用于存储随机字符
	randomString := make([]byte, length)

	// 遍历切片，为每个位置生成一个随机字符
	for i := 0; i < length; i++ {
		// 生成一个随机索引，用于从字符集合中选择字符
		randomIndex := rand.Intn(len(charset))
		// 将随机选择的字符放入切片
		randomString[i] = charset[randomIndex]
	}

	return string(randomString)
}
