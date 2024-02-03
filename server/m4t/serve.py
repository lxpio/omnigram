#!/usr/bin/env python3
from concurrent import futures
import grpc
from pb import m4t_pb2_grpc,m4t_pb2
from tts_server import  ClonerManager, TTSModel
import argparse
from ltp import StnSplit
import re
import torch

from speakers import Speakers



class TextToAudioServicer(m4t_pb2_grpc.TextToAudioServicer):

    def __init__(self,manager,speakers):
        self.manager = manager
        self.speakers = speakers

    def ConvertTextToAudio(self, request, context):
        # Convert text to audio data (simple example)
        print(request.audio_id, request.text,request.lang)

        clone = self.manager.get_cloner(request.audio_id)
     
        
        # Get audio data bytes
        audio_bytes = clone.text_to_speech(request.text,request.lang)
        
        return m4t_pb2.AudioResponse(audio_data=audio_bytes)
    
    def TTSStream(self, request: m4t_pb2.TextRequest, context):
        # Convert text to audio data (simple example)
     
        clone = self.manager.get_cloner(request.audio_id)

        sentences = text_split(request.text)
        
        for sentence in sentences:
            for i,chunk in clone.tts_stream(sentence,request.lang):
            # Get audio data bytes
                # chunk.
                # if request.format == 1:
                #     int16_tensor = (chunk * 32767).to(torch.int16)
                #     bytes_data = int16_tensor.numpy().tobytes(order='little')
                # else:
                #         bytes_data = chunk.numpy().tobytes(order='little')
                # python_list = (chunk * 32767).to(torch.int16).tolist()
                bytes_data = (chunk * 32767).to(torch.int16).cpu().numpy().tobytes(order='C')
                resp = m4t_pb2.AudioResponse(audio_data=bytes_data)
                yield resp
        
    def AllSpeaker(self, request, context):
        speakers = self.speakers.all()
        return m4t_pb2.SpeakerList(speakers=speakers)

    def AddSpeaker(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def DelSpeaker(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

def text_split(input):
    if (len(input) < 50):
        return [input]
    
    sentences = StnSplit().split(input)

    parts = split_long_sentences(sentences)

    return merge_short_sentences(parts)
            


def split_long_sentences(inputs, max_len=50):
    result = []
    for s in inputs:
        if len(s) > max_len:
            parts = re.split(r'[，,]', s)
            for s2 in parts:
                if len(s2) > max_len:
                    midpoint = len(s2) // 2
                    result.append(s2[:midpoint])
                    result.append(s2[midpoint:])
                else:
                    result.append(s2)
        else:
            result.append(s)
    return result

def merge_short_sentences(sentences, min_len=20):
    result = []
    current_sentence = sentences[0]

    for sentence in sentences[1:]:
        if len(current_sentence) + len(sentence) + 1 <= min_len:
            current_sentence += ',' + sentence
        else:
            result.append(current_sentence)
            current_sentence = sentence

    result.append(current_sentence)
    return result

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--host", type=str, default="localhost")
    parser.add_argument("--port", type=str, default='50051')
    parser.add_argument("--device", type=str, default="cuda")
    parser.add_argument("--model-path", type=str, default="/HHD1/XTTS-v2/")
    parser.add_argument("--speakers-path", type=str, default="/speakers")

    args = parser.parse_args()
    speakers = Speakers(args.speakers_path)
    speakers.load()

    manager = ClonerManager(TTSModel(args.model_path,args.device),speakers)


    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    m4t_pb2_grpc.add_TextToAudioServicer_to_server(TextToAudioServicer(manager,speakers), server)
    # server.add_insecure_port('[::]:50051')
    server.add_insecure_port( args.host + ':'+ args.port)

    server.start()
    print("Server is running...")
    server.wait_for_termination()