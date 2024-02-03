from TTS.tts.configs.xtts_config import XttsConfig
from TTS.tts.models.xtts import Xtts
import os
from scipy.io.wavfile import write
from io import BytesIO
from pb import m4t_pb2
import torch
# import deepspeed


class ClonerManager:
    def __init__(self,model,speakerManager):
        self.cloners = {}
        self.model = model
        self.speakerManager = speakerManager

    def get_cloner(self,audio_id):
        if audio_id in self.cloners:
            return self.cloners[audio_id]
        else:
            speaker = self.speakerManager.speakers.get(audio_id,m4t_pb2.Speaker(path="female-0-100.wav"))
            clone = Cloner(self.model, speaker.path)
            self.cloners[audio_id] = clone
            return clone

SAMPLE_RATE = 24_000

class Cloner:
    def __init__(self, model, audio_path):
        self.model = model
        self.gpt_cond_latent, self.speaker_embedding = self.model.get_conditioning_latents(audio_path)


    def text_to_speech(self, text, language,**kwargs):
       
        outputs = self.model.inference(
                    text,
                    language,
                    self.gpt_cond_latent,
                    self.speaker_embedding,
                    **kwargs,
                )
        
        # 合成语音
        # outputs = self.synthesize(text, speaker_wav, gpt_cond_len, language)

        audio_stream = BytesIO()
        write(audio_stream, rate=SAMPLE_RATE,data= outputs['wav'])
        
        # Get audio data bytes
        return audio_stream.getvalue()
 # 保存语音到文件
        # torch.save(outputs['wav'], audio_path)
    def tts_stream(self, text, language,**kwargs):
       
        # outputs = 
        
        # 合成语音
        # outputs = self.synthesize(text, speaker_wav, gpt_cond_len, language)
        print('current tts stream: ',text)
        # wav_chuncks = []
        yield from self.model.inference_stream(
                    text,
                    language,
                    self.gpt_cond_latent,
                    self.speaker_embedding,
                )
            # python_list = chunk.tolist()
            # yield python_list
            # wav_chuncks.append(chunk)
            # print("current",i,len(chunk), type(chunk),type(chunk[0]))


        # wavdata = torch.cat(wav_chuncks, dim=0)
        # audio_stream = BytesIO()
        # python_list1 = wavdata.tolist()
        # output = wavdata.squeeze().unsqueeze(0).cpu()
        # print("current",i,len(wavdata),"ouput type: ", type(output))
        # python_list = output.tolist()
        # print("current",len(python_list),len(python_list1),"ouput type: ", type(python_list[0]))
        # torchaudio.save(audio_stream, output, SAMPLE_RATE,format="wav")
        # write(audio_stream, rate=SAMPLE_RATE,data= wavdata.squeeze().unsqueeze(0).cpu())
        
        # Get audio data bytes
        # return audio_stream.getvalue()
 # 保存语音到文件
        # torch.save(outputs['wav'], audio_path)

class TTSModel:
    def __init__(self, model_path,device_type = "cuda"):
        self.config = XttsConfig()
        self.config.load_json(os.path.join(model_path, 'config.json'))
        self.model = Xtts.init_from_config(self.config)
        # 初始化模型，根据是否有 GPU 决定使用 GPU 还是 CPU 推导
        if torch.cuda.is_available() and device_type == "cuda":
            print("using cuda as device.")
            self.device = torch.device("cuda")
            self.model.load_checkpoint(self.config, checkpoint_dir=model_path, eval=True, use_deepspeed=False)
        else:
            print("using cpu as device.")
            self.device = torch.device("cpu")
            self.model.load_checkpoint(self.config, checkpoint_dir=model_path, eval=True, use_deepspeed=False)
        self.model.to(self.device)


    def get_conditioning_latents(
            self,
            audio_path,
        ): 
        return self.model.get_conditioning_latents(audio_path)
    
    def inference(
        self,
        text,
        language,
        gpt_cond_latent,
        speaker_embedding,
        **kwargs,
    ):

        # settings = {
        #             "temperature": self.config.temperature,
        #             "length_penalty": self.config.length_penalty,
        #             "repetition_penalty": self.config.repetition_penalty,
        #             "top_k": self.config.top_k,
        #             "top_p": self.config.top_p,
        #             "cond_free_k": self.config.cond_free_k,
        #             "diffusion_temperature": self.config.diffusion_temperature,
        #             "decoder_iterations": self.config.decoder_iterations,
        #             "decoder_sampler": self.config.decoder_sampler,
        #         }
        # settings.update(kwargs)  # allow overriding of preset settings with kwargs
        return self.model.inference(
            text,
            language,
            gpt_cond_latent,
            speaker_embedding,
            # temperature=temperature,
            # length_penalty=length_penalty,
            # repetition_penalty=repetition_penalty,
            # top_k=top_k,
            # top_p=top_p,
            # do_sample=do_sample,
            # decoder_iterations=decoder_iterations,
            # cond_free=cond_free,
            # cond_free_k=cond_free_k,
            # diffusion_temperature=diffusion_temperature,
            # decoder_sampler=decoder_sampler,
            **kwargs,
        )

    def inference_stream(
        self,
        text,
        language,
        gpt_cond_latent,
        speaker_embedding,
        **kwargs,
    ):
        chunks = self.model.inference_stream(
            text,
            language,
            gpt_cond_latent,
            speaker_embedding
        )
        # wav_chuncks = []
        for chunk in enumerate(chunks):
            # if i == 0:
            #     print(f"Time to first chunck: {time.time() - t0}")
            # print(f"Received chunk {i} of audio length {chunk.shape[-1]}")
            yield chunk