# Simulation Results & Waveform Timing Analysis: Event Marker

This directory contains the simulation results and timing verification captured from the **AMD Vivado Simulator (`xsim`)** for the `event_marker` core on the **AMD Artix-7** FPGA platform.

---

## 📸 Simulation Waveform Capture

![Event Marker Timing Simulation](event_marker_result.png)

---

## 🔍 In-Depth Waveform Walkthrough & Analysis

The waveform window displays all key internal registers and I/O signals under full behavioral simulation with a 100 MHz clock ($T_{\text{clk}} = 10.000\text{ ns}$):

| Signal Name | Radix | Type | Description |
|:---|:---:|:---:|:---|
| `clk` | Binary | Input | 100 MHz system clock ($T = 10\text{ ns}$). |
| `rst` | Binary | Input | Synchronous active-high reset. |
| `start` | Binary | Input | Qualified input trigger / enable strobe. |
| `pulse` | Binary | Output | Single-cycle event marker output pulse. |
| `wait_counter[3:0]` | Hexadecimal | Internal Reg | 4-bit state counter tracking elapsed clock cycles. |
| `counter_width[31:0]` | Hexadecimal | Parameter | Configured to `0x00000004` (4 bits). |
| `wait_time[31:0]` | Hexadecimal | Parameter | Configured to `0x0000000a` (10 cycles decimal). |

---

### Phase 1: Glitch / Under-Duration Rejection Test ($1,110\text{ ns} - 1,200\text{ ns}$)

```text
Time (ns):   1110     1120     1130     1140     1150     1160     1170     1180     1190     1200
clk:         _|-|_    _|-|_    _|-|_    _|-|_    _|-|_    _|-|_    _|-|_    _|-|_    _|-|_    _|-|_
start:       |========================================================================|______
wait_counter: [ 0 ]   [ 1 ]    [ 2 ]    [ 3 ]    [ 4 ]    [ 5 ]    [ 6 ]    [ 7 ]    [ 8 ]    [ 9 ] -> [ 0 ]
pulse:       ________________________________________________________________________________________ (0)
```

1. At $1,110\text{ ns}$, `start` transitions to `1`.
2. The internal register `wait_counter` increments sequentially each clock cycle:
   $$\text{Counter sequence: } 1 \rightarrow 2 \rightarrow 3 \rightarrow 4 \rightarrow 5 \rightarrow 6 \rightarrow 7 \rightarrow 8 \rightarrow 9$$
3. At $1,200\text{ ns}$ (after 9 clock cycles = $90\text{ ns}$), `start` falls back to `0`.
4. Because the target `wait_time = 10` was not met, the hardware resets `wait_counter` back to `0`.
5. **Result:** `pulse` remains strictly `0`. Spurious triggers and runt pulses are successfully filtered.

---

### Phase 2: Qualified Timed Event Marker Test ($1,305\text{ ns} - 1,415\text{ ns}$)

```text
                               Cursor 1                                    Cursor 2
                               (1305 ns)                                   (1405 ns)
                                  |                                           |
Time (ns):   ... 1305   1315 ... 1385     1395     1405 (100 ns)   1415 (110 ns)    1420
clk:             _|-|_  _|-|_    _|-|_    _|-|_    _|-|_           _|-|_            _|-|_
start:           |========================================================|_________
wait_counter:    [ 0 ]  [ 1 ] ... [ 8 ]   [ 9 ]    [ a (10) ]      [ 0 ]            [ 0 ]
pulse:           __________________________________|===============|________________ (1-cycle pulse)
                                  |<--------- Δ = 100.000 ns -------->|
```

1. **Trigger Assertion (Cursor 1 @ $1,305.000\text{ ns}$):**
   * `start` is asserted continuously for $110\text{ ns}$ (11 clock cycles).
2. **Deterministic Counting:**
   * `wait_counter` counts from `0x1` up through `0x9` and reaches `0xa` ($10$ in decimal).
3. **Marker Pulse Assertion (Cursor 2 @ $1,405.000\text{ ns}$):**
   * Exactly **$100.000\text{ ns}$** after `start` assertion ($\Delta = 100.000\text{ ns}$), `wait_counter == wait_time` evaluates true.
   * `pulse` transitions high (`1'b1`) at the positive clock edge.
4. **Single-Cycle Pulse Duration:**
   * `pulse` remains asserted for exactly **1 master clock cycle** ($10.000\text{ ns}$), deasserting cleanly at $1,415.000\text{ ns}$.
   * `wait_counter` resets to `0x0`.

---

## 📊 Timing Verification Matrix

| Verification Criterion | Expected Timing | Measured Timing | Margin / Error | Verification Status |
|:---|:---:|:---:|:---:|:---:|
| **Clock Period ($T_{\text{clk}}$)** | 10.000 ns | 10.000 ns | 0.000 ns | **PASS** |
| **Clock Frequency ($F_{\text{clk}}$)** | 100.00 MHz | 100.00 MHz | 0.00 MHz | **PASS** |
| **Glitch Rejection ($9 \times T_{\text{clk}}$)** | Zero pulse output | `pulse = 0` | 0 pulses fired | **PASS** |
| **Marker Trigger Delay ($\Delta T$)** | 100.000 ns (10 cycles) | 100.000 ns | 0.000 ns | **PASS** |
| **Pulse Assertion Width ($T_{\text{pulse}}$)** | 10.000 ns (1 cycle) | 10.000 ns | 0.000 ns | **PASS** |
| **Counter State Rollover** | Reset to `0` after `wait_time` | Resets to `0` | Synchronous | **PASS** |
