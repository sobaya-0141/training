import math
import struct
import wave
from pathlib import Path


SAMPLE_RATE = 44_100
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "audio"


def tone(frequency: float, duration: float, volume: float = 0.72) -> list[float]:
    sample_count = int(SAMPLE_RATE * duration)
    fade_count = min(int(SAMPLE_RATE * 0.012), sample_count // 2)
    samples = []
    for index in range(sample_count):
        envelope = 1.0
        if index < fade_count:
            envelope = index / fade_count
        elif index >= sample_count - fade_count:
            envelope = (sample_count - index - 1) / fade_count
        samples.append(
            volume * envelope * math.sin(2 * math.pi * frequency * index / SAMPLE_RATE)
        )
    return samples


def silence(duration: float) -> list[float]:
    return [0.0] * int(SAMPLE_RATE * duration)


def write_wave(name: str, samples: list[float]) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT_DIR / name), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(SAMPLE_RATE)
        output.writeframes(
            b"".join(
                struct.pack("<h", int(max(-1.0, min(1.0, sample)) * 32767))
                for sample in samples
            )
        )


write_wave("countdown.wav", tone(880, 0.16))
write_wave(
    "start.wav",
    tone(880, 0.16) + silence(0.06) + tone(1320, 0.34, volume=0.78),
)
write_wave(
    "stop.wav",
    tone(660, 0.18) + silence(0.06) + tone(440, 0.42, volume=0.78),
)
