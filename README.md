# 🎙️ Vocoder Implementation in VHDL

A **channel vocoder** written in **VHDL**, built from modular, individually tested blocks: an **oscillator** (carrier), **IIR band-pass filters** (biquad), and an **envelope detector** (rectifier + low-pass filter), all tied together in `Vocoder_Top`.

![Channel Vocoder](Channel_Vocoder.png)

---

## 📖 Table of Contents

- [Overview](#-overview)
- [How a Vocoder Works](#-how-a-vocoder-works)
- [System Architecture](#-system-architecture)
- [Modules](#-modules)
  - [Oscillator](#1-oscillator)
  - [Band-Pass Filter (IIR Biquad)](#2-band-pass-filter-iir-biquad)
  - [Envelope Detector (Low-Pass Filter)](#3-envelope-detector-low-pass-filter)
- [Repository Structure](#-repository-structure)
- [Testing & Verification](#-testing--verification)
- [Getting Started](#-getting-started)
- [Tools & Technologies](#-tools--technologies)
- [Future Improvements](#-future-improvements)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

---

## 🔍 Overview

A **vocoder** (voice encoder) takes the spectral shape of a speech signal (the *modulator*) and imposes it on another sound (the *carrier*), producing the classic "robot voice" effect.

This project implements a **channel vocoder** in hardware description language:

- The voice is split into frequency bands by **IIR band-pass filters**.
- The **envelope** of each band is extracted with a rectifier and a **low-pass filter**.
- A synthetic carrier from the **oscillator** goes through a matching filter bank.
- Each carrier band is scaled by the matching voice envelope, and the bands are summed into the output.

Every block comes with its own **testbench** and simulation results.

<!-- TODO: add context (course/lab, FPGA board, etc.) -->

---

## 🧠 How a Vocoder Works

1. **Analysis**: the modulator (voice) passes through N band-pass filters.
2. **Envelope detection**: each band is rectified and low-pass filtered to get its amplitude over time.
3. **Synthesis**: the carrier passes through the same bank of band-pass filters.
4. **Modulation**: each carrier band is multiplied by its voice envelope.
5. **Mixing**: all bands are summed into the final output.

---

## 🏗️ System Architecture

![Channel Vocoder Architecture](Channel_Vocoder.png)

| Parameter           | Value         |
|---------------------|---------------|
| Language            | VHDL          |
| Filter type         | IIR band-pass (biquad) |
| Number of channels  | `TODO`        |
| Sampling frequency  | `TODO`        |
| Data width          | `TODO`        |
| Arithmetic          | `TODO` (fixed-point / integer) |

---

## 🧩 Modules

### 1. Oscillator

Generates the **carrier signal** that gets shaped by the voice envelope. Its frequency sets the pitch of the vocoded output.

![Oscillator](Oscillator.png)

- **Source:** [`Oscillator.vhd`](Vocoder_Top/Oscillator/Oscillator.vhd)
- **Testbench:** [`Testbensh_Oscillator.vhd`](Vocoder_Top/Oscillator/Testbensh_Oscillator.vhd)

<!-- TODO: waveform type (sine / saw / square), generation method (LUT, phase accumulator...), frequency resolution -->

---

### 2. Band-Pass Filter (IIR Biquad)

The analysis and synthesis stages use **second-order IIR (biquad) band-pass filters**. IIR filters give sharp band selectivity with few coefficients, which saves hardware resources.

**Filter structure:**

![IIR Structure](Vocoder_Top/Band_Pass%20Filtre/Filter_IIR_Structure.png)

**Biquad implementation:**

![IIR Biquad](Vocoder_Top/Band_Pass%20Filtre/Filter_IIR_Biquad.png)

Difference equation:

```
y[n] = b0·x[n] + b1·x[n-1] + b2·x[n-2] − a1·y[n-1] − a2·y[n-2]
```

- **Source:** [`Filter.vhd`](Vocoder_Top/Band_Pass%20Filtre/Filter.vhd)
- **Testbench:** [`Filter_tb.vhd`](Vocoder_Top/Band_Pass%20Filtre/Filter_tb.vhd)

<!-- TODO: Direct Form I / II, coefficient format, center frequencies and Q -->

---

### 3. Envelope Detector (Low-Pass Filter)

Extracts the **amplitude envelope** of each voice band (rectification followed by low-pass filtering). This envelope later controls the carrier's amplitude.

- **Source:** [`Enveloppe.vhd`](Vocoder_Top/Enveloppe-Low_Pass%20Filtre/Enveloppe.vhd)
- **Testbench:** [`Enveloppe_tb.vhd`](Vocoder_Top/Enveloppe-Low_Pass%20Filtre/Enveloppe_tb.vhd)

<!-- TODO: cutoff frequency, filter order -->

---

## 📁 Repository Structure

```
Vocoder-Implementation/
├── Channel_Vocoder.png                  # Full vocoder block diagram
├── Filter_IIR.png                       # IIR filter overview
├── Oscillator.png                       # Oscillator overview
└── Vocoder_Top/
    ├── Band_Pass Filtre/
    │   ├── Filter.vhd                   # IIR band-pass filter
    │   ├── Filter_tb.vhd                # Filter testbench
    │   ├── Filter_IIR_Structure.png     # Filter structure diagram
    │   ├── Filter_IIR_Biquad.png        # Biquad diagram
    │   ├── Band-pass_Test.png           # Simulation result
    │   └── Band-pass_Test2.png          # Simulation result
    ├── Enveloppe-Low_Pass Filtre/
    │   ├── Enveloppe.vhd                # Envelope detector
    │   ├── Enveloppe_tb.vhd             # Envelope testbench
    │   └── Enveloppe_Test.png           # Simulation result
    └── Oscillator/
        ├── Oscillator.vhd               # Carrier oscillator
        ├── Testbensh_Oscillator.vhd     # Oscillator testbench
        ├── Oscillator.png               # Oscillator diagram
        └── Oscillator_Test.png          # Simulation result
```

---

## 🧪 Testing & Verification

Each block was verified on its own with a dedicated VHDL testbench before integration.

| Module | Testbench | What is verified | Result |
|--------|-----------|------------------|--------|
| Oscillator | `Testbensh_Oscillator.vhd` | Output frequency and waveform shape | ✅ |
| Band-pass filter | `Filter_tb.vhd` | Frequency selectivity: in-band signals pass, out-of-band signals are attenuated | ✅ |
| Envelope detector | `Enveloppe_tb.vhd` | Output follows the amplitude of the input | ✅ |

### Oscillator

![Oscillator Test](Vocoder_Top/Oscillator/Oscillator_Test.png)

*Simulation waveform of the oscillator output.* <!-- TODO: say what the reader should see (frequency, amplitude) -->

### Band-Pass Filter

![Band-pass Test 1](Vocoder_Top/Band_Pass%20Filtre/Band-pass_Test.png)

![Band-pass Test 2](Vocoder_Top/Band_Pass%20Filtre/Band-pass_Test2.png)

*Filter response for test input signals.* <!-- TODO: describe the two test cases (e.g., in-band vs out-of-band frequency) -->

### Envelope Detector

![Envelope Test](Vocoder_Top/Enveloppe-Low_Pass%20Filtre/Enveloppe_Test.png)

*The envelope detector output tracking the input amplitude.*


In **ModelSim/Questa** or **Vivado**, add the `.vhd` source and its testbench to a project, set the testbench as the top simulation unit, and run the simulation.

---

## 🛠️ Tools & Technologies

- **HDL:** VHDL
- **DSP concepts:** IIR biquad filters, envelope detection, digital oscillators
- **Simulation:** `TODO` (ModelSim / Vivado / GHDL)
- **Target hardware:** `TODO` (FPGA board, if any)

---

## 🔮 Future Improvements

- Increase the number of frequency channels for better intelligibility
- Add real-time audio I/O (I2S codec) on FPGA
- Handle sibilants/noise (unvoiced sounds) with a noise generator
- Make carrier waveform and pitch selectable at runtime
- Add self-checking testbenches with automatic pass/fail assertions
---
