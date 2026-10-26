# Measurement Data

This directory is reserved for future chip and board experiments. No measured data is present yet.

Create `<date>_<device>_<measurement>/` for each acquisition, containing `raw_data/`, `processed_data/`, and a measurement record. Record the device and board revision, instrument/clock/source settings, sample rate, coding, supplies, temperature, data units, and analysis-script revision. Preserve original acquisitions as read-only data; write new outputs when reprocessing them.

Before designing a measurement procedure, read the root documentation/ANALOG_DEVICES_REFERENCE_ALIGNMENT.md and consult the relevant chapter in references/analog_devices. Ideal clocks and input signals in the behavioral model do not replace checks of instrument purity, synchronization, or grounding.
