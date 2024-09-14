package m4t

import (
	"context"
	"sync"

	grpc "google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

type Speakers struct {
	sync.RWMutex

	list []*Speaker
}

func (s *Speakers) load() ([]*Speaker, error) {

	client, err := NewClient()
	if err != nil {

		return nil, err
	}
	list, err := client.AllSpeaker(context.Background(), &EmptyRequsest{})

	if err != nil {

		return nil, err
	}

	s.Lock()
	defer s.Unlock()

	s.list = list.Speakers
	return s.list, nil

}

func (s *Speakers) All() []*Speaker {

	s.RLock()
	defer s.RUnlock()

	return s.list

}

func (s *Speakers) Upload(ctx context.Context, req *UploadRequsest) (*Speaker, error) {

	client, err := NewClient()
	if err != nil {

		return nil, err
	}

	speaker, err := client.AddSpeaker(ctx, req)
	if err != nil {

		return nil, err
	}

	s.Lock()
	defer s.Unlock()

	s.list = append(s.list, speaker)

	return speaker, err
}

func (s *Speakers) Delete(ctx context.Context, id string) error {

	s.Lock()
	defer s.Unlock()

	index := -1
	// findIndex 函数用于查找元素的索引
	for i, v := range s.list {
		if v.AudioId == id {
			index = i
			break
		}
	}
	if index != -1 {
		s.list = append(s.list[:index], s.list[index+1:]...)
	}

	client, err := NewClient()
	if err != nil {

		return err
	}

	_, err = client.DelSpeaker(ctx, &DelRequsest{AudioID: id})

	return err

}

func NewClient() (TextToAudioClient, error) {

	conn, err := grpc.Dial(remoteServer.addr(), grpc.WithTransportCredentials(insecure.NewCredentials()))

	if err != nil {

		return nil, err
	}

	// Create a gRPC client
	client := NewTextToAudioClient(conn)
	return client, nil

}
