const RING_CAP = 32768; // stereo i16 interleaved samples (~341ms at 48 kHz)

class AwreAudioProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.ring = new Int16Array(RING_CAP);
    this.readPos = 0;
    this.writePos = 0;
    this.count = 0;
    this.reportTick = 0;

    this.port.onmessage = (ev) => {
      const chunk = ev.data;
      if (!(chunk instanceof Int16Array)) return;
      for (let i = 0; i < chunk.length; i++) {
        if (this.count >= RING_CAP) {
          this.readPos = (this.readPos + 2) % RING_CAP;
          this.count -= 2;
        }
        this.ring[this.writePos] = chunk[i];
        this.writePos = (this.writePos + 1) % RING_CAP;
        this.count += 1;
      }
    };
  }

  process(_inputs, outputs) {
    const out = outputs[0];
    if (!out || out.length < 2) return true;
    const chL = out[0];
    const chR = out[1];
    const frames = chL.length;

    for (let i = 0; i < frames; i++) {
      if (this.count >= 2) {
        const l = this.ring[this.readPos];
        const r = this.ring[(this.readPos + 1) % RING_CAP];
        this.readPos = (this.readPos + 2) % RING_CAP;
        this.count -= 2;
        chL[i] = l / 32768.0;
        chR[i] = r / 32768.0;
      } else {
        chL[i] = 0.0;
        chR[i] = 0.0;
      }
    }

    this.reportTick += 1;
    if ((this.reportTick & 3) === 0) {
      this.port.postMessage(this.count * 2); // queued bytes
    }
    return true;
  }
}

registerProcessor("awre-audio-processor", AwreAudioProcessor);
