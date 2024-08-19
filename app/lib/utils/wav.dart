import 'dart:io';
import 'dart:typed_data';

const _kFormatSize = 16;
const _kFactSize = 4;
const _kFileSizeWithoutData = 36;
const _kFloatFmtExtraSize = 12;
const _kPCM = 1;
const _kFloat = 3;
const _kStrRiff = 'RIFF';
const _kStrWave = 'WAVE';
const _kStrFmt = 'fmt ';
const _kStrData = 'data';
const _kStrFact = 'fact';

/// Rounds [x] up to the nearest even number.
int roundUpToEven(int x) => x + (x % 2);

class Int16Wav {
  Uint8List _samples;
  final int numChannels;
  final int sampleRate;

  Int16Wav({required this.numChannels, required this.sampleRate})
      : _samples = Uint8List(0);

  void append(Uint8List data) {
    var newList = Uint8List(_samples.length + data.length);
    newList.setAll(0, _samples);
    newList.setAll(_samples.length, data);
    _samples = newList;
  }

  Uint8List get wavBytes {
    final header = headerBytes;

    return Uint8List.fromList([...header, ..._samples]);
  }

  Uint8List get headerBytes {
    const bitsPerSample = 16; //浮点就是32
    const bytesPerSample = bitsPerSample ~/ 8;
    final bytesPerSecond = sampleRate * numChannels * bytesPerSample;

    final dataSize = _samples.length;

    var fileSize = _kFileSizeWithoutData + roundUpToEven(dataSize);

    // Write metadata.
    final bytes = BytesWriter()
      ..writeString(_kStrRiff)
      ..writeUint32(fileSize)
      ..writeString(_kStrWave)
      ..writeString(_kStrFmt)
      ..writeUint32(_kFormatSize)
      ..writeUint16(1) //int6 -> 1
      ..writeUint16(numChannels)
      ..writeUint32(sampleRate)
      ..writeUint32(bytesPerSecond)
      ..writeUint16(numChannels * bytesPerSample)
      ..writeUint16(bitsPerSample)
      ..writeString(_kStrData)
      ..writeUint32(dataSize);

    return bytes.takeBytes();
  }

  Future<void> writeFile(String path) async {
    // return bytes.takeBytes();
    File file = File(path);

    await file.writeAsBytes(headerBytes);

    await file.writeAsBytes(_samples, mode: FileMode.append);
  }
}

class Float32Wav {
  Uint8List _samples;
  final int numChannels;
  final int sampleRate;

  Float32Wav({required this.numChannels, required this.sampleRate})
      : _samples = Uint8List(0);

  void append(Uint8List data) {
    var newList = Uint8List(_samples.length + data.length);
    newList.setAll(0, _samples);
    newList.setAll(_samples.length, data);
    _samples = newList;
  }

  Uint8List get wavBytes {
    final header = headerBytes;

    return Uint8List.fromList([...header, ..._samples]);
  }

  Uint8List get headerBytes {
    const bitsPerSample = 32; //浮点就是32
    const bytesPerSample = bitsPerSample ~/ 8;
    final bytesPerSecond = sampleRate * numChannels * bytesPerSample;

    final dataSize = _samples.length;

    var fileSize =
        _kFileSizeWithoutData + roundUpToEven(dataSize) + _kFloatFmtExtraSize;

    // Write metadata.
    final bytes = BytesWriter()
      ..writeString(_kStrRiff)
      ..writeUint32(fileSize)
      ..writeString(_kStrWave)
      ..writeString(_kStrFmt)
      ..writeUint32(_kFormatSize)
      ..writeUint16(_kFloat)
      ..writeUint16(numChannels)
      ..writeUint32(sampleRate)
      ..writeUint32(bytesPerSecond)
      ..writeUint16(numChannels * bytesPerSample)
      ..writeUint16(bitsPerSample)
      ..writeString(_kStrData)
      ..writeUint32(dataSize);

    return bytes.takeBytes();
  }

  Future<void> writeFile(String path) async {
    // return bytes.takeBytes();
    File file = File(path);

    await file.writeAsBytes(headerBytes);

    await file.writeAsBytes(_samples, mode: FileMode.append);
    // file.close();
  }
}

/// Utility class to construct a byte buffer by writing little endian ints and
/// floats etc. Every write operation appends to the end of the buffer.
class BytesWriter {
  final _bytes = BytesBuilder();

  /// Writes a Uint8 to the buffer.
  void writeUint8(int x) => _bytes.addByte(x);

  /// Writes a Uint16 to the buffer.
  void writeUint16(int x) {
    writeUint8(x);
    writeUint8(x >> 8);
  }

  /// Writes a Uint24 to the buffer.
  void writeUint24(int x) {
    writeUint16(x);
    writeUint8(x >> 16);
  }

  /// Writes a Uint32 to the buffer.
  void writeUint32(int x) {
    writeUint24(x);
    writeUint8(x >> 24);
  }

  /// Writes string [s] to the buffer. [s] must be ASCII only.
  void writeString(String s) {
    for (int c in s.codeUnits) {
      _bytes.addByte(c);
    }
  }

  /// Takes the byte buffer from [this] and clears [this].
  Uint8List takeBytes() => _bytes.takeBytes();
}
