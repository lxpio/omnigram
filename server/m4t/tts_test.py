



from tts_server import TTSModel,ClonerManager



model = TTSModel("/HHD1/XTTS-v2/")

manager = ClonerManager(model)


cloner = manager.get_cloner('female_001')



print("Inference...")

bytes = cloner.text_to_speech("云想衣裳花想容，春风拂槛露华浓","zh-cn")

# Specify the file path
file_path = 'output.wav'

# Open the file in binary write mode ('wb')
with open(file_path, 'wb') as file:
    # Write the bytes to the file
    file.write(bytes)
