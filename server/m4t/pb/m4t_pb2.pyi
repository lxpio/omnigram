from google.protobuf.internal import containers as _containers
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Iterable as _Iterable, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class TextRequest(_message.Message):
    __slots__ = ["text", "lang", "audio_id", "format"]
    TEXT_FIELD_NUMBER: _ClassVar[int]
    LANG_FIELD_NUMBER: _ClassVar[int]
    AUDIO_ID_FIELD_NUMBER: _ClassVar[int]
    FORMAT_FIELD_NUMBER: _ClassVar[int]
    text: str
    lang: str
    audio_id: str
    format: int
    def __init__(self, text: _Optional[str] = ..., lang: _Optional[str] = ..., audio_id: _Optional[str] = ..., format: _Optional[int] = ...) -> None: ...

class UploadRequsest(_message.Message):
    __slots__ = ["speaker", "audio_data"]
    SPEAKER_FIELD_NUMBER: _ClassVar[int]
    AUDIO_DATA_FIELD_NUMBER: _ClassVar[int]
    speaker: Speaker
    audio_data: bytes
    def __init__(self, speaker: _Optional[_Union[Speaker, _Mapping]] = ..., audio_data: _Optional[bytes] = ...) -> None: ...

class DelRequsest(_message.Message):
    __slots__ = ["audioID"]
    AUDIOID_FIELD_NUMBER: _ClassVar[int]
    audioID: str
    def __init__(self, audioID: _Optional[str] = ...) -> None: ...

class EmptyRequsest(_message.Message):
    __slots__ = []
    def __init__(self) -> None: ...

class Speaker(_message.Message):
    __slots__ = ["audio_id", "gender", "default_type", "display_name", "description", "avatar_url", "path"]
    AUDIO_ID_FIELD_NUMBER: _ClassVar[int]
    GENDER_FIELD_NUMBER: _ClassVar[int]
    DEFAULT_TYPE_FIELD_NUMBER: _ClassVar[int]
    DISPLAY_NAME_FIELD_NUMBER: _ClassVar[int]
    DESCRIPTION_FIELD_NUMBER: _ClassVar[int]
    AVATAR_URL_FIELD_NUMBER: _ClassVar[int]
    PATH_FIELD_NUMBER: _ClassVar[int]
    audio_id: str
    gender: int
    default_type: bool
    display_name: str
    description: str
    avatar_url: str
    path: str
    def __init__(self, audio_id: _Optional[str] = ..., gender: _Optional[int] = ..., default_type: bool = ..., display_name: _Optional[str] = ..., description: _Optional[str] = ..., avatar_url: _Optional[str] = ..., path: _Optional[str] = ...) -> None: ...

class SpeakerList(_message.Message):
    __slots__ = ["speakers"]
    SPEAKERS_FIELD_NUMBER: _ClassVar[int]
    speakers: _containers.RepeatedCompositeFieldContainer[Speaker]
    def __init__(self, speakers: _Optional[_Iterable[_Union[Speaker, _Mapping]]] = ...) -> None: ...

class AudioResponse(_message.Message):
    __slots__ = ["audio_data"]
    AUDIO_DATA_FIELD_NUMBER: _ClassVar[int]
    audio_data: bytes
    def __init__(self, audio_data: _Optional[bytes] = ...) -> None: ...
