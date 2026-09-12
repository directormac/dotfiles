# PipeWire audio server with ALSA, JACK, and PulseAudio compatibility.
# Replaces PulseAudio and JACK with a single modern audio stack.
{
  den.ful.audio.pipewire.nixos.services.pipewire = {
    enable = true;
    alsa.enable = true;
    jack.enable = true;
    pulse.enable = true;
  };
}
